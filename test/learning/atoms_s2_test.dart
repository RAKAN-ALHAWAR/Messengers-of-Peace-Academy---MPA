// Step 0 of slice S2: every guard of the course page and the video player
// screen is proven alone. Each test goes red when its one guard is removed.
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Core/Helper/http/http.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Database/config/database_end_point.dart';
import 'package:messengersofpeace/Data/Model/user/user.dart';
import 'package:messengersofpeace/Ui/Screen/Course/CourseDetails/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Course/VideoPlayer /controller/controller.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart' show ToastX;
// The fake platform is the only way to hold a video's initialize() pending.
// ignore: depend_on_referenced_packages
import 'package:video_player_platform_interface/video_player_platform_interface.dart';
import 'empty_home_test.dart' show functionOf, userFixture;
import 'lesson_counts_test.dart' show activityJson, utf8Response;
import 'next_activity_test.dart' show courseJson;

/// What the fake server has seen
class _Calls {
  int loads = 0;
}

/// Serves the course; a load can be held for later or refused
http.Client Function() _server(
  _Calls calls, {
  Map<int, Completer<http.Response>> held = const {},
  Set<int> refused = const {},
  Map<String, Object?> Function(int load)? course,
}) {
  final client = MockClient((request) async {
    if (request.url.queryParameters['wsfunction'] ==
        functionOf(DBEndPointX.postCompleteVideoOfCourse)) {
      return utf8Response({'status': 'success'});
    }
    final load = ++calls.loads;
    if (held.containsKey(load)) return held[load]!.future;
    if (refused.contains(load)) return http.Response('boom', 500);
    return utf8Response((course ?? (_) => courseJson(aDone: false))(load));
  });
  return () => client;
}

Map<String, Object?> named(
  String name, {
  bool aDone = false,
  List<Map<String, Object?>>? tail,
}) => courseJson(aDone: aDone, tail: tail)..['coursename'] = name;

final quizTail = [activityJson(topicId: 1, cmId: 'Q', quizId: 7)];
final fileTail = [
  activityJson(topicId: 1, cmId: 'F', file: 'https://x.invalid/f'),
];

/// The pages the flows need; the player and the quiz info are stubs
Future<CourseDetailsController> mount(WidgetTester tester) async {
  await tester.pumpWidget(
    GetMaterialApp(
      initialRoute: '/entry',
      getPages: [
        GetPage(
          name: '/entry',
          page: () => const Scaffold(body: SizedBox()),
        ),
        GetPage(
          name: '/course-test',
          page: () => const Scaffold(body: SizedBox()),
        ),
        GetPage(
          name: RouteNameX.videoPlayer,
          page: () => const Scaffold(body: Text('Synthetic player')),
        ),
        GetPage(
          name: RouteNameX.testInfo,
          page: () => const Scaffold(body: Text('Synthetic quiz info')),
        ),
      ],
    ),
  );
  await tester.pumpAndSettle();
  Get.toNamed('/course-test', arguments: '19');
  await tester.pumpAndSettle();
  final controller = Get.put<CourseDetailsController>(
    CourseDetailsController(),
  );
  // A Hive disk write never finishes under the fake test clock
  controller.addLearnedSeconds = (_) async {};
  return controller;
}

/// Let the mocked requests answer, then settle navigation and rebuilds
Future<void> answered(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 100)),
  );
  await tester.pumpAndSettle();
}

/// Makes [controller] stop being the owner of the page, one reason at a time
void flip(String atom, CourseDetailsController controller) {
  switch (atom) {
    case 'closed':
      // Closed but still registered: only the open check can tell
      controller.onDelete();
    case 'replaced':
      // Open but no longer the registered one: only the instance check can tell
      final app = Get.find<AppControllerX>();
      GetInstance().resetInstance(clearRouteBindings: false);
      Get.put<AppControllerX>(app, permanent: true);
      Get.put(CourseDetailsController());
    case 'app':
      Get.delete<AppControllerX>(force: true);
      Get.put(
        AppControllerX()..user = UserX.fromJson(userFixture('synthetic-A')).obs,
        permanent: true,
      );
    default:
      throw ArgumentError(atom);
  }
}

