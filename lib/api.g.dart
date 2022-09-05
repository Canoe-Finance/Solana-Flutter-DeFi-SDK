// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NftScanGetTransactionResponse _$NftScanGetTransactionResponseFromJson(
        Map<String, dynamic> json) =>
    NftScanGetTransactionResponse(
      msg: json['msg'] as String?,
      code: json['code'] as int?,
      data: json['data'] == null
          ? null
          : NftTransactionsData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NftScanGetTransactionResponseToJson(
        NftScanGetTransactionResponse instance) =>
    <String, dynamic>{
      'msg': instance.msg,
      'code': instance.code,
      'data': instance.data,
    };

NftTransactionsData _$NftTransactionsDataFromJson(Map<String, dynamic> json) =>
    NftTransactionsData(
      total: json['nft_tx_total'] as int?,
      records: (json['nft_tx_record'] as List<dynamic>?)
          ?.map((e) => NftTransactionRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NftTransactionsDataToJson(
        NftTransactionsData instance) =>
    <String, dynamic>{
      'nft_tx_total': instance.total,
      'nft_tx_record': instance.records,
    };

NftTransactionRecord _$NftTransactionRecordFromJson(
        Map<String, dynamic> json) =>
    NftTransactionRecord(
      transactionHash: json['transaction_hash'] as String?,
      transactionMethod: json['transaction_method'] as String?,
      transactionTime: json['transaction_time'] as int?,
      fromAddress: json['from_address'] as String?,
      toAddress: json['to_address'] as String?,
      txTimestamp: json['tx_timestamp'] as String?,
      status: json['status'] as String?,
      cover: json['cover'] as String?,
      tokenAddress: json['token_address'] as String?,
      collection: json['collection'] as String?,
      blockNumber: json['block_number'] as String?,
      fee: json['fee'] as num?,
      txValue: json['tx_value'] as num?,
      fromUserAddress: json['from_user_address'] as String?,
      toUserAddress: json['to_user_address'] as String?,
      txUniqueSeq: json['tx_unique_seq'] as int?,
      tradePlatform: json['tradePlatform'] as String?,
      tradePlatformLogo: json['tradePlatformLogo'] as String?,
      tradePlatformProgram: json['tradePlatformProgram'] as String?,
    );

Map<String, dynamic> _$NftTransactionRecordToJson(
        NftTransactionRecord instance) =>
    <String, dynamic>{
      'transaction_hash': instance.transactionHash,
      'transaction_method': instance.transactionMethod,
      'transaction_time': instance.transactionTime,
      'from_address': instance.fromAddress,
      'to_address': instance.toAddress,
      'tx_timestamp': instance.txTimestamp,
      'status': instance.status,
      'cover': instance.cover,
      'token_address': instance.tokenAddress,
      'collection': instance.collection,
      'block_number': instance.blockNumber,
      'fee': instance.fee,
      'tx_value': instance.txValue,
      'from_user_address': instance.fromUserAddress,
      'to_user_address': instance.toUserAddress,
      'tx_unique_seq': instance.txUniqueSeq,
      'tradePlatform': instance.tradePlatform,
      'tradePlatformLogo': instance.tradePlatformLogo,
      'tradePlatformProgram': instance.tradePlatformProgram,
    };

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers

class _RestClient implements RestClient {
  _RestClient(this._dio, {this.baseUrl});

  final Dio _dio;

  String? baseUrl;

  @override
  Future<NftScanGetTransactionResponse> getTransactionByUserAddress(
      {required userAddress,
      collection = '',
      transferType = 'all',
      pageIndex = 0,
      pageSize = 20}) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'user_address': userAddress,
      r'collection': collection,
      r'transferType': transferType,
      r'pageIndex': pageIndex,
      r'pageSize': pageSize
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(_setStreamType<
        NftScanGetTransactionResponse>(Options(
            method: 'GET', headers: _headers, extra: _extra)
        .compose(_dio.options,
            'https://solana.nftscan.com/nftscan/getTransactionByUserAddress',
            queryParameters: queryParameters, data: _data)
        .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = NftScanGetTransactionResponse.fromJson(_result.data!);
    return value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }
}
