library solana_defi_sdk;

import 'dart:convert';

import 'package:bip39/bip39.dart' as bip39;
import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:jupiter_aggregator/jupiter_aggregator.dart';
import 'package:solana/base58.dart';
import 'package:solana/dto.dart';
import 'package:solana/metaplex.dart';
import 'package:solana/solana.dart';
import 'package:solana/solana_pay.dart';

import 'api.dart';

class AddressNames {
  static final names = {
    'USDT': 'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB',
  };

  static String? getAddressByName(String name) {
    return names[name];
  }

  static String? getNameByAddress(String address) {
    return names.entries.firstWhere((element) => element.value == address).key;
  }
}

class SolanaDeFiSDK {
  static const int lamportsPerSol = 1000000000;
  static const int solDecimalPlaces = 9;
  // static final httpClient = http.Client();
  static final JupiterAggregatorClient _jupClient = JupiterAggregatorClient();
  static final _rest = RestClient(Dio());

  static late SolanaClient _client;

  /// create mainnet(https://api.mainnet-beta.solana.com) solana client by default
  ///
  /// devnet - https://api.devnet.solana.com
  static void initialize([SolanaClient? solanaClient]) {
    _client = solanaClient ??
        SolanaClient(
            rpcUrl: Uri.parse('https://api.mainnet-beta.solana.com'),
            websocketUrl: Uri.parse('wss://api.mainnet-beta.solana.com'));
  }

  static SolanaClient get client => _client;
  static JupiterAggregatorClient get jup => _jupClient;

  static Future<String?> getNameOfAddress(String address) async {
    final name = AddressNames.getNameByAddress(address);
    if (name != null) return name;

    final metadata = await SolanaDeFiSDK.client.rpcClient
        .getMetadata(mint: Ed25519HDPublicKey.fromBase58(address));
    if (metadata?.name != null) {
      debugPrint('add name ${metadata!.name}/$address to cache.');
      AddressNames.names[metadata.name] = address;
      return metadata.name;
    }
    return null;
  }

  static Future<int> getAvailableTransferLamports(String address) async {
    final fees = await _client.rpcClient.getFees();
    final balance = await getBalance(address);
    final fee = fees.feeCalculator.lamportsPerSignature;
    debugPrint('[sdk] balance is $balance, transfer fee is $fee');
    return balance > fee ? balance - fee : 0;
  }

  static Future<int> getBalance(String address) async {
    return await _client.rpcClient
        .getBalance(address, commitment: Commitment.confirmed);
  }

  static Future<List<TokenAccountData>> getTokenAccounts(String address) async {
    final accounts =
        await SolanaDeFiSDK.client.rpcClient.getTokenAccountsByOwner(
      address,
      const TokenAccountsFilter.byProgramId(TokenProgram.programId),
      encoding: Encoding.jsonParsed,
      commitment: Commitment.confirmed,
    );
    final filtered = accounts.where((element) {
      final data = element.account.data as ParsedSplTokenProgramAccountData;
      final parsed = data.parsed as TokenAccountData;
      return parsed.info.tokenAmount.decimals != 0 &&
          num.parse(parsed.info.tokenAmount.amount) >
              0; // && parsed.info.tokenAmount.amount;
    });
    // print(filtered.length);
    for (final element in filtered) {
      final data = element.account.data as ParsedAccountData;
      final programData = data as ParsedSplTokenProgramAccountData;
      final parsed = programData.parsed as TokenAccountData;
      final mint = parsed.info.mint;
      final amount = parsed.info.tokenAmount.uiAmountString;
      final isNft = parsed.info.tokenAmount.decimals == 0;
      debugPrint('--> mint:$mint isNft:$isNft amount:$amount');
    }
    return filtered
        .map((element) =>
            (element.account.data as ParsedSplTokenProgramAccountData).parsed
                as TokenAccountData)
        .toList(growable: false);
  }

  static Future<TokenAccountData> getUSDTTokenAccount(String address) async {
    final response = await _client.rpcClient.getTokenAccountsByOwner(
      address,
      const TokenAccountsFilterByMint(
          'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB'),
      encoding: Encoding.jsonParsed,
      commitment: Commitment.confirmed,
    );
    debugPrint('length is ${response.length}');
    final data = response.first.account.data as ParsedAccountData;
    final programData = data as ParsedSplTokenProgramAccountData;
    return programData.parsed as TokenAccountData;
  }

