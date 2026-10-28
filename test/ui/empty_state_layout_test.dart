import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Model/my_certificate.dart';
import 'package:messengersofpeace/Ui/Screen/Meeting/AllMeetings/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Meeting/AllMeetings/view/view.dart';
import 'package:messengersofpeace/Ui/Screen/My/MyCertificates/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/My/MyCertificates/view/sections/certificates_section.dart';
import 'package:messengersofpeace/Ui/Screen/My/MyCertificates/view/sections/course_grades_section.dart';
import 'package:messengersofpeace/Ui/Widget/Custom/Card/certificate_card.dart';
import 'package:messengersofpeace/Ui/Widget/Custom/Other/empty_message.dart';
import 'package:messengersofpeace/Ui/Widget/Custom/Other/tab_segment.dart';
import 'package:messengersofpeace/Ui/Widget/Basic/Other/label.dart';

/// Meetings controller that answers from memory, no network.
class _Meetings extends AllMeetingsController {
  @override
  Future<void> getData() async => isLoading.value = false;
}

MyCertificate _certificate() => MyCertificate(
  name: 'Certificate',
  courseName: 'Course',
  shareUrl: 'https://x.test/s',
  downloadUrl: 'https://x.test/d',
  issuedDate: '2025-03-04',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final directory = await Directory.systemTemp.createTemp('mopa_empty');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('synthetic');
  });
  tearDown(Get.reset);

  Future<void> pumpPage(WidgetTester tester, Widget page) async {
    await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: page)));
    await tester.pump(const Duration(seconds: 1));
  }

  group('empty states keep the original top margin of 150', () {
    testWidgets('certificates', (tester) async {
      Get.put(MyCertificatesController());
      await pumpPage(tester, const CertificatesSection());
      final label = tester.getRect(find.byType(LabelX));
      final text = tester.getRect(find.byType(EmptyMessage));
      // label, 12 gap, 150 margin, then the message at the top of the list area
      expect(text.top - label.bottom, closeTo(12 + 150, 1));
    });

    testWidgets('course grades', (tester) async {
      Get.put(MyCertificatesController());
      await pumpPage(tester, const CourseGradesSection());
      final label = tester.getRect(find.byType(LabelX));
      final text = tester.getRect(find.byType(EmptyMessage));
      expect(text.top - label.bottom, closeTo(12 + 150, 1));
    });

    testWidgets('meetings', (tester) async {
      Get.put<AllMeetingsController>(_Meetings());
      await tester.pumpWidget(
        const GetMaterialApp(home: AllMeetingsView()),
      );
      await tester.pump(const Duration(seconds: 1));
      final tabs = tester.getRect(find.byType(TabSegmentX));
      final text = tester.getRect(
        find.text('No meetings and encounters currently'),
      );
      // 16 below the tabs, then the 150 margin
      expect(text.top - tabs.bottom, closeTo(16 + 150, 1));
    });
  });

  group('certificate card', () {
    testWidgets('has two half width tap areas that call the right callback', (
      tester,
    ) async {
      var downloads = 0, shares = 0;
      await pumpPage(
        tester,
        SingleChildScrollView(
          child: CertificateCard(
            certificate: _certificate(),
            onDownloadCertificate: (_) => downloads++,
            onShareCertificate: (_) => shares++,
          ),
        ),
      );
      final download = tester.getRect(find.text('Download'));
      final share = tester.getRect(find.text('Share'));
      final areas = find.byType(GestureDetector);
      final first = tester.getRect(areas.at(0));
      final second = tester.getRect(areas.at(1));
      expect(first.width, closeTo(second.width, 0.5));
      expect(first.right + 12, closeTo(second.left, 0.5));
      // The two areas sit side by side on one row
      expect(first.top, second.top);

      await tester.tap(find.text('Download'));
      expect((downloads, shares), (1, 0));
      await tester.tap(find.text('Share'));
      expect((downloads, shares), (1, 1));
      expect(download.top, share.top);
    });
  });
}
