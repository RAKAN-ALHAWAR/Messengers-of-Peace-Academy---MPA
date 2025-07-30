
import '../../Enum/transmission_method_status.dart';

/// A class to hold various parameters used for data source configuration.
///
/// This class encapsulates parameters related to data requests, including
/// timeout settings, pagination, search, sorting, order options, authentication,
/// language settings, HTTP headers, local settings, and error handling.
/// ---------------------------------------------------------------------
/// هذا الكلاس يضم مجموعة من المعلمات المستخدمة لتكوين مصدر البيانات.
///
/// يشمل هذا الكلاس معلمات تتعلق بطلبات البيانات، بما في ذلك
/// إعدادات الوقت المستغرق، التصفح، البحث، الترتيب، خيارات الطلب، التوثيق،
/// إعدادات اللغة، رؤوس HTTP، الإعدادات المحلية، ومعالجة الأخطاء.
class DataSourceParamX {
  /// The body of the request.
  ///
  /// جسم الطلب.
  final Map<String, dynamic>? requestBody;

  /// Fallback response to be used if the primary response fails.
  ///
  /// استجابة بديلة تستخدم إذا فشلت الاستجابة الرئيسية.
  final dynamic fallbackResponse;

  /// The duration to wait before a request times out.
  ///
  /// المدة التي يجب الانتظار قبل أن ينتهي الطلب بسبب تجاوز الوقت.
  final Duration? requestTimeout;

  /// The maximum number of retries for a failed request.
  ///
  /// الحد الأقصى لعدد المحاولات لإعادة إرسال الطلب في حالة فشله.
  final int? maxRetries;

  /// The starting point for pagination.
  ///
  /// نقطة البداية للبيانات.
  final int? start;

  /// The key for pagination start.
  ///
  /// المفتاح لنقطة بداية البيانات.
  final String? startKey;

  /// The page number for pagination.
  ///
  /// رقم الصفحة البيانات.
  final int? page;

  /// The key for pagination page.
  ///
  /// المفتاح لرقم الصفحةالبيانات.
  final String? pageKey;

  /// The number of items per page.
  ///
  /// عدد العناصر لكل صفحة.
  final int? limit;

  /// The key for pagination limit.
  ///
  /// المفتاح لعدد العناصر لكل صفحة.
  final String? limitKey;

  /// The method for handling pagination transmission.
  ///
  /// الطريقة المستخدمة لمعالجة نقل التصفح.
  final TransmissionMethodStatusX? paginationMethod;

  /// The query string used for searching.
  ///
  /// سلسلة الاستعلام المستخدمة للبحث.
  final String? search;

  /// The key for search query.
  ///
  /// المفتاح لاستعلام البحث.
  final String? searchKey;

  /// The method for handling search transmission.
  ///
  /// الطريقة المستخدمة لمعالجة نقل البحث.
  final TransmissionMethodStatusX? searchMethod;

  /// The field to sort by.
  ///
  /// الحقل الذي يتم الترتيب حسبه.
  final String? sort;

  /// The key for sorting field.
  ///
  /// المفتاح لحقل الترتيب.
  final String? sortKey;

  /// The method for handling sorting transmission.
  ///
  /// الطريقة المستخدمة لمعالجة نقل الترتيب.
  final TransmissionMethodStatusX? sortMethod;

  /// The order direction (e.g., ascending or descending).
  ///
  /// اتجاه الترتيب (مثل تصاعدي أو تنازلي).
  final String? order;

  /// The key for order field.
  ///
  /// المفتاح لحقل الترتيب.
  final String? orderKey;

  /// The method for handling order transmission.
  ///
  /// الطريقة المستخدمة لمعالجة نقل الترتيب.
  final TransmissionMethodStatusX? orderMethod;

  /// Additional parameters used for filtering the data.
  ///
  /// معلمات إضافية تستخدم لتصفية البيانات.
  final Map<String, dynamic>? filterParams;

  /// The method for handling filter transmission.
  ///
  /// الطريقة المستخدمة لمعالجة نقل التصفية.
  final TransmissionMethodStatusX? filterMethod;

  /// Additional query parameters for data requests.
  ///
  /// معلمات استعلام إضافية لطلبات البيانات.
  final Map<String, dynamic>? additionalQueryParams;

