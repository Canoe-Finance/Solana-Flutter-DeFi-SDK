library solana_defi_sdk;

import 'dart:convert';
import 'dart:math';

import 'package:bip39/bip39.dart' as bip39;
import 'package:collection/collection.dart';
import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:simple_logger/simple_logger.dart';
import 'package:solana/base58.dart';
import 'package:solana/dto.dart';
import 'package:solana/encoder.dart';
import 'package:solana/metaplex.dart';
import 'package:solana/solana.dart';
import 'package:solana/solana_pay.dart';

import 'api.dart';

/// address name and label mapping for mainnet
class TokenSymbols {
  /// for mainnet
  static final data = {
    'SOL': 'So11111111111111111111111111111111111111112',
    'USDT': 'Es9vMFrzaCERmJfrF4H2FYD4KCoNkY11McCe8BenwNYB',
    'USDC': 'EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v',
  };

  static String? getAddress(String symbol) {
    return data[symbol.toUpperCase()];
  }

  static String? getSymbol(String address) {
    return data.entries
        .firstWhereOrNull((element) => element.value == address)
        ?.key;
  }
}

enum ClusterEnv { mainnet, devnet, testnet }

class KeyManager {
  static const storeKey = 'mnemonic';

  /// using flutter secure storage store mnemonic
  ///
  /// TODO
  static Future<void> persistMnemonic(String mnemonic) {
    return const FlutterSecureStorage().write(key: storeKey, value: mnemonic);
  }

  static Future<String?> restoreMnemonic() {
    return const FlutterSecureStorage().read(key: storeKey);
  }
}

class SolanaDeFiSDK {
  static const int lamportsPerSol = 1000000000;
  static const int solDecimalPlaces = 9;

  static final logger = SimpleLogger();

  static ClusterEnv? _env;
  // static final httpClient = http.Client();
  // static final JupiterAggregatorClient _jupClient = JupiterAggregatorClient();
  static late final ApiClient _api;

  /// setup by initialize functions
  Wallet? _wallet;
  Wallet? get wallet => _wallet;

  SolanaClient? _client;
  SolanaClient get client => _client!;
  // JupiterAggregatorClient get jup => _jupClient;

  static final SolanaDeFiSDK _instance = SolanaDeFiSDK._();
  static SolanaDeFiSDK get instance => _instance;
  static ClusterEnv? get env => _env;

  // factory SolanaDeFiSDK() => _instance!;
  SolanaDeFiSDK._() {
    final dio = Dio();
    dio.interceptors.add(LogInterceptor());
    _api = ApiClient(Dio());
  }

