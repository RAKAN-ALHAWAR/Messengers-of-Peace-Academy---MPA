import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/Basic/Utils/future_builder.dart';
import '../../../../Widget/Custom/Card/course_card.dart';
import '../../../../Widget/Custom/Other/empty_message.dart';
import '../controller/controller.dart';
import 'sections/loading.dart';

class AllCoursesView extends GetView<AllCoursesController> {
  const AllCoursesView({super.key});
  @override
  Widget build(BuildContext context) {
    /// All courses
    return Scaffold(
      body: SafeArea(
        child: FutureBuilderX(
          future: controller.getData,

          /// Loading state
          loading: const AllCoursesLoading(),

          /// Data state
          child: (data) {
            /// Empty message
            if (controller.levels.isEmpty) {
              return const EmptyMessage('No courses found');
            }

            /// Content
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(vertical: StyleX.vPaddingApp),
              child: Column(
                children: [
                  /// Level sections
                  for (var level in controller.levels)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Level name and course count
                        Row(
                          children: [
                            /// Level name
                            Text(level.name, style: TextStyleX.titleMedium),

                            /// Spacer
                            SizedBox(width: 4),

                            /// Course count
                            Text(
                              "(${controller.getCourseCountName(level.totalCourses).tr})",
                              style: TextStyleX.labelLarge,
                            ),
                          ],
                        ).paddingSymmetric(horizontal: StyleX.hPaddingApp),

                        /// Course cards for each level
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsetsDirectional.only(
                            start: StyleX.hPaddingApp,
                            top: 14,
                            bottom: 24,
                          ),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                /// Course cards
                                for (var course in level.courses)
                                  CourseCard(
                                    course: course,
                                    onTap: (course) {
                                      controller.onCourseTap(course);
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
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
