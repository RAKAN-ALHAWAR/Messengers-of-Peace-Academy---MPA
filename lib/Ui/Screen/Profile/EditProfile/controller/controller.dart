import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messengersofpeace/Core/Error/error.dart';
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
  late var age =
      (ageList.firstWhereOrNull((element) => element == app.user.value.age) ==
                  null
              ? ""
              : app.user.value.age)
          .obs;
  late var howToFindUs =
      (howToFindUsList.firstWhereOrNull(
                    (element) => element == app.user.value.howToFindUs,
                  ) ==
                  null
              ? ""
              : app.user.value.howToFindUs)
          .obs;
  late var isSaudiUniversity = app.user.value.isSaudiUniversity.obs;
  late var university =
      (universities.firstWhereOrNull(
                    (element) => element == app.user.value.university,
                  ) ==
                  null
              ? ""
              : app.user.value.university)
          .obs;

  // API Data Lists
  final countriesList = <Country>[].obs;
  final phoneCodesList = <PhoneCode>[].obs;
  final languagesList = <Language>[].obs;

  // Static data for dropdowns that don't come from API
  final ageList = ConstantX.ageList;
  final howToFindUsList = ConstantX.howToFindUsList;
  final universities = ConstantX.universities;

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
  AutovalidateMode autoValidate = AutovalidateMode.disabled;

  //============================================================================
  // Functions

  /// Get data from database
  Future<void> getData() async {
    // Load data in parallel
    await Future.wait<void>([
      loadCountries(),
      loadPhoneCodes(),
      loadLanguages(),
    ]);
  }

  /// Navigate to contact us screen
  void onContactUs() async {
    var url = Uri.parse('https://mopacademy.org/mod/page/view.php?id=80');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  /// Load countries from database
  loadCountries() async {
    try {
      countriesList.value = await DatabaseX.getCountriesList();
    } catch (_) {}

    /// Set default country if not found
    if (countriesList.firstWhereOrNull(
          (element) => element.name == country.value,
        ) ==
        null) {
      country.value = "";
    }
  }

  /// Load phone codes from database
  loadPhoneCodes() async {
    try {
      phoneCodesList.value = await DatabaseX.getPhoneCodeCountriesList();
    } catch (e) {
      ErrorX.console(e);
    }

    /// Set default country code if not found
    if (phoneCodesList.firstWhereOrNull(
          (element) => element.dialCode == countryCode.value,
        ) ==
        null) {
      countryCode.value = "+966";
    }

    /// Add default country code if not found
    if (phoneCodesList.isEmpty) {
      phoneCodesList.add(
        PhoneCode(code: "SA", name: "Saudi Arabia", dialCode: "+966"),
      );
      countryCode.value = phoneCodesList.first.dialCode;
    }
  }

  /// Load languages from database
  loadLanguages() async {
    try {
      languagesList.value = await DatabaseX.getNativeLanguages();
    } catch (_) {}

    /// Set default language if not found
    if (languagesList.firstWhereOrNull(
          (element) => element.name == language.value,
        ) ==
        null) {
      language.value = "";
    }

    /// Add default languages if not found
    if (languagesList.isEmpty) {
      languagesList.add(Language(code: "en", name: "English"));
      languagesList.add(Language(code: "ar", name: "Arabic"));
    }
  }

  /// Change image
  changeImage({bool isGallery = true}) async {
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
    gender: gender.value.trim(),
    whatsappNumber: countryCode.value + whatsapp.text.trim(),
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
  onEdit() async {
    /// If loading, return
    if (isLoading.isTrue) {
      return;
    }

    /// If form is valid, proceed
    if (formKey.currentState!.validate()) {
      /// Set loading to true
      isLoading.value = true;
      buttonState.value = ButtonStateEX.loading;

      try {
        /// Update user data in database
        var message = await DatabaseX.updateUser(
          form: formData,
          username: app.user.value.username,
        );

        /// Update user image in database
        if (image != null) {
          try {
            await DatabaseX.updateUserImage(image: File(image!.path));
          } catch (_) {}
        }

        /// Get user data from database
        try {
          app.user.value = await DatabaseX.getUser();
        } catch (_) {}

        /// The time delay here is aesthetically beneficial
        buttonState.value = ButtonStateEX.success;
        await Future.delayed(
          const Duration(seconds: StyleX.successButtonSecond),
        );

        /// Close the edit profile screen
        Get.back();

        /// Show success toast
        ToastX.success(message: message);
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
      /// Show error toast
      ToastX.error(message: "Make sure all fields are filled in correctly.");

      /// Set autovalidate mode to always
      autoValidate = AutovalidateMode.always;
    }
  }

  //============================================================================
  // Lifecycle

  @override
  void onInit() {
    super.onInit();

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
    super.onClose();

    /// Dispose text editing controllers
    firstName.dispose();
    lastName.dispose();
    whatsapp.dispose();
    city.dispose();
    howToFindUsOthers.dispose();
    telegramId.dispose();
    telegramName.dispose();
  }
}
