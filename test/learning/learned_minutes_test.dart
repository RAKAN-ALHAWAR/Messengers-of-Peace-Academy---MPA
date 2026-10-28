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
import 'package:messengersofpeace/Data/Model/user/user_statistics.dart';
import 'package:messengersofpeace/Ui/Section/UserStat/user_statistics.dart';
import 'package:messengersofpeace/Ui/Screen/Course/CourseDetails/controller/controller.dart';
import 'empty_home_test.dart' show statsFixture, userFixture;
import 'lesson_counts_test.dart' show activityJson, utf8Response;
import 'progression_test.dart' show mountCourse;

UserStatisticsX statsWithMinutes(String minutes) =>
    UserStatisticsX.fromJson({...statsFixture(), 'minutes': minutes});

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
    Get.delete<AppControllerX>(force: true);
    Get.delete<CourseDetailsController>(force: true);
    Get.reset();
  });
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  group('learning minutes (TEMP local total)', () {
    test('seconds add up and stay per user', () async {
      expect(UserStatisticsX.localLearnedSeconds, 0);
      await UserStatisticsX.addLocalLearnedSeconds(40);
      await UserStatisticsX.addLocalLearnedSeconds(35);
      expect(UserStatisticsX.localLearnedSeconds, 75);

      await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
      expect(UserStatisticsX.localLearnedSeconds, 0);
      await UserStatisticsX.addLocalLearnedSeconds(10);
      expect(UserStatisticsX.localLearnedSeconds, 10);

      await LocalDataX.put(LocalKeyX.userid, 'synthetic-A');
      expect(UserStatisticsX.localLearnedSeconds, 75);
    });

    test('calls that are not awaited in between still add up', () async {
      final first = UserStatisticsX.addLocalLearnedSeconds(40);
      final second = UserStatisticsX.addLocalLearnedSeconds(35);
      await Future.wait([first, second]);
      expect(UserStatisticsX.localLearnedSeconds, 75);
    });

    test('a queued add stays with the user who earned it', () async {
      final first = UserStatisticsX.addLocalLearnedSeconds(40);
      final second = UserStatisticsX.addLocalLearnedSeconds(35);
      await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
      await Future.wait([first, second]);
      expect(UserStatisticsX.localLearnedSeconds, 0);
      await LocalDataX.put(LocalKeyX.userid, 'synthetic-A');
      expect(UserStatisticsX.localLearnedSeconds, 75);
    });

    test('a zero or negative dwell adds nothing', () async {
      await UserStatisticsX.addLocalLearnedSeconds(0);
      await UserStatisticsX.addLocalLearnedSeconds(-5);
      expect(UserStatisticsX.localLearnedSeconds, 0);
    });

    test('the server value wins when above zero, else whole local minutes', () {
      expect(statsWithMinutes('12').minutesShown(600), '12');
      expect(statsWithMinutes('0').minutesShown(0), '0');
      expect(statsWithMinutes('0').minutesShown(59), '0');
      expect(statsWithMinutes('0').minutesShown(150), '2');
      expect(statsWithMinutes('').minutesShown(120), '2');
    });

    testWidgets('the statistics card shows the local total when server is 0', (
      tester,
    ) async {
      // Hive writes to disk, which needs real async
      await tester.runAsync(() => UserStatisticsX.addLocalLearnedSeconds(185));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserStatisticsSection(statistics: statsWithMinutes('0')),
          ),
        ),
      );
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('the minutes card updates when more time is added', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserStatisticsSection(statistics: statsWithMinutes('0')),
          ),
        ),
      );
      expect(find.text('0'), findsWidgets);
      await tester.runAsync(() => UserStatisticsX.addLocalLearnedSeconds(185));
      await tester.pump();
      expect(find.text('3'), findsOneWidget);
      await tester.runAsync(() => UserStatisticsX.addLocalLearnedSeconds(60));
      await tester.pump();
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('the statistics card keeps a server value above zero', (
      tester,
    ) async {
      // Hive writes to disk, which needs real async
      await tester.runAsync(() => UserStatisticsX.addLocalLearnedSeconds(185));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UserStatisticsSection(statistics: statsWithMinutes('42')),
          ),
        ),
      );
      expect(find.text('42'), findsOneWidget);
      expect(find.text('3'), findsNothing);
    });

    testWidgets('time spent on a lesson video is added when the user returns', (
      tester,
    ) async {
      await http.runWithClient(
        () async {
          final controller = await mountCourse(tester);
          final saved = <int>[];
          controller.addLearnedSeconds = (seconds) async => saved.add(seconds);
          await controller.getData();
          final pending = controller.onTapLessonVideo(0);
          await tester.pumpAndSettle();
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 2100)),
          );
          Get.back();
          await tester.pumpAndSettle();
          await pending;
          expect(saved, hasLength(1));
          expect(saved.single, inInclusiveRange(2, 4));
        },
        () => MockClient(
          (_) async => utf8Response({
            'courseid': 'synthetic-course',
            'coursename': 'Course',
            'levelid': 1,
            'levelname': 'Level',
            'completion_percent': 0,
            'completed_topics_total': 0,
            'activities': [
              activityJson(
                topicId: 1,
                cmId: 'v1',
                video: 'https://x.invalid/1',
              ),
            ],
          }),
        ),
      );
    });
  });
}
