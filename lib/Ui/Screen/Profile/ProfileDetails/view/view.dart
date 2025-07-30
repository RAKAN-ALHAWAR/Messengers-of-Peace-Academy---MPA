import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/Basic/Utils/future_builder.dart';
import '../../../../../Ui/Widget/widget.dart';
import '../../../../Section/UserStat/user_statistics.dart';
import '../../../../Widget/Basic/Other/label.dart';
import '../../../../Widget/Custom/Card/option_card.dart';
import '../controller/controller.dart';
import 'sections/loading.dart';
import 'sections/under_appbar.dart';

class ProfileDetailsView extends GetView<ProfileDetailsController> {
  const ProfileDetailsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilderX(
        future: controller.getData,

        /// Loading state
        loading: const ProfileDetailsLoading(),

        /// Data state
        child: (_) {
          return SingleChildScrollView(
            child: Column(
              children: [
                /// User data and points card
                ProfileDetailsUnderAppbarSection(),

                /// Statistics, options cards and logout bottom
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: StyleX.hPaddingApp,
                    vertical: 16,
                  ),
                  child: Column(
                    children: [
                      /// My Progress label
                      LabelX("My Progress", marginBottom: 12).fadeAnimation150,

                      /// User statistics
                      UserStatisticsSection(
                        statistics: controller.statistics.value,
                      ).fadeAnimation200,

                      /// Spacer
                      SizedBox(height: 24),

                      /// My Account label
                      LabelX("My Account", marginBottom: 12).fadeAnimation250,

                      /// Achievements Board
                      OptionCardX(
                        title: "Achievements Board",
                        icon: IconX.social_leaderboard,
                        onTap: controller.onAchievementsBoard,
                      ).fadeAnimation250,

                      /// Leaderboard
                      OptionCardX(
                        title: "Leaderboard",
                        icon: IconX.trophy,
                        onTap: controller.onLeaderboard,
                      ).fadeAnimation250,

                      /// Edit Personal Information
                      OptionCardX(
                        title: "Edit Personal Information",
                        icon: IconX.person,
                        onTap: controller.onEditPersonalData,
                      ).fadeAnimation250,

                      /// Enrolled Courses
                      OptionCardX(
                        title: "Enrolled Courses",
                        icon: IconX.school,
                        onTap: controller.onCoursesAttended,
                      ).fadeAnimation300,
                      OptionCardX(
                        title: "My Grades and Certificates",
                        icon: IconX.verified,
                        onTap: controller.onMyGradesAndCertificates,
                      ).fadeAnimation300,

                      /// Update Password
                      OptionCardX(
                        title: "Update Password",
                        icon: IconX.lock,
                        onTap: controller.onUpdatePassword,
                        marginBottom: 24,
                      ).fadeAnimation300,
                      LabelX("Application", marginBottom: 12).fadeAnimation350,

                      /// Dark Mode switch
                      OptionCardX(
                        title: "Dark Mode",
                        icon: IconX.dark_mode,
                        onTap: controller.onChangeDarkMode,
                        child: Obx(
                          () => Transform.scale(
                            scale: 1.2,
                            child: SwitchX(
                              value: controller.themeIsDark.value,
                              onChange: (_) => controller.onChangeDarkMode(),
                            ),
                          ),
                        ),
                      ).fadeAnimation350,

                      /// App Language change
                      OptionCardX(
                        title: "App Language",
                        icon: IconX.g_translate,
                        onTap: controller.onChangeLanguage,
                      ).fadeAnimation350,

                      /// Submit Complaint or Suggestion
                      OptionCardX(
                        title: "Submit Complaint or Suggestion",
                        icon: IconX.chat,
                        onTap: controller.onSubmitComplaintOrSuggestion,
                        marginBottom: 24,
                      ).fadeAnimation350,

                      /// Logout button
                      ButtonX.dangerous(
                        text: "Logout",
                        iconData: IconX.logout,
                        onTap: () async {
                          /// Show logout confirmation bottom sheet
                          await bottomSheetX(
                            child: Column(
                              children: [
                                /// Warning icon
                                Image.asset(
                                  ImageX.warning,
                                  width: 80,
                                  height: 80,
                                ).fadeAnimation150.marginOnly(
                                  bottom: 16,
                                  top: 14,
                                ),

                                /// Warning text
                                TextX(
                                      "Are you sure you want to logout?",
                                      textAlign: TextAlign.center,
                                      style: TextStyleX.titleSLarge,
                                    ).fadeAnimation150
                                    .marginSymmetric(horizontal: 50)
                                    .marginOnly(bottom: 16),

                                /// Logout buttons
                                Row(
                                  children: [
                                    /// Stay button
                                    Flexible(
                                      child: ButtonX(
                                        text: "Stay",
                                        onTap: Get.back,
                                      ),
                                    ),

                                    /// Spacer
                                    const SizedBox(width: 8),

                                    /// Logout button
                                    Flexible(
                                      child: ButtonX.dangerous(
                                        text: "Logout",
                                        onTap: controller.onLogout,
                                      ),
                                    ),
                                  ],
                                ).fadeAnimation200,
                              ],
                            ),
                          );
                        },
                      ).fadeAnimation400,
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
