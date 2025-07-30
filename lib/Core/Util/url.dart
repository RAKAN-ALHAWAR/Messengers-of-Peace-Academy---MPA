class UrlUtilX {
  /// Function to build headers
  static String buildQuery(
    String url, {
    String? start,
    String startKey = 'start',
    String? page,
    String pageKey = 'page',
    String? limit,
    String limitKey = 'limit',
    String? search,
    String searchKey = 'search',
    String? sort,
    String sortKey = 'sort',
    String? order,
    String orderKey = 'order',
    String? languageCode,
    String languageKey = 'Accept-Language',
    String? apiVersion,
    String apiVersionKey = 'API-Version',
    Map<String, dynamic>? filterParams = const {},
    Map<String, dynamic>? additionalQueryParams = const {},
    Map<String, dynamic>? pathParams = const {},
  }) {

    // Step 1: Replace path parameters in the URL
    url = replacePathParams(url, pathParams);

    // Step 2: Add query parameters
    final queryParams = <String, String>{};

    if (start != null && start.isNotEmpty) {
      queryParams[startKey] = start;
    }
    if (page != null && page.isNotEmpty) {
      queryParams[pageKey] = page;
    }
    if (limit != null && limit.isNotEmpty) {
      queryParams[limitKey] = limit;
    }
    if (search != null && search.isNotEmpty) {
      queryParams[searchKey] = search;
    }
    if (sort != null && sort.isNotEmpty) {
      queryParams[sortKey] = sort;
    }
    if (order != null && order.isNotEmpty) {
      queryParams[orderKey] = order;
    }
    if (languageCode != null && languageCode.isNotEmpty) {
      queryParams[languageKey] = languageCode;
    }
    if (apiVersion != null && apiVersion.isNotEmpty) {
      queryParams[apiVersionKey] = apiVersion;
    }

    // Adding additional filter parameters
    filterParams?.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        if(value is List){
          queryParams['$key[]'] = value.map((item) => item.toString()).join(',');
        }else{
        queryParams[key] = value.toString();
        }
      }
    });

    // Adding additional query parameters
    additionalQueryParams?.forEach((key, value) {
      if (value != null && value.toString().isNotEmpty) {
        queryParams[key] = value.toString();
      }
    });


    // Construct the query string
    if (queryParams.isNotEmpty) {
      final existingParams = getQueryParameters(url);

      final newQueryParams = queryParams.entries
          .where((entry) => !existingParams.containsKey(entry.key));

      if (newQueryParams.isNotEmpty) {
        final queryString = newQueryParams
            .map((entry) => '${entry.key}=${entry.value}')
            .join('&');
        url += (url.contains('?') ? '&' : '?') + queryString;
      }
    }
    return url;
  }

  /// Function to replace path parameters in the URL
  static String replacePathParams(String url, Map<String, dynamic>? pathParams) {
    pathParams?.forEach((key, value) {
      if (url.contains('{$key}')) {
        url = url.replaceAll('{$key}', value.toString());
      }
    });
    return url;
  }

  /// Function to get Query Parameters from url
  static Map<String, String> getQueryParameters(String url) {
    final queryStart = url.indexOf('?');
    if (queryStart == -1) {
      return {};
    }
    final queryString = url.substring(queryStart + 1);
    final queryParams = queryString.split('&');
    final paramsMap = <String, String>{};
    for (var param in queryParams) {
      final keyValue = param.split('=');
      if (keyValue.length == 2) {
        final key = Uri.decodeComponent(keyValue[0]);
        final value = Uri.decodeComponent(keyValue[1]);
        paramsMap[key] = value;
      }
    }

    return paramsMap;
  }

  /// Function to check URL validity
  static bool validate(String url) {
    if (url.isNotEmpty &&
        Uri.parse(url).isAbsolute &&
        Uri.parse(url).hasAbsolutePath) {
      return true;
    } else {
      return false;
    }
  }

  /// Function to convert from String to URL
  static Uri parse(String url) {
    return Uri.parse(url);
  }
}
