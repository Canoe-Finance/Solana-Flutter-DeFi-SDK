library solana_defi_sdk;

import 'dart:convert';
import 'dart:typed_data';

import 'package:bip39/bip39.dart' as bip39;
import 'package:collection/collection.dart';
import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jupiter_aggregator/jupiter_aggregator.dart';
import 'package:solana/base58.dart';
import 'package:solana/dto.dart';
import 'package:solana/encoder.dart';
import 'package:solana/metaplex.dart';
import 'package:solana/solana.dart';
import 'package:solana/solana_pay.dart';

import 'api.dart';

/// address name and label mapping for mainnet
class TokenSymbols {
  static final data = {
    'SOL': 'So11111111111111111111111111111111111111112',
    'USDT': 'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB',
    'USDC': 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',
  };

  static String? getAddress(String symbol) {
    return data[symbol];
  }

  static String? getSymbol(String address) {
    return data.entries
        .firstWhereOrNull((element) => element.value == address)
        ?.key;
  }
}

enum ClusterEnvironment { mainnet, devnet, testnet }

class KeyManager {
  /// using flutter secure storage store mnemonic
  ///
  /// TODO
  static Future<void> persistMnemonic(String mnemonic) {
    return const FlutterSecureStorage().write(key: "mnemonic", value: mnemonic);
  }

  static Future<String?> restoreMnemonic() {
    return const FlutterSecureStorage().read(key: 'mnemonic');
  }
}

class SolanaDeFiSDK {
  static const int lamportsPerSol = 1000000000;
  static const int solDecimalPlaces = 9;

  static ClusterEnvironment? _env;
  // static final httpClient = http.Client();
  static final JupiterAggregatorClient _jupClient = JupiterAggregatorClient();
  static final _api = ApiClient(Dio());

  SolanaClient? _client;
  SolanaClient get client => _client!;
  JupiterAggregatorClient get jup => _jupClient;

  static final SolanaDeFiSDK _instance = SolanaDeFiSDK._();
  static SolanaDeFiSDK get instance => _instance;

  // factory SolanaDeFiSDK() => _instance!;
  SolanaDeFiSDK._();

  /// create mainnet(https://api.mainnet-beta.solana.com) solana client by default
  ///
  /// devnet - https://api.devnet.solana.com
  /// testnet - https://api.testnet.solana.com
  static SolanaDeFiSDK initialize({
    ClusterEnvironment? env,
    SolanaClient? solanaClient,
  }) {
    SolanaClient client;
    assert(!(env != null && solanaClient != null));
    _env = env;
    if (solanaClient != null) {
      client = solanaClient;
    } else {
      switch (env) {
        case ClusterEnvironment.devnet:
          client = SolanaClient(
              rpcUrl: Uri.parse('https://api.devnet.solana.com'),
              websocketUrl: Uri.parse('wss://api.devnet.solana.com'));
          break;
        case ClusterEnvironment.testnet:
          client = SolanaClient(
              rpcUrl: Uri.parse('https://api.testnet.solana.com'),
              websocketUrl: Uri.parse('wss://api.testnet.solana.com'));
          break;
        default:
          client = SolanaClient(
              rpcUrl: Uri.parse('https://api.mainnet-beta.solana.com'),
              websocketUrl: Uri.parse('wss://api.mainnet-beta.solana.com'));
      }
    }
    instance._client = client;
    return instance;
  }

  Future<String?> getNameOfAddress(String address) async {
    final name = TokenSymbols.getSymbol(address);
    if (name != null) return name;

    final metadata = await client.rpcClient
        .getMetadata(mint: Ed25519HDPublicKey.fromBase58(address));
    if (metadata?.name != null) {
      debugPrint('add name ${metadata!.name}/$address to cache.');
      TokenSymbols.data[metadata.name] = address;
      return metadata.name;
    }
    return null;
  }

  Future<int> getAvailableTransferLamports(String address) async {
    final fees = await client.rpcClient.getFees();
    final balance = await getBalance(address);
    final fee = fees.feeCalculator.lamportsPerSignature;
    debugPrint('[sdk] balance is $balance, transfer fee is $fee');
    return balance > fee ? balance - fee : 0;
  }

