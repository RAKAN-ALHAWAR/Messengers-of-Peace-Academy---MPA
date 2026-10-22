import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/Translation/translation.dart';
import 'package:messengersofpeace/Core/core.dart';

import '../../../../../Config/config.dart';
import '../../../../../Core/Service/session_lease.dart';
import '../../../../../Core/Error/error.dart';
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
  (int, String)? _loadedKey;
  int _loadGeneration = 0;

  //============================================================================
  // Functions

  /// Get data from database
  Future<void> getData() async {
    if (isClosed) return;
    // This authenticated screen may briefly survive logout navigation. Do not
    // let its reload adopt the public service credential.
    if (!SessionLeaseX.capture().hasAuthenticatedIdentity) {
      throw ErrorX.createErrorByCode(ErrorCodesX.unauthorized);
    }
    final locale = TranslationX.getLanguageCode;
    final key = (LocalDataX.sessionRevision, locale);
    if (isInit &&
        _loadedKey == key &&
        lastUpdate.isAfter(
          DateTime.now().subtract(const Duration(minutes: 1)),
        )) {
      return;
    }
    final accountId = LocalDataX.userid;
    final generation = ++_loadGeneration;
    final lease = SessionLeaseX.capture(
      isActive:
          () =>
              !isClosed &&
              generation == _loadGeneration &&
              TranslationX.getLanguageCode == locale,
    );
    try {
      final loadedUser = await DatabaseX.getUser();
      if (!lease.isCurrent) return;
      if (loadedUser.id != accountId) {
        throw ErrorX(
          message: 'Unable to start a secure session. Please sign in again.',
        );
      }
      final loadedStatistics = await DatabaseX.getUserStatistics();
      if (!lease.isCurrent) return;
      final badges = await DatabaseX.getBadges();
      if (!lease.isCurrent) return;

      // Publish one complete snapshot only while its identity is still current.
      user = loadedUser.obs;
      statistics = loadedStatistics.obs;
      app.user.value = loadedUser;
      currentBadge.value =
          badges.isEmpty
              ? null
              : badges.firstWhere(
                (badge) =>
                    badge.requiredPoints > loadedUser.points && !badge.earned,
                orElse: () => badges.last,
              );
      lastUpdate = DateTime.now();
      _loadedKey = key;
      isInit = true;
    } catch (_) {
      if (!lease.isCurrent) return;
      if (!isInit || _loadedKey != key) rethrow;
    }
  }

  @override
  void onClose() {
    complaintController.dispose();
    super.onClose();
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
