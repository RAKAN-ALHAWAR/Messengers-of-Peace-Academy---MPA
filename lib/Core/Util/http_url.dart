class HttpHeaderUtilX {
  /// Function to build headers
  static Map<String, String> build({
    String? authToken,
    String authType = 'Bearer',
    String authTypeKey = 'Authorization',
    String? languageCode,
    String languageKey = 'Accept-Language',
    String contentType = "application/json",
    String accept = "application/json",
    Map<String, String>? additionalHeaders,
    Map<String, String>? customHeaders,
  }) {
    Map<String, String> headers = {};

    // Adding additional headers if provided
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    // Adding default headers
    headers['Content-Type'] = contentType;
    headers['Accept'] = accept;

    if (languageCode != null && languageCode.isNotEmpty) {
      headers[languageKey] = languageCode;
    }

    if (authToken != null && authToken.isNotEmpty) {
      headers[authTypeKey] = "$authType $authToken".trim();
    }

    // Adding custom headers if provided
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }

    return headers;
  }
}