  /// Path parameters used to replace dynamic parts of the URL.
  ///
  /// معلمات المسار تستخدم لاستبدال الأجزاء الديناميكية في الرابط.
  late final Map<String, dynamic>? pathParams;

  /// The method for handling query transmission.
  ///
  /// الطريقة المستخدمة لمعالجة نقل الاستعلام.
  final TransmissionMethodStatusX? queryMethod;

  /// The token used for authentication.
  ///
  /// الرمز المستخدم للتوثيق.
  final String? authToken;

  /// The type of authentication (e.g., Bearer).
  ///
  /// نوع التوثيق (مثل: Bearer).
  final String? authType;

  /// The key for authentication type.
  ///
  /// المفتاح لنوع التوثيق.
  final String? authTypeKey;

  /// The method for handling authentication transmission.
  ///
  /// الطريقة المستخدمة لمعالجة نقل التوثيق.
  final TransmissionMethodStatusX? authMethod;

  /// The language code for the request.
  ///
  /// رمز اللغة للطلب.
  final String? languageCode;

  /// The key for language code.
  ///
  /// المفتاح لرمز اللغة.
  final String? languageKey;

  /// The method for handling language transmission.
  ///
  /// الطريقة المستخدمة لمعالجة نقل اللغة.
  final TransmissionMethodStatusX? languageMethod;

  /// The API version to use.
  ///
  /// إصدار واجهة برمجة التطبيقات (API) المراد استخدامه.
  final String? apiVersion;

  /// The key for API version.
  ///
  /// المفتاح لإصدار API.
  final String? apiVersionKey;

  /// The method for handling version transmission.
  ///
  /// الطريقة المستخدمة لمعالجة نقل الإصدار.
  final TransmissionMethodStatusX? apiVersionMethod;

  /// The Content-Type header for the request.
  ///
  /// رأس Content-Type للطلب.
  final String? contentTypeHeader;

  /// The Accept header for the request.
  ///
  /// رأس Accept للطلب.
  final String? acceptHeader;

  /// The Accept-Encoding header for the request.
  ///
  /// رأس Accept-Encoding للطلب.
  final String? acceptEncodingHeader;

  /// The User-Agent header for the request.
  ///
  /// رأس User-Agent للطلب.
  final String? userAgentHeader;

  /// The Host header for the request.
  ///
  /// رأس Host للطلب.
  final String? hostHeader;

  /// The Origin header for the request.
  ///
  /// رأس Origin للطلب.
  final String? originHeader;

  /// The Cookie header for the request.
  ///
  /// رأس Cookie للطلب.
  final String? cookieHeader;

  /// Additional HTTP headers for the request.
  ///
  /// رؤوس HTTP إضافية للطلب.
  final Map<String, String>? additionalHttpHeaders;

  /// Custom HTTP headers for the request.
  ///
  /// رؤوس HTTP مخصصة للطلب.
  final Map<String, String>? customHttpHeaders;

  /// Whether to use local caching.
  ///
  /// ما إذا كان يجب استخدام التخزين المؤقت المحلي.
  late final bool useLocalCache;

  /// Key to store and retrieve local cache
  ///
  /// مفتاح تخزين واسترجاع البيانات المؤقتة المحلية
  late final String? localCacheKey;

  /// The maximum age of local cache.
  ///
  /// أقصى عمر للتخزين المؤقت المحلي.
  final Duration? localCacheMaxAge;

  /// Whether to ignore all errors.
  ///
  /// ما إذا كان يجب تجاهل جميع الأخطاء.
  late final bool ignoreError;

  /// Whether to ignore unauthorized errors.
  ///
  /// ما إذا كان يجب تجاهل الأخطاء غير المصرح بها.
  late final bool ignoreUnauthorized;


