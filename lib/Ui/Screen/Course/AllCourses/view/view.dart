import 'package:messengersofpeace/Config/Translation/translation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/Basic/Utils/future_builder.dart';
import '../../../../Widget/Custom/Other/course_carousel.dart';
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
          requestKey: (controller, TranslationX.getLanguageCode),

          /// Loading state
          loading: const AllCoursesLoading(),

          /// Data state
          ///
          /// While the levels are refetched, the first-load skeleton covers them
          child: (data) => Stack(
            children: [
              Obx(() {
                /// Empty message
                if (controller.levels.isEmpty) {
                  return const EmptyMessage('No courses found');
                }

                /// Content
                return ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: StyleX.vPaddingApp),
                  itemCount: controller.levels.length,
                  itemBuilder: (context, index) {
                    final level = controller.levels[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// Level name and course count
                        Wrap(
                          spacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            /// Level name
                            Text(level.name, style: TextStyleX.titleMedium),

                            /// Course count
                            Text(
                              "(${controller.getCourseCountName(level.totalCourses).tr})",
                              style: TextStyleX.labelLarge,
                            ),
                          ],
                        ).paddingSymmetric(horizontal: StyleX.hPaddingApp),

                        /// Course cards for each level
                        Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: CourseCarousel(
                            courses: level.courses,
                            onTap: controller.onCourseTap,
                          ),
                        ),
                      ],
                    ).fadeAnimation150;
                  },
                );
              }),

              /// Loading cover
              Obx(
                () => controller.isRefreshing.value
                    ? SizedBox.expand(
                        child: ColoredBox(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: const AllCoursesLoading(),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
