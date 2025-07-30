part of '../remote_data.dart';

Map<String, String> _headersBuild(DataSourceParamX param) {
  Map<String, String> headers = HttpHeaderUtilX.build(
    authToken: param.authToken,
    authType: param.authType ?? RemoteConfigX.authType,
    authTypeKey: param.authTypeKey ?? RemoteKeyX.authType,
    languageCode:
        (param.languageMethod ?? RemoteConfigX.languageMethod) ==
                TransmissionMethodStatusX.headers
            ? param.languageCode ?? RemoteConfigX.languageCode
            : null,
    languageKey: param.languageKey ?? RemoteKeyX.language,
    contentType: param.contentTypeHeader ?? RemoteConfigX.contentType,
    accept: param.acceptHeader ?? RemoteConfigX.accept,
    additionalHeaders: param.additionalHttpHeaders,
    customHeaders: param.customHttpHeaders,
  );
  return headers;
}

String _urlQueryBuild(String url, DataSourceParamX param) {
  String result = UrlUtilX.buildQuery(
    url,
    start: param.start?.toString(),
    startKey: param.startKey ?? RemoteKeyX.start,
    page: param.page?.toString(),
    pageKey: param.pageKey ?? RemoteKeyX.page,
    limit: param.limit?.toString(),
    limitKey: param.limitKey ?? RemoteKeyX.limit,
    search: param.search,
    searchKey: param.searchKey ?? RemoteKeyX.search,
    sort: param.sort,
    sortKey: param.sortKey ?? RemoteKeyX.sort,
    order: param.order,
    orderKey: param.orderKey ?? RemoteKeyX.order,
    languageCode:
        (param.languageMethod ?? RemoteConfigX.languageMethod) ==
                TransmissionMethodStatusX.queryParams
            ? param.languageCode
            : null,
    languageKey: param.languageKey ?? RemoteKeyX.language,
    apiVersion:
        (param.apiVersionMethod ?? RemoteConfigX.apiVersionMethod) ==
                TransmissionMethodStatusX.queryParams
            ? param.apiVersion ?? RemoteConfigX.version
            : null,
    apiVersionKey: param.apiVersionKey ?? RemoteKeyX.apiVersion,
    filterParams: param.filterParams,
    additionalQueryParams: param.additionalQueryParams,
    pathParams: param.pathParams,
  );
  return result;
}
