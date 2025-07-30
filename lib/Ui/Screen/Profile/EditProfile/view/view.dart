import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

import '../../../../../Config/config.dart';
import '../../../../../Core/core.dart';
import '../../../../Widget/Basic/Other/label.dart';
import '../../../../Widget/Basic/Utils/future_builder.dart';
import '../controller/controller.dart';
import 'Sections/loading.dart';
import 'sections/profile_image_section.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarX(title: "Edit Personal Information"),
      body: SafeArea(
        child: FutureBuilderX(
          future: controller.getData,
          loading: EditProfileLoading(),
          child: (_) {
            return SingleChildScrollView(
              padding: StyleX.paddingApp,
              child: Obx(
                () => AbsorbPointer(
                  /// Lock screen when loading
                  absorbing: controller.isLoading.value,
                  child: Column(
                    children: [
                      /// Profile image
                      ProfileImageSectionX().marginOnly(bottom: 24),

                      /// Personal information label
                      LabelX(
                        "Personal Information",
                        marginBottom: 16,
                      ).fadeAnimation200,

                      /// Form fields
                      Form(
                        key: controller.formKey,
                        autovalidateMode: controller.autoValidate,
                        child: Column(
                          children: [
                            /// First Name and Last Name inputs
                            Row(
                              children: [
                                /// First Name input
                                Flexible(
                                  child: TextFieldX(
                                    controller: controller.firstName,
                                    hint: "First Name",
                                    validate: ValidatorX.name,
                                    textInputType: TextInputType.name,
                                    textInputAction: TextInputAction.next,
                                    margin: EdgeInsets.zero,
                                    onlyRead: true,
                                  ),
                                ),

                                /// Spacer
                                SizedBox(width: 16),

                                /// Last Name input
                                Flexible(
                                  child: TextFieldX(
                                    controller: controller.lastName,
                                    hint: "Last Name",
                                    validate: ValidatorX.name,
                                    textInputType: TextInputType.name,
                                    textInputAction: TextInputAction.next,
                                    margin: EdgeInsets.zero,
                                    onlyRead: true,
                                  ),
                                ),
                              ],
                            ).marginOnly(bottom: 8).fadeAnimation200,

                            /// Note that you cannot change the name later unless you contact us
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child:
                                  Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              "${"To change the name, please".tr} ",
                                          style: TextStyleX.bodySmall.copyWith(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.onSurface,
                                          ),
                                        ),
                                        TextSpan(
                                          recognizer:
                                              TapGestureRecognizer()
                                                ..onTap =
                                                    controller.onContactUs,
                                          text: "contact us.".tr,
                                          style: TextStyleX.bodySmall.copyWith(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ).marginOnly(bottom: 18).fadeAnimation200,
                            ),

                            /// Username input
                            TextFieldX(
                              controller: controller.username,
                              hint: "Username",
                              validate: ValidatorX.username,
                              textInputType: TextInputType.name,
                              textInputAction: TextInputAction.next,
                              margin: EdgeInsets.only(bottom: 16),
                              onlyRead: true,
                            ).fadeAnimation200,

                            /// Email input
                            TextFieldX(
                              controller: controller.email,
                              hint: "Email",
                              validate: ValidatorX.email,
                              textInputType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              margin: EdgeInsets.only(bottom: 16),
                            ).fadeAnimation200,

                            /// Age dropdown
                            DropdownX(
                              hint: "Age",
                              value: controller.age.value,
                              list: controller.ageList,
                              onChanged: controller.changeAge,
                            ).fadeAnimation200.marginOnly(bottom: 16),

                            /// WhatsApp number and country code inputs
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// WhatsApp number input
                                Expanded(
                                  child: TextFieldX(
                                    controller: controller.whatsapp,
                                    hint: "WhatsApp Number",
                                    validate: ValidatorX.phone,
                                    textInputType: TextInputType.phone,
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),

                                /// Spacer
                                SizedBox(width: 8),

                                /// Country code dropdown
                                SizedBox(
                                  width: 100,
                                  height: 65,
                                  child: Center(
                                    child: DropdownX(
                                      value: controller.countryCode.value,
                                      onlyEnglish: true,
                                      onChanged: controller.changeCountryCode,
                                      list:
                                          controller.phoneCodesList
                                              .map((e) => e.dialCode)
                                              .toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ).fadeAnimation200.marginOnly(bottom: 16),

                            /// Gender label
                            LabelInputX(
                              "Gender",
                              marginBottom: 8,
                            ).fadeAnimation250,

                            /// Gender radio buttons
                            Row(
                              children: [
                                /// Male radio button
                                Expanded(
                                  child: RadioButtonX(
                                    value: "male",
                                    label: "Male",
                                    groupValue: controller.gender.value,
                                    onChanged: controller.changeGender,
                                  ),
                                ),

                                /// Spacer
                                SizedBox(width: 8),

                                /// Female radio button
                                Expanded(
                                  child: RadioButtonX(
                                    value: "female",
                                    label: "Female",
                                    groupValue: controller.gender.value,
                                    onChanged: controller.changeGender,
                                  ),
                                ),
                              ],
                            ).fadeAnimation250.marginOnly(bottom: 24),

                            /// University information label
                            LabelX(
                              "University Information",
                              marginBottom: 16,
                            ).fadeAnimation250,

                            /// Current city of residence dropdown
                            DropdownX(
                              hint: "Current City of Residence",
                              value: controller.country.value,
                              onChanged: controller.changeCountry,
                              list:
                                  controller.countriesList
                                      .map((e) => e.name)
                                      .toList(),
                            ).fadeAnimation300.marginOnly(bottom: 16),

                            /// City input
                            TextFieldX(
                              controller: controller.city,
                              hint: "City",
                              validate: ValidatorX.city,
                              textInputType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              margin: EdgeInsets.only(bottom: 16),
                            ).fadeAnimation300,

                            /// Native language dropdown
                            DropdownX(
                              hint: "Your Native Language",
                              value: controller.language.value,
                              list:
                                  controller.languagesList
                                      .map((e) => e.name)
                                      .toList(),
                              onChanged: controller.changeLanguage,
                            ).fadeAnimation300.marginOnly(bottom: 16),

                            /// How did you hear about us dropdown
                            DropdownX(
                              hint: "How did you hear about us",
                              value: controller.howToFindUs.value,
                              list: controller.howToFindUsList,
                              onChanged: controller.changeHowToFindUs,
                            ).fadeAnimation300.marginOnly(bottom: 16),

                            /// Others input
                            if (controller.howToFindUs.value == "Others")
                              TextFieldX(
                                controller: controller.howToFindUsOthers,
                                hint: "Others",
                                validate: ValidatorX.required,
                                textInputType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                margin: EdgeInsets.only(bottom: 16),
                              ).fadeAnimation300,

                            /// Telegram ID input
                            TextFieldX(
                              controller: controller.telegramId,
                              hint: "Your Telegram ID",
                              validate: ValidatorX.required,
                              textInputType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              margin: EdgeInsets.only(bottom: 16),
                            ).fadeAnimation350,

                            /// Telegram name input
                            TextFieldX(
                              controller: controller.telegramName,
                              hint: "Your Telegram Name",
                              validate: ValidatorX.required,
                              textInputType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              margin: EdgeInsets.only(bottom: 16),
                            ).fadeAnimation350,

                            /// Scholarship student label
                            LabelInputX(
                              "Are you a scholarship student at one of the Saudi universities?",
                              marginBottom: 8,
                            ).fadeAnimation400,

                            /// Scholarship student radio buttons
                            Row(
                              children: [
                                /// Yes radio button
                                Expanded(
                                  child: RadioButtonX(
                                    value: true,
                                    label: "Yes",
                                    groupValue:
                                        controller.isSaudiUniversity.value,
                                    onChanged:
                                        controller.changeIsSaudiUniversity,
                                  ),
                                ),

                                /// Spacer
                                SizedBox(width: 8),

                                /// No radio button
                                Expanded(
                                  child: RadioButtonX(
                                    value: false,
                                    label: "No",
                                    groupValue:
                                        controller.isSaudiUniversity.value,
                                    onChanged:
                                        controller.changeIsSaudiUniversity,
                                  ),
                                ),
                              ],
                            ).fadeAnimation400.marginOnly(
                              bottom:
                                  controller.isSaudiUniversity.value ? 16 : 24,
                            ),

                            /// Saudi university dropdown
                            if (controller.isSaudiUniversity.value)
                              DropdownX(
                                hint: "What university do you study at",
                                value: controller.university.value,
                                list: controller.universities,
                                onChanged: controller.changeUniversity,
                              ).fadeAnimation400.marginOnly(bottom: 24),
                          ],
                        ),
                      ),

                      /// Save and cancel buttons
                      Row(
                        children: [
                          /// Save button
                          Expanded(
                            child: ButtonStateX(
                              text: "Save",
                              state: controller.buttonState.value,
                              onTap: controller.onEdit,
                            ),
                          ),

                          /// Spacer
                          SizedBox(width: 16),

                          /// Cancel button
                          Expanded(
                            child: ButtonX.second(
                              text: "Cancel",
                              onTap: Get.back,
                            ),
                          ),
                        ],
                      ).fadeAnimation450,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
