import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/Basic/Utils/future_builder.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import '../../../../Widget/Custom/Other/empty_message.dart';
import '../controller/controller.dart';
import 'sections/activities.dart';
import 'sections/completion_percentage.dart';
import 'sections/loading.dart';

class CourseDetailsView extends GetView<CourseDetailsController> {
  const CourseDetailsView({super.key});
  @override
  Widget build(BuildContext context) {
    /// Course details
    return Scaffold(
      appBar: AppBarX(title: 'Course Details'),
      body: SafeArea(
        /// Get data from the controller
        child: FutureBuilderX(
          future: controller.getData,

          /// Loading state
          loading: const CourseDetailsLoading(),

          /// Data state
          child: (_) {
            /// Empty message
            if (controller.course.value == null) {
              return const EmptyMessage('No course details found');
            }

            /// Content
            return SingleChildScrollView(
              padding: StyleX.paddingApp,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Course image
                  ImageNetworkX(
                    radius: StyleX.radiusLg,
                    imageUrl: controller.course.value!.image,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ).fadeAnimation150,

                  /// Spacer
                  SizedBox(height: 24),

                  /// Course name
                  TextX(
                    controller.course.value!.name,
                    style: TextStyleX.titleSLarge,
                  ).fadeAnimation150,

                  /// Spacer
                  SizedBox(height: 4),

                  /// Course level name
                  TextX(
                    controller.course.value!.levelName,
                    style: TextStyleX.bodyMedium,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ).fadeAnimation150,

                  /// Spacer
                  SizedBox(height: 24),

                  /// Course completion percentage
                  CourseDetailsCompletionPercentageSection().fadeAnimation200,

                  /// Spacer
                  SizedBox(height: 24),

                  /// Course content
                  Row(
                    children: [
                      /// Course content title
                      TextX("Course Content", style: TextStyleX.titleMedium),

                      /// Spacer
                      SizedBox(width: 4),

                      /// Course content count
                      TextX(
                        "(${controller.getActivityCountName.tr})",
                        style: TextStyleX.labelLarge,
                      ),
                    ],
                  ).fadeAnimation200,

                  /// Spacer
                  SizedBox(height: 12),

                  /// Check if there are no activities
                  if (controller.course.value!.activities.isEmpty)
                    /// Empty message
                    ContainerX(
                      height: 150,
                      margin: EdgeInsets.only(top: 20),
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      child: EmptyMessage('There are no lessons'),
                    ).fadeAnimation250,

                  /// Check if there are activities
                  if (controller.course.value!.activities.isNotEmpty)
                    /// Course activities list
                    CourseDetailsActivitiesSection(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
