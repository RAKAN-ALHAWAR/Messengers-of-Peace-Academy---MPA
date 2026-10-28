import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Core/Error/error.dart';
import 'package:messengersofpeace/Core/Service/session_lease.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Model/info/country.dart';
import 'package:messengersofpeace/Data/Model/info/language.dart';
import 'package:messengersofpeace/Data/Model/info/phone_code.dart';

import '../../../../../Config/config.dart';
import '../../../../../Config/Translation/translation.dart';
import '../../../../../Data/Form/update_user_form.dart';
import '../../../../Widget/widget.dart';
import '../../../../Widget/Basic/Utils/form_validation.dart';

class CompleteAccountInfoController extends GetxController {
  //============================================================================
  // Injection of required controls

  AppControllerX app = Get.find();

  //============================================================================
  // Variables

  // Loading state
  final isLoading = false.obs;

  // Button states
  final buttonState = ButtonStateEX.normal.obs;

  // Image
  XFile? image;

  // Image picker
  final ImagePicker picker = ImagePicker();

  // Values
  final countryCode = "+966".obs;
  final gender = "male".obs;
  final country = "".obs;
  final language = "".obs;
  final howToFindUs = "".obs;
  final isSaudiUniversity = false.obs;
  final university = "".obs;

  // API Data Lists
  final countriesList = <Country>[].obs;
  final phoneCodesList = <PhoneCode>[].obs;
  final languagesList = <Language>[].obs;

  // Static data for dropdowns that don't come from API
  final howToFindUsList = ConstantX.howToFindUsList;
  final universities = ConstantX.universities;

  // True when the server refused the profile of this account at login, so the
  // profile in memory is only a placeholder until this data is saved.
  bool profileMissing =
      Get.arguments is Map && (Get.arguments as Map)['profileMissing'] == true;

  // Form key
  late GlobalKey<FormState> formKey;

  // Autovalidate mode
  final autoValidate = AutovalidateMode.disabled.obs;
  Future<void>? _referenceData;
  (String, int)? _referenceKey;
  Timer? _buttonResetTimer;
  late final SessionLeaseX _ownerLease;

  // Text editing controllers
  TextEditingController dateOfBirth = TextEditingController();

  /// The picked date of birth.
  ///
  /// [dateOfBirth] only holds the localized display text, which is not
  /// parsable, so the picked value has to be kept as it is
  DateTime? birthDate;

  /// The most recent date of birth accepted, users must be 18 or older
  static DateTime get maxBirthDate => DateTime(
    DateTime.now().year - 18,
    DateTime.now().month,
    DateTime.now().day,
  );

  /// Store the date picked in the date of birth field
  void onChangeBirthDate(DateTime? value) => birthDate = value;
  TextEditingController whatsapp = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController howToFindUsOthers = TextEditingController();
  TextEditingController telegramId = TextEditingController();
  TextEditingController telegramName = TextEditingController();
  // TextEditingController usernameController = TextEditingController();

  //============================================================================
  // Functions

  /// Get data
  Future<void> getData() {
    final key = (TranslationX.getLanguageCode, LocalDataX.sessionRevision);
    if (_referenceKey != key) {
      _referenceKey = key;
      _referenceData = null;
    }
    return _referenceData ??= _loadData(key);
  }

  Future<void> _loadData((String, int) key) async {
    final ownsLocale = _referenceGuard();
    bool ownsRequest() => ownsLocale() && _referenceKey == key;
    if (!ownsRequest()) return;

    /// Load data in parallel
    try {
      await Future.wait<void>([
        loadCountries(ownsRequest),
        loadPhoneCodes(ownsRequest),
        loadLanguages(ownsRequest),
      ]);
    } catch (_) {
      // A failed load must be retryable; a successful load survives rebuilds.
      if (_referenceKey == key) _referenceData = null;
      rethrow;
    }
  }

  /// Load countries
  Future<void> loadCountries([bool Function()? operation]) async {
    final ownsSession = operation ?? _referenceGuard();
    if (!ownsSession()) return;
    final result = await DatabaseX.getCountriesList();
    if (ownsSession()) countriesList.value = result;
  }

