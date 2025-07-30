import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../Util/console/console.dart';
import '../Util/info.dart';
import '../Util/string.dart';
import '../Error/error.dart';

part 'lib/logging_console.dart';

class LoggingX {
  static init({
    List<Function(FlutterErrorDetails)> addToFlutterError = const [],
    List<Function(Object, StackTrace)> addToPlatformDispatcher = const []
}) async{
    await ignoreException(NetworkImageLoadException);
    await ignoreException(ArgumentError);

    FlutterError.onError = (error){
      // LoggingConsoleX.log(error);
      for(var x in addToFlutterError) {
        x(error);
      }
    };

    PlatformDispatcher.instance.onError = (Object error, StackTrace stack){
      // LoggingConsoleX.logger(error, stack);
      for(var x in addToPlatformDispatcher) {
        x(error,stack);
      }
      return true;
    };

    ErrorWidget.builder = CaptureScreenErrorX.builder;
  }
  static Future<void> ignoreException(Type exceptionType) async {
    final originalOnError = FlutterError.onError!;
    FlutterError.onError = (FlutterErrorDetails details) {
      final currentError = details.exception.runtimeType;
      if (currentError == exceptionType) {
        return;
      }
      originalOnError(details);
    };
  }
  static safeZone(Function() zone) {
    runZonedGuarded(
      zone,
      LoggingConsoleX.logger,
    );
  }
}
