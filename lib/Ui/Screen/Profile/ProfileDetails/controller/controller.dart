import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/Translation/translation.dart';
import 'package:messengersofpeace/Core/core.dart';

import '../../../../../Config/config.dart';
import '../../../../../Data/Model/badge.dart';
import '../../../../../Data/Model/user/user.dart';
import '../../../../../Data/Model/user/user_statistics.dart';
import '../../../../../Data/data.dart';
import '../../../../ScreenSheet/Language/language_sheet.dart';
import '../../../../ScreenSheet/submit_complaint_or_suggestion_sheet.dart';
import '../../../../Widget/widget.dart';

class ProfileDetailsController extends GetxController {
  //============================================================================
  // Injection of required controls

  final AppControllerX app = Get.find();

  //============================================================================
  // Variables

  /// Theme
  RxBool themeIsDark = ThemeX.isDarkMode.obs;

  /// Language
  RxString languageName = TranslationX.getCurrentNameLanguage().obs;

  /// User
  late Rx<UserX> user;

  /// User statistics
  late Rx<UserStatisticsX> statistics;

  /// Current badge
  Rx<BadgeX?> currentBadge = Rx<BadgeX?>(null);

  /// Complaint controller
  final TextEditingController complaintController = TextEditingController();

  /// Last update
  DateTime lastUpdate = DateTime.now();

  /// Is init
  bool isInit = false;

  //============================================================================
  // Functions

  /// Get data from database
  Future<void> getData() async {
    try {
      /// Check if the data is already initialized and the last update is not more than 1 minute ago
      if (isInit &&
          lastUpdate.isAfter(DateTime.now().subtract(Duration(minutes: 1)))) {
        return;
      }

      /// Get user data from database
      user = (await DatabaseX.getUser()).obs;

      /// Update the user in the app controller
      app.user.value = user.value;

      /// Get user statistics from database
      statistics = (await DatabaseX.getUserStatistics()).obs;

      /// Get badges from database
      final badges = await DatabaseX.getBadges();

      /// Check if there are badges
      if (badges.isNotEmpty) {
        currentBadge =
            badges
                .firstWhere(
                  (badge) =>
                      badge.requiredPoints > app.user.value.points &&
                      badge.earned == false,
                  orElse: () => badges.last,
                )
                .obs;
      }

      /// Update the last update time
      lastUpdate = DateTime.now();

      /// Update initilization
      isInit = true;
    } catch (e) {
      /// Check if the data is not initialized
      if (!isInit) {
        rethrow;
      }
    }
  }

  /// Navigate to achievements board
  onAchievementsBoard() => Get.toNamed(RouteNameX.myAchievements);

  /// Navigate to leaderboard
  onLeaderboard() => Get.toNamed(RouteNameX.leaderboard);

  /// Navigate to edit profile
  onEditPersonalData() => Get.toNamed(RouteNameX.editProfile);

  /// Navigate to my courses
  onCoursesAttended() => Get.toNamed(RouteNameX.myCourses);

  /// Navigate to my grades and certificates
  onMyGradesAndCertificates() => Get.toNamed(RouteNameX.myCertificates);

  /// Navigate to change password
  onUpdatePassword() => Get.toNamed(RouteNameX.changePassword);

  /// Show submit complaint or suggestion sheet
  onSubmitComplaintOrSuggestion() => submitComplaintOrSuggestionSheetX();

  /// Log out
  onLogout() async => await app.logOut();

  /// Change dark mode
  onChangeDarkMode() {
    try {
      /// Change the values of variables
      themeIsDark.value = !themeIsDark.value;

      /// Switch Theme
      ThemeX.change(themeIsDark.value);

      /// Save the theme to internal storage
      LocalDataX.put(LocalKeyX.themeIsDark, themeIsDark.value);
    } catch (e) {
      /// Show error toast
      ToastX.error(message: e);
    }
  }

  /// Change language
  onChangeLanguage() async {
    /// Show language sheet
    await languageSheetX((String val) async {
      try {
        /// Switch language
        await TranslationX.changeLocale(val);

        /// Update the language name
        languageName.value = TranslationX.getCurrentNameLanguage();

        /// Save the language to internal storage
        LocalDataX.put(LocalKeyX.language, val);

        /// Close the bottom sheet
        Get.back();
      } catch (e) {
        /// Show error toast
        ToastX.error(message: e);
      }
    });
  }
}
