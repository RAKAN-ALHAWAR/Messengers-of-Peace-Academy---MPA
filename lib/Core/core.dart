library;

import 'dart:async';
import 'dart:io';
import 'package:messengersofpeace/Core/Extension/convert/convert.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import '../Config/config.dart';
import '../Data/Model/user/user.dart';
import '../Data/data.dart';
import '../Ui/Widget/widget.dart';
import 'Helper/http/http.dart';
import 'Util/info.dart';
part 'Controller/App/app_controller.dart';
part 'Util/function.dart';
part 'Helper/clipboard.dart';
part 'Helper/config_app.dart';
part 'Helper/catch_error.dart';
part 'Helper/color.dart';
part 'Helper/devise.dart';
part 'Util/validate.dart';
part 'Helper/http_overrides.dart';
// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this section }}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// Controlling the internal processes of an application and general controllers,
/// containing all internal processors and general functions
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class CoreX {
  static init() async {
    await InfoUtilX.init();
    await HttpX.init();
    // await OnesignalServiceX.init();
    /// Here codes are added to configure anything within this section when the application starts
  }
}
