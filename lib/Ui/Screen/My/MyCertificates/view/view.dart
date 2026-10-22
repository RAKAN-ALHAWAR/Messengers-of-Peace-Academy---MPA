import 'package:messengersofpeace/Config/Translation/translation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Ui/Animation/fade/fade_animation.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import '../../../../Widget/Basic/Utils/future_builder.dart';
import '../../../../Widget/Custom/Other/tab_segment.dart';
import '../controller/controller.dart';
import 'sections/certificates_section.dart';
import 'sections/course_grades_section.dart';
import 'sections/loading.dart';

class MyCertificatesView extends GetView<MyCertificatesController> {
  const MyCertificatesView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarX(title: 'My Grades and Certificates'),
      body: SafeArea(
        child: Column(
          children: [
            /// Tab segment
            Padding(
              padding: EdgeInsets.only(
                left: StyleX.hPaddingApp,
                right: StyleX.hPaddingApp,
                top: StyleX.vPaddingApp,
                bottom: 28,
              ),
              child: TabSegmentX(
                controller: controller.tabController,
                tabs: {1: 'Course Grades'.tr, 2: 'Certificates'.tr},
              ),
            ).fadeAnimation100,

            Expanded(
              child: FutureBuilderX<void>(
                future: controller.getData,
                requestKey: (controller, TranslationX.getLanguageCode),
                loading: const MyCertificatesLoading(),
                child:
                    (_) => Obx(
                      () =>
                          controller.isCourseGrades.value
                              ? const CourseGradesSection()
                              : const CertificatesSection(),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
