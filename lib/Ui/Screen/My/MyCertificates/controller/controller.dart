import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Data/Model/course/my_course.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../../Core/Service/download_file_form_url.dart';
import '../../../../../Data/Model/my_certificate.dart';
import '../../../../../Data/data.dart';

class MyCertificatesController extends GetxController {
  //============================================================================
  // Variables

  /// Courses
  List<MyCourse> courses = [];

  /// Certificates
  List<MyCertificate> certificates = [];

  /// Tab controller
  final tabController = ValueNotifier(1);

  /// Is course grades
  RxBool isCourseGrades = true.obs;

  /// Is loading
  RxBool isLoading = true.obs;

  //============================================================================
  // Functions

  /// Get data from database
  Future<void> getData() async {
    /// Get certificates
    certificates = await DatabaseX.getMyCertificates();

    /// Get courses
    courses = await DatabaseX.getMyCourses();

    /// Set loading to false
    isLoading.value = false;
  }

  /// Download certificate
  Future<void> onDownloadCertificate(MyCertificate certificate) async {
    await DownloadFileFormUrl.download(
      certificate.downloadUrl,
      "${certificate.name}_${certificate.courseName}",
    );
  }

  /// Share certificate
  void onShareCertificate(MyCertificate certificate) {
    SharePlus.instance.share(ShareParams(text: certificate.shareUrl));
  }

  //============================================================================
  // Lifecycle

  @override
  void onInit() {
    super.onInit();

    /// Add listener to tab controller
    tabController.addListener(() {
      isCourseGrades.value = tabController.value == 1;
    });
  }
}
