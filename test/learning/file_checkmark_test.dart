import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Core/Helper/http/http.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Model/user/user.dart';
import 'package:messengersofpeace/Ui/Screen/Course/CourseDetails/controller/controller.dart';
import 'empty_home_test.dart' show userFixture;
import 'lesson_counts_test.dart' show activityJson, utf8Response;
import 'progression_test.dart' show mountCourse;

/// Course with a summary file topic and a video topic (real payload shape)
http.Response courseResponse() => utf8Response({
  'courseid': 'synthetic-course',
  'coursename': 'Course',
  'levelid': 1,
  'levelname': 'Level',
  'completion_percent': 0,
  'completed_topics_total': 0,
  'activities': [
    activityJson(topicId: 1, cmId: 'v1', video: 'https://x.invalid/1'),
    activityJson(topicId: 2, cmId: 'f2', file: 'https://x.invalid/f'),
  ],
});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-local-progress-');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('app');
    HttpX.init();
  });
  setUp(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (_) async => null);
    Get.testMode = true;
    Get.locale = const Locale('en');
    await HiveX.removeAll();
    await LocalDataX.put(LocalKeyX.userid, 'synthetic-A');
    await LocalDataX.put(LocalKeyX.token, 'synthetic-token');
    Get.put(
      AppControllerX()..user = UserX.fromJson(userFixture('synthetic-A')).obs,
      permanent: true,
    );
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
    Get.delete<CourseDetailsController>(force: true);
    Get.delete<AppControllerX>(force: true);
    Get.reset();
  });
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  group('file checkmark (TEMP local flag)', () {
    Future<void> inCourse(
      WidgetTester tester,
      Future<void> Function(CourseDetailsController controller) body,
    ) => http.runWithClient(() async {
      final controller = await mountCourse(tester);
      await controller.getData();
      await body(controller);
    }, () => MockClient((_) async => courseResponse()));

    testWidgets('a successful download marks the file done and its topic', (
      tester,
    ) async {
      await inCourse(tester, (controller) async {
        controller.downloadFile = (url, name) async => true;
        final file = controller.course.value!.activities[1];
        expect(file.isDone, isFalse);
        expect(controller.lessonsDone, 0);
        var refreshes = 0;
        final sub = controller.course.listen((_) => refreshes++);
        // Hive writes to disk, which needs real async
        await tester.runAsync(() => controller.onTapLessonSummary(file));
        await sub.cancel();
        expect(file.isDone, isTrue);
        expect(controller.lessonsDone, 1, reason: 'the file topic is done');
        expect(controller.lessonsTotal, 2);
        expect(refreshes, greaterThan(0), reason: 'the checkmark rebuilds');
        expect(controller.isLoading, isFalse);
      });
    });

    testWidgets('a failed download does not mark anything', (tester) async {
      await inCourse(tester, (controller) async {
        controller.downloadFile = (url, name) async => false;
        final file = controller.course.value!.activities[1];
        // Hive writes to disk, which needs real async
        await tester.runAsync(() => controller.onTapLessonSummary(file));
        expect(file.isDone, isFalse);
        expect(controller.lessonsDone, 0);
        await controller.getData();
        expect(controller.course.value!.activities[1].isDone, isFalse);
      });
    });

    testWidgets(
      'the flag survives a reload but another account never sees it',
      (tester) async {
        await inCourse(tester, (controller) async {
          controller.downloadFile = (url, name) async => true;
          final file = controller.course.value!.activities[1];
          await tester.runAsync(() => controller.onTapLessonSummary(file));

          await controller.getData();
          expect(controller.course.value!.activities[1].isDone, isTrue);

          await tester.runAsync(() async {
            await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
            await LocalDataX.put(LocalKeyX.token, 'token-B');
          });
          await controller.getData();
          expect(
            controller.course.value!.activities[1].isDone,
            isFalse,
            reason: 'flag is stored per user',
          );

          await tester.runAsync(() async {
            await LocalDataX.put(LocalKeyX.userid, 'synthetic-A');
            await LocalDataX.put(LocalKeyX.token, 'synthetic-token');
          });
          await controller.getData();
          expect(controller.course.value!.activities[1].isDone, isTrue);
        });
      },
    );
  });
}
