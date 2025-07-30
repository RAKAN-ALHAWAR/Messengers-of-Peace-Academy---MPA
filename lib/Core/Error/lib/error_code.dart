part of '../error.dart';

class ErrorCodesX {
  //----------------------------------------------------------------------------
  // 1xxx: General - Created to deal with common bugs
  //----------------------------------------------------------------------------

  /// Unknown or unexpected error occurred.
  ///
  /// حدث خطأ غير معروف أو غير متوقع.
  static const int unexpected = 1000;

  /// VPN presence required error.
  ///
  /// خطأ بسبب وجود VPN. لا يجب أن يكون هناك VPN.
  static const int vpnRequired = 1001;

  /// VPN must be enabled error.
  ///
  ///الدولة التي يأتي منها الطلب محظور، يجب تشغيل VPN.
  static const int vpnMustBeEnabled = 1002;

  /// No internet connection available error.
  ///
  /// خطأ عدم توفر اتصال بالإنترنت. أو أن الأتصال بالأنترنت ضعيف.
  static const int noInternetConnection = 1003;

  /// Invalid URL format.
  ///
  /// عنوان URL غير صالح.
  static const int invalidURL = 1004;

  /// Failed to convert JSON to model due to invalid format or data.
  ///
  /// فشل تحويل JSON إلى نموذج بسبب تنسيق أو بيانات غير صالحة.
  static const int jsonToModelConversionFailed = 1005;

  /// Failed to convert model to JSON due to invalid format or data.
  ///
  /// فشل تحويل النموذج إلى JSON بسبب تنسيق أو بيانات غير صالحة.
  static const int modelToJsonConversionFailed = 1006;

  /// Error occurred during JSON decoding.
  ///
  /// خطأ أثناء عملية فك شفرة JSON.
  static const int jsonDecoding = 1007;

  /// Error occurred during JSON encoding.
  ///
  /// خطأ أثناء عملية ترميز JSON.
  static const int jsonEncoding = 1008;

  /// Data type mismatch error.
  ///
  /// خطأ في عدم تطابق نوع البيانات.
  static const int dataTypeMismatch = 1010;

  static const int missingRequiredKeysInJson = 1011;

  //----------------------------------------------------------------------------
  // 3xx: Redirection - Further action must be taken in order to complete the request
  //----------------------------------------------------------------------------

  /// The request has more than one possible response. The user agent or user should choose one of them.
  /// There is no standardized way to choose one of the responses.
  ///
  /// الطلب يحتوي على أكثر من استجابة محتملة. يجب على وكيل المستخدم أو المستخدم اختيار واحدة منها.
  /// لا توجد طريقة موحدة لاختيار إحدى الاستجابات.
  static const int multipleChoices = 300;

  /// The URI of the requested resource has been changed permanently. The new URI is given in the response.
  /// The client should use the new URI for future requests.
  ///
  /// تم تغيير معرف URI للمورد المطلوب بشكل دائم. يتم تقديم معرف URI الجديد في الاستجابة.
  /// يجب على العميل استخدام معرف URI الجديد في الطلبات المستقبلية.
  static const int movedPermanently = 301;

  /// The URI of the requested resource has been changed temporarily. The new URI is given in the response.
  /// The client should use the original URI for future requests.
  ///
  /// تم تغيير معرف URI للمورد المطلوب بشكل مؤقت. يتم تقديم معرف URI الجديد في الاستجابة.
  /// يجب على العميل استخدام معرف URI الأصلي في الطلبات المستقبلية.
  static const int found = 302;

  /// The response to the request can be found under another URI using a GET method.
  /// When received in response to a POST request, the client should assume that the server has received the data and should use a separate GET request to retrieve the resource.
  ///
  /// يمكن العثور على الاستجابة للطلب تحت معرف URI آخر باستخدام طريقة GET.
  /// عند استلامها استجابةً لطلب POST، يجب على العميل افتراض أن الخادم قد استلم البيانات ويجب عليه استخدام طلب GET منفصل لاسترداد المورد.
  static const int seeOther = 303;

  /// The requested resource has not been modified since the last request.
  /// The server returns this response when the client has a cached copy of the resource and sends a conditional request to check if the resource has been modified.
  ///
  /// لم يتم تعديل المورد المطلوب منذ الطلب الأخير.
  /// يعيد الخادم هذه الاستجابة عندما يكون لدى العميل نسخة مخبأة من المورد ويرسل طلبًا شرطيًا للتحقق مما إذا كان المورد قد تم تعديله.
  static const int notModified = 304;

