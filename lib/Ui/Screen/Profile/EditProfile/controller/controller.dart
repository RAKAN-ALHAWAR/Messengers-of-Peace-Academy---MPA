import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messengersofpeace/Core/Service/session_lease.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../../Core/core.dart';
import '../../../../../../Data/data.dart';
import '../../../../../Config/config.dart';
import '../../../../../Data/Form/update_user_form.dart';
import '../../../../../Data/Model/info/country.dart';
import '../../../../../Data/Model/info/language.dart';
import '../../../../../Data/Model/info/phone_code.dart';
import '../../../../Widget/widget.dart';

class EditProfileController extends GetxController {
  //============================================================================
  // Injection of required controls

  AppControllerX app = Get.find();

  //============================================================================
  // Variables

  /// Is loading
  final isLoading = false.obs;

  /// Button state
  final buttonState = ButtonStateEX.normal.obs;

  /// Image picker
  XFile? image;
  final ImagePicker picker = ImagePicker();

  /// Values
  late var countryCode = app.user.value.phoneCodeCountry.obs;
  late var gender = app.user.value.gender.obs;
  late var country = app.user.value.country.obs;
  late var language = app.user.value.language.obs;
  late var age = app.user.value.age.obs;
  late var howToFindUs = app.user.value.howToFindUs.obs;
  late var isSaudiUniversity = app.user.value.isSaudiUniversity.obs;
  late var university = app.user.value.university.obs;

  // API Data Lists
  final countriesList = <Country>[].obs;
  final phoneCodesList = <PhoneCode>[].obs;
  final languagesList = <Language>[].obs;

  // Static data for dropdowns that don't come from API
  final ageList = List<String>.of(ConstantX.ageList);
  final howToFindUsList = List<String>.of(ConstantX.howToFindUsList);
  final universities = List<String>.of(ConstantX.universities);

  /// Text editing controllers
  late TextEditingController firstName;
  late TextEditingController lastName;
  late TextEditingController whatsapp;
  late TextEditingController city;
  late TextEditingController howToFindUsOthers;
  late TextEditingController telegramId;
  late TextEditingController telegramName;
  late TextEditingController username;
  late TextEditingController email;

  /// Form key
  late GlobalKey<FormState> formKey;

  /// Autovalidate mode
  final autoValidate = AutovalidateMode.disabled.obs;
  late final SessionLeaseX _ownerLease;
  Timer? _buttonResetTimer;
  Timer? _successTimer;
  Completer<void>? _successDelay;
  late final String _originalPhone;
  late final String _originalPrefix;
  late final String _originalPhoneInput;
  Map<String, String>? _acknowledgedProfile;
  SessionLeaseX? _acknowledgedLease;
  String? _acknowledgedMessage;

  //============================================================================
  // Functions

  /// Get data from database
  Future<void> getData() async {
    final lease = _captureLease();
    if (!lease.isCurrent) return;
    // Load data in parallel
    await Future.wait<void>([
      loadCountries(lease),
      loadPhoneCodes(lease),
      loadLanguages(lease),
    ]);
  }

  /// Navigate to contact us screen
  void onContactUs() async {
    final lease = _captureLease();
    var url = Uri.parse('https://mopacademy.org/mod/page/view.php?id=80');
    if (await canLaunchUrl(url) && lease.isCurrent) {
      await launchUrl(url);
    }
  }

  /// Load countries from database
  Future<void> loadCountries([SessionLeaseX? operation]) async {
    final lease = operation ?? _captureLease();
    if (!lease.isCurrent) return;
    try {
      final result = await DatabaseX.getCountriesList();
      if (!lease.isCurrent) return;
      countriesList.value = result;
    } catch (_) {}
    if (!lease.isCurrent) return;
    if (country.value.isNotEmpty &&
        !countriesList.any((element) => element.name == country.value)) {
      countriesList.add(Country(code: '', name: country.value));
    }
  }