class _FakePlatform extends VideoPlayerPlatform {
  final created = Completer<int?>();
  final events = StreamController<VideoEvent>(sync: true);
  @override
  Future<void> init() async {}
  @override
  Future<int?> createWithOptions(VideoCreationOptions options) =>
      created.future;
  @override
  Stream<VideoEvent> videoEventsFor(int playerId) => events.stream;
  @override
  Future<void> dispose(int playerId) async {}
  @override
  Future<void> setLooping(int playerId, bool looping) async {}
  @override
  Future<void> setVolume(int playerId, double volume) async {}
  @override
  Future<void> pause(int playerId) async {}
}

class _Screen extends VideoPlayerController {
  @override
  void onInit() {
    url = 'https://synthetic.invalid/video.mp4';
    super.onInit();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  var orientations = 0;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-atoms-s2-');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('app');
    HttpX.init();
  });
  setUp(() async {
    orientations = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'SystemChrome.setPreferredOrientations') {
            orientations++;
          }
          return null;
        });
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
    ToastX.dismiss();
    Get.delete<CourseDetailsController>(force: true);
    Get.delete<AppControllerX>(force: true);
    Get.reset();
  });
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  group('page owner', () {
    for (final atom in ['replaced', 'app']) {
      testWidgets('a pending load is dropped when the page owner is $atom', (
        tester,
      ) async {
        final calls = _Calls();
        final response = Completer<http.Response>();
        await http.runWithClient(() async {
          final controller = await mount(tester);
          final pending = controller.getData();
          await tester.pump();
          expect(calls.loads, 1);
          flip(atom, controller);
          response.complete(utf8Response(courseJson(aDone: false)));
          await pending;
          expect(controller.course.value, isNull);
        }, _server(calls, held: {1: response}));
      });
    }

    for (final atom in ['closed', 'replaced', 'app']) {
      testWidgets('a load is not requested once the page owner is $atom', (
        tester,
      ) async {
        final calls = _Calls();
        await http.runWithClient(() async {
          final controller = await mount(tester);
          flip(atom, controller);
          await controller.getData();
          expect(calls.loads, 0);
        }, _server(calls));
      });
    }

    for (final atom in ['closed', 'replaced', 'app', 'account']) {
      testWidgets('a finished download marks nothing after $atom', (
        tester,
      ) async {
        final calls = _Calls();
        await http.runWithClient(() async {
          final controller = await mount(tester);
          await controller.getData();
          final file = controller.course.value!.activities[1];
          // Hive writes to disk, which needs real async (the completer too)
          await tester.runAsync(() async {
            final download = Completer<bool>();
            controller.downloadFile = (url, name) => download.future;
            final pending = controller.onTapLessonSummary(file);
            expect(controller.isLoading, isTrue);
            if (atom == 'account') {
              await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
            } else {
              flip(atom, controller);
            }
            download.complete(true);
            await pending;
          });
          expect(file.isFileDownloaded, isFalse);
        }, _server(calls, course: (_) => named('Course', tail: fileTail)));
      });
    }
  });

  group('download lease', () {
    for (final atom in ['closed', 'swapped', 'locale']) {
      testWidgets('a failed download reports nothing after $atom', (
        tester,
      ) async {
        final calls = _Calls();
        await http.runWithClient(() async {
          final controller = await mount(tester);
          await controller.getData();
          final download = Completer<bool>();
          controller.downloadFile = (url, name) => download.future;
          final pending = controller.onTapLessonSummary(
            controller.course.value!.activities[1],
          );
          if (atom == 'closed') controller.onDelete();
          if (atom == 'swapped') controller.course.value = null;
          if (atom == 'locale') Get.locale = const Locale('es');
          download.completeError(StateError('synthetic download failure'));
          await pending;
          expect(tester.takeException(), isNull);
        }, _server(calls, course: (_) => named('Course', tail: fileTail)));
      });
    }
  });

  group('video return', () {
    for (final atom in ['route left', 'course swapped', 'activity removed']) {
      testWidgets('is ignored after the $atom', (tester) async {
        final calls = _Calls();
        await http.runWithClient(() async {
          final controller = await mount(tester);
          await controller.getData();
          final pending = controller.onTapLessonVideo(0);
          await tester.pumpAndSettle();
          expect(Get.currentRoute, RouteNameX.videoPlayer);
          if (atom == 'course swapped') controller.course.value = null;
          if (atom == 'activity removed') {
            controller.course.value!.activities.removeAt(0);
          }
          if (atom == 'route left') {
            Get.offNamed('/entry');
          } else {
            Get.back();
          }
          await answered(tester);
          await pending;
          expect(calls.loads, 1, reason: 'no refetch for an abandoned visit');
          expect(orientations, 0);
        }, _server(calls));
      });
    }

    testWidgets('is ignored after a newer load that failed', (tester) async {
      final calls = _Calls();
      await http.runWithClient(() async {
        final controller = await mount(tester);
        await controller.getData();
        final pending = controller.onTapLessonVideo(0);
        await tester.pumpAndSettle();
        // The failed load keeps the same course object, only the counters move
        await expectLater(controller.getData(), throwsA(anything));
        Get.back();
        await answered(tester);
        await pending;
        expect(calls.loads, 2, reason: 'no refetch for an abandoned visit');
        expect(orientations, 0);
      }, _server(calls, refused: {2}));
    });

    testWidgets('Next after a failed refetch opens nothing', (tester) async {
      final calls = _Calls();
      await http.runWithClient(() async {
        final controller = await mount(tester);
        // The old snapshot already has the next lesson open
        await controller.getData();
        expect(controller.course.value!.activities[1].isOpen, isTrue);
        final pending = controller.onTapLessonVideo(0);
        await tester.pumpAndSettle();
        Get.back(result: VideoPlayerController.nextResult);
        await answered(tester);
        expect(Get.currentRoute, '/course-test');
        expect(calls.loads, 2);
        expect(tester.takeException(), isNotNull, reason: 'reported');
        ToastX.dismiss();
        await pending;
      }, _server(calls, refused: {2}, course: (_) => courseJson(aDone: true)));
    });

    testWidgets('going back without the Next result opens nothing', (
      tester,
    ) async {
      final calls = _Calls();
      await http.runWithClient(() async {
        final controller = await mount(tester);
        await controller.getData();
        final pending = controller.onTapLessonVideo(0);
        await tester.pumpAndSettle();
        Get.back();
        await answered(tester);
        expect(Get.currentRoute, '/course-test');
        expect(calls.loads, 2);
        await pending;
      }, _server(calls, course: (_) => courseJson(aDone: true)));
    });

    testWidgets('Next opens nothing when the page was left during the refetch', (
      tester,
    ) async {
      final calls = _Calls();
      await http.runWithClient(() async {
        final controller = await mount(tester);
        await controller.getData();
        var left = false;
        final sub = controller.course.listen((_) {
          if (left) return;
          left = true;
          // Pushed on top: replacing the page would delete this controller too
          Get.toNamed('/entry');
        });
        addTearDown(sub.cancel);
        final pending = controller.onTapLessonVideo(0);
        await tester.pumpAndSettle();
        Get.back(result: VideoPlayerController.nextResult);
        await answered(tester);
        expect(left, isTrue);
        expect(Get.currentRoute, '/entry');
        expect(calls.loads, 2);
        await pending;
      }, _server(calls, course: (_) => courseJson(aDone: true)));
    });

    testWidgets(
      'Next opens nothing when a newer load began during the refetch',
      (tester) async {
        final calls = _Calls();
        await http.runWithClient(() async {
          final controller = await mount(tester);
          await controller.getData();
          var reloaded = false;
          final sub = controller.course.listen((_) {
            if (reloaded) return;
            reloaded = true;
            unawaited(controller.getData());
          });
          addTearDown(sub.cancel);
          final pending = controller.onTapLessonVideo(0);
          await tester.pumpAndSettle();
          Get.back(result: VideoPlayerController.nextResult);
          await answered(tester);
          expect(reloaded, isTrue);
          expect(Get.currentRoute, '/course-test');
          expect(calls.loads, 3);
          await pending;
        }, _server(calls, course: (_) => courseJson(aDone: true)));
      },
    );
  });

  group('quiz', () {
    testWidgets('a newer load retires the refetch after the passed quiz', (
      tester,
    ) async {
      final calls = _Calls();
      final old = Completer<http.Response>();
      await http.runWithClient(
        () async {
          final controller = await mount(tester);
          await controller.getData();
          final pending = controller.continueAfterPassedQuiz('7');
          await tester.pump();
          expect(calls.loads, 2);
          await controller.getData();
          old.complete(utf8Response(named('Old')));
          await pending;
          expect(controller.course.value!.name, 'Newest');
        },
        _server(
          calls,
          held: {2: old},
          course: (load) => named(load == 1 ? 'First' : 'Newest'),
        ),
      );
    });

    testWidgets(
      'the refetch after the passed quiz is dropped once the page is left',
      (tester) async {
        final calls = _Calls();
        final fresh = Completer<http.Response>();
        await http.runWithClient(() async {
          final controller = await mount(tester);
          await controller.getData();
          final pending = controller.continueAfterPassedQuiz('7');
          await tester.pump();
          expect(calls.loads, 2);
          // Pushed on top: popping the page would delete this controller too
          Get.toNamed('/entry');
          await tester.pumpAndSettle();
          fresh.complete(utf8Response(named('Fresh')));
          await pending;
          expect(controller.course.value!.name, 'First');
        }, _server(calls, held: {2: fresh}, course: (_) => named('First')));
      },
    );

    testWidgets('a newer load retires the refetch after the quiz page', (
      tester,
    ) async {
      final calls = _Calls();
      await http.runWithClient(() async {
        final controller = await mount(tester);
        await controller.getData();
        final pending = controller.onTapLessonQuiz(
          controller.course.value!.activities[1],
        );
        await tester.pumpAndSettle();
        expect(Get.currentRoute, RouteNameX.testInfo);
        await controller.getData();
        Get.back();
        await answered(tester);
        await pending;
        expect(calls.loads, 2);
      }, _server(calls, course: (_) => named('Course', tail: quizTail)));
    });

    testWidgets('the quiz page replaced by another page gives no refetch', (
      tester,
    ) async {
      final calls = _Calls();
      await http.runWithClient(() async {
        final controller = await mount(tester);
        await controller.getData();
        final pending = controller.onTapLessonQuiz(
          controller.course.value!.activities[1],
        );
        await tester.pumpAndSettle();
        expect(Get.currentRoute, RouteNameX.testInfo);
        Get.offNamed('/entry');
        await answered(tester);
        await pending;
        expect(calls.loads, 1);
      }, _server(calls, course: (_) => named('Course', tail: quizTail)));
    });
  });

  group('video player screen', () {
    late VideoPlayerPlatform previous;
    late _FakePlatform platform;
    setUp(() {
      previous = VideoPlayerPlatform.instance;
      platform = _FakePlatform();
      VideoPlayerPlatform.instance = platform;
    });
    tearDown(() {
      VideoPlayerPlatform.instance = previous;
      Get.delete<VideoPlayerController>(force: true);
    });

    test('a video ready after the screen closed changes nothing', () async {
      final screen = Get.put<VideoPlayerController>(_Screen());
      platform.created.complete(1);
      await pumpEventQueue();
      expect(screen.isLoading.value, isTrue);
      platform.events.add(
        VideoEvent(
          eventType: VideoEventType.initialized,
          duration: Duration.zero,
          size: const Size(1, 1),
        ),
      );
      screen.onDelete();
      await pumpEventQueue();
      expect(screen.isLoading.value, isTrue);
      expect(screen.hasError.value, isFalse);
    });

    test(
      'a video that fails after the screen closed changes nothing',
      () async {
        final screen = Get.put<VideoPlayerController>(_Screen());
        screen.onDelete();
        platform.created.completeError(PlatformException(code: 'synthetic'));
        await pumpEventQueue();
        expect(screen.hasError.value, isFalse);
        expect(screen.isLoading.value, isTrue);
      },
    );

    test('an open screen shows the failure of its video', () async {
      final screen = Get.put<VideoPlayerController>(_Screen());
      platform.created.completeError(PlatformException(code: 'synthetic'));
      await pumpEventQueue();
      expect(screen.hasError.value, isTrue);
      expect(screen.isLoading.value, isFalse);
    });
  });
}