  /// create mainnet(https://api.mainnet-beta.solana.com) solana client by default
  ///
  /// devnet - https://api.devnet.solana.com
  /// testnet - https://api.testnet.solana.com
  static SolanaDeFiSDK initialize({
    ClusterEnv? env,
    SolanaClient? solanaClient,
  }) {
    assert(!(env != null && solanaClient != null));

    SolanaClient client;
    _env = env;
    if (solanaClient != null) {
      client = solanaClient;
    } else {
      switch (env) {
        case ClusterEnv.devnet:
          client = SolanaClient(
              rpcUrl: Uri.parse('https://api.devnet.solana.com'),
              websocketUrl: Uri.parse('wss://api.devnet.solana.com'));
          break;
        case ClusterEnv.testnet:
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
    // logger.setLevel(loggerLevel ?? Level.WARNING);
    return instance;
  }

  Future<String?> getNameOfAddress(String address) async {
    final name = TokenSymbols.getSymbol(address);
    if (name != null) return name;

    final metadata = await client.rpcClient
        .getMetadata(mint: Ed25519HDPublicKey.fromBase58(address));
    if (metadata?.name != null) {
      logger.info('add name ${metadata!.name}/$address to cache.');
      TokenSymbols.data[metadata.name] = address;
      return metadata.name;
    }
    return null;
  }

  Future<Mint> getMint(String address) async {
    logger.info('get mint for $address');
    return await client.getMint(
        address: Ed25519HDPublicKey.fromBase58(address));
  }

  Future<int> getAvailableTransferLamports(String address) async {
    final fee = await getFee();
    final balance = await getBalance(address);
    logger.info('[sdk] balance is $balance, transfer fee is $fee');
    return balance > fee ? balance - fee : 0;
  }

  /// parse ui amount to decimals
  Future<int> parseUIAmount(String mintAddress, String uiAmount) async {
    final mint = await getMint(mintAddress);
    return (num.parse(uiAmount) * pow(10, mint.decimals)).toInt();
  }

  Future<int> getFee() async {
    final fees = await client.rpcClient.getFees();
    return fees.feeCalculator.lamportsPerSignature;
  }

  Future<int> getBalance(String address) async {
    logger.info('[${_env ?? ClusterEnv.mainnet}](getBalance) $address');
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
    // logger.i(filtered.length);
    for (final element in filtered) {
      final data = element.account.data as ParsedAccountData;
      final programData = data as ParsedSplTokenProgramAccountData;
      final parsed = programData.parsed as TokenAccountData;
      final mint = parsed.info.mint;
      final amount = parsed.info.tokenAmount.uiAmountString;
      final isNft = parsed.info.tokenAmount.decimals == 0;
      logger.info('--> mint:$mint isNft:$isNft amount:$amount');
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
    logger.info('length is ${response.length}');
    final data = response.first.account.data as ParsedAccountData;
    final programData = data as ParsedSplTokenProgramAccountData;
    return programData.parsed as TokenAccountData;
  }

  String uiAmount(int lamports) =>
      (lamports / lamportsPerSol).toStringAsFixed(solDecimalPlaces);

  /// TODO client.transferLamports or transferSplToken
  Future<String> transfer(
      Wallet source, String destinationAddress, int amount) async {
    logger.info(
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
    logger.info('[sdk] transfer transaction id is $transactionId');
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

  /// restore wallet, if no info found by (getAccountInfo), will throw an error
  ///
  /// String mnemonic = generateMnemonic();
  /// List<int> seed = bip39.mnemonicToSeed(mnemonic);
  ///     String seedHash = sha256
  ///         .convert(seed)
  ///         .bytes
  ///         .sublist(0, 4)
  ///         .map((e) => e.toRadixString(16).padLeft(2, "0"))
  ///         .join("");
  Future<Wallet> initializeWalletFromMnemonic(String mnemonic) async {
    final Ed25519HDKeyPair keyPair =
        await Ed25519HDKeyPair.fromMnemonic(mnemonic);
    final Wallet wallet = keyPair;
    logger.info('initialized wallet address is "${wallet.address}"');
    final info = await client.rpcClient.getAccountInfo(wallet.address);
    if (info == null) {
      _wallet = null;
      throw Exception('no account info found');
    }
    _wallet = wallet;
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
      logger.info('decoded key is $decodedKey');
      throw 'invalid key';
    }
    final privateKey = decodedKey.sublist(0, 32);
    final keyPair =
        await Ed25519HDKeyPair.fromPrivateKeyBytes(privateKey: privateKey);

    _wallet = keyPair;
    return keyPair;
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
    logger.info(
        'inputMint: $inputMint, outputMint: $outputMint, amount: $amount, feeBps: $feeBps, slippage: $slippage');
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
    final txs = [
      transactions.setupTransaction,
      transactions.swapTransaction,
      transactions.cleanupTransaction
    ]
        .whereNotNull()
        .map(base64Decode)
        // { 01 + empty 64 byte signature (64 bytes of 00) + unsigned transaction }
        // .map((t) => t.sublist(65)) // if not using CompiledMessage.fromSignedTransaction
        .toList();
    for (var tx in txs) {
      final message = Message.decompile(
          CompiledMessage.fromSignedTransaction(ByteArray(tx)));
      /*
      final recent = await client.rpcClient.getRecentBlockhash();
      final signed = await wallet.signMessage(
          message: message, recentBlockhash: recent.blockhash);
      final transactionId =
          await client.rpcClient.sendTransaction(signed.encode());*/

      final transactionId = await client.sendAndConfirmTransaction(
          message: message,
          signers: [wallet],
          commitment: Commitment.confirmed);
      await client.waitForSignatureStatus(
        transactionId,
        status: Commitment.confirmed,
      );
      logger.info('swap - transactionId: $transactionId');
    }
  }

  /// cross chain by wormhole api from an api created by canoe.fiance,
  /// Redeem by returned TransactionId at https://www.portalbridge.com/#/redeem
  Future<TransactionId> cross(
    Wallet wallet, {
    required String mint,
    required String targetAddress,
    required int amount,
  }) async {
    final messageKey = await Ed25519HDKeyPair.random();
    final dto = WormHoleDTO(
        userPublicKey: wallet.address,
        mint: mint,
        targetAddress: targetAddress,
        messageAddress: messageKey.address,
        amount: amount.toString());
    logger.info('cross by ${dto.toJson()}');

    final transaction = await _api.wormhole(dto);
    final data = ByteArray(base64Decode(transaction));
    /*
    final signaturesCount = CompactU16.raw(data.toList()).value;
    logger.info('signaturesCount is $signaturesCount');*/
    final message = Message.decompile(
      CompiledMessage.fromSignedTransaction(data),
    );
    /*
    // other way
    final recent = await client.rpcClient.getRecentBlockhash();
    final signed = await wallet.signMessage(
        message: message, recentBlockhash: recent.blockhash);
    final transactionId =
        await client.rpcClient.sendTransaction(signed.encode());*/
    final transactionId = await client.sendAndConfirmTransaction(
      message: message,
      signers: [wallet, messageKey],
      commitment: Commitment.confirmed,
    );
    await client.waitForSignatureStatus(
      transactionId,
      status: Commitment.confirmed,
    );
    logger.info('cross - transactionId: $transactionId');
    return transactionId;
  }

  /// get nfts on Mainnet
  Future<NftScanGetTransactionResponse> getNfts(String address,
      {pageIndex = 0, pageSize = 20}) async {
    final response = await _api.getTransactionByUserAddress(
        userAddress: address, pageIndex: pageIndex, pageSize: pageSize);
    logger.info('found ${response.data?.total} nfts');
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
