/// An enum representing different methods of transmitting data in a request.
///
/// This enum specifies how data should be transmitted or included in the request,
/// such as through query parameters, path parameters, headers, body, or other methods.
/// ---------------------------------------------
/// تعداد يمثل طرق مختلفة لنقل البيانات في الطلب.
///
/// يحدد هذا التعداد كيفية نقل البيانات أو تضمينها في الطلب، مثل من خلال
/// معلمات الاستعلام، أو معلمات المسار، أو رؤوس الطلب، أو جسم الطلب، أو طرق أخرى.
///
enum TransmissionMethodStatusX {
  /// Data is transmitted via query parameters in the URL.
  ///
  /// Example: https://api.example.com/items?page=2&limit=10
  ///
  /// يتم نقل البيانات عبر معلمات الاستعلام في عنوان URL.
  ///
  /// Example: https://api.example.com/items?page=2&limit=10
  queryParams,

  /// Data is transmitted via path parameters in the URL.
  ///
  /// Example: https://api.example.com/items/page/2/limit/10
  ///
  /// يتم نقل البيانات عبر معلمات المسار في عنوان URL.
  ///
  /// Example: https://api.example.com/v1/
  pathParams,

  /// Data is transmitted via headers in the HTTP request.
  ///
  /// يتم نقل البيانات عبر رؤوس الطلب في طلب HTTP.
  headers,

  /// Data is transmitted in the body of the HTTP request.
  ///
  /// يتم نقل البيانات في جسم طلب HTTP.
  body,
}