  /// Constructor for [DataSourceParamX].
  ///
  /// Constructor لكلاس [DataSourceParamX].
  DataSourceParamX({
    this.requestBody,
    this.fallbackResponse,
    this.requestTimeout,
    this.maxRetries,
    this.start,
    this.startKey,
    this.page,
    this.pageKey,
    this.limit,
    this.limitKey,
    this.paginationMethod,
    this.search,
    this.searchKey,
    this.searchMethod,
    this.sort,
    this.sortKey,
    this.sortMethod,
    this.order,
    this.orderKey,
    this.orderMethod,
    this.filterParams,
    this.filterMethod,
    this.additionalQueryParams,
    this.pathParams,
    this.queryMethod,
    this.authToken,
    this.authType,
    this.authTypeKey,
    this.authMethod,
    this.languageCode,
    this.languageKey,
    this.languageMethod,
    this.apiVersion,
    this.apiVersionKey,
    this.apiVersionMethod,
    this.contentTypeHeader,
    this.acceptHeader,
    this.acceptEncodingHeader,
    this.userAgentHeader,
    this.hostHeader,
    this.originHeader,
    this.cookieHeader,
    this.additionalHttpHeaders,
    this.customHttpHeaders,
    this.localCacheKey,
    this.localCacheMaxAge,
    bool ignoreError = false,
    bool ignoreUnauthorized = false,
  }) {
    useLocalCache = localCacheKey != null;
    this.ignoreError = fallbackResponse != null ? true : ignoreError;
    this.ignoreUnauthorized = this.ignoreError? true : ignoreUnauthorized;
  }

  /// Creates a copy of this [DataSourceParamX] object with the given fields replaced by new values.
  ///
  /// ينشئ نسخة من كائن [DataSourceParamX] هذا مع استبدال الحقول المحددة بالقيم الجديدة.
  DataSourceParamX copyWith({
    Map<String,dynamic>? requestBody,
    dynamic fallbackResponse,
    Duration? requestTimeout,
    int? maxRetries,
    int? start,
    String? startKey,
    int? page,
    String? pageKey,
    int? limit,
    String? limitKey,
    TransmissionMethodStatusX? paginationMethod,
    String? search,
    String? searchKey,
    TransmissionMethodStatusX? searchMethod,
    String? sort,
    String? sortKey,
    TransmissionMethodStatusX? sortMethod,
    String? order,
    String? orderKey,
    TransmissionMethodStatusX? orderMethod,
    Map<String, dynamic>? filterParams,
    TransmissionMethodStatusX? filterMethod,
    Map<String, dynamic>? additionalQueryParams,
    Map<String, dynamic>? pathParams,
    TransmissionMethodStatusX? queryMethod,
    String? authToken,
    String? authType,
    String? authTypeKey,
    TransmissionMethodStatusX? authMethod,
    String? languageCode,
    String? languageKey,
    TransmissionMethodStatusX? languageMethod,
    String? apiVersion,
    String? apiVersionKey,
    TransmissionMethodStatusX? apiVersionMethod,
    String? contentTypeHeader,
    String? acceptHeader,
    String? acceptEncodingHeader,
    String? userAgentHeader,
    String? hostHeader,
    String? originHeader,
    String? cookieHeader,
    Map<String, String>? additionalHttpHeaders,
    Map<String, String>? customHttpHeaders,
    String? localCacheKey,
    Duration? localCacheMaxAge,
    bool? ignoreError,
    bool? ignoreUnauthorized,
  }) {
    return DataSourceParamX(
      requestBody: requestBody ?? this.requestBody,
      fallbackResponse: fallbackResponse ?? this.fallbackResponse,
      requestTimeout: requestTimeout ?? this.requestTimeout,
      maxRetries: maxRetries ?? this.maxRetries,
      start: start ?? this.start,
      startKey: startKey ?? this.startKey,
      page: page ?? this.page,
      pageKey: pageKey ?? this.pageKey,
      limit: limit ?? this.limit,
      limitKey: limitKey ?? this.limitKey,
      paginationMethod: paginationMethod ?? this.paginationMethod,
      search: search ?? this.search,
      searchKey: searchKey ?? this.searchKey,
      searchMethod: searchMethod ?? this.searchMethod,
      sort: sort ?? this.sort,
      sortKey: sortKey ?? this.sortKey,
      sortMethod: sortMethod ?? this.sortMethod,
      order: order ?? this.order,
      orderKey: orderKey ?? this.orderKey,
      orderMethod: orderMethod ?? this.orderMethod,
      filterParams: filterParams ?? this.filterParams,
      filterMethod: filterMethod ?? this.filterMethod,
      additionalQueryParams:
          additionalQueryParams ?? this.additionalQueryParams,
      pathParams:
      pathParams ?? this.pathParams,
      queryMethod: queryMethod ?? this.queryMethod,
      authToken: authToken ?? this.authToken,
      authType: authType ?? this.authType,
      authTypeKey: authTypeKey ?? this.authTypeKey,
      authMethod: authMethod ?? this.authMethod,
      languageCode: languageCode ?? this.languageCode,
      languageKey: languageKey ?? this.languageKey,
      languageMethod: languageMethod ?? this.languageMethod,
      apiVersion: apiVersion ?? this.apiVersion,
      apiVersionKey: apiVersionKey ?? this.apiVersionKey,
      apiVersionMethod: apiVersionMethod ?? this.apiVersionMethod,
      contentTypeHeader: contentTypeHeader ?? this.contentTypeHeader,
      acceptHeader: acceptHeader ?? this.acceptHeader,
      acceptEncodingHeader: acceptEncodingHeader ?? this.acceptEncodingHeader,
      userAgentHeader: userAgentHeader ?? this.userAgentHeader,
      hostHeader: hostHeader ?? this.hostHeader,
      originHeader: originHeader ?? this.originHeader,
      cookieHeader: cookieHeader ?? this.cookieHeader,
      additionalHttpHeaders:
          additionalHttpHeaders ?? this.additionalHttpHeaders,
      customHttpHeaders: customHttpHeaders ?? this.customHttpHeaders,
      localCacheKey: localCacheKey ?? this.localCacheKey,
      localCacheMaxAge: localCacheMaxAge ?? this.localCacheMaxAge,
      ignoreError: ignoreError ?? this.ignoreError,
      ignoreUnauthorized: ignoreUnauthorized ?? this.ignoreUnauthorized,
    );
  }

