// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WormHoleDTO _$WormHoleDTOFromJson(Map<String, dynamic> json) => WormHoleDTO(
      userPublicKey: json['userPublicKey'] as String,
      messageAddress: json['messageAddress'] as String,
      mint: json['mint'] as String,
      targetAddress: json['targetAddress'] as String,
      amount: json['amount'] as String,
    );

Map<String, dynamic> _$WormHoleDTOToJson(WormHoleDTO instance) =>
    <String, dynamic>{
      'userPublicKey': instance.userPublicKey,
      'messageAddress': instance.messageAddress,
      'mint': instance.mint,
      'targetAddress': instance.targetAddress,
      'amount': instance.amount,
    };

SolScanTokenAccount _$SolScanTokenAccountFromJson(Map<String, dynamic> json) =>
    SolScanTokenAccount(
      tokenAddress: json['tokenAddress'] as String?,
      tokenAccount: json['tokenAccount'] as String?,
      tokenName: json['tokenName'] as String?,
      tokenIcon: json['tokenIcon'] as String?,
      tokenSymbol: json['tokenSymbol'] as String?,
      rentEpoch: json['rentEpoch'] as int?,
      lamports: json['lamports'] as int?,
      tokenAmount: json['tokenAmount'] == null
          ? null
          : SolScanTokenAmount.fromJson(
              json['tokenAmount'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SolScanTokenAccountToJson(
        SolScanTokenAccount instance) =>
    <String, dynamic>{
      'tokenAddress': instance.tokenAddress,
      'tokenAccount': instance.tokenAccount,
      'tokenName': instance.tokenName,
      'tokenIcon': instance.tokenIcon,
      'tokenSymbol': instance.tokenSymbol,
      'rentEpoch': instance.rentEpoch,
      'lamports': instance.lamports,
      'tokenAmount': instance.tokenAmount,
    };

SolScanTokenAmount _$SolScanTokenAmountFromJson(Map<String, dynamic> json) =>
    SolScanTokenAmount(
      amount: json['amount'] as String?,
      uiAmountString: json['uiAmountString'] as String?,
      decimals: json['decimals'] as int?,
      uiAmount: json['uiAmount'] as num?,
    );

Map<String, dynamic> _$SolScanTokenAmountToJson(SolScanTokenAmount instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'uiAmountString': instance.uiAmountString,
      'decimals': instance.decimals,
      'uiAmount': instance.uiAmount,
    };

SwapDTO _$SwapDTOFromJson(Map<String, dynamic> json) => SwapDTO(
      route: JupRoute.fromJson(json['route'] as Map<String, dynamic>),
      userPublicKey: json['userPublicKey'] as String,
      wrapUnwrapSOL: json['wrapUnwrapSOL'] as bool?,
      feeAccount: json['feeAccount'] as String?,
      tokenLedger: json['tokenLedger'] as String?,
      destinationWallet: json['destinationWallet'] as String?,
    );

Map<String, dynamic> _$SwapDTOToJson(SwapDTO instance) => <String, dynamic>{
      'route': instance.route,
      'userPublicKey': instance.userPublicKey,
      'wrapUnwrapSOL': instance.wrapUnwrapSOL,
      'feeAccount': instance.feeAccount,
      'tokenLedger': instance.tokenLedger,
      'destinationWallet': instance.destinationWallet,
    };

JupSwapTransactions _$JupSwapTransactionsFromJson(Map<String, dynamic> json) =>
    JupSwapTransactions(
      setupTransaction: json['setupTransaction'] as String?,
      swapTransaction: json['swapTransaction'] as String,
      cleanupTransaction: json['cleanupTransaction'] as String?,
    );

Map<String, dynamic> _$JupSwapTransactionsToJson(
        JupSwapTransactions instance) =>
    <String, dynamic>{
      'setupTransaction': instance.setupTransaction,
      'swapTransaction': instance.swapTransaction,
      'cleanupTransaction': instance.cleanupTransaction,
    };

JupResponse<T> _$JupResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    JupResponse<T>(
      timeTaken: json['timeTaken'] as num?,
      contextSlot: json['contextSlot'] as String?,
      data: _$nullableGenericFromJson(json['data'], fromJsonT),
    );

Map<String, dynamic> _$JupResponseToJson<T>(
  JupResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'timeTaken': instance.timeTaken,
      'contextSlot': instance.contextSlot,
      'data': _$nullableGenericToJson(instance.data, toJsonT),
    };

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) =>
    input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) =>
    input == null ? null : toJson(input);

JupRoute _$JupRouteFromJson(Map<String, dynamic> json) => JupRoute(
      inAmount: json['inAmount'] as int,
      outAmount: json['outAmount'] as int,
      priceImpactPct: (json['priceImpactPct'] as num?)?.toDouble(),
      marketInfos: (json['marketInfos'] as List<dynamic>)
          .map((e) => JupMarketInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      outAmountWithSlippage: json['outAmountWithSlippage'] as int,
      otherAmountThreshold: json['otherAmountThreshold'] as int,
      swapMode: json['swapMode'] as String,
      fees: (json['fees'] as List<dynamic>?)
          ?.map((e) => JupRouteFee.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$JupRouteToJson(JupRoute instance) => <String, dynamic>{
      'inAmount': instance.inAmount,
      'outAmount': instance.outAmount,
      'priceImpactPct': instance.priceImpactPct,
      'marketInfos': instance.marketInfos,
      'outAmountWithSlippage': instance.outAmountWithSlippage,
      'otherAmountThreshold': instance.otherAmountThreshold,
      'swapMode': instance.swapMode,
      'fees': instance.fees,
    };

JupMarketInfo _$JupMarketInfoFromJson(Map<String, dynamic> json) =>
    JupMarketInfo(
      id: json['id'] as String,
      label: json['label'] as String,
      inputMint: json['inputMint'] as String,
      outputMint: json['outputMint'] as String,
      notEnoughLiquidity: json['notEnoughLiquidity'] as bool,
      inAmount: json['inAmount'] as int,
      outAmount: json['outAmount'] as int,
      priceImpactPct: json['priceImpactPct'] as num?,
      lpFee: JupFee.fromJson(json['lpFee'] as Map<String, dynamic>),
      platformFee: JupFee.fromJson(json['platformFee'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$JupMarketInfoToJson(JupMarketInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'label': instance.label,
      'inputMint': instance.inputMint,
      'outputMint': instance.outputMint,
      'notEnoughLiquidity': instance.notEnoughLiquidity,
      'inAmount': instance.inAmount,
      'outAmount': instance.outAmount,
      'priceImpactPct': instance.priceImpactPct,
      'lpFee': instance.lpFee,
      'platformFee': instance.platformFee,
    };

JupFee _$JupFeeFromJson(Map<String, dynamic> json) => JupFee(
      amount: json['amount'] as num,
      mint: json['mint'] as String,
      pct: json['pct'] as num?,
    );

Map<String, dynamic> _$JupFeeToJson(JupFee instance) => <String, dynamic>{
      'amount': instance.amount,
      'mint': instance.mint,
      'pct': instance.pct,
    };

JupRouteFee _$JupRouteFeeFromJson(Map<String, dynamic> json) => JupRouteFee(
      signatureFee: json['signatureFee'] as num,
      openOrdersDeposits: (json['openOrdersDeposits'] as List<dynamic>)
          .map((e) => e as num)
          .toList(),
      ataDeposits:
          (json['ataDeposits'] as List<dynamic>).map((e) => e as num).toList(),
      totalFeeAndDeposits: json['totalFeeAndDeposits'] as num,
      minimumSOLForTransaction: json['minimumSOLForTransaction'] as num,
    );

Map<String, dynamic> _$JupRouteFeeToJson(JupRouteFee instance) =>
    <String, dynamic>{
      'signatureFee': instance.signatureFee,
      'openOrdersDeposits': instance.openOrdersDeposits,
      'ataDeposits': instance.ataDeposits,
      'totalFeeAndDeposits': instance.totalFeeAndDeposits,
      'minimumSOLForTransaction': instance.minimumSOLForTransaction,
    };

JupGetPriceData _$JupGetPriceDataFromJson(Map<String, dynamic> json) =>
    JupGetPriceData(
      id: json['id'] as String?,
      mintSymbol: json['mintSymbol'] as String?,
      vsToken: json['vsToken'] as String?,
      vsTokenSymbol: json['vsTokenSymbol'] as String?,
      price: json['price'] as num?,
    );

Map<String, dynamic> _$JupGetPriceDataToJson(JupGetPriceData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'mintSymbol': instance.mintSymbol,
      'vsToken': instance.vsToken,
      'vsTokenSymbol': instance.vsTokenSymbol,
      'price': instance.price,
    };

NFTScanResponse<T> _$NFTScanResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) =>
    NFTScanResponse<T>(
      msg: json['msg'] as String?,
      code: json['code'] as int?,
      data: _$nullableGenericFromJson(json['data'], fromJsonT),
    );

Map<String, dynamic> _$NFTScanResponseToJson<T>(
  NFTScanResponse<T> instance,
  Object? Function(T value) toJsonT,
) =>
    <String, dynamic>{
      'msg': instance.msg,
      'code': instance.code,
      'data': _$nullableGenericToJson(instance.data, toJsonT),
    };

GetAllAssetsDataElement _$GetAllAssetsDataElementFromJson(
        Map<String, dynamic> json) =>
    GetAllAssetsDataElement(
      ownsTotal: json['owns_total'] as int?,
      logoUrl: json['logo_url'] as String?,
      itemsTotal: json['items_total'] as int?,
      description: json['description'] as String?,
      collection: json['collection'] as String?,
      assets: (json['assets'] as List<dynamic>?)
          ?.map((e) =>
              GetAllAssetsDataElementAsset.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GetAllAssetsDataElementToJson(
        GetAllAssetsDataElement instance) =>
    <String, dynamic>{
      'owns_total': instance.ownsTotal,
      'logo_url': instance.logoUrl,
      'items_total': instance.itemsTotal,
      'description': instance.description,
      'collection': instance.collection,
      'assets': instance.assets,
    };

GetAllAssetsDataElementAsset _$GetAllAssetsDataElementAssetFromJson(
        Map<String, dynamic> json) =>
    GetAllAssetsDataElementAsset(
      blockNumber: json['block_number'] as int?,
      collection: json['collection'] as String?,
      contentType: json['content_type'] as String?,
      contentUri: json['content_uri'] as String?,
      externalLink: json['external_link'] as String?,
      imageUri: json['image_uri'] as String?,
      interactProgram: json['interact_program'] as String?,
      latestTradePrice: json['latest_trade_price'] as num?,
      latestTradeTimestamp: json['latest_trade_timestamp'] as int?,
      latestTradeTransactionHash:
          json['latest_trade_transaction_hash'] as String?,
      metadataJson: json['metadata_json'] as String?,
      mintPrice: json['mint_price'] as num?,
      mintTimestamp: json['mint_timestamp'] as int?,
      mintTransactionHash: json['mint_transaction_hash'] as String?,
      minter: json['minter'] as String?,
      name: json['name'] as String?,
      owner: json['owner'] as String?,
      tokenAddress: json['token_address'] as String?,
      tokenUri: json['token_uri'] as String?,
    );

Map<String, dynamic> _$GetAllAssetsDataElementAssetToJson(
        GetAllAssetsDataElementAsset instance) =>
    <String, dynamic>{
      'block_number': instance.blockNumber,
      'collection': instance.collection,
      'content_type': instance.contentType,
      'content_uri': instance.contentUri,
      'external_link': instance.externalLink,
      'image_uri': instance.imageUri,
      'interact_program': instance.interactProgram,
      'latest_trade_price': instance.latestTradePrice,
      'latest_trade_timestamp': instance.latestTradeTimestamp,
      'latest_trade_transaction_hash': instance.latestTradeTransactionHash,
      'metadata_json': instance.metadataJson,
      'mint_price': instance.mintPrice,
      'mint_timestamp': instance.mintTimestamp,
      'mint_transaction_hash': instance.mintTransactionHash,
      'minter': instance.minter,
      'name': instance.name,
      'owner': instance.owner,
      'token_address': instance.tokenAddress,
      'token_uri': instance.tokenUri,
    };

NFTTransactionsData _$NFTTransactionsDataFromJson(Map<String, dynamic> json) =>
    NFTTransactionsData(
      total: json['nft_tx_total'] as int?,
      records: (json['nft_tx_record'] as List<dynamic>?)
          ?.map((e) => NFTTransactionRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$NFTTransactionsDataToJson(
        NFTTransactionsData instance) =>
    <String, dynamic>{
      'nft_tx_total': instance.total,
      'nft_tx_record': instance.records,
    };

NFTTransactionRecord _$NFTTransactionRecordFromJson(
        Map<String, dynamic> json) =>
    NFTTransactionRecord(
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

Map<String, dynamic> _$NFTTransactionRecordToJson(
        NFTTransactionRecord instance) =>
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

class _ApiClient implements ApiClient {
  _ApiClient(
    this._dio, {
    this.baseUrl,
  });

  final Dio _dio;

  String? baseUrl;

  @override
  Future<List<SolScanTokenAccount>> getTokenAccounts({required account}) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{r'account': account};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio
        .fetch<List<dynamic>>(_setStreamType<List<SolScanTokenAccount>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              'https://public-api.solscan.io/account/tokens',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    var value = _result.data!
        .map((dynamic i) =>
            SolScanTokenAccount.fromJson(i as Map<String, dynamic>))
        .toList();
    return value;
  }

  @override
  Future<NFTScanResponse<NFTTransactionsData>> getTransactionByUserAddress({
    required userAddress,
    collection = '',
    transferType = 'all',
    pageIndex = 0,
    pageSize = 20,
  }) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'user_address': userAddress,
      r'collection': collection,
      r'transferType': transferType,
      r'pageIndex': pageIndex,
      r'pageSize': pageSize,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<NFTScanResponse<NFTTransactionsData>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              'https://solana.nftscan.com/nftscan/getTransactionByUserAddress',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = NFTScanResponse<NFTTransactionsData>.fromJson(
      _result.data!,
      (json) => NFTTransactionsData.fromJson(json as Map<String, dynamic>),
    );
    return value;
  }

  @override
  Future<NFTScanResponse<List<GetAllAssetsDataElement>>>
      getAllAssetsGroupByCollection({
    required accountAddress,
    required apiKey,
  }) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{r'X-API-KEY': apiKey};
    _headers.removeWhere((k, v) => v == null);
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<NFTScanResponse<List<GetAllAssetsDataElement>>>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              'https://solanaapi.nftscan.com/api/sol/account/own/all/${accountAddress}',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = NFTScanResponse<List<GetAllAssetsDataElement>>.fromJson(
      _result.data!,
      (json) => (json as List<dynamic>)
          .map<GetAllAssetsDataElement>((i) =>
              GetAllAssetsDataElement.fromJson(i as Map<String, dynamic>))
          .toList(),
    );
    return value;
  }

  @override
  Future<String> jupGetPrice({
    required id,
    vsToken,
    amount,
  }) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'id': id,
      r'vsToken': vsToken,
      r'amount': amount,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<String>(_setStreamType<String>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          'https://quote-api.jup.ag/v1/price',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data!;
    return value;
  }

  @override
  Future<String> jupGetQuote({
    required inputMint,
    required outputMint,
    required amount,
    swapMode,
    slippage,
    feeBps,
    onlyDirectRoutes,
    userPublicKey,
  }) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{
      r'inputMint': inputMint,
      r'outputMint': outputMint,
      r'amount': amount,
      r'swapMode': swapMode,
      r'slippage': slippage,
      r'feeBps': feeBps,
      r'onlyDirectRoutes': onlyDirectRoutes,
      r'userPublicKey': userPublicKey,
    };
    queryParameters.removeWhere((k, v) => v == null);
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    final _result = await _dio.fetch<String>(_setStreamType<String>(Options(
      method: 'GET',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          'https://quote-api.jup.ag/v1/quote',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data!;
    return value;
  }

  @override
  Future<JupSwapTransactions> jupPostSwap(dto) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(dto.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
        _setStreamType<JupSwapTransactions>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
            .compose(
              _dio.options,
              'https://quote-api.jup.ag/v1/swap',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = JupSwapTransactions.fromJson(_result.data!);
    return value;
  }

  @override
  Future<String> wormhole(dto) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(dto.toJson());
    final _result = await _dio.fetch<String>(_setStreamType<String>(Options(
      method: 'POST',
      headers: _headers,
      extra: _extra,
    )
        .compose(
          _dio.options,
          'https://wormhole.canoe.finance',
          queryParameters: queryParameters,
          data: _data,
        )
        .copyWith(baseUrl: baseUrl ?? _dio.options.baseUrl)));
    final value = _result.data!;
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
