import 'package:dio/dio.dart' hide Headers;
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/http.dart';

part 'api.g.dart';

@RestApi()
abstract class ApiClient {
  /// ApiClient(Dio())
  factory ApiClient(Dio dio) = _ApiClient;

  /// get multi nfts by user address
  @GET('https://solana.nftscan.com/nftscan/getTransactionByUserAddress')
  Future<NftScanGetTransactionResponse> getTransactionByUserAddress({
    @Query('user_address') required String userAddress,
    @Query('collection') String? collection = '',
    @Query('transferType') String? transferType = 'all',
    @Query('pageIndex') int? pageIndex = 0,
    @Query('pageSize') int? pageSize = 20,
  });

  // - jupiter API -

  /// Get simple price for a given input mint, output mint and amount
  @GET('https://quote-api.jup.ag/v1/price')
  Future<String> jupGetPrice({
    /// Symbol or address of a token, (e.g. SOL or EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v).
    /// Use , to query multiple tokens, e.g. (sol,btc,mer,)
    @Query("id") required String id,

    /// Default to USDC. Symbol or address of a token, (e.g. SOL or EPjFWdd5AufqSSqeM2qN1xzybapC8G4wEGGkZwyTDt1v).
    @Query("vsToken") String? vsToken,

    /// Unit amount of specified input token. Default to 1.
    @Query("amount") num? amount,
  });

  /// Get quote for a given input mint, output mint and amount
  @GET('https://quote-api.jup.ag/v1/quote')
  Future<String> jupGetQuote({
    @Query("inputMint") required String inputMint,
    @Query("outputMint") required String outputMint,
    @Query("amount") required int amount,

    /// Available values : ExactIn, ExactOut
    @Query("swapMode") String? swapMode,
    @Query("slippage") num? slippage,

    /// Fee BPS (only pass in if you want to charge a fee on this swap)
    @Query("feeBps") int? feeBps,

    /// Only return direct routes (no hoppings and split trade)
    @Query("onlyDirectRoutes") bool? onlyDirectRoutes,

    /// Public key of the user (only pass in if you want deposit and fee being returned, might slow down query)
    @Query("userPublicKey") String? userPublicKey,
  });

  @POST('https://quote-api.jup.ag/v1/swap')
  Future<JupSwapTransactions> jupPostSwap(@Body() SwapDTO dto);
}

@JsonSerializable()
class SwapDTO {
  final JupRoute route;

  /// Public key of the user
  final String userPublicKey;

  /// auto wrap and unwrap SOL. default is true
  final bool? wrapUnwrapSOL;

  /// Fee token account for the output token (only pass in if you set a feeBps)
  final String? feeAccount;

  /// Custom token ledger account (only pass in if you want to track your swap)
  final String? tokenLedger;

  /// Public key of the wallet that will receive the output of the swap,
  /// this assumes the associated token account exists, currently adds a token transfer
  final String? destinationWallet;

  SwapDTO({
    required this.route,
    required this.userPublicKey,
    this.wrapUnwrapSOL,
    this.feeAccount,
    this.tokenLedger,
    this.destinationWallet,
  });

  factory SwapDTO.fromJson(Map<String, dynamic> json) =>
      _$SwapDTOFromJson(json);
  Map<String, dynamic> toJson() => _$SwapDTOToJson(this);
}

@JsonSerializable()
class JupSwapTransactions {
  final String? setupTransaction;
  final String swapTransaction;
  final String? cleanupTransaction;

  JupSwapTransactions(
      {this.setupTransaction,
      required this.swapTransaction,
      this.cleanupTransaction});

  factory JupSwapTransactions.fromJson(Map<String, dynamic> json) =>
      _$JupSwapTransactionsFromJson(json);

  Map<String, dynamic> toJson() => _$JupSwapTransactionsToJson(this);
}

@JsonSerializable(genericArgumentFactories: true)
class JupResponse<T> {
  num? timeTaken;
  String? contextSlot;
  T? data;

  JupResponse({this.timeTaken, this.contextSlot, this.data});

  factory JupResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$JupResponseFromJson(json, fromJsonT);
  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$JupResponseToJson(this, toJsonT);
}

@JsonSerializable()
class JupRoute {
  final int inAmount;
  final int outAmount;
  final double? priceImpactPct;
  final List<JupMarketInfo> marketInfos;

  /// The minimum out amount, populated when swapMode is ExactIn, deprecated please use otherAmountThreshold instead
  @Deprecated('https://quote-api.jup.ag/docs/static/index.html')
  final int outAmountWithSlippage;

  /// The threshold for the swap based on the provided slippage:
  /// when swapMode is ExactIn the minimum out amount, when swapMode is ExactOut the maximum in amount
  final int otherAmountThreshold;

  /// Enum: ExactIn, ExactOut
  final String swapMode;

  /// Only returned when userPublicKey is given to /quote
  final List<JupRouteFee>? fees;

  JupRoute({
    required this.inAmount,
    required this.outAmount,
    this.priceImpactPct,
    required this.marketInfos,
    required this.outAmountWithSlippage,
    required this.otherAmountThreshold,
    required this.swapMode,
    this.fees,
  });

  factory JupRoute.fromJson(Map<String, dynamic> json) =>
      _$JupRouteFromJson(json);
  Map<String, dynamic> toJson() => _$JupRouteToJson(this);
}

@JsonSerializable()
class JupMarketInfo {
  final String id;
  final String label;
  final String inputMint;
  final String outputMint;
  final bool notEnoughLiquidity;
  final int inAmount;
  final int outAmount;
  final num? priceImpactPct;
  final JupFee lpFee;
  final JupFee platformFee;

