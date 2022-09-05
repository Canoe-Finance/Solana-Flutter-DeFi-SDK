import 'package:dio/dio.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/http.dart';

part 'api.g.dart';

@RestApi()
abstract class RestClient {
  factory RestClient(Dio dio) = _RestClient;

  @GET('https://solana.nftscan.com/nftscan/getTransactionByUserAddress')
  Future<NftScanGetTransactionResponse> getTransactionByUserAddress({
    @Query('user_address') required String userAddress,
    @Query('collection') String? collection = '',
    @Query('transferType') String? transferType = 'all',
    @Query('pageIndex') int? pageIndex = 0,
    @Query('pageSize') int? pageSize = 20,
  });
}

@JsonSerializable()
class NftScanGetTransactionResponse {
  String? msg;
  int? code;
  NftTransactionsData? data;

  NftScanGetTransactionResponse({this.msg, this.code, this.data});

  factory NftScanGetTransactionResponse.fromJson(Map<String, dynamic> json) =>
      _$NftScanGetTransactionResponseFromJson(json);
  Map<String, dynamic> toJson() => _$NftScanGetTransactionResponseToJson(this);
}

@JsonSerializable()
class NftTransactionsData {
  @JsonKey(name: 'nft_tx_total')
  int? total;
  @JsonKey(name: 'nft_tx_record')
  List<NftTransactionRecord>? records;

  NftTransactionsData({this.total, this.records});

  factory NftTransactionsData.fromJson(Map<String, dynamic> json) =>
      _$NftTransactionsDataFromJson(json);
  Map<String, dynamic> toJson() => _$NftTransactionsDataToJson(this);
}

// transaction_hash": "HYMu6Uyodt3Qpj3BdNhD1j29dtea8w3FwrjgZpZxJyhXro1izWMDTVdtzFXDpJiQ4VWpD51ZfszoeX7D6BouSza",
// "transaction_method": "Bought",
// "transaction_time": 1660016560,
// "from_address": "AsB9yepMBFQ1K984TLfYHMTVoRikz5Ep52Zi5hDqHFrU",
// "to_address": "888888u1JfaH1986a8X2kqC9GrXEuPVMHL91H95H9gqM",
// "tx_timestamp": null,
// "status": null,
// "cover": "https://arweave.net/FsLSRulMgW1qECx8pckiymbUTtCG3-Hdk0-P6C2KM0c",
// "token_address": "Ef6DAoouSrKwHaJwjhqyy9GyCma3iaTVPgxmoP8bozLp",
// "collection": "Slayerz-V2",
// "block_number": null,
// "fee": 0.00001,
// "tx_value": 0.085,
// "from_user_address": "AsB9yepMBFQ1K984TLfYHMTVoRikz5Ep52Zi5hDqHFrU",
// "to_user_address": "888888u1JfaH1986a8X2kqC9GrXEuPVMHL91H95H9gqM",
// "tx_unique_seq": 0,
// "tradePlatform": "MagicEden",
// "tradePlatformLogo": "https://d1vqhwsspszdq0.cloudfront.net/solana-logo/MagicEden.png",
// "tradePlatformProgram": "M2mx93ekt1fmXSVkTrUL9xVFHkmME8HTUi5Cyc5aF7K"

@JsonSerializable()
class NftTransactionRecord {
  @JsonKey(name: 'transaction_hash')
  String? transactionHash;
  @JsonKey(name: 'transaction_method')
  String? transactionMethod;
  @JsonKey(name: 'transaction_time')
  int? transactionTime;
  @JsonKey(name: 'from_address')
  String? fromAddress;
  @JsonKey(name: 'to_address')
  String? toAddress;
  @JsonKey(name: 'tx_timestamp')
  String? txTimestamp;
  @JsonKey(name: 'status')
  String? status;
  @JsonKey(name: 'cover')
  String? cover;
  @JsonKey(name: 'token_address')
  String? tokenAddress;
  @JsonKey(name: 'collection')
  String? collection;
  @JsonKey(name: 'block_number')
  String? blockNumber;
  @JsonKey(name: 'fee')
  num? fee;
  @JsonKey(name: 'tx_value')
  num? txValue;
  @JsonKey(name: 'from_user_address')
  String? fromUserAddress;
  @JsonKey(name: 'to_user_address')
  String? toUserAddress;
  @JsonKey(name: 'tx_unique_seq')
  int? txUniqueSeq;
  @JsonKey(name: 'tradePlatform')
  String? tradePlatform;
  @JsonKey(name: 'tradePlatformLogo')
  String? tradePlatformLogo;
  @JsonKey(name: 'tradePlatformProgram')
  String? tradePlatformProgram;

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
