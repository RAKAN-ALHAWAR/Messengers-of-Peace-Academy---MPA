library;

import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:messengersofpeace/Data/Model/blog.dart';
import 'package:messengersofpeace/Data/Model/meeting.dart';
import 'package:messengersofpeace/Data/Model/my_activity_point.dart';
import 'package:messengersofpeace/Data/Model/notification.dart';
import 'package:path_provider/path_provider.dart';
import '../Config/Translation/translation.dart';
import '../Config/config.dart';
import '../Core/Error/error.dart';
import '../Core/Helper/model/model.dart';
import 'Database/config/database_end_point.dart';
import 'Database/remote/remote_data.dart';
import 'Enum/event_option.dart';
import 'Enum/meeting_option.dart';
import 'Form/update_user_form.dart';
import 'Model/course/course.dart';
import 'Model/course/level.dart';
import 'Model/course/my_course.dart';
import 'Model/activity_point.dart';
import 'Model/badge.dart';
import 'Model/event.dart';
import 'Model/leaderboard.dart';
import 'Model/my_certificate.dart';
import 'Model/quiz/quiz.dart';
import 'Model/quiz/quiz_result.dart';
import 'Model/quiz/quiz_start_attempt.dart';
import 'Model/user/user.dart';
import 'Model/info/country.dart';
import 'Model/info/language.dart';
import 'Model/info/phone_code.dart';
import 'Model/user/user_statistics.dart';

part 'Constant/constant.dart';
part 'Enum/enum.dart';
part 'Constant/name.dart';
part 'Database/database.dart';
part 'Local/config/local_default_data.dart';
part 'Local/config/local_key.dart';
part 'Local/local_data.dart';
part 'Local/storage/hive.dart';
part 'Model/Basic/scroll_refresh_load_more_parameters.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this section }}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// Control all types of data within the application, including static data,
/// managing data stored on the device, database connections, data models, etc.
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class DataX {
  static init() async {
    /// Formatting and retrieving data stored on the device
    await LocalDataX.init();

    /// Configure database connections
    await DatabaseX.init();
  }
}
