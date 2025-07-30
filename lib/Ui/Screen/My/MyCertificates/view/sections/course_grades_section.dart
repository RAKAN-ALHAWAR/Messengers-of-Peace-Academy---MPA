import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/Basic/Other/label.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../../../../../Widget/Custom/Other/empty_message.dart';
import '../../controller/controller.dart';

class CourseGradesSection extends GetView<MyCertificatesController> {
  const CourseGradesSection({super.key});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: StyleX.hPaddingApp),
        child: Column(
          children: [
            /// Course grades label
            LabelX(
              "My school course grades",
            ).fadeAnimation200.marginOnly(bottom: 12),

            /// If there are no courses, show empty message
            if (controller.courses.isEmpty)
              EmptyMessage('No courses').fadeAnimation250.marginOnly(top: 150),

            /// If there are courses, show them
            if (controller.courses.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      /// Course list cards
                      for (var course in controller.courses)
                        ContainerX(
                          height: 78,
                          radius: StyleX.radiusMd,
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          margin: EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              /// Course name
                              TextX(
                                course.fullName,
                                style: TextStyleX.titleMedium,
                              ),

                              /// Circular percent indicator
                              Center(
                                child: CircularPercentIndicator(
                                  radius: 26.0,
                                  lineWidth: 5.0,
                                  percent: course.completionPercent / 100,
                                  center: TextX(
                                    "%${course.completionPercent}",
                                    style: TextStyleX.labelMedium,
                                    textDirection: TextDirection.ltr,
                                  ),
                                  circularStrokeCap: CircularStrokeCap.round,
                                  animation: true,
                                  progressColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
