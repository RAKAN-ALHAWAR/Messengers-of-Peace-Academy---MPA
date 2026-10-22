import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';

import '../../../../../Config/config.dart';
import '../../../../Widget/Custom/Other/gradient_progress_bar.dart';
import '../../../../Widget/widget.dart';
import '../../controller/controller.dart';

class LevelProgressCard extends GetView<HomeController> {
  const LevelProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    /// Build level progress card
    return Obx(() {
      final level = controller.currentLevel.value;
      if (level == null) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Stack(
          children: [
            /// Background
            Container(
              width: double.infinity,
              height: 80,
              decoration: BoxDecoration(gradient: ColorX.primaryGradient),
            ),

            /// Content
            Padding(
              padding: EdgeInsets.only(
                top: 16,
                right: StyleX.hPaddingApp,
                left: StyleX.hPaddingApp,
              ),
              child: Column(
                children: [
                  /// Level Progress
                  Container(
                    height: 126,
                    decoration: BoxDecoration(
                      gradient: ColorX.goldGradient,
                      borderRadius: BorderRadius.circular(StyleX.radiusLg),
                      border: Border.all(color: Color(0xFFFEF4D5), width: 2),
                    ),
                    child: Stack(
                      children: [
                        /// Background Image
                        Opacity(
                          opacity: 0.2,
                          child: Image.asset(
                            ImageX.background,
                            height: 126,
                            width: double.infinity,
                            fit: BoxFit.fitHeight,
                            alignment: Alignment.center,
                          ),
                        ),

                        /// Content
                        Container(
                          height: 126,
                          width: double.infinity,
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              /// Level Progress
                              Row(
                                children: [
                                  Image.asset(
                                    ImageX.doneLevel,
                                    width: 18,
                                    height: 18,
                                  ),
                                  SizedBox(width: 6),
                                  TextX(
                                    level.name,
                                    style: TextStyleX.titleMedium,
                                    color: ColorX.yellow.shade900,
                                  ),
                                ],
                              ),

                              /// Level Progress Bar
                              GlassX(
                                isLight: true,
                                opacity: 0.35,
                                radius: BorderRadius.circular(100),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      /// Level Progress Bar
                                      Expanded(
                                        child: GradientProgressBar(
                                          value: level.completionPercent / 100,
                                        ),
                                      ),

                                      /// Spacer
                                      SizedBox(width: 10),

                                      /// Level courses count text
                                      TextX(
                                        "${level.completedCourses}/${level.totalCourses} ${"Course (session)".tr}",
                                        style: TextStyleX.labelMedium,
                                        color: ColorX.yellow.shade900,
                                      ),
                                    ],
                                  ),
                                ),
                              ).marginSymmetric(vertical: 4),

                              /// Level progress text
                              TextX(
                                "${"I have completed".tr} ${level.completionPercent.toInt()}%"
                                " "
                                "${"from".tr} ${level.name}",
                                style: TextStyleX.labelLarge,
                                color: ColorX.yellow.shade900,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// Spacer
                  SizedBox(height: 6),
                ],
              ),
            ).fadeAnimation150,
          ],
        ),
      );
    });
  }
}
