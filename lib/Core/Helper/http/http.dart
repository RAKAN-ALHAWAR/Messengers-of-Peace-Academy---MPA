library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../Error/error.dart';

part 'lib/request.dart';
part 'lib/response.dart';
part 'lib/util.dart';

class HttpX {
  static late final String _internetCheckUrl;
  static late final Duration _timeout;
  static late final Duration _internetRetryDelay;

  static init({
    String internetCheckUrl = "one.one.one.one",
    Duration timeout = const Duration(seconds: 15),
    Duration internetRetryDelay = const Duration(seconds: 5),
  }) {
    _internetCheckUrl = internetCheckUrl;
    _timeout = timeout;
    _internetRetryDelay = internetRetryDelay;
  }

  static Future<T?> _call<T>({
    required String url,
    required Future<http.Response> Function() method,
    T? fallbackResponse,
    int? maxRetries,
    bool ignoreUnauthorized = false,
  }) async {
    try {
      // Validate Url
      HttpUtilX.validateUrl(url);

      // Handle Request
      http.Response response = await HttpRequestX.call(method, maxRetries);

      // Handle response status codes
      return await HttpResponseX.call(
        response,
        fallbackResponse,
        ignoreUnauthorized,
      );
    } on ErrorX {
      if (fallbackResponse != null) {
        return fallbackResponse;
      } else {
        rethrow;
      }
    } catch (e, stackTrace) {
      if (fallbackResponse != null) {
        return fallbackResponse;
      } else {
        throw ErrorX.createErrorByCode(
          ErrorCodesX.unexpected,
          originalError: e.toString(),
          stackTrace: stackTrace,
        );
      }
    }
  }

  /// Get
  static Future<T?> get<T>({
    required String url,
    Map<String, String>? headers,
    T? fallbackResponse,
    int? maxRetries,
    Duration? timeout,
    bool ignoreUnauthorized = false,
  }) async {
    return await _call(
      url: url,
      method: () async {
        return await http
            .get(Uri.parse(url), headers: headers)
            .timeout(timeout ?? _timeout);
      },
      fallbackResponse: fallbackResponse,
      maxRetries: maxRetries,
      ignoreUnauthorized: ignoreUnauthorized,
    );
  }

  /// Post
  static Future<T?> post<T>({
    required String url,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T? fallbackResponse,
    int? maxRetries,
    Duration? timeout,
    bool ignoreUnauthorized = false,
  }) async {
    var mybody =
        headers?['Content-Type'] == 'application/json'
            ? jsonEncode(body)
            : body;
    return await _call(
      url: url,
      method: () async {
        return await http
            .post(Uri.parse(url), body: mybody, headers: headers)
            .timeout(timeout ?? _timeout);
      },
      fallbackResponse: fallbackResponse,
      maxRetries: maxRetries,
      ignoreUnauthorized: ignoreUnauthorized,
    );
  }

  /// Post Files
  static Future<T?> postFiles<T>({
    required String url,
    required Map<String, File> files,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T? fallbackResponse,
    int? maxRetries,
    Duration? timeout,
    bool ignoreUnauthorized = false,
    bool isAcceptsBlankFiles = false,
  }) async {
    if (isAcceptsBlankFiles && files.isEmpty) {
      return await post(
        url: url,
        body: body,
        headers: headers,
        fallbackResponse: fallbackResponse,
        maxRetries: maxRetries,
        timeout: timeout,
        ignoreUnauthorized: ignoreUnauthorized,
      );
    }
    // Create request
    var request = http.MultipartRequest('POST', Uri.parse(url));

    // Add headers
    if (headers != null) {
      request.headers.addAll(headers);
    }

    // Add each file to the request
    for (int i = 0; i < files.length; i++) {
      request.files.add(
        await http.MultipartFile.fromPath(
          files.keys.elementAt(i),
          files.values.elementAt(i).path,
        ),
      );
    }

    // Add body if any
    if (body != null) {
      // Convert body to Map<String, String> by converting each value to a string
      var fields = body.map((key, value) => MapEntry(key, value.toString()));
      request.fields.addAll(fields);
    }
    return await _call(
      url: url,
      method: () async {
        return await http.Response.fromStream(
          await request.send().timeout(timeout ?? _timeout),
        );
      },
      fallbackResponse: fallbackResponse,
      maxRetries: maxRetries,
      ignoreUnauthorized: ignoreUnauthorized,
    );
  }

  /// Put
  static Future<T?> put<T>({
    required String url,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T? fallbackResponse,
    int? maxRetries,
    Duration? timeout,
    bool ignoreUnauthorized = false,
  }) async {
    var mybody =
        headers?['Content-Type'] == 'application/json'
            ? jsonEncode(body)
            : body;
    return await _call(
      url: url,
      method: () async {
        return await http
            .put(Uri.parse(url), body: mybody, headers: headers)
            .timeout(timeout ?? _timeout);
      },
      fallbackResponse: fallbackResponse,
      maxRetries: maxRetries,
      ignoreUnauthorized: ignoreUnauthorized,
    );
  }

  /// Put Files
  static Future<T?> putFiles<T>({
    required String url,
    required Map<String, File> files,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T? fallbackResponse,
    int? maxRetries,
    Duration? timeout,
    bool ignoreUnauthorized = false,
    bool isAcceptsBlankFiles = false,
  }) async {
    // if (isAcceptsBlankFiles && files.isEmpty) {
    //   return await put(
    //     url: url,
    //     body: body,
    //     headers: headers,
    //     fallbackResponse: fallbackResponse,
    //     maxRetries: maxRetries,
    //     timeout: timeout,
    //     ignoreUnauthorized: ignoreUnauthorized,
    //   );
    // }
    // Create request
    var request = http.MultipartRequest('PUT', Uri.parse(url));

    // Add headers
    if (headers != null) {
      request.headers.addAll(headers);
    }

    // Add each file to the request
    for (int i = 0; i < files.length; i++) {
      request.files.add(
        await http.MultipartFile.fromPath(
          files.keys.elementAt(i),
          files.values.elementAt(i).path,
        ),
      );
    }
    // Add body if any
    if (body != null) {
      // Convert body to Map<String, String> by converting each value to a string
      var fields = body.map((key, value) => MapEntry(key, value.toString()));
      request.fields.addAll(fields);
    }
    return await _call(
      url: url,
      method: () async {
        return await http.Response.fromStream(
          await request.send().timeout(timeout ?? _timeout),
        );
      },
      fallbackResponse: fallbackResponse,
      maxRetries: maxRetries,
      ignoreUnauthorized: ignoreUnauthorized,
    );
  }

  /// Delete
  static Future<T?> delete<T>({
    required String url,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T? fallbackResponse,
    int? maxRetries,
    Duration? timeout,
    bool ignoreUnauthorized = false,
  }) async {
    var mybody =
        headers?['Content-Type'] == 'application/json'
            ? jsonEncode(body)
            : body;
    return await _call(
      url: url,
      method: () async {
        return await http
            .delete(Uri.parse(url), body: mybody, headers: headers)
            .timeout(timeout ?? _timeout);
      },
      fallbackResponse: fallbackResponse,
      maxRetries: maxRetries,
      ignoreUnauthorized: ignoreUnauthorized,
    );
  }
}
