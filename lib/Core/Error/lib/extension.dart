part of '../error.dart';

extension ErrorExtensionX on Object {
  ErrorX get toErrorX{
    return ErrorX.fromException(this);
  }
}