  /// Load languages
  Future<void> loadLanguages([bool Function()? operation]) async {
    final ownsSession = operation ?? _referenceGuard();
    if (!ownsSession()) return;
    try {
      final result = await DatabaseX.getNativeLanguages();
      if (!ownsSession()) return;
      languagesList.value = result;
    } catch (_) {}
    if (!ownsSession()) return;

    /// If languages is empty, add english and arabic
    if (languagesList.isEmpty) {
      languagesList.add(Language(code: "en", name: "English"));
      languagesList.add(Language(code: "ar", name: "Arabic"));
    }
  }

  /// Load phone codes
  Future<void> loadPhoneCodes([bool Function()? operation]) async {
    final ownsSession = operation ?? _referenceGuard();
    if (!ownsSession()) return;
    try {
      /// Get phone codes
      final result = await DatabaseX.getPhoneCodeCountriesList();
      if (!ownsSession()) return;
      phoneCodesList.value = result;

      /// Set default country code if available
      if (phoneCodesList.isNotEmpty) {
        /// Get saudi code
        var saudiCode = phoneCodesList.firstWhere(
          (code) => code.code == "SA",
          orElse: () => phoneCodesList.first,
        );
        countryCode.value = saudiCode.dialCode;
      }
    } catch (_) {}
    if (!ownsSession()) return;

    /// If phone codes is empty, add saudi code
    if (phoneCodesList.isEmpty) {
      phoneCodesList.add(
        PhoneCode(code: "SA", name: "Saudi Arabia", dialCode: "+966"),
      );
      countryCode.value = phoneCodesList.first.dialCode;
    }
  }

  /// Change image
  Future<void> changeImage({bool isGallery = true}) async {
    final ownsSession = _sessionGuard();
    if (!ownsSession()) return;

    /// Close the bottom sheet
    Get.back();

    /// Open the user's photo gallery to select a photo
    var x = await picker.pickImage(
      source: isGallery ? ImageSource.gallery : ImageSource.camera,
    );

    /// If an image is selected, the data is updated
    if (x != null && ownsSession()) {
      image = x;
      update();
    }
  }

  /// Get form data
  UpdateUserForm get formData => UpdateUserForm(
    username: app.user.value.username.trim(),
    email: app.user.value.email.trim(),
    firstname: app.user.value.firstname.trim(),
    lastname: app.user.value.lastname.trim(),
    language: language.value.trim(),
    gender: gender.value.trim(),
    whatsappNumber: countryCode.value + whatsapp.text.trim(),
    countryPhoneCode: countryCode.value,
    hearAboutUs: howToFindUs.value.trim(),
    telegramId: telegramId.text.trim(),
    telegramName: telegramName.text.trim(),
    isSaudiUniversityStudent: isSaudiUniversity.value,
    saudiUniversityName: university.value.trim(),
    country: country.value.trim(),
    city: city.text.trim(),
    howToFindUsOthers: howToFindUsOthers.text.trim(),
    birthOfDate: birthDate,
  );

  /// Save and update user data
  Future<void> onEdit() async {
    if (isLoading.value || isClosed) return;
    final ownsSession = _sessionGuard();
    if (!ownsSession()) return;
    final form = formKey.currentState;
    if (form == null) return;
    autoValidate.value = AutovalidateMode.onUserInteraction;
    if (!validateAndRevealFirstError(form)) return;
    // Preserve the existing gender policy; the normal default is visibly male.
    if (gender.value.isEmpty) {
      ToastX.error(message: 'Please select a gender');
      return;
    }
    _buttonResetTimer?.cancel();
    isLoading.value = true;
    buttonState.value = ButtonStateEX.loading;
    final selectedImage = image;
    var saveCall = true;
    try {
      final message = await DatabaseX.updateUser(
        form: formData,
        username: app.user.value.username.trim(),
      );
      saveCall = false;
      if (!ownsSession()) return;
      if (selectedImage != null) {
        try {
          await DatabaseX.updateUserImage(image: File(selectedImage.path));
        } catch (_) {
          if (!ownsSession()) return;
          buttonState.value = ButtonStateEX.failed;
          ToastX.error(
            message:
                'Profile information saved, but the photo could not be uploaded. Please try again.',
          );
          return;
        }
        if (!ownsSession()) return;
      }
      if (profileMissing) {
        // The data is saved, so the real profile can be loaded now. If the
        // server still refuses it, the error shows here and the user stays.
        final user = await DatabaseX.getUser(userId: app.user.value.id);
        if (!ownsSession()) return;
        app.user = user.obs;
        profileMissing = false;
      }
      ToastX.success(message: message);
      buttonState.value = ButtonStateEX.success;
      await Future<void>.delayed(
        const Duration(seconds: StyleX.successButtonSecond),
      );
      if (ownsSession()) Get.offAllNamed(RouteNameX.root);
    } catch (error) {
      if (!ownsSession()) return;
      buttonState.value = ButtonStateEX.failed;
      // The server refuses every call of an account whose setup it sees as
      // incomplete, the save included. Its own text ("setup not complete yet")
      // reads as the screen the user is already on, so say what is happening.
      final notSetUp =
          saveCall &&
          error.toErrorX.details[NameX.errorcode] == 'usernotfullysetup';
      ToastX.error(message: notSetUp ? _accountNotSetUpMessage.tr : error);
    } finally {
      if (ownsSession()) {
        isLoading.value = false;
        _buttonResetTimer = Timer(
          const Duration(seconds: StyleX.returnButtonToNormalStateSecond),
          () {
            if (ownsSession()) buttonState.value = ButtonStateEX.normal;
          },
        );
      }
    }
  }

  static const _accountNotSetUpMessage =
      'Your account setup is not complete on the server, so the data could not be saved. Please contact support.';

  /// Async results belong only to this controller and the initiating session.
  bool Function() _sessionGuard() {
    final lease = SessionLeaseX.capture(isActive: () => _ownerLease.isCurrent);
    return () => lease.isCurrent;
  }

  bool get ownsCurrentSession => _ownerLease.isCurrent;

  bool Function() _referenceGuard() {
    final ownsSession = _sessionGuard();
    final locale = TranslationX.getLanguageCode;
    return () => ownsSession() && TranslationX.getLanguageCode == locale;
  }

  /// Complete later
  ///
  /// An account without a loadable profile cannot use the app yet, so it signs
  /// out instead; its data can be completed on the next sign in.
  Future<void> completeLater() async {
    if (profileMissing) {
      await app.logOut();
      return;
    }
    Get.offAllNamed(RouteNameX.root);
  }

  /// Change country code
  void changeCountryCode(String value) => countryCode.value = value;

  /// Change gender
  void changeGender(String? value) => gender.value = value ?? gender.value;

  /// Change country
  void changeCountry(String? value) => country.value = value ?? country.value;

  /// Change language
  void changeLanguage(String? value) =>
      language.value = value ?? language.value;

  /// Change how to find us
  void changeHowToFindUs(String? value) =>
      howToFindUs.value = value ?? howToFindUs.value;

  /// Change is saudi university
  void changeIsSaudiUniversity(bool? value) =>
      isSaudiUniversity.value = value ?? isSaudiUniversity.value;

  /// Change university
  void changeUniversity(String? value) =>
      university.value = value ?? university.value;

  //============================================================================
  // Lifecycle

  @override
  void onInit() {
    super.onInit();
    final accountId = app.user.value.id;
    _ownerLease = SessionLeaseX.capture(
      isActive: () =>
          !isClosed &&
          Get.isRegistered<CompleteAccountInfoController>() &&
          identical(Get.find<CompleteAccountInfoController>(), this) &&
          Get.isRegistered<AppControllerX>() &&
          identical(Get.find<AppControllerX>(), app) &&
          app.user.value.id == accountId,
    );

    /// Initialize form key
    formKey = GlobalKey<FormState>();

    /// Initialize username controller
    // usernameController.text = appController.user.value.username;
  }

  @override
  void onClose() {
    _buttonResetTimer?.cancel();

    /// Dispose controllers
    dateOfBirth.dispose();
    whatsapp.dispose();
    city.dispose();
    telegramId.dispose();
    telegramName.dispose();
    howToFindUsOthers.dispose();
    // usernameController.dispose();
    super.onClose();
  }
}