  /// Returns a string representation of this [DataSourceParamX] object.
  ///
  /// يعيد تمثيل نصي لكائن [DataSourceParamX] هذا.
  @override
  String toString() {
    return 'DataSourceParameters('
        'requestBody: $requestBody, '
        'fallbackResponse: $fallbackResponse, '
        'requestTimeout: $requestTimeout, '
        'maxRetryCount: $maxRetries, '
        'start: $start, '
        'startKey: $startKey, '
        'page: $page, '
        'pageKey: $pageKey, '
        'limit: $limit, '
        'limitKey: $limitKey, '
        'paginationMethod: $paginationMethod, '
        'search: $search, '
        'searchKey: $searchKey, '
        'searchMethod: $searchMethod, '
        'sort: $sort, '
        'sortKey: $sortKey, '
        'sortMethod: $sortMethod, '
        'order: $order, '
        'orderKey: $orderKey, '
        'orderMethod: $orderMethod, '
        'additionalFilterParameters: $filterParams, '
        'filterMethod: $filterMethod, '
        'additionalQueryParameters: $additionalQueryParams, '
        'queryMethod: $queryMethod, '
        'authToken: $authToken, '
        'authType: $authType, '
        'authTypeKey: $authTypeKey, '
        'authMethod: $authMethod, '
        'languageCode: $languageCode, '
        'languageKey: $languageKey, '
        'languageMethod: $languageMethod, '
        'apiVersion: $apiVersion, '
        'versionKey: $apiVersionKey, '
        'versionMethod: $apiVersionMethod, '
        'contentTypeHeader: $contentTypeHeader, '
        'acceptHeader: $acceptHeader, '
        'acceptEncodingHeader: $acceptEncodingHeader, '
        'userAgentHeader: $userAgentHeader, '
        'hostHeader: $hostHeader, '
        'originHeader: $originHeader, '
        'cookieHeader: $cookieHeader, '
        'additionalHttpHeaders: $additionalHttpHeaders, '
        'customHttpHeaders: $customHttpHeaders, '
        'useLocalCache: $useLocalCache, '
        'localCacheKey: $localCacheKey, '
        'localCacheMaxAge: $localCacheMaxAge, '
        'shouldIgnoreErrors: $ignoreError, '
        'shouldIgnoreUnauthorizedErrors: $ignoreUnauthorized'
        ')';
  }
}
