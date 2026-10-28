import 'dart:math' as math;
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Config/Translation/translation.dart';
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: StyleX.hPaddingApp),
      child: Column(
        children: [
          LabelX(
            'My school course grades',
          ).fadeAnimation200.marginOnly(bottom: 12),
          Expanded(
            child:
                controller.courses.isEmpty
                    /// Empty state, in a Column so it sits at the top with the
                    /// original 150 margin instead of the page centre
                    ? Column(
                      children: [
                        EmptyMessage(
                          'No courses',
                        ).fadeAnimation250.marginOnly(top: 150),
                      ],
                    )
                    : ListView.builder(
                      key: PageStorageKey((
                        LocalDataX.sessionRevision,
                        TranslationX.getLanguageCode,
                        'grades',
                      )),
                      itemCount: controller.courses.length,
                      itemBuilder: (context, index) {
                        final course = controller.courses[index];
                        return ContainerX(
                          minHeight: 78,
                          radius: StyleX.radiusMd,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextX(
                                  course.fullName,
                                  style: TextStyleX.titleMedium,
                                ),
                              ),
                              const SizedBox(width: 12),
                              CircularPercentIndicator(
                                radius:
                                    26.0 *
                                    math.max(
                                      1,
                                      MediaQuery.textScalerOf(
                                            context,
                                          ).scale(12) /
                                          12,
                                    ),
                                lineWidth: 5.0,
                                percent: course.completionPercent / 100,
                                center: TextX(
                                  '%${course.completionPercent}',
                                  style: TextStyleX.labelMedium,
                                  textDirection: TextDirection.ltr,
                                ),
                                circularStrokeCap: CircularStrokeCap.round,
                                animation: true,
                                progressColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
