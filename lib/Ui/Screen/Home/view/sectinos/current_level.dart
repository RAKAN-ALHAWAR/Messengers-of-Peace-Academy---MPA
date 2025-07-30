import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';

import '../../../../../Config/config.dart';
import '../../../../Widget/Basic/Other/label.dart';
import '../../../../Widget/Custom/Card/course_card.dart';
import '../../controller/controller.dart';

class CurrentLevelSection extends GetView<HomeController> {
  const CurrentLevelSection({super.key});

  @override
  Widget build(BuildContext context) {
    /// Build current level section
    return Obx(
      () => Column(
        children: [
          /// Current level label
          LabelX(
            "${"Your courses at current level".tr} (${controller.currentLevel.value.name})",
            marginBottom: 12,
          ).fadeAnimation350.marginSymmetric(horizontal: StyleX.hPaddingApp),

          /// Current level courses
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsetsDirectional.only(
              start: StyleX.hPaddingApp,
              bottom: 24,
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  /// Current level courses
                  for (var course in controller.currentLevel.value.courses)
                    CourseCard(
                      course: course,
                      onTap: (course) => controller.onCourseTap(course),
                    ),
                ],
              ),
            ),
          ).fadeAnimation400,
        ],
      ),
    );
  }
}
