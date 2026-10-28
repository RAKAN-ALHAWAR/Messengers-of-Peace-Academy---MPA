import 'package:get/get.dart';

import '../../Config/Translation/translation.dart';
import '../core.dart';
import 'route_origin.dart';
import 'session_lease.dart';

/// Asks "is this work still mine?" before a late answer is written.
/// Every site chooses its own questions; nothing is added or dropped for it.
class ControllerLeaseX {
  //============================================================================
  // Functions

  /// Open, still the registered instance of its type, and (when [app] is given
  /// or [withApp] is true) [app] is still the registered app controller.
  /// A null [app] with [withApp] is not owned.
  static bool owns<T extends GetxController>(
    T controller, {
    bool withApp = false,
    AppControllerX? app,
  }) =>
      !controller.isClosed &&
      _isRegistered(controller) &&
      (!(withApp || app != null) || _isLiveApp(app));

  /// A lease for work started now. Always asks "is the controller open", then
  /// only the options passed: [registered] is the live instance of its type,
  /// [app]/[withApp] is the live app controller (the caller passes the
  /// reference it holds, this never looks it up), [locale] is the language of
  /// this call, [origin] is the page of the tap, [owner] is the parent tap's
  /// lease, [also] is a site test such as `request == _loadGeneration`.
  static SessionLeaseX capture<T extends GetxController>(
    T controller, {
    bool registered = false,
    bool withApp = false,
    AppControllerX? app,
    bool locale = false,
    RouteOriginX? origin,
    SessionLeaseX? owner,
    bool Function()? also,
  }) {
    final language = locale ? TranslationX.getLanguageCode : null;
    return SessionLeaseX.capture(
      isActive: () =>
          !controller.isClosed &&
          (!registered || _isRegistered(controller)) &&
          (!(withApp || app != null) || _isLiveApp(app)) &&
          (owner?.isCurrent ?? true) &&
          (!locale || TranslationX.getLanguageCode == language) &&
          (origin?.isActive ?? true) &&
          (also?.call() ?? true),
    );
  }

  static bool _isRegistered<T extends GetxController>(T controller) =>
      Get.isRegistered<T>() && identical(Get.find<T>(), controller);

  static bool _isLiveApp(AppControllerX? app) =>
      app != null &&
      Get.isRegistered<AppControllerX>() &&
      identical(Get.find<AppControllerX>(), app);
}