  /// The requested resource must be accessed through the proxy specified in the Location field.
  /// The proxy is an intermediary server between the client and the final server to fetch the requested resource.
  ///
  /// يجب الوصول إلى المورد المطلوب من خلال الوكيل المحدد في حقل Location.
  /// الوكيل هو خادم وسيط بين العميل والخادم النهائي لجلب المورد المطلوب.
  static const int useProxy = 305;

  /// The requested resource is temporarily located under a different URI, as specified in the Location header.
  /// The client should use the original URI for future requests. This status code is similar to 302 Found, but the client must follow the temporary URI specified.
  ///
  /// يقع المورد المطلوب مؤقتًا تحت معرف URI مختلف، كما هو محدد في رأس Location.
  /// يجب على العميل استخدام معرف URI الأصلي في الطلبات المستقبلية. هذا الرمز الحالة مشابه لـ 302 Found، ولكن يجب على العميل اتباع معرف URI المؤقت المحدد.
  static const int temporaryRedirect = 307;

  /// The requested resource has been permanently moved to a new URI, as specified in the Location header.
  /// The client should use the new URI for future requests. This status code is similar to 301 Moved Permanently, but it does not allow changing the request method from POST to GET.
  ///
  /// تم نقل المورد المطلوب بشكل دائم إلى معرف URI جديد، كما هو محدد في رأس Location.
  /// يجب على العميل استخدام معرف URI الجديد في الطلبات المستقبلية. هذا الرمز الحالة مشابه لـ 301 Moved Permanently، ولكنه لا يسمح بتغيير طريقة الطلب من POST إلى GET.
  static const int permanentRedirect = 308;

  //----------------------------------------------------------------------------
  // 4xx: Client Error - The request contains bad syntax or cannot be fulfilled
  //----------------------------------------------------------------------------

  /// The server could not understand the request due to invalid syntax.
  /// The client should not repeat the request without modifications.
  ///
  /// لم يتمكن الخادم من فهم الطلب بسبب صياغة غير صحيحة.
  /// يجب على العميل عدم تكرار الطلب بدون تعديلات.
  static const int badRequest = 400;

  /// The client must authenticate itself to get the requested response.
  /// Indicates that the request has not been applied because it lacks valid authentication credentials for the target resource.
  ///
  /// يجب على العميل مصادقة نفسه للحصول على الاستجابة المطلوبة.
  /// يشير إلى أن الطلب لم يتم تطبيقه لأنه يفتقر إلى بيانات اعتماد المصادقة الصالحة للمورد المستهدف.
  static const int unauthorized = 401;

  /// The client does not have access rights to the content; that is, it is unauthorized.
  /// Unlike 401 Unauthorized, the client's identity is known to the server.
  ///
  /// ليس لدى العميل حقوق الوصول إلى المحتوى؛ أي أنه غير مصرح له.
  /// على عكس 401 Unauthorized، هوية العميل معروفة للخادم.
  static const int forbidden = 403;

  /// The server can not find the requested resource.
  /// This response code means that the server could not find what was requested.
  ///
  /// لا يمكن للخادم العثور على المورد المطلوب.
  /// يعني رمز الاستجابة هذا أن الخادم لم يتمكن من العثور على ما تم طلبه.
  static const int notFound = 404;

  /// The request method is known by the server but is not supported by the target resource.
  /// For example, an API may not allow calling DELETE to remove a resource.
  ///
  /// طريقة الطلب معروفة من قبل الخادم ولكنها غير مدعومة من قبل المورد المستهدف.
  /// على سبيل المثال، قد لا تسمح API باستدعاء DELETE لإزالة المورد.
  static const int methodNotAllowed = 405;

  /// The requested resource is capable of generating only content not acceptable according to the Accept headers sent in the request.
  /// In other words, the client specified in its request the types of content it can accept (such as JSON or HTML), but the server cannot provide any of those types.
  ///
  /// يمكن للمورد المطلوب إنتاج محتوى غير مقبول فقط وفقًا للرؤوس "Accept" المرسلة في الطلب.
  /// بمعنى آخر، حدد العميل في طلبه أنواع المحتوى التي يمكنه قبولها (مثل JSON أو HTML)، ولكن الخادم لا يمكنه تقديم أي من هذه الأنواع.
  static const int notAcceptable = 406;

  /// This response is sent on an incomplete request by the server due to a request timeout.
  /// It indicates that the server did not receive a complete request message within the time it was prepared to wait.
  ///
  /// يتم إرسال هذه الاستجابة على طلب غير مكتمل من قبل الخادم بسبب انتهاء مهلة الطلب.
  /// يشير إلى أن الخادم لم يتلقَ رسالة طلب كاملة في الوقت الذي كان مستعدًا للانتظار فيه.
  static const int requestTimeout = 408;

