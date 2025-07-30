part of '../http.dart';

class HttpRequestX {
  static Future<http.Response> call(
    Future<http.Response> Function() method, [
    int? maxRetries = 1,
  ]) async {
    Exception error = Exception();
    for (int retries = 0; retries < (maxRetries ?? 1); retries++) {
      try {
        // Send the HTTP request
        http.Response response = await method();
        // Return response
        return response;
      } on TimeoutException catch (e, stackTrace) {
        error = ErrorX.createErrorByCode(
          ErrorCodesX.requestTimeout,
          stackTrace: stackTrace,
          originalError: e.toString(),
        );
      } on SocketException catch (e, stackTrace) {
        if (await HttpUtilX.checkInternetConnection()) {
          error = ErrorX.createErrorByCode(
            ErrorCodesX.serviceUnavailable,
            stackTrace: stackTrace,
            originalError: e.toString(),
          );
        } else {
          error = ErrorX.createErrorByCode(
            ErrorCodesX.noInternetConnection,
            stackTrace: stackTrace,
            originalError: e.toString(),
          );
          // Adding a time delay to attempts, except for the last one, in case there is an error from the Internet
          if (retries != maxRetries) {
            await Future.delayed(HttpX._internetRetryDelay);
          }
        }
      } on http.ClientException catch (e, stackTrace) {
        error = ErrorX.createErrorByCode(
          ErrorCodesX.badRequest,
          stackTrace: stackTrace,
          originalError: e.toString(),
        );
        break;
      } on ErrorX catch (e) {
        error = e;
        break;
      } catch (e, stackTrace) {
        error = ErrorX.createErrorByCode(
          ErrorCodesX.badRequest,
          originalError: e.toString(),
          stackTrace: stackTrace,
        );
        break;
      }
    }
    return throw error;
  }
}
