import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';

import '../../../../../Config/config.dart';
import '../../../../Widget/Basic/Other/label.dart';
import '../../../../Widget/Custom/Other/course_carousel.dart';
import '../../controller/controller.dart';

class CurrentLevelSection extends GetView<HomeController> {
  const CurrentLevelSection({super.key});

  @override
  Widget build(BuildContext context) {
    /// Build current level section
    return Obx(() {
      final level = controller.currentLevel.value;
      if (level == null) return const SizedBox.shrink();
      return Column(
        children: [
          /// Current level label
          LabelX(
            "Your courses at current level",
            hint: "(${level.name})",
            marginBottom: 12,
          ).fadeAnimation350.marginSymmetric(horizontal: StyleX.hPaddingApp),

          /// Current level courses
          CourseCarousel(
            courses: level.courses,
            onTap: controller.onCourseTap,
          ).fadeAnimation400,
        ],
      );
    });
  }
}
