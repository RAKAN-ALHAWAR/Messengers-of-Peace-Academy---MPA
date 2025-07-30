import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/Basic/Utils/future_builder.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import '../../../../Widget/Basic/Other/label.dart';
import '../controller/controller.dart';
import 'sections/loading.dart';
import 'sections/profile_image_section.dart';

class CompleteAccountInfoView extends GetView<CompleteAccountInfoController> {
  const CompleteAccountInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    /// Complete account info view
    return Scaffold(
      /// App bar
      appBar: AppBarX(
        title: 'Complete Account Information',
        isBack: false,
        backgroundColor: Colors.transparent,
        color: Theme.of(context).textTheme.bodyLarge?.color,
      ),

      /// Content
      body: SafeArea(
        /// Future builder to load data
        child: FutureBuilderX(
          /// Future to load data
          future: controller.getData,

          /// Loading widget
          loading: const LoadingCompleteAccountInfo(),

          /// Data widget
          child: (_) {
            return SingleChildScrollView(
              padding: StyleX.paddingApp,
              child: Obx(
                /// Lock the screen if loading
                () => AbsorbPointer(
                  absorbing: controller.isLoading.value,
                  child: Column(
                    children: [
                      /// Profile image section
                      ProfileImageSectionX().marginOnly(bottom: 24),

                      /// Personal information label
                      LabelX(
                        "Personal Information",
                        marginBottom: 12,
                      ).fadeAnimation200,

                      /// Personal information form
                      Form(
                        key: controller.formKey,
                        autovalidateMode: controller.autoValidate,
                        child: Column(
                          children: [
                            /// Username
                            // TextFieldX(
                            //   controller: controller.usernameController,
                            //   hint: "Username",
                            //   validate: ValidatorX.username,
                            //   textInputType: TextInputType.name,
                            //   textInputAction: TextInputAction.next,
                            //   margin: EdgeInsets.only(bottom: 12),
                            // ).fadeAnimation200,

                            /// Date of Birth
                            TextFieldDateX(
                              hint: "Date of Birth",
                              controller: controller.dateOfBirth,
                              icon: IconX.today,
                              margin: EdgeInsets.only(bottom: 12),
                              validate: ValidatorX.date,
                            ).fadeAnimation200,

                            /// Whatsapp number
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Whatsapp number
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
                            ).fadeAnimation200.marginOnly(bottom: 12),

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
                              marginBottom: 12,
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
                            ).fadeAnimation300.marginOnly(bottom: 12),

                            /// City
                            TextFieldX(
                              controller: controller.city,
                              hint: "City",
                              validate: ValidatorX.city,
                              textInputType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              margin: EdgeInsets.only(bottom: 12),
                            ).fadeAnimation300,

                            /// Native language dropdown
                            DropdownX(
                              hint: "Your Native Language",
                              value: controller.language.value,
                              onChanged: controller.changeLanguage,
                              list:
                                  controller.languagesList
                                      .map((e) => e.name)
                                      .toList(),
                            ).fadeAnimation300.marginOnly(bottom: 12),

                            /// How did you hear about us dropdown
                            DropdownX(
                              hint: "How did you hear about us",
                              value: controller.howToFindUs.value,
                              list: controller.howToFindUsList,
                              onChanged: controller.changeHowToFindUs,
                            ).fadeAnimation300.marginOnly(bottom: 12),

                            /// How did you hear about us text field if others
                            if (controller.howToFindUs.value == "Others")
                              TextFieldX(
                                controller: controller.howToFindUsOthers,
                                hint: "Others",
                                validate: ValidatorX.required,
                                textInputType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                margin: EdgeInsets.only(bottom: 12),
                              ).fadeAnimation300,

                            /// Telegram ID
                            TextFieldX(
                              controller: controller.telegramId,
                              hint: "Your Telegram ID",
                              validate: ValidatorX.required,
                              textInputType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              margin: EdgeInsets.only(bottom: 12),
                            ).fadeAnimation350,

                            /// Telegram name
                            TextFieldX(
                              controller: controller.telegramName,
                              hint: "Your Telegram Name",
                              validate: ValidatorX.required,
                              textInputType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              margin: EdgeInsets.only(bottom: 12),
                            ).fadeAnimation350,

                            /// If saudi universities label
                            LabelInputX(
                              "Are you a scholarship student at one of the Saudi universities?",
                              marginBottom: 8,
                            ).fadeAnimation400,

                            /// If saudi universities radio buttons
                            Row(
                              children: [
                                /// Yes radio button for saudi universities
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

                                /// No radio button for saudi universities
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
                            ).fadeAnimation400,

                            /// Saudi universities dropdown if yes
                            if (controller.isSaudiUniversity.value)
                              DropdownX(
                                hint: "What university do you study at",
                                value: controller.university.value,
                                list: controller.universities,
                                onChanged: controller.changeUniversity,
                              ).fadeAnimation400.marginOnly(top: 12),
                          ],
                        ),
                      ).marginOnly(bottom: 24),

                      /// Save and complete later buttons
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
                          SizedBox(width: 12),

                          /// Complete later button
                          Expanded(
                            child: ButtonX.second(
                              text: "Complete Later",
                              onTap: controller.completeLater,
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
