import 'package:flutter/material.dart';

import '../../Ui/Section/GeneralState/system_crash.dart';

part 'lib/error_type_status.dart';
part 'lib/capture_screen_error.dart';
part 'lib/error_code.dart';
part 'lib/error_message.dart';
part 'lib/error_severity_status.dart';
part 'lib/error_title.dart';
part 'lib/extension.dart';
part 'lib/error_type.dart';

class ErrorX implements Exception {
  late String title;
  late String message;
  int errorCode;
  late ErrorTypeStatusX errorType;
  ErrorSeverityStatusX severity;
  Map<String, dynamic> details;
  late String originalError;
  StackTrace? stackTrace;

  ErrorX({
    String? message,
    String? title,
    originalError,
    this.errorCode = ErrorCodesX.unexpected,
    this.details = const {},
    this.severity = ErrorSeverityStatusX.medium,
    ErrorTypeStatusX? errorType,
    this.stackTrace,
  }) {
    this.title = title ?? ErrorTitlesX.getTitle(errorCode);
    this.message = message ?? ErrorMessagesX.getMessage(errorCode);
    this.originalError = originalError?.toString() ?? this.message;
    this.errorType = errorType ?? ErrorTypeX.getErrorType(errorCode);
  }

  factory ErrorX.fromException(dynamic error, {StackTrace? stackTrace}) {
    if (check(error)) {
      ErrorX e = error;
      return e;
    } else {
      return ErrorX(originalError: error, stackTrace: stackTrace);
    }
  }

  /// An answer that belongs to a previous login; the text is a translation key.
  factory ErrorX.sessionChanged() =>
      ErrorX(message: 'Session changed. Please try again.');

  /// Restructure the error message - Static version
  static void console(error) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: ErrorX(
          message: diagnosticSummary(error),
          errorCode: error is ErrorX ? error.errorCode : ErrorCodesX.unexpected,
        ),
        library: 'Saker Dakak',
      ),
    );
  }

  static bool check(dynamic val) {
    return ErrorX().runtimeType.toString() == val.runtimeType.toString();
  }

  /// Unknown response/exception payloads are not safe diagnostic metadata.
  static String diagnosticSummary(Object? error) =>
      error is ErrorX
          ? 'ErrorX(code: ${error.errorCode}, type: ${error.errorType.name}, severity: ${error.severity.name})'
          : 'Failure type: ${error.runtimeType}';

  static String diagnosticStack(String stack) =>
      stack.replaceAll(RegExp(r'https?://[^\s]+'), '[redacted-url]');

  /// Restructure the error message - Instance version
  void log() {
    console(this);
  }

  // الدالة لإنشاء الأخطاء بناءً على رمز الخطأ وتفاصيل إضافية
  static ErrorX createErrorByCode(
    int errorCode, {
    dynamic originalError,
    StackTrace? stackTrace,
    Map<String, dynamic> details = const {},
  }) {
    String title = ErrorTitlesX.getTitle(errorCode);
    String message = ErrorMessagesX.getMessage(errorCode);
    return ErrorX(
      message: message,
      title: title,
      originalError: originalError?.toString(),
      errorCode: errorCode,
      details: details,
      stackTrace: stackTrace,
    );
  }

  @override
  String toString() {
    return message;
  }
}
