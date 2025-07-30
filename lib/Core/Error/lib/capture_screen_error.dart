part of '../error.dart';

class CaptureScreenErrorX{

  static Widget builder(FlutterErrorDetails details) {
   return SystemCrashView(error: details);
  }
}