  /// Load phone codes from database
  Future<void> loadPhoneCodes([SessionLeaseX? operation]) async {
    final lease = operation ?? _captureLease();
    if (!lease.isCurrent) return;
    try {
      final result = await DatabaseX.getPhoneCodeCountriesList();
      if (!lease.isCurrent) return;
      phoneCodesList.value = result;
    } catch (_) {}
    if (!lease.isCurrent) return;
    // Unavailable reference data is not an instruction to replace saved data.
    if (countryCode.value.isNotEmpty &&
        !phoneCodesList.any(
          (element) => element.dialCode == countryCode.value,
        )) {
      phoneCodesList.add(
        PhoneCode(
          code: '',
          name: countryCode.value,
          dialCode: countryCode.value,
        ),
      );
    }
  }

  /// Load languages from database
  Future<void> loadLanguages([SessionLeaseX? operation]) async {
    final lease = operation ?? _captureLease();
    if (!lease.isCurrent) return;
    try {
      final result = await DatabaseX.getNativeLanguages();
      if (!lease.isCurrent) return;
      languagesList.value = result;
    } catch (_) {}
    if (!lease.isCurrent) return;
    if (language.value.isNotEmpty &&
        !languagesList.any((element) => element.name == language.value)) {
      languagesList.add(Language(code: '', name: language.value));
    }
  }

  /// Change image
  Future<void> changeImage({bool isGallery = true}) async {
    final lease = _captureLease();
    if (!lease.isCurrent) return;

    /// Close the bottom sheet
    Get.back();

    /// Open the user's photo gallery to select a photo
    var x = await picker.pickImage(
      source: isGallery ? ImageSource.gallery : ImageSource.camera,
    );

    /// If an image is selected, the data is updated
    if (x != null && lease.isCurrent) {
      image = x;
      update();
    }
  }

  /// Change age
  void changeAge(String? value) => age.value = value ?? age.value;

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

  /// Get form data
  UpdateUserForm get formData => UpdateUserForm(
    username: app.user.value.username,
    email: email.text.trim(),
    firstname: firstName.text.trim(),
    lastname: lastName.text.trim(),
    city: city.text.trim(),
    age: age.value.trim(),
    language: language.value.trim(),
    gender: gender.value.trim().isNotEmpty ? gender.value.trim() : null,
    whatsappNumber:
        countryCode.value == _originalPrefix &&
                whatsapp.text == _originalPhoneInput
            ? _originalPhone
            : countryCode.value + whatsapp.text.trim(),
    countryPhoneCode: countryCode.value,
    hearAboutUs: howToFindUs.value.trim(),
    telegramId: telegramId.text.trim(),
    telegramName: telegramName.text.trim(),
    isSaudiUniversityStudent: isSaudiUniversity.value,
    saudiUniversityName: university.value.trim(),
    country: country.value.trim(),
    howToFindUsOthers: howToFindUsOthers.text.trim(),
  );