  /// This response is sent when a request conflicts with the current state of the server.
  /// For example, a version conflict on an API that updates a resource can trigger a 409 status code.
  ///
  /// يتم إرسال هذه الاستجابة عندما يتعارض الطلب مع الحالة الحالية للخادم.
  /// على سبيل المثال، قد يؤدي تعارض الإصدار في API الذي يحدث المورد إلى تشغيل رمز الحالة 409.
  static const int conflict = 409;

  /// This response is sent when the requested content has been permanently deleted from the server, with no forwarding address.
  /// Clients should remove their caches and links to the resource.
  ///
  /// يتم إرسال هذه الاستجابة عندما يتم حذف المحتوى المطلوب بشكل دائم من الخادم، دون عنوان إعادة توجيه.
  /// يجب على العملاء إزالة ذاكرات التخزين المؤقت والروابط الخاصة بهم إلى المورد.
  static const int gone = 410;

  /// The server rejected the request because the Content-Length header field is not defined and the server requires it.
  /// This occurs when the server expects a Content-Length header in the request, but it is missing.
  ///
  /// رفض الخادم الطلب لأن حقل الرأس Content-Length غير معرف والخادم يتطلب ذلك.
  /// يحدث هذا عندما يتوقع الخادم وجود رأس Content-Length في الطلب، لكنه مفقود.
  static const int lengthRequired = 411;

  /// The client has indicated preconditions in its headers which the server does not meet.
  /// For example, a client might require that a resource be modified only if it has been modified since the last request it made, which the server cannot satisfy.
  ///
  /// أشار العميل إلى شروط مسبقة في رؤوسه لا يستوفيها الخادم.
  /// على سبيل المثال، قد يتطلب العميل تعديل المورد فقط إذا تم تعديله منذ آخر طلب قدمه، وهو ما لا يمكن للخادم تلبيته.
  static const int preconditionFailed = 412;

  /// The server is refusing to process a request because the request payload is larger than the server is willing or able to process.
  /// Indicates that the server will close the connection rather than continue processing.
  ///
  /// يرفض الخادم معالجة الطلب لأن الحمولة المرسلة في الطلب أكبر مما يمكن أن يعالجه الخادم.
  /// يشير إلى أن الخادم سيغلق الاتصال بدلاً من الاستمرار في المعالجة.
  static const int payloadTooLarge = 413;

  /// The URI requested by the client is longer than the server is willing to interpret.
  /// Indicates that the URI is too long to be processed by the server.
  ///
  /// معرف URI المطلوب من العميل أطول مما يرغب الخادم في تفسيره.
  /// يشير إلى أن معرف URI طويل جدًا بحيث لا يمكن معالجته بواسطة الخادم.
  static const int uriTooLong = 414;

  /// The media format of the requested data is not supported by the server, so the server is rejecting the request.
  /// Indicates that the server cannot process the request because the media format is not supported.
  ///
  /// تنسيق الوسائط للبيانات المطلوبة غير مدعوم من قبل الخادم، لذلك يرفض الخادم الطلب.
  /// يشير إلى أن الخادم لا يمكنه معالجة الطلب لأن تنسيق الوسائط غير مدعوم.
  static const int unsupportedMediaType = 415;

  /// The range specified by the Range header field in the request cannot be fulfilled.
  /// Indicates that the range specified is outside the size of the target URI's data.
  ///
  /// النطاق المحدد بواسطة حقل الرأس Range في الطلب لا يمكن تلبيته.
  /// يشير إلى أن النطاق المحدد خارج حجم بيانات معرف URI المستهدف.
  static const int rangeNotSatisfiable = 416;

  /// The expectation given in the request's Expect header could not be met by the server.
  /// Indicates that the server cannot meet the requirements specified in the Expect header of the request.
  ///
  /// التوقع المعطى في رأس الطلب Expect لا يمكن تلبيته من قبل الخادم.
  /// يشير إلى أن الخادم لا يمكنه تلبية المتطلبات المحددة في رأس Expect للطلب.
  static const int expectationFailed = 417;

  /// The server refuses the attempt to brew coffee with a teapot.
  /// This code was defined as an April Fools' joke and is not expected to be implemented by actual HTTP servers.
  ///
  /// يرفض الخادم محاولة تحضير القهوة باستخدام إبريق الشاي.
  /// تم تعريف هذا الرمز كمزحة في الأول من أبريل ولا يُتوقع تنفيذه من قبل خوادم HTTP الفعلية.
  static const int imATeapot = 418;

