library;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Core/core.dart';
import '../Data/data.dart';

part "Asset/icons.dart";
part 'Asset/image.dart';
part 'Route/route_name.dart';
part 'Theme/color.dart';
part 'Theme/text_style.dart';
part 'Theme/theme.dart';
part 'Theme/style.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this section }}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// Control the basic application configuration settings, including language,
/// theme, navigation, style, fixed files, etc.
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class ConfigX {
  static init() async {
    /// Set the color of the phone's status bar
    ConfigAppHelperX.statusBarColor(Colors.transparent);

    /// Select application directions available
    ConfigAppHelperX.deviceOrientation(up: true, down: false);
  }
}
