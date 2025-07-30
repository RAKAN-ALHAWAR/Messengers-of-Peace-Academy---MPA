import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/Basic/Utils/future_builder.dart';
import 'package:messengersofpeace/Ui/Widget/Custom/Other/empty_message.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import '../controller/controller.dart';
import 'sections/loading.dart';

class MyCoursesView extends GetView<MyCoursesController> {
  const MyCoursesView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarX(title: 'Enrolled Courses'),
      body: SafeArea(
        child: FutureBuilderX(
          // Get data
          future: controller.getData,
          // Loading state
          loading: MyCoursesLoading(),
          // Data state
          child: (data) {
            /// If there are no courses, show empty message
            if (controller.myCourses.isEmpty) {
              return EmptyMessage("No courses found").fadeAnimation150;
            }

            /// If there are courses, show them
            return SingleChildScrollView(
              padding: StyleX.paddingApp,
              child: Column(
                children: [
                  /// Courses list cards
                  for (var course in controller.myCourses)
                    GestureDetector(
                      onTap: () => controller.onTapCourse(course),
                      child: ContainerX(
                        radius: StyleX.radiusLg,
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.only(bottom: 16),
                        width: double.maxFinite,
                        child: Row(
                          children: [
                            /// Course image
                            ImageNetworkX(
                              imageUrl: course.image,
                              width: 100,
                              height: 100,
                              radius: StyleX.radiusLg,
                              failed: Container(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerLow,
                                child: Icon(Icons.image_not_supported_outlined),
                              ),
                            ),

                            /// Spacer
                            SizedBox(width: 16),

                            /// Course name and progress
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  /// Course name
                                  TextX(
                                    course.fullName,
                                    style: TextStyleX.titleMedium,
                                  ),

                                  /// Spacer
                                  SizedBox(height: 12),

                                  /// Progress
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      /// Total sections
                                      TextX(
                                        "${course.totalSections}/${course.completedSections}",
                                        style: TextStyleX.labelSmall,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                      ),

                                      /// Completion percent
                                      TextX(
                                        "${course.completionPercent}%",
                                        style: TextStyleX.labelSmall,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurfaceVariant,
                                      ),
                                    ],
                                  ),

                                  /// Spacer
                                  SizedBox(height: 4, width: double.infinity),

                                  /// Progress indicator
                                  Row(
                                    children: [
                                      Expanded(
                                        child: LinearProgressIndicator(
                                          value: course.completionPercent / 100,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).fadeAnimation150,
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