  /// The request was directed at a server that is not able to produce a response.
  /// Indicates that the server cannot produce a response because the requested resource is not configured to generate one for the HTTP method used.
  ///
  /// تم توجيه الطلب إلى خادم غير قادر على إنتاج استجابة.
  /// يشير إلى أن الخادم لا يمكنه إنتاج استجابة لأن المورد المطلوب غير مهيأ لإنشاء واحدة للطريقة HTTP المستخدمة.
  static const int misdirectedRequest = 421;

  /// The request was well-formed but was unable to be followed due to semantic errors.
  /// Indicates that the server understands the request but is refusing to process it because of semantic errors.
  ///
  /// كان الطلب مكونًا بشكل صحيح ولكنه لم يتمكن من المتابعة بسبب أخطاء دلالية.
  /// يشير إلى أن الخادم يفهم الطلب ولكنه يرفض معالجته بسبب أخطاء دلالية.
  static const int unprocessableEntity = 422;

  /// The resource that is being accessed is locked.
  /// Indicates that the resource is being accessed is currently locked and cannot be modified.
  ///
  /// المورد الذي يتم الوصول إليه مقفل.
  /// يشير إلى أن المورد الذي يتم الوصول إليه مقفل حاليًا ولا يمكن تعديله.
  static const int locked = 423;

  /// The request failed due to failure of a previous request.
  /// Indicates that the current request cannot be processed because a previous request failed, leading to a cascade of errors.
  ///
  /// فشل الطلب بسبب فشل طلب سابق.
  /// يشير إلى أن الطلب الحالي لا يمكن معالجته لأن طلبًا سابقًا فشل، مما أدى إلى سلسلة من الأخطاء.
  static const int failedDependency = 424;

  /// Indicates that the client should switch to a different protocol, such as TLS/1.0, given in the Upgrade header field.
  /// The server sends this response to indicate that it can fulfill the request only through a different protocol.
  ///
  /// يشير إلى أنه يجب على العميل التبديل إلى بروتوكول مختلف، مثل TLS/1.0، المحدد في حقل الرأس Upgrade.
  /// يرسل الخادم هذه الاستجابة للإشارة إلى أنه يمكنه تلبية الطلب فقط من خلال بروتوكول مختلف.
  static const int upgradeRequired = 426;

  /// The server refuses to perform the request using the current protocol but might be willing to do so after the client upgrades to a different protocol.
  /// This response code indicates that the server cannot perform the request using the current protocol, but it might do so after upgrading the client to a different protocol.
  ///
  /// يرفض الخادم تنفيذ الطلب باستخدام البروتوكول الحالي ولكنه قد يكون مستعدًا للقيام بذلك بعد ترقية العميل إلى بروتوكول مختلف.
  /// يشير رمز الاستجابة هذا إلى أن الخادم لا يمكنه تنفيذ الطلب باستخدام البروتوكول الحالي، ولكنه قد يقوم بذلك بعد ترقية العميل إلى بروتوكول مختلف.
  static const int preconditionRequired = 428;

  /// The user has sent too many requests in a given amount of time ("rate limiting").
  /// Indicates that the client has sent too many requests in a given amount of time and should slow down the request rate.
  ///
  /// أرسل المستخدم عددًا كبيرًا جدًا من الطلبات في فترة زمنية معينة (تحديد معدل).
  /// يشير إلى أن العميل أرسل عددًا كبيرًا جدًا من الطلبات في فترة زمنية معينة ويجب عليه تقليل معدل الطلبات.
  static const int tooManyRequests = 429;

  /// The server is unwilling to process the request because its header fields are too large.
  /// Indicates that the request header fields are too large for the server to process.
  ///
  /// الخادم غير مستعد لمعالجة الطلب لأن حقول رأسه كبيرة جدًا.
  /// يشير إلى أن حقول رأس الطلب كبيرة جدًا بحيث لا يمكن للخادم معالجتها.
  static const int requestHeaderFieldsTooLarge = 431;

  /// The user agent requested a resource that cannot legally be provided, such as a web page censored by a government.
  /// Indicates that the resource is unavailable for legal reasons.
  ///
  /// طلب وكيل المستخدم موردًا لا يمكن توفيره قانونيًا، مثل صفحة ويب تم فرض رقابة عليها من قبل الحكومة.
  /// يشير إلى أن المورد غير متاح لأسباب قانونية.
  static const int unavailableForLegalReasons = 451;

