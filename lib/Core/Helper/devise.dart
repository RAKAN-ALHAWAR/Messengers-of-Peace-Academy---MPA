part of '../core.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this Helper }}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// Inquiries about the client device
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class DeviseX{
  /// Application language direction
  static bool get isLTR => Directionality.of(Get.context!) == TextDirection.ltr;

  /// Application sizes queries
  static double width(context) => MediaQuery.of(context).size.width;
  static double height(context) => MediaQuery.of(context).size.height;
  static double heightSafe(context) => height(context)-MediaQuery.of(context).padding.top-MediaQuery.of(context).padding.bottom;

  static SizeTypeEX size(BuildContext context){
    if (width(context) < 600) {
      return SizeTypeEX.small;
    } else if (width(context) < 1024) {
      return SizeTypeEX.medium;
    } else{
      return SizeTypeEX.large;
    }
  }

  /// Client device type
  static DeviceTypeEX get type {
    if (kIsWeb) {
      return DeviceTypeEX.web;
    } else if (MediaQuery.of(Get.context!).size.width < 600) {
      return DeviceTypeEX.mobile;
    } else if (MediaQuery.of(Get.context!).size.width >= 600 && MediaQuery.of(Get.context!).size.width <= 1024) {
      return DeviceTypeEX.tablet;
    } else {
      return DeviceTypeEX.desktop;
    }
  }

  /// Operating system type of the client device
  static PlatformTypeEX get platform {
    if (kIsWeb) {
      return PlatformTypeEX.web;
    } else if (Platform.isAndroid) {
      return PlatformTypeEX.android;
    } else if (Platform.isIOS) {
      return PlatformTypeEX.ios;
    } else if (Platform.isMacOS) {
      return PlatformTypeEX.mac;
    } else if (Platform.isWindows) {
      return PlatformTypeEX.windows;
    } else if (Platform.isLinux) {
      return PlatformTypeEX.linux;
    } else {
      return PlatformTypeEX.fuchsia;
    }
  }
}