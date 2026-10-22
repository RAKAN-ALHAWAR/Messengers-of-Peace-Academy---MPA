import 'package:messengersofpeace/Config/Translation/translation.dart';
import 'package:messengersofpeace/Core/Service/session_lease.dart';
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
  int _loadGeneration = 0;
  (int, String)? _ownerKey;

  //============================================================================
  // Functions

  /// Get data from database
  Future<void> getData() async {
    if (isClosed) return;
    final locale = TranslationX.getLanguageCode;
    final key = (LocalDataX.sessionRevision, locale);
    final generation = ++_loadGeneration;
    final lease = SessionLeaseX.capture(
      isActive:
          () =>
              !isClosed &&
              generation == _loadGeneration &&
              TranslationX.getLanguageCode == locale,
    );
    if (_ownerKey != key || !lease.hasAuthenticatedIdentity) {
      certificates = [];
      courses = [];
      _ownerKey = key;
    }
    if (!lease.hasAuthenticatedIdentity) {
      isLoading.value = false;
      return;
    }
    isLoading.value = true;
    try {
      final loadedCertificates = await DatabaseX.getMyCertificates();
      if (!lease.isCurrent) return;
      final loadedCourses = await DatabaseX.getMyCourses();
      if (!lease.isCurrent) return;
      certificates = loadedCertificates;
      courses = loadedCourses;
    } catch (_) {
      if (!lease.isCurrent) return;
      rethrow;
    } finally {
      if (lease.isCurrent) isLoading.value = false;
    }
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
    tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    isCourseGrades.value = tabController.value == 1;
  }

  @override
  void onClose() {
    tabController.removeListener(_onTabChanged);
    tabController.dispose();
    super.onClose();
  }
}
