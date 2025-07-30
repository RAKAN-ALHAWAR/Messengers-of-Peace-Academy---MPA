import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Model/info/country.dart';
import 'package:messengersofpeace/Data/Model/info/language.dart';
import 'package:messengersofpeace/Data/Model/info/phone_code.dart';

import '../../../../../Config/config.dart';
import '../../../../../Data/Form/update_user_form.dart';
import '../../../../Widget/widget.dart';

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
  final gender = "Male".obs;
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

  // Form key
  late GlobalKey<FormState> formKey;

  // Autovalidate mode
  AutovalidateMode autoValidate = AutovalidateMode.disabled;

  // Text editing controllers
  TextEditingController dateOfBirth = TextEditingController();
  TextEditingController whatsapp = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController howToFindUsOthers = TextEditingController();
  TextEditingController telegramId = TextEditingController();
  TextEditingController telegramName = TextEditingController();
  // TextEditingController usernameController = TextEditingController();

  //============================================================================
  // Functions

  /// Get data
  Future<void> getData() async {
    /// Load data in parallel
    await Future.wait<void>([
      loadCountries(),
      loadPhoneCodes(),
      loadLanguages(),
    ]);
  }

  /// Load countries
  Future<void> loadCountries() async {
    countriesList.value = await DatabaseX.getCountriesList();
  }

  /// Load languages
  Future<void> loadLanguages() async {
    try {
      languagesList.value = await DatabaseX.getNativeLanguages();
    } catch (_) {}

    /// If languages is empty, add english and arabic
    if (languagesList.isEmpty) {
      languagesList.add(Language(code: "en", name: "English"));
      languagesList.add(Language(code: "ar", name: "Arabic"));
    }
  }

  /// Load phone codes
  Future<void> loadPhoneCodes() async {
    try {
      /// Get phone codes
      phoneCodesList.value = await DatabaseX.getPhoneCodeCountriesList();

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
    /// Close the bottom sheet
    Get.back();

    /// Open the user's photo gallery to select a photo
    var x = await picker.pickImage(
      source: isGallery ? ImageSource.gallery : ImageSource.camera,
    );

    /// If an image is selected, the data is updated
    if (x != null) {
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
    birthOfDate: DateTime.tryParse(dateOfBirth.text.trim()),
  );

  /// Save and update user data
  Future<void> onEdit() async {
    /// Check if the loading is false
    if (isLoading.isFalse) {
      /// Check if the form is valid
      if (formKey.currentState!.validate()) {
        /// Check if the whatsapp number is valid
        if (country.isEmpty) {
          /// Show error toast
          ToastX.error(message: "Please select a country");
          return;
        }

        /// Check if the language is valid
        if (language.isEmpty) {
          /// Show error toast
          ToastX.error(message: "Please select a language");
          return;
        }

        /// Check if the how to find us is valid
        if (howToFindUs.isEmpty) {
          /// Show error toast
          ToastX.error(message: "Please select a how to find us");
          return;
        }

        /// Check if the university is valid
        if (isSaudiUniversity.value && university.isEmpty) {
          /// Show error toast
          ToastX.error(message: "Please select a university");
          return;
        }

        /// Check if the city is valid
        if (gender.value.isEmpty) {
          /// Show error toast
          ToastX.error(message: "Please select a gender");
          return;
        }

        /// Set loading to true
        isLoading.value = true;

        /// Set button state to loading
        buttonState.value = ButtonStateEX.loading;

        try {
          /// Update user data
          var message = await DatabaseX.updateUser(
            form: formData,
            username: app.user.value.username.trim(),
          );

          /// Update user image
          if (image != null) {
            try {
              await DatabaseX.updateUserImage(image: File(image!.path));
            } catch (_) {}
          }

          /// Show success toast
          ToastX.success(message: message);

          /// Set button state to success
          buttonState.value = ButtonStateEX.success;
          await Future.delayed(
            const Duration(seconds: StyleX.successButtonSecond),
          );

          /// Navigate to root
          Get.offAllNamed(RouteNameX.root);
        } catch (e) {
          /// Set button state to failed
          buttonState.value = ButtonStateEX.failed;

          /// Show error toast
          ToastX.error(message: e);
        }

        /// Set loading to false
        isLoading.value = false;

        /// Reset the button state
        Timer(
          const Duration(seconds: StyleX.returnButtonToNormalStateSecond),
          () => buttonState.value = ButtonStateEX.normal,
        );
      } else {
        /// Set autovalidate mode to always
        autoValidate = AutovalidateMode.always;

        /// Show error toast
        ToastX.error(
          message: "Please fill in all fields and verify their accuracy",
        );
      }
    }
  }

  /// Complete later
  void completeLater() => Get.offAllNamed(RouteNameX.root);

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

    /// Initialize form key
    formKey = GlobalKey<FormState>();

    /// Initialize username controller
    // usernameController.text = appController.user.value.username;
  }

  @override
  void onClose() {
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
