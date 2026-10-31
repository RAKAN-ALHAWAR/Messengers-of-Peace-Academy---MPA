import 'dart:async';
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
        controller.downloadFile = (url, name, {onProgress}) async => true;
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
        expect(controller.fileProgress, isEmpty);
      });
    });

    testWidgets('a failed download does not mark anything', (tester) async {
      await inCourse(tester, (controller) async {
        controller.downloadFile = (url, name, {onProgress}) async => false;
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
          controller.downloadFile = (url, name, {onProgress}) async => true;
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

  group('file download state', () {
    /// The body runs in real async time (Hive and the completers need it)
    Future<void> inCourse(
      WidgetTester tester,
      Future<void> Function(CourseDetailsController controller) body,
    ) => http.runWithClient(() async {
      final controller = await mountCourse(tester);
      await controller.getData();
      await tester.runAsync(() => body(controller));
    }, () => MockClient((_) async => courseResponse()));

    testWidgets('shows the percent while it runs and clears it at the end', (
      tester,
    ) async {
      await inCourse(tester, (controller) async {
        final file = controller.course.value!.activities[1];
        late void Function(int, int) report;
        final done = Completer<bool>();
        controller.downloadFile = (url, name, {onProgress}) {
          report = onProgress!;
          return done.future;
        };
        final pending = controller.onTapLessonSummary(file);
        expect(controller.fileProgress.containsKey(file.cmId), isTrue);
        expect(controller.fileProgress[file.cmId], isNull, reason: 'unknown yet');
        report(250, 1000);
        expect(controller.fileProgress[file.cmId], 0.25);
        report(1000, 1000);
        expect(controller.fileProgress[file.cmId], 1.0);
        done.complete(true);
        await pending;
        expect(controller.fileProgress, isEmpty);
      });
    });

    testWidgets('an unknown total stays indeterminate, no fake percent', (
      tester,
    ) async {
      await inCourse(tester, (controller) async {
        final file = controller.course.value!.activities[1];
        late void Function(int, int) report;
        final done = Completer<bool>();
        controller.downloadFile = (url, name, {onProgress}) {
          report = onProgress!;
          return done.future;
        };
        final pending = controller.onTapLessonSummary(file);
        report(4096, -1);
        report(8192, 0);
        expect(controller.fileProgress.containsKey(file.cmId), isTrue);
        expect(controller.fileProgress[file.cmId], isNull);
        done.complete(false);
        await pending;
      });
    });

    testWidgets('a second tap while it runs does nothing', (tester) async {
      await inCourse(tester, (controller) async {
        final file = controller.course.value!.activities[1];
        var calls = 0;
        final done = Completer<bool>();
        controller.downloadFile = (url, name, {onProgress}) {
          calls++;
          return done.future;
        };
        final first = controller.onTapLessonSummary(file);
        await controller.onTapLessonSummary(file);
        await controller.onTapLessonSummary(file);
        expect(calls, 1);
        done.complete(true);
        await first;
        expect(controller.fileProgress, isEmpty);
      });
    });

    testWidgets('success shows the checkmark at once, nothing left running', (
      tester,
    ) async {
      await inCourse(tester, (controller) async {
        final file = controller.course.value!.activities[1];
        controller.downloadFile = (url, name, {onProgress}) async {
          onProgress!(10, 10);
          return true;
        };
        await controller.onTapLessonSummary(file);
        expect(file.isFileDownloaded, isTrue);
        expect(file.isDone, isTrue);
        expect(controller.fileProgress, isEmpty);
      });
    });

    testWidgets('a failure returns to the download icon and can be retried', (
      tester,
    ) async {
      await inCourse(tester, (controller) async {
        final file = controller.course.value!.activities[1];
        var calls = 0;
        controller.downloadFile = (url, name, {onProgress}) async {
          calls++;
          onProgress!(5, 10);
          return false;
        };
        await controller.onTapLessonSummary(file);
        expect(file.isDone, isFalse);
        expect(controller.fileProgress, isEmpty);
        await controller.onTapLessonSummary(file);
        expect(calls, 2, reason: 'the tap works again after a failure');
      });
    });

    testWidgets('a second tap on a downloaded file opens the saved copy', (
      tester,
    ) async {
      await inCourse(tester, (controller) async {
        final file = controller.course.value!.activities[1];
        var downloads = 0;
        final opened = <String>[];
        controller.downloadFile = (url, name, {onProgress}) async {
          downloads++;
          return true;
        };
        controller.openSavedFile = (name) async {
          opened.add(name);
          return true;
        };
        await controller.onTapLessonSummary(file);
        expect(file.isFileDownloaded, isTrue);
        expect(opened, isEmpty, reason: 'the first tap downloads');
        await controller.onTapLessonSummary(file);
        expect(downloads, 1, reason: 'the second tap reuses the saved copy');
        expect(opened, hasLength(1));
        expect(opened.single, 'Course_${file.name}');
        expect(controller.fileProgress, isEmpty, reason: 'not left busy');
        expect(file.isDone, isTrue, reason: 'the checkmark stays');
      });
    });

    testWidgets('a downloaded file whose copy is gone downloads again', (
      tester,
    ) async {
      await inCourse(tester, (controller) async {
        final file = controller.course.value!.activities[1];
        var downloads = 0;
        controller.downloadFile = (url, name, {onProgress}) async {
          downloads++;
          onProgress!(1, 2);
          return true;
        };
        controller.openSavedFile = (name) async => false;
        await controller.onTapLessonSummary(file);
        await controller.onTapLessonSummary(file);
        expect(downloads, 2);
        expect(controller.fileProgress, isEmpty);
        expect(file.isDone, isTrue);
      });
    });

    testWidgets('an open error clears the busy state, the tap works again', (
      tester,
    ) async {
      var failOpen = true;
      var opens = 0;
      await inCourse(tester, (controller) async {
        final file = controller.course.value!.activities[1];
        controller.downloadFile = (url, name, {onProgress}) async => true;
        controller.openSavedFile = (name) async {
          opens++;
          if (failOpen) throw StateError('synthetic open error');
          return true;
        };
        await controller.onTapLessonSummary(file);
        await controller.onTapLessonSummary(file);
        expect(controller.fileProgress, isEmpty);
        failOpen = false;
        await controller.onTapLessonSummary(file);
        expect(opens, 2, reason: 'the second tap after the error opens again');
        expect(controller.fileProgress, isEmpty);
      });
      expect(tester.takeException(), isNotNull);
    });

    testWidgets('a download that throws also clears the running state', (
      tester,
    ) async {
      await inCourse(tester, (controller) async {
        final file = controller.course.value!.activities[1];
        controller.downloadFile = (url, name, {onProgress}) async {
          throw StateError('synthetic');
        };
        await controller.onTapLessonSummary(file);
        expect(controller.fileProgress, isEmpty);
        expect(file.isDone, isFalse);
      });
      // The error is reported to the console channel, not rethrown to the tap
      expect(tester.takeException(), isNotNull);
    });
  });
}
