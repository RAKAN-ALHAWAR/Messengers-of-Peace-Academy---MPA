import 'dart:io';

import '../../../Core/Error/error.dart';
import '../../../Core/Service/session_lease.dart';
import '../../../Core/Helper/http/http.dart';
import '../../../Core/Util/http_url.dart';
import '../../../Core/Util/url.dart';
import '../../Enum/transmission_method_status.dart';
import '../../Model/basic/data_source_param.dart';
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
    final lease = SessionLeaseX.capture();
    final authenticated = lease.authenticates(url);
    T? result;
    ErrorX? error;
    try {
      result = await method();
    } catch (e) {
      error = ErrorX.fromException(e);
    }

    if (authenticated && !lease.isCurrent) {
      throw ErrorX(message: 'Session changed. Please try again.');
    }
    if (authenticated &&
        (result is Map && result['errorcode'] == 'invalidtoken')) {
      SessionExpiryX.report(lease);
      throw ErrorX.createErrorByCode(ErrorCodesX.unauthorized);
    }

    if (error?.errorCode == ErrorCodesX.unauthorized) throw error!;

    // The cache of an authenticated request is owned by the user who made it:
    // the key carries the user id, so one account never reads another's data.
    // Old keys without the id are never read here. The session is still the
    // same one at this point (checked above), so the current id is the owner.
    if ((error?.errorCode ?? -1) != ErrorCodesX.unauthorized &&
        (param.page == null || param.page == 1)) {
      result = _useLocal<T>(
        _cacheKey(param.localCacheKey, authenticated),
        result,
      );
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

  static String? _cacheKey(String? localCacheKey, bool authenticated) {
    if (!authenticated || localCacheKey == null || localCacheKey.isEmpty) {
      return localCacheKey;
    }
    return '${LocalDataX.userid}:$localCacheKey';
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