  /// Save and update user data
  Future<void> onEdit() async {
    if (isLoading.value || isClosed) return;
    final lease = _captureLease();
    if (!lease.isCurrent) return;
    final form = formKey.currentState;
    if (form == null) return;
    if (!form.validate()) {
      autoValidate.value = AutovalidateMode.always;
      ToastX.error(message: 'Make sure all fields are filled in correctly.');
      return;
    }

    final requestForm = formData;
    final requestUsername = app.user.value.username;
    final selectedImage = image;
    final requestFields = {'username': requestUsername, ...requestForm.toMap()};
    _buttonResetTimer?.cancel();
    isLoading.value = true;
    buttonState.value = ButtonStateEX.loading;
    try {
      // An acknowledged text update is not repeated just to retry its photo.
      // Changes to any serialized field still require a new explicit update.
      if (_acknowledgedLease?.isCurrent != true ||
          !mapEquals(_acknowledgedProfile, requestFields)) {
        final message = await DatabaseX.updateUser(
          form: requestForm,
          username: requestUsername,
        );
        if (!lease.isCurrent) return;
        _acknowledgedProfile = Map.unmodifiable(requestFields);
        _acknowledgedLease = lease;
        _acknowledgedMessage = message;
      }
      if (selectedImage != null) {
        if (!lease.isCurrent) return;
        try {
          await DatabaseX.updateUserImage(image: File(selectedImage.path));
        } catch (_) {
          if (!lease.isCurrent) return;
          buttonState.value = ButtonStateEX.failed;
          ToastX.error(
            message:
                'Profile information saved, but the photo could not be uploaded. Please try again.',
          );
          return;
        }
        if (!lease.isCurrent) return;
      }

      try {
        final refreshed = await DatabaseX.getUser();
        if (!lease.isCurrent) return;
        // A malformed refresh must not replace the initiating account.
        if (refreshed.id == app.user.value.id) app.user.value = refreshed;
      } catch (_) {}
      if (!lease.isCurrent) return;
      buttonState.value = ButtonStateEX.success;
      await _waitForSuccessFeedback();
      if (!lease.isCurrent) return;
      Get.back();
      ToastX.success(message: _acknowledgedMessage);
    } catch (error) {
      if (!lease.isCurrent) return;
      buttonState.value = ButtonStateEX.failed;
      ToastX.error(message: error);
    } finally {
      if (lease.isCurrent) {
        isLoading.value = false;
        _buttonResetTimer = Timer(
          const Duration(seconds: StyleX.returnButtonToNormalStateSecond),
          () {
            if (lease.isCurrent) buttonState.value = ButtonStateEX.normal;
          },
        );
      }
    }
  }

  SessionLeaseX _captureLease() =>
      SessionLeaseX.capture(isActive: () => _ownerLease.isCurrent);

  Future<void> _waitForSuccessFeedback() {
    final delay = Completer<void>();
    _successDelay = delay;
    _successTimer = Timer(
      const Duration(seconds: StyleX.successButtonSecond),
      () {
        _successTimer = null;
        _successDelay = null;
        delay.complete();
      },
    );
    return delay.future;
  }

  //============================================================================
  // Lifecycle

  @override
  void onInit() {
    super.onInit();
    final accountId = app.user.value.id;
    _ownerLease = SessionLeaseX.capture(
      isActive:
          () =>
              !isClosed &&
              Get.isRegistered<EditProfileController>() &&
              identical(Get.find<EditProfileController>(), this) &&
              Get.isRegistered<AppControllerX>() &&
              identical(Get.find<AppControllerX>(), app) &&
              app.user.value.id == accountId,
    );
    _originalPhone = app.user.value.whatsapp;
    _originalPrefix = app.user.value.phoneCodeCountry;
    _originalPhoneInput = app.user.value.phone;
    // A saved legacy option remains visible without changing its wire value.
    for (final (options, current) in [
      (ageList, age.value),
      (howToFindUsList, howToFindUs.value),
      (universities, university.value),
    ]) {
      if (current.isNotEmpty && !options.contains(current)) {
        options.add(current);
      }
    }

    /// Initialize form key
    formKey = GlobalKey<FormState>();

    /// Initialize text editing controllers
    firstName = TextEditingController(text: app.user.value.firstname);
    lastName = TextEditingController(text: app.user.value.lastname);
    whatsapp = TextEditingController(text: app.user.value.phone);
    city = TextEditingController(text: app.user.value.city);
    telegramId = TextEditingController(text: app.user.value.telegramId);
    telegramName = TextEditingController(text: app.user.value.telegramName);
    username = TextEditingController(text: app.user.value.username);
    email = TextEditingController(text: app.user.value.email);
    howToFindUsOthers = TextEditingController(
      text: app.user.value.howToFindUsOthers,
    );
  }

  @override
  void onClose() {
    _buttonResetTimer?.cancel();
    _successTimer?.cancel();
    _successDelay?.complete();
    _successDelay = null;

    /// Dispose text editing controllers
    firstName.dispose();
    lastName.dispose();
    whatsapp.dispose();
    city.dispose();
    howToFindUsOthers.dispose();
    telegramId.dispose();
    telegramName.dispose();
    username.dispose();
    email.dispose();
    super.onClose();
  }
}
