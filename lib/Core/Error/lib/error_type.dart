part of '../error.dart';

class ErrorTypeX {
  static ErrorTypeStatusX getErrorType(int errorCode) {
    if (errorCode >= 1001 && errorCode <= 1003) {
      return ErrorTypeStatusX.network;
    } if (errorCode >= 1004 && errorCode < 2000) {
      return ErrorTypeStatusX.input;
    } else if (errorCode >= 300 && errorCode < 400) {
      return ErrorTypeStatusX.network;
    } else if (errorCode >= 400 && errorCode < 500) {
      return ErrorTypeStatusX.network;
    } else if (errorCode >= 500 && errorCode < 600) {
      return ErrorTypeStatusX.server;
    } else {
      return ErrorTypeStatusX.unknown;
    }
  }
}