  JupMarketInfo({
    required this.id,
    required this.label,
    required this.inputMint,
    required this.outputMint,
    required this.notEnoughLiquidity,
    required this.inAmount,
    required this.outAmount,
    this.priceImpactPct,
    required this.lpFee,
    required this.platformFee,
  });

  factory JupMarketInfo.fromJson(Map<String, dynamic> json) =>
      _$JupMarketInfoFromJson(json);
  Map<String, dynamic> toJson() => _$JupMarketInfoToJson(this);
}

@JsonSerializable()
class JupFee {
  final num amount;
  final String mint;
  final num? pct;

  JupFee({required this.amount, required this.mint, this.pct});

  factory JupFee.fromJson(Map<String, dynamic> json) => _$JupFeeFromJson(json);
  Map<String, dynamic> toJson() => _$JupFeeToJson(this);
}

@JsonSerializable()
class JupRouteFee {
  /// This inidicate the total amount needed for signing transaction(s). Value in lamports.
  final num signatureFee;

  /// This inidicate the total amount needed for deposit of serum order account(s). Value in lamports.
  final List<num> openOrdersDeposits;

  /// This inidicate the total amount needed for deposit of associative token account(s). Value in lamports.
  final List<num> ataDeposits;

  /// This inidicate the total lamports needed for fees and deposits above.
  final num totalFeeAndDeposits;

  /// This inidicate the minimum lamports needed for transaction(s).
  /// Might be used to create wrapped SOL and will be returned when the wrapped SOL is closed.
  final num minimumSOLForTransaction;

  JupRouteFee(
      {required this.signatureFee,
      required this.openOrdersDeposits,
      required this.ataDeposits,
      required this.totalFeeAndDeposits,
      required this.minimumSOLForTransaction});

  factory JupRouteFee.fromJson(Map<String, dynamic> json) =>
      _$JupRouteFeeFromJson(json);
  Map<String, dynamic> toJson() => _$JupRouteFeeToJson(this);
}

@JsonSerializable()
class JupGetPriceData {
  /// Address of the token
  final String? id;

  /// Symbol of the token
  final String? mintSymbol;

  /// Address of the vs token
  final String? vsToken;

  /// Symbol of the vs token
  final String? vsTokenSymbol;

  /// Default to 1 unit of the token worth in USDC if vsToken is not specified.
  final num? price;

  JupGetPriceData(
      {this.id, this.mintSymbol, this.vsToken, this.vsTokenSymbol, this.price});

  factory JupGetPriceData.fromJson(Map<String, dynamic> json) =>
      _$JupGetPriceDataFromJson(json);
  Map<String, dynamic> toJson() => _$JupGetPriceDataToJson(this);
}

@JsonSerializable()
class NftScanGetTransactionResponse {
  final String? msg;
  final int? code;
  final NftTransactionsData? data;

  NftScanGetTransactionResponse({this.msg, this.code, this.data});

  factory NftScanGetTransactionResponse.fromJson(Map<String, dynamic> json) =>
      _$NftScanGetTransactionResponseFromJson(json);
  Map<String, dynamic> toJson() => _$NftScanGetTransactionResponseToJson(this);
}

@JsonSerializable()
class NftTransactionsData {
  @JsonKey(name: 'nft_tx_total')
  final int? total;
  @JsonKey(name: 'nft_tx_record')
  final List<NftTransactionRecord>? records;

  NftTransactionsData({this.total, this.records});

  factory NftTransactionsData.fromJson(Map<String, dynamic> json) =>
      _$NftTransactionsDataFromJson(json);
  Map<String, dynamic> toJson() => _$NftTransactionsDataToJson(this);
}

@JsonSerializable()
class NftTransactionRecord {
  @JsonKey(name: 'transaction_hash')
  final String? transactionHash;
  @JsonKey(name: 'transaction_method')
  final String? transactionMethod;
  @JsonKey(name: 'transaction_time')
  final int? transactionTime;
  @JsonKey(name: 'from_address')
  final String? fromAddress;
  @JsonKey(name: 'to_address')
  final String? toAddress;
  @JsonKey(name: 'tx_timestamp')
  final String? txTimestamp;
  @JsonKey(name: 'status')
  final String? status;
  @JsonKey(name: 'cover')
  final String? cover;
  @JsonKey(name: 'token_address')
  final String? tokenAddress;
  @JsonKey(name: 'collection')
  final String? collection;
  @JsonKey(name: 'block_number')
  final String? blockNumber;
  @JsonKey(name: 'fee')
  final num? fee;
  @JsonKey(name: 'tx_value')
  final num? txValue;
  @JsonKey(name: 'from_user_address')
  final String? fromUserAddress;
  @JsonKey(name: 'to_user_address')
  final String? toUserAddress;
  @JsonKey(name: 'tx_unique_seq')
  final int? txUniqueSeq;
  @JsonKey(name: 'tradePlatform')
  final String? tradePlatform;
  @JsonKey(name: 'tradePlatformLogo')
  final String? tradePlatformLogo;
  @JsonKey(name: 'tradePlatformProgram')
  final String? tradePlatformProgram;

  NftTransactionRecord(
      {this.transactionHash,
      this.transactionMethod,
      this.transactionTime,
      this.fromAddress,
      this.toAddress,
      this.txTimestamp,
      this.status,
      this.cover,
      this.tokenAddress,
      this.collection,
      this.blockNumber,
      this.fee,
      this.txValue,
      this.fromUserAddress,
      this.toUserAddress,
      this.txUniqueSeq,
      this.tradePlatform,
      this.tradePlatformLogo,
      this.tradePlatformProgram});

  factory NftTransactionRecord.fromJson(Map<String, dynamic> json) =>
      _$NftTransactionRecordFromJson(json);
  Map<String, dynamic> toJson() => _$NftTransactionRecordToJson(this);
}
