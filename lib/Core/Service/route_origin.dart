import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

/// The page a tap came from. A controller keeps it so that work finishing after
/// a child route returns is dropped when the user has already left that page.
class RouteOriginX {
  RouteOriginX._(this._route);

  /// Reads the top route from the navigator itself. `Get.rawRoute` is only the
  /// last route the GetX observer reported: `offAllNamed` ends with a removal
  /// of the old stack whose previous route is null, so on the root page right
  /// after launch or sign-in it is null and every tap would count as stale.
  /// `popUntil` with a predicate that accepts the top route never pops.
  factory RouteOriginX.capture() {
    Route<dynamic>? top;
    Get.key.currentState?.popUntil((route) {
      top = route;
      return true;
    });
    return RouteOriginX._(top ?? Get.rawRoute);
  }

  final Route<dynamic>? _route;

  /// False once the page was popped or replaced (a missing route counts as left).
  bool get isActive => _route?.isActive ?? false;
}
