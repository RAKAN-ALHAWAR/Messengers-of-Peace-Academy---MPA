import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/Translation/translation.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../Config/config.dart';
import '../../../../../Core/Service/controller_lease.dart';
import '../../../../../Core/Service/route_origin.dart';
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

  /// The first snapshot made `user` and `statistics`
  bool _snapshotInitialized = false;

  /// Current badge
  Rx<BadgeX?> currentBadge = Rx<BadgeX?>(null);

  /// Complaint controller
  final TextEditingController complaintController = TextEditingController();

  /// Last update
  DateTime lastUpdate = DateTime.now();

  /// Is init
  bool isInit = false;

  /// Account and language of the snapshot now shown
  (int, String)? _loadedKey;

  /// The newest load wins
  int _loadGeneration = 0;

  /// The newest page tap wins
  int _navigationGeneration = 0;

  /// A progress page is open, ignore taps
  bool _openingProgressRoute = false;

  //============================================================================
  // Functions

  /// Get data from database
  Future<void> getData({bool force = false, SessionLeaseX? owner}) async {
    if (isClosed || owner?.isCurrent == false) return;
    // After logout this screen must not reload with the public credential.
    if (!SessionLeaseX.capture().hasAuthenticatedIdentity) {
      throw ErrorX.createErrorByCode(ErrorCodesX.unauthorized);
    }
    final locale = TranslationX.getLanguageCode;
    final key = (LocalDataX.sessionRevision, locale);
    if (!force &&
        isInit &&
        _loadedKey == key &&
        lastUpdate.isAfter(
          DateTime.now().subtract(const Duration(minutes: 1)),
        )) {
      return;
    }
    final accountId = LocalDataX.userid;
    final generation = ++_loadGeneration;
    final lease = ControllerLeaseX.capture(
      this,
      owner: owner,
      locale: true,
      also: () => generation == _loadGeneration,
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

      // Publish one whole snapshot, in the same containers the views watch.
      if (_snapshotInitialized) {
        user.value = loadedUser;
        statistics.value = loadedStatistics;
      } else {
        user = loadedUser.obs;
        statistics = loadedStatistics.obs;
        _snapshotInitialized = true;
      }
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
      if (force || !isInit || _loadedKey != key) rethrow;
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
  Future<void> onEditPersonalData() => _openAndRefresh(RouteNameX.editProfile);

  /// Navigate to my courses
  Future<void> onCoursesAttended() => _openAndRefresh(RouteNameX.myCourses);

  Future<void> _openAndRefresh(String destination) async {
    if (isClosed || _openingProgressRoute) return;
    final origin = RouteOriginX.capture();
    final generation = ++_navigationGeneration;
    final lease = ControllerLeaseX.capture(
      this,
      origin: origin,
      registered: true,
      locale: true,
      also: () => generation == _navigationGeneration,
    );
    if (!lease.hasAuthenticatedIdentity || !lease.isCurrent) return;
    _openingProgressRoute = true;
    try {
      await Get.toNamed(destination);
      if (lease.isCurrent) await getData(force: true, owner: lease);
    } catch (error) {
      if (!lease.isCurrent) return;
      ErrorX.console(error);
      ToastX.error(message: error);
    } finally {
      if (!isClosed) _openingProgressRoute = false;
    }
  }

  /// Navigate to my grades and certificates
  onMyGradesAndCertificates() => Get.toNamed(RouteNameX.myCertificates);

  /// Navigate to change password
  onUpdatePassword() => Get.toNamed(RouteNameX.changePassword);

  /// Show submit complaint or suggestion sheet
  onSubmitComplaintOrSuggestion() => submitComplaintOrSuggestionSheetX();

  /// Log out
  onLogout() async => await app.logOut();

  /// The site's data-deletion request page (Moodle data privacy tool)
  static const dataDeletionRequestUrl =
      'https://mopacademy.org/admin/tool/dataprivacy/createdatarequest.php';

  /// Opens a link in the external browser. A field so tests can fake it.
  Future<bool> Function(Uri url) launcher =
      (url) => launchUrl(url, mode: LaunchMode.externalApplication);

  /// Ask the user to confirm before leaving for the deletion request page
  onDeleteAccount() => AlertDialogX.okAndCancel(
    title: 'Delete account',
    message:
        'We will open the website page where you can send a request to delete your account and data. The team reviews the request and then deletes the account.',
    textOK: 'Open page'.tr,
    colorTextOk: ColorX.danger,
    onOk: onConfirmDeleteAccount,
  );

  /// Hand the deletion request over to the website
  Future<void> onConfirmDeleteAccount() async {
    // TEMP(backend): the app has no account-deletion endpoint yet (none among
    // the 163 web service functions), so it hands off to the site's data
    // request page until the backend adds one. The session is left as is.
    Get.back();
    var opened = false;
    try {
      opened = await launcher(Uri.parse(dataDeletionRequestUrl));
    } catch (_) {}
    if (!opened) {
      ToastX.error(message: 'Could not open the page, please try again');
    }
  }

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