  Future<int> getBalance(String address) async {
    debugPrint('[${_env ?? ClusterEnvironment.mainnet}](getBalance) $address');
    return await client.rpcClient
        .getBalance(address, commitment: Commitment.confirmed);
  }

  Future<List<TokenAccountData>> getTokenAccounts(String address) async {
    final accounts = await client.rpcClient.getTokenAccountsByOwner(
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

  /// get usdt for mainnet only
  Future<TokenAccountData> getUSDTTokenAccount(String address) async {
    final response = await client.rpcClient.getTokenAccountsByOwner(
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

  String uiAmount(int lamports) =>
      (lamports / lamportsPerSol).toStringAsFixed(solDecimalPlaces);

  Future<String> transfer(
      Wallet source, String destinationAddress, int amount) async {
    debugPrint(
        '[sdk] transfer ${uiAmount(amount)}($amount) from "${source.address}" to "$destinationAddress"');
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

  SolanaPayRequest createPayRequest(
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

  Future<String> getPrivateKey(Wallet wallet) async {
    List<int> key = (await wallet.extract()).bytes;
    key += wallet.publicKey.bytes;
    return base58encode(key);
  }

  String generateMnemonic() {
    return bip39.generateMnemonic();
  }

  Future<Wallet> initializeWalletFromMnemonic(String mnemonic) async {
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

  Future<Wallet> initializeWalletFromPrivateKey(String key) async {
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

  /// get simple price for swap
  ///
  /// input - sol or So11111111111111111111111111111111111111112
  /// output - usdt or Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB
  Future<JupGetPriceData?> getSwapPrice(
      String input, String output, num amount) async {
    final response =
        await _api.jupGetPrice(id: input, vsToken: output, amount: amount);
    return JupResponse<JupGetPriceData>.fromJson(jsonDecode(response),
        (json) => JupGetPriceData.fromJson(json as dynamic)).data;
  }

  Future<List<JupRoute?>?> getSwapQuote(
    String inputMint,
    String outputMint,
    int amount, {
    num? slippage,

    /// Fee BPS (only pass in if you want to charge a fee on this swap)
    int? feeBps,
  }) async {
    final response = await _api.jupGetQuote(
        inputMint: inputMint,
        outputMint: outputMint,
        amount: amount,
        feeBps: feeBps,
        slippage: slippage);
    return JupResponse<List<JupRoute?>>.fromJson(
        jsonDecode(response),
        (routes) => (routes as List<dynamic>)
            .map((json) => JupRoute.fromJson(json as dynamic))
            .toList(growable: false)).data;
  }

  /// https://docs.jup.ag/jupiter-api/swap-api-for-solana
  ///
  /// Send a route to jupiter to generate transactions
  Future<JupSwapTransactions> getSwapTxs(
    String publicKey,
    JupRoute route, {

    /// Fee token account for the output token (only pass in if you set a *feeBps*)
    String? feeAccount,
  }) async {
    final response = await _api.jupPostSwap(SwapDTO(
        route: route, userPublicKey: publicKey, feeAccount: feeAccount));
    return response;
  }

  Future<void> swap(Wallet wallet, JupSwapTransactions transactions) async {
    List<Uint8List> txs = [
      transactions.setupTransaction,
      transactions.swapTransaction,
      transactions.cleanupTransaction
    ].whereNotNull().map(base64Decode).map((t) => t.sublist(65)).toList();
    for (var tx in txs) {
      final recent = await client.rpcClient.getRecentBlockhash();
      final message = Message.decompile(CompiledMessage(ByteArray(tx)));
      final signed = await wallet.signMessage(
          message: message, recentBlockhash: recent.blockhash);
      final transactionId =
          await client.rpcClient.sendTransaction(signed.encode());
      await client.waitForSignatureStatus(transactionId,
          status: Commitment.confirmed, timeout: const Duration(seconds: 30));
    }
  }

  /// get nfts on mainnet
  Future<NftScanGetTransactionResponse> getNfts(String address,
      {pageIndex = 0, pageSize = 20}) async {
    final response = await _api.getTransactionByUserAddress(
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
