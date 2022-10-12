import 'package:dio/dio.dart' hide Headers;
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/http.dart';

part 'api.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio) = _ApiClient;

  // - SolScan Public API -

  @GET('https://public-api.solscan.io/account/tokens')
  Future<List<SolScanTokenAccount>> getTokenAccounts({
    @Query('account') required String account,
  });

  // - NFTScan -

  /// [deprecated] get multi nfts by user address
  @Deprecated('Use `getAllAssetsGroupByCollection` instead')
  @GET('https://solana.nftscan.com/nftscan/getTransactionByUserAddress')
  Future<NFTScanResponse<NFTTransactionsData>> getTransactionByUserAddress({
    @Query('user_address') required String userAddress,
    @Query('collection') String? collection = '',
    @Query('transferType') String? transferType = 'all',
    @Query('pageIndex') int? pageIndex = 0,
    @Query('pageSize') int? pageSize = 20,
  });

  /// Retrieve all assets owned by an account group by collection
  ///
  /// This endpoint returns all NFTs owned by an account address. And the NFTs are grouped according to collection.
  /// https://docs.nftscan.com/solana/getAccountNftAssetsGroupByCollectionUsingGET
  @GET(
      'https://solanaapi.nftscan.com/api/sol/account/own/all/{account_address}')
  Future<NFTScanResponse<List<GetAllAssetsDataElement>>>
      getAllAssetsGroupByCollection({
    /// The address of the owner of the assets
    @Path('account_address') required String accountAddress,

    /// Authentication required for this api
    ///
    /// You may get the apiKey from https://developer.nftscan.com/
    /// Overview: https://docs.nftscan.com/solana/API%20Overview
    @Header("X-API-KEY") required String apiKey,
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

  // - wormhole wrapped by canoe.finance -

  /// wormhole api wrapped by canoe.finance
  @POST('https://wormhole.canoe.finance')
  // @Headers({'Content-Type': 'application/json'})
  Future<String> wormhole(@Body() WormHoleDTO dto);
}

@JsonSerializable()
class WormHoleDTO {
  final String userPublicKey;
  final String messageAddress;
  final String mint;
  final String targetAddress;
  final String amount;

  WormHoleDTO({
    required this.userPublicKey,
    required this.messageAddress,
    required this.mint,
    required this.targetAddress,
    required this.amount,
  });

  factory WormHoleDTO.fromJson(Map<String, dynamic> json) =>
      _$WormHoleDTOFromJson(json);
  Map<String, dynamic> toJson() => _$WormHoleDTOToJson(this);
}

@JsonSerializable()
class SolScanTokenAccount {
  final String? tokenAddress;
  final String? tokenAccount;
  final String? tokenName;
  final String? tokenIcon;
  final String? tokenSymbol;
  final int? rentEpoch;
  final int? lamports;
  final SolScanTokenAmount? tokenAmount;

  SolScanTokenAccount(
      {this.tokenAddress,
      this.tokenAccount,
      this.tokenName,
      this.tokenIcon,
      this.tokenSymbol,
      this.rentEpoch,
      this.lamports,
      this.tokenAmount});

  factory SolScanTokenAccount.fromJson(Map<String, dynamic> json) =>
      _$SolScanTokenAccountFromJson(json);
  Map<String, dynamic> toJson() => _$SolScanTokenAccountToJson(this);
}

@JsonSerializable()
class SolScanTokenAmount {
  final String? amount;
  final String? uiAmountString;
  final int? decimals;
  final num? uiAmount;

  SolScanTokenAmount(
      {this.amount, this.uiAmountString, this.decimals, this.uiAmount});

  factory SolScanTokenAmount.fromJson(Map<String, dynamic> json) =>
      _$SolScanTokenAmountFromJson(json);
  Map<String, dynamic> toJson() => _$SolScanTokenAmountToJson(this);
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

@JsonSerializable(genericArgumentFactories: true)
class NFTScanResponse<T> {
  /// Error information message while the request fails
  final String? msg;

  /// Response status code (200 means the request successes, 4XX or 5XX means the request fails)
  final int? code;

  /// Response data
  final T? data;

  NFTScanResponse({this.msg, this.code, this.data});

  factory NFTScanResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$NFTScanResponseFromJson(json, fromJsonT);
  Map<String, dynamic> toJson(Object Function(T value) toJsonT) =>
      _$NFTScanResponseToJson(this, toJsonT);
}

@JsonSerializable()
class GetAllAssetsDataElement {
  /// How many items the account address owns
  @JsonKey(name: 'owns_total')
  final int? ownsTotal;

  /// The logo URL
  @JsonKey(name: 'logo_url')
  final String? logoUrl;

  /// How many items for the collection
  @JsonKey(name: 'items_total')
  final int? itemsTotal;

  /// The description
  @JsonKey(name: 'description')
  final String? description;

  /// The collection
  @JsonKey(name: 'collection')
  final String? collection;

  /// List of Asset Model
  @JsonKey(name: 'assets')
  final List<GetAllAssetsDataElementAsset>? assets;

  GetAllAssetsDataElement(
      {this.ownsTotal,
      this.logoUrl,
      this.itemsTotal,
      this.description,
      this.collection,
      this.assets});

  factory GetAllAssetsDataElement.fromJson(Map<String, dynamic> json) =>
      _$GetAllAssetsDataElementFromJson(json);
  Map<String, dynamic> toJson() => _$GetAllAssetsDataElementToJson(this);
}

@JsonSerializable()
class GetAllAssetsDataElementAsset {
  @JsonKey(name: 'block_number')
  final int? blockNumber;
  @JsonKey(name: 'collection')
  final String? collection;
  @JsonKey(name: 'content_type')
  final String? contentType;

  /// The content URI to display
  @JsonKey(name: 'content_uri')
  final String? contentUri;

  /// External link to the original website
  @JsonKey(name: 'external_link')
  final String? externalLink;
  @JsonKey(name: 'image_uri')
  final String? imageUri;

  /// The program interacted with when the item was minted
  @JsonKey(name: 'interact_program')
  final String? interactProgram;

  /// The latest trade price for the item
  @JsonKey(name: 'latest_trade_price')
  final num? latestTradePrice;

  /// The latest trade timestamp in milliseconds for the item
  @JsonKey(name: 'latest_trade_timestamp')
  final int? latestTradeTimestamp;

  /// The latest trade transaction hash for the item
  @JsonKey(name: 'latest_trade_transaction_hash')
  final String? latestTradeTransactionHash;
  @JsonKey(name: 'metadata_json')
  final String? metadataJson;

  /// The price when the item was minted
  @JsonKey(name: 'mint_price')
  final num? mintPrice;

  /// The timestamp in milliseconds when the item was minted
  @JsonKey(name: 'mint_timestamp')
  final int? mintTimestamp;

  /// The transaction hash when the item was minted
  @JsonKey(name: 'mint_transaction_hash')
  final String? mintTransactionHash;

  /// The user address who minted the item
  @JsonKey(name: 'minter')
  final String? minter;
  @JsonKey(name: 'name')
  final String? name;

  /// The user address who owns the item now
  @JsonKey(name: 'owner')
  final String? owner;
  @JsonKey(name: 'token_address')
  final String? tokenAddress;
  @JsonKey(name: 'token_uri')
  final String? tokenUri;

  GetAllAssetsDataElementAsset(
      {this.blockNumber,
      this.collection,
      this.contentType,
      this.contentUri,
      this.externalLink,
      this.imageUri,
      this.interactProgram,
      this.latestTradePrice,
      this.latestTradeTimestamp,
      this.latestTradeTransactionHash,
      this.metadataJson,
      this.mintPrice,
      this.mintTimestamp,
      this.mintTransactionHash,
      this.minter,
      this.name,
      this.owner,
      this.tokenAddress,
      this.tokenUri});

  factory GetAllAssetsDataElementAsset.fromJson(Map<String, dynamic> json) =>
      _$GetAllAssetsDataElementAssetFromJson(json);
  Map<String, dynamic> toJson() => _$GetAllAssetsDataElementAssetToJson(this);
}

@JsonSerializable()
class NFTTransactionsData {
  @JsonKey(name: 'nft_tx_total')
  final int? total;
  @JsonKey(name: 'nft_tx_record')
  final List<NFTTransactionRecord>? records;

  NFTTransactionsData({this.total, this.records});

  factory NFTTransactionsData.fromJson(Map<String, dynamic> json) =>
      _$NFTTransactionsDataFromJson(json);
  Map<String, dynamic> toJson() => _$NFTTransactionsDataToJson(this);
}

@JsonSerializable()
class NFTTransactionRecord {
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

  NFTTransactionRecord(
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

  factory NFTTransactionRecord.fromJson(Map<String, dynamic> json) =>
      _$NFTTransactionRecordFromJson(json);
  Map<String, dynamic> toJson() => _$NFTTransactionRecordToJson(this);
}