  static String uiAmount(int lamports) =>
      (lamports / lamportsPerSol).toStringAsFixed(solDecimalPlaces);

  static Future<String> transfer(
      Wallet source, String destinationAddress, int amount) async {
    debugPrint(
        '[sdk] transfer ${uiAmount(amount)} from "${source.address}" to "$destinationAddress"');
    // final source = Ed25519HDPublicKey.fromBase58(sourceAddress);
    final destination = Ed25519HDPublicKey.fromBase58(destinationAddress);
    final instruction = SystemInstruction.transfer(
        fundingAccount: source.publicKey,
        recipientAccount: destination,
        lamports: amount);
    final transactionId = await client.sendAndConfirmTransaction(
        message: Message.only(instruction),
        signers: [source],
        commitment: Commitment.confirmed);
    debugPrint('[sdk] transfer transaction id is $transactionId');
    return transactionId;
  }

  static SolanaPayRequest createPayRequest(
    String recipientAddress,
    String amount, {
    String? label,
    String? message,
    String? memo,
  }) {
    final recipient = Ed25519HDPublicKey.fromBase58(recipientAddress);
    return SolanaPayRequest(
      recipient: recipient,
      label: label,
      message: message,
      memo: memo,
      amount: Decimal.parse(amount),
    );
  }

  static Future<String> getPrivateKey(Wallet wallet) async {
    List<int> key = (await wallet.extract()).bytes;
    key += wallet.publicKey.bytes;
    return base58encode(key);
  }

  static String generateMnemonic() {
    return bip39.generateMnemonic();
  }

  static Future<Wallet> initializeWalletFromMnemonic(String mnemonic) async {
    // String mnemonic = generateMnemonic();
    /*
    List<int> seed = bip39.mnemonicToSeed(mnemonic);
    debugPrint('seed is $seed');
    String seedHash = sha256
        .convert(seed)
        .bytes
        .sublist(0, 4)
        .map((e) => e.toRadixString(16).padLeft(2, "0"))
        .join("");
    debugPrint('seedHash1 is $seedHash');*/
    debugPrint('seedHash2 is "${mnemonic.hashCode}"');
    final Ed25519HDKeyPair keyPair =
        await Ed25519HDKeyPair.fromMnemonic(mnemonic);
    final Wallet wallet = keyPair;
    debugPrint('wallet address is "${wallet.address}"');
    return wallet;
  }

  static Future<Wallet> initializeWalletFromPrivateKey(String key) async {
    List<int>? decodedKey;
    try {
      decodedKey = base58decode(key);
    } catch (_) {
      try {
        decodedKey = (jsonDecode(key) as List).cast();
      } catch (_) {}
    }
    if (decodedKey == null ||
        (decodedKey.length != 64 && decodedKey.length != 32)) {
      debugPrint('decoded key is $decodedKey');
      throw 'invalid key';
    }
    final privateKey = decodedKey.sublist(0, 32);
    return await Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: privateKey);
  }

  static Future<NftScanGetTransactionResponse> getNfts(String address,
      {pageIndex = 0, pageSize = 20}) async {
    final response = await _rest.getTransactionByUserAddress(
        userAddress: address, pageIndex: pageIndex, pageSize: pageSize);
    debugPrint('found ${response.data?.total} nfts');
    return response;

    /*
    final tokenAccounts = await _client.rpcClient.getTokenAccountsByOwner(
      address,
      const TokenAccountsFilter.byProgramId(TokenProgram.programId),
      encoding: Encoding.jsonParsed,
      commitment: Commitment.confirmed,
    );
    final mints = tokenAccounts
        .map((element) {
          final data = element.account.data as ParsedAccountData;
          final programData = data as ParsedSplTokenProgramAccountData;
          return programData.parsed as TokenAccountData;
        })
        .where((element) => element.info.tokenAmount.decimals == 0)
        .map((element) => element.info.mint);
    mints.map((mint) async {});*/
  }
}