  //----------------------------------------------------------------------------
  // 5xx: Server Error - The server failed to fulfill an apparently valid request
  //----------------------------------------------------------------------------

  /// The server encountered an unexpected condition that prevented it from fulfilling the request.
  /// This indicates a general error message when no more specific message is suitable.
  ///
  /// واجه الخادم حالة غير متوقعة منعته من تنفيذ الطلب.
  /// يشير هذا إلى رسالة خطأ عامة عندما لا تكون هناك رسالة أكثر تحديدًا مناسبة.
  static const int internalServerError = 500;

  /// The server does not recognize the request method, or it lacks the ability to fulfill the request.
  /// Usually implies future availability (e.g., a new feature is not yet supported).
  ///
  /// لا يتعرف الخادم على طريقة الطلب، أو يفتقر إلى القدرة على تنفيذ الطلب.
  /// عادةً ما يشير إلى توفر مستقبلي (مثل ميزة جديدة لم يتم دعمها بعد).
  static const int notImplemented = 501;

  /// The server, while acting as a gateway or proxy, received an invalid response from the upstream server.
  /// Indicates issues with the server from which the gateway or proxy received the response.
  ///
  /// تلقى الخادم، أثناء العمل كبوابة أو وكيل، استجابة غير صالحة من الخادم العلوي.
  /// يشير إلى مشاكل مع الخادم الذي تلقت منه البوابة أو الوكيل الاستجابة.
  static const int badGateway = 502;

  /// The server is currently unable to handle the request due to temporary overloading or maintenance.
  /// This is usually a temporary state.
  ///
  /// الخادم غير قادر حاليًا على معالجة الطلب بسبب التحميل الزائد المؤقت أو الصيانة.
  /// عادةً ما تكون هذه حالة مؤقتة.
  static const int serviceUnavailable = 503;

  /// The server, while acting as a gateway or proxy, did not receive a timely response from the upstream server.
  /// Indicates that the upstream server is down or not functioning properly.
  ///
  /// لم يتلقَ الخادم، أثناء العمل كبوابة أو وكيل، استجابة في الوقت المناسب من الخادم العلوي.
  /// يشير إلى أن الخادم العلوي معطل أو لا يعمل بشكل صحيح.
  static const int gatewayTimeout = 504;

  /// The server does not support the HTTP protocol version that was used in the request.
  /// Indicates an issue with the protocol version compatibility.
  ///
  /// لا يدعم الخادم إصدار بروتوكول HTTP المستخدم في الطلب.
  /// يشير إلى مشكلة في توافق إصدار البروتوكول.
  static const int httpVersionNotSupported = 505;

  /// The server has an internal configuration error: the chosen resource is configured to engage in transparent content negotiation itself, which is not appropriate.
  /// Indicates a configuration problem on the server.
  ///
  /// يحتوي الخادم على خطأ في التكوين الداخلي: تم تكوين المورد المختار للمشاركة في التفاوض على المحتوى الشفاف بنفسه، وهو ما ليس مناسباً.
  /// يشير إلى مشكلة في التكوين على الخادم.
  static const int variantAlsoNegotiates = 506;

  /// The server is unable to store the representation needed to complete the request.
  /// Typically indicates a storage capacity issue on the server.
  ///
  /// غير قادر على تخزين التمثيل المطلوب لإكمال الطلب.
  /// عادةً ما يشير إلى مشكلة في سعة التخزين على الخادم.
  static const int insufficientStorage = 507;

  /// The server detected an infinite loop while processing a request with "Depth: infinity".
  /// Indicates a logical loop in the request processing on the server.
  ///
  /// اكتشف الخادم حلقة لانهائية أثناء معالجة طلب يحتوي على "Depth: infinity".
  /// يشير إلى وجود حلقة منطقية في معالجة الطلب على الخادم.
  static const int loopDetected = 508;

  /// Further extensions to the request are required for the server to fulfill it.
  /// Indicates that the server requires additional extensions in the request to process it.
  ///
  /// هناك حاجة إلى تمديدات إضافية للطلب ليتمكن الخادم من تنفيذه.
  /// يشير إلى أن الخادم يحتاج إلى تمديدات إضافية في الطلب لمعالجته.
  static const int notExtended = 510;

  /// The client needs to authenticate to gain network access.
  /// Indicates that the client must authenticate itself to access the network.
  ///
  /// يحتاج العميل إلى المصادقة للحصول على الوصول إلى الشبكة.
  /// يشير إلى أن العميل يجب أن يصادق نفسه للوصول إلى الشبكة.
  static const int networkAuthenticationRequired = 511;
}
