library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import '../../Error/error.dart';
import '../../Service/session_lease.dart';

part 'lib/request.dart';
part 'lib/response.dart';
part 'lib/util.dart';

class HttpX {
  static late final String _internetCheckUrl;
  static late final Duration _timeout;
  static late final Duration _internetRetryDelay;
  // Protocol response budget for multipart acknowledgements, not file contents.
  static const _multipartResponseLimit = 16 * 1024 * 1024;

  static Future<http.Response> _sendMultipart(
    http.MultipartRequest request,
    Duration? timeout,
  ) async {
    final client = http.Client();
    StreamSubscription<List<int>>? subscription;
    final completion = Completer<http.Response>();
    var cancelled = false;
    Future<http.Response> send() async {
      final streamed = await client.send(request);
      if (cancelled) throw const HttpException('Upload response cancelled');
      final bytes = BytesBuilder(copy: false);
      subscription = streamed.stream.listen(
        (chunk) {
          if (completion.isCompleted) return;
          if (bytes.length + chunk.length > _multipartResponseLimit) {
            completion.completeError(
              ErrorX.createErrorByCode(ErrorCodesX.payloadTooLarge),
            );
          } else {
            bytes.add(chunk);
          }
        },
        onError: (Object error, StackTrace stack) {
          if (!completion.isCompleted) completion.completeError(error, stack);
        },
        onDone: () {
          if (!completion.isCompleted) {
            completion.complete(
              http.Response.bytes(
                bytes.takeBytes(),
                streamed.statusCode,
                headers: streamed.headers,
                reasonPhrase: streamed.reasonPhrase,
                request: streamed.request,
                isRedirect: streamed.isRedirect,
                persistentConnection: streamed.persistentConnection,
              ),
            );
          }
        },
        cancelOnError: true,
      );
      return completion.future;
    }

    try {
      return await send().timeout(timeout ?? _timeout);
    } finally {
      cancelled = true;
      client.close();
      // Stream cancellation may itself wait on a stalled transport. The owned
      // client is closed immediately; cleanup cannot extend the request deadline.
      if (subscription != null) unawaited(subscription!.cancel());
    }
  }

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
    final lease = SessionLeaseX.capture();
    final authenticated = lease.authenticates(url);
    try {
      // Validate Url
      HttpUtilX.validateUrl(url);

      // Handle Request
      http.Response response = await HttpRequestX.call(method, maxRetries);

      if (response.statusCode == 401 && authenticated && !ignoreUnauthorized) {
        SessionExpiryX.report(lease);
        // Never let fallbackResponse turn an expired identity into success.
        throw ErrorX.createErrorByCode(ErrorCodesX.unauthorized);
      }

      // Handle response status codes
      return await HttpResponseX.call(
        response,
        fallbackResponse,
        ignoreUnauthorized,
      );
    } on ErrorX catch (error) {
      if (error.errorCode == ErrorCodesX.unauthorized && !ignoreUnauthorized) {
        rethrow;
      }
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
      method: () => _sendMultipart(request, timeout),
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
      method: () => _sendMultipart(request, timeout),
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
