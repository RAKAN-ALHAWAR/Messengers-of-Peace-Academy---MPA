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
import 'package:messengersofpeace/Data/Model/course/activity.dart';
import 'package:messengersofpeace/Data/Model/user/user.dart';
import 'package:messengersofpeace/Ui/Screen/Course/CourseDetails/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Course/VideoPlayer /controller/controller.dart';
import 'package:messengersofpeace/Ui/Widget/Custom/Other/lesson_item_on_accordion.dart';
import 'package:video_player/video_player.dart' as vp;
import 'empty_home_test.dart' show userFixture;
import 'lesson_counts_test.dart' show activityJson, utf8Response;
import 'progression_test.dart' show mountCourse;

const _url = 'https://x.invalid/1';

/// A video activity as the server sends it, with the given video_duration
ActivityX videoActivity(String duration, {int localSeconds = 0}) =>
    ActivityX.fromJson({
      ...activityJson(topicId: 1, cmId: 'v1', video: _url),
      'video_duration': duration,
    })..localDurationSeconds = localSeconds;

class _Player extends vp.VideoPlayerController {
  _Player() : super.networkUrl(Uri.parse(_url));
}

class _ScreenController extends VideoPlayerController {
  @override
  void onInit() {
    url = ''; // No native source is opened; the test supplies a notifier.
    super.onInit();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-duration-');
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

  group('the text shown for a lesson duration', () {
    test('an empty or zero server duration is hidden', () {
      for (final zero in ['', '0', '0:00', '00:00', '0:00:00', ' 0:00 ']) {
        expect(videoActivity(zero).durationText, isNull, reason: '"$zero"');
      }
    });

    test('a real server duration is shown as sent', () {
      expect(videoActivity('3:00').durationText, '3:00');
      expect(videoActivity('12:05').durationText, '12:05');
    });

    test('a real server duration wins over the stored one', () {
      expect(videoActivity('3:00', localSeconds: 95).durationText, '3:00');
    });

    test('the stored duration shows when the server sends zero', () {
      expect(videoActivity('0:00', localSeconds: 95).durationText, '1:35');
      expect(videoActivity('0:00', localSeconds: 9).durationText, '0:09');
      expect(videoActivity('0:00', localSeconds: 3725).durationText, '1:02:05');
    });

    testWidgets('the list row shows no text for a hidden duration', (
      tester,
    ) async {
      Future<void> pumpRow(String? duration) => tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LessonItemOnAccordion(
              icon: Icons.play_arrow,
              name: 'Lesson',
              videoDuration: duration,
            ),
          ),
        ),
      );
      await pumpRow(null);
      expect(find.text('0:00'), findsNothing);
      await pumpRow('');
      expect(find.text(''), findsNothing);
      await pumpRow('1:35');
      expect(find.text('1:35'), findsOneWidget);
    });
  });

  group('the real length learned by the player (TEMP local value)', () {
    testWidgets('the player stores the total duration it learned', (
      tester,
    ) async {
      final controller = Get.put<VideoPlayerController>(_ScreenController())
        ..url = _url;
      controller.videoPlayerController = _Player()
        ..value = const vp.VideoPlayerValue(duration: Duration(seconds: 95));
      await tester.runAsync(controller.rememberDuration);
      expect(
        LocalDataX.get<int>(LocalKeyX.videoSeconds(_url), defaultData: 0),
        95,
      );
    });

    test(
      'the stored key drops the query and fragment, so no token is kept',
      () {
        const base = 'https://x.invalid/pluginfile.php/1/video.mp4';
        expect(
          LocalKeyX.videoSeconds('$base?token=secret-one&forcedownload=1#t=3'),
          LocalKeyX.videoSeconds(base),
        );
        expect(
          LocalKeyX.videoSeconds('$base?token=secret-two'),
          LocalKeyX.videoSeconds('$base?token=secret-one'),
        );
        expect(
          LocalKeyX.videoSeconds('$base?token=secret-one'),
          isNot(contains('secret')),
        );
        expect(LocalKeyX.videoSeconds(base), isNot(contains('?')));
      },
    );

    testWidgets('a player url with a token stores only the plain key', (
      tester,
    ) async {
      final controller = Get.put<VideoPlayerController>(_ScreenController())
        ..url = '$_url?token=secret-one';
      controller.videoPlayerController = _Player()
        ..value = const vp.VideoPlayerValue(duration: Duration(seconds: 95));
      await tester.runAsync(controller.rememberDuration);
      expect(
        HiveX.box.keys.where((key) => key.toString().contains('secret')),
        isEmpty,
      );
      expect(
        LocalDataX.get<int>(LocalKeyX.videoSeconds(_url), defaultData: 0),
        95,
      );
    });

    testWidgets('an unknown duration (zero) stores nothing', (tester) async {
      final controller = Get.put<VideoPlayerController>(_ScreenController())
        ..url = _url;
      controller.videoPlayerController = _Player()
        ..value = const vp.VideoPlayerValue(duration: Duration.zero);
      await tester.runAsync(controller.rememberDuration);
      expect(
        LocalDataX.get<int>(LocalKeyX.videoSeconds(_url), defaultData: 0),
        0,
      );
    });

    testWidgets('the course page shows the stored duration after a reload', (
      tester,
    ) async {
      await tester.runAsync(
        () => LocalDataX.put<int>(LocalKeyX.videoSeconds(_url), 95),
      );
      await http.runWithClient(
        () async {
          final controller = await mountCourse(tester);
          await controller.getData();
          final video = controller.course.value!.activities.first;
          expect(video.videoDuration, '0:00');
          expect(video.durationText, '1:35');
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
              {
                ...activityJson(topicId: 1, cmId: 'v1', video: _url),
                'video_duration': '0:00',
              },
            ],
          }),
        ),
      );
    });
  });
}
