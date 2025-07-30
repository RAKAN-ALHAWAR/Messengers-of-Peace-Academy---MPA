import 'dart:io';

import '../../../Core/Error/error.dart';
import '../../../Core/Helper/http/http.dart';
import '../../../Core/Util/http_url.dart';
import '../../../Core/Util/url.dart';
import '../../Enum/transmission_method_status.dart';
import '../../Model/Basic/data_source_param.dart';
import '../../data.dart';
import 'config/remote_config.dart';
import 'config/remote_key.dart';

part 'lib/build.dart';

class RemoteDataSourceX {
  static init() async {}

  static Future<(T data, String? message)> _call<T>(
    String url,
    Function method, [
    DataSourceParamX? param,
    bool isSkeepStatus = false,
  ]) async {
    param ??= DataSourceParamX(); // Use default parameters if none provided
    T? result;
    ErrorX? error;
    try {
      result = await method();
    } catch (e) {
      error = ErrorX.fromException(e);
    }

    if ((error?.errorCode ?? -1) != ErrorCodesX.unauthorized &&
        (param.page == null || param.page == 1)) {
      result = _useLocal<T>(param.localCacheKey, result);
    }

    // Return the result if it's not null
    if (result != null) {
      if (result is Map &&
          ((!isSkeepStatus &&
                  (result['status'] != 'success' &&
                      result['status'].toString() != 'true' &&
                      result['status'] != null)) ||
              result['errorcode'] != null)) {
        throw ErrorX(
          message: result['message'],
          details: result as Map<String, dynamic>,
        );
      }
      String? message;
      message =
          (result is Map && result[RemoteKeyX.infoMessage] is String)
              ? result[RemoteKeyX.infoMessage]
              : (result is Map && result[RemoteKeyX.infoMessage2] is String)
              ? result[RemoteKeyX.infoMessage2]
              : null;
      return (result, message);
    }

    // Handle the case where T can be null
    if (null is T && (error == null || param.ignoreError)) {
      return (null as T, null);
    }

    // If T is not supposed to be nullable, throw an error or handle it accordingly
    if (!param.ignoreError && error != null) {
      if (error.details[RemoteKeyX.errorMessage] != null) {
        error.message = error.details[RemoteKeyX.errorMessage];
      } else if (error.details[RemoteKeyX.errorMessage2] != null) {
        error.message = error.details[RemoteKeyX.errorMessage2];
      }
    } else {
      error = ErrorX.createErrorByCode(ErrorCodesX.notFound);
    }
    throw error;
  }

  static T? _useLocal<T>(String? localCacheKey, T? result) {
    if (localCacheKey != null && localCacheKey.isNotEmpty) {
      if (result == null) {
        try {
          return LocalDataX.get(localCacheKey, defaultData: null);
        } catch (e) {
          LocalDataX.remove(localCacheKey);
          ErrorX.console(e);
        }
      } else {
        try {
          LocalDataX.put<T>(localCacheKey, result);
        } catch (e) {
          ErrorX.console(e);
        }
      }
    }
    return result;
  }

  /// Get
  static Future<(T data, String? message)> get<T>(
    String url, {
    DataSourceParamX? param,
  }) async {
    param ??= DataSourceParamX(); // Use default parameters if none provided
    return await _call(url, () async {
      return await HttpX.get<T>(
        url: _urlQueryBuild(url, param!),
        timeout: param.requestTimeout,
        maxRetries: param.maxRetries,
        ignoreUnauthorized: param.ignoreUnauthorized,
        fallbackResponse: param.fallbackResponse,
        headers: _headersBuild(param),
      );
    }, param);
  }

  /// Post
  static Future<(T data, String? message)> post<T>(
    String url, {
    Map<String, String>? body,
    DataSourceParamX? param,
    bool isSkeepStatus = false,
  }) async {
    param ??= DataSourceParamX(); // Use default parameters if none provided
    return await _call(
      url,
      () async {
        return await HttpX.post<T>(
          url: _urlQueryBuild(url, param!),
          body: body ?? param.requestBody,
          timeout: param.requestTimeout,
          maxRetries: param.maxRetries,
          ignoreUnauthorized: param.ignoreUnauthorized,
          fallbackResponse: param.fallbackResponse,
          headers: _headersBuild(param),
        );
      },
      param,
      isSkeepStatus,
    );
  }

  /// Post File
  static Future<(T data, String? message)> postFiles<T>(
    String url,
    Map<String, File> files, {
    Map<String, String>? body,
    DataSourceParamX? param,
    bool isAcceptsBlankFiles = false,
  }) async {
    param ??= DataSourceParamX(); // Use default parameters if none provided
    return await _call<T>(
      url,
      () async => await HttpX.postFiles<T>(
        url: _urlQueryBuild(url, param!),
        files: files,
        body: body ?? param.requestBody,
        timeout: param.requestTimeout,
        maxRetries: param.maxRetries,
        ignoreUnauthorized: param.ignoreUnauthorized,
        fallbackResponse: param.fallbackResponse,
        headers: _headersBuild(param),
        isAcceptsBlankFiles: isAcceptsBlankFiles,
      ),
      param,
    );
  }

  /// Put
  static Future<(T data, String? message)> put<T>(
    String url, {
    Map<String, String>? body,
    DataSourceParamX? param,
  }) async {
    param ??= DataSourceParamX(); // Use default parameters if none provided
    return await _call(
      url,
      () async => await HttpX.put<T>(
        url: _urlQueryBuild(url, param!),
        body: body ?? param.requestBody,
        timeout: param.requestTimeout,
        maxRetries: param.maxRetries,
        ignoreUnauthorized: param.ignoreUnauthorized,
        fallbackResponse: param.fallbackResponse,
        headers: _headersBuild(param),
      ),
      param,
    );
  }

  /// Put File
  static Future<(T data, String? message)> putFiles<T>(
    String url,
    Map<String, File> files, {
    Map<String, String>? body,
    DataSourceParamX? param,
    bool isAcceptsBlankFiles = false,
  }) async {
    param ??= DataSourceParamX(); // Use default parameters if none provided
    return await _call<T>(
      url,
      () async => await HttpX.putFiles<T>(
        url: _urlQueryBuild(url, param!),
        files: files,
        body: body ?? param.requestBody,
        timeout: param.requestTimeout,
        maxRetries: param.maxRetries,
        ignoreUnauthorized: param.ignoreUnauthorized,
        fallbackResponse: param.fallbackResponse,
        headers: _headersBuild(param),
        isAcceptsBlankFiles: isAcceptsBlankFiles,
      ),
      param,
    );
  }

  /// Delete
  static Future<(T data, String? message)> delete<T>(
    String url, {
    Map<String, String>? body,
    DataSourceParamX? param,
  }) async {
    param ??= DataSourceParamX(); // Use default parameters if none provided
    return await _call(
      url,
      () async => await HttpX.delete<T>(
        url: _urlQueryBuild(url, param!),
        body: body ?? param.requestBody,
        timeout: param.requestTimeout,
        maxRetries: param.maxRetries,
        ignoreUnauthorized: param.ignoreUnauthorized,
        fallbackResponse: param.fallbackResponse,
        headers: _headersBuild(param),
      ),
      param,
    );
  }
}
