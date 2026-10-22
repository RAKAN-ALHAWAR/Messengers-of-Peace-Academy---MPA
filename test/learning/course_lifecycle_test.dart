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
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import 'empty_home_test.dart' show fixtureResponse, userFixture;
import 'progression_test.dart' show courseFixture, mountCourse;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-course-lifecycle-');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('app');
    HttpX.init();
  });
  setUp(() async {
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
    ToastX.dismiss();
    Get.delete<CourseDetailsController>(force: true);
    Get.delete<AppControllerX>(force: true);
    Get.reset();
  });
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  for (final abandon in [
    'account',
    'same-token',
    'locale',
    'course',
    'closed',
  ]) {
    testWidgets('course load ignores its response after $abandon changes', (
      tester,
    ) async {
      final response = Completer<http.Response>();
      var count = 0;
      await http.runWithClient(
        () async {
          final controller = await mountCourse(tester);
          final pending = controller.getData();
          await tester.pump();
          if (abandon == 'account' || abandon == 'same-token') {
            await tester.runAsync(
              () => LocalDataX.put(
                abandon == 'account' ? LocalKeyX.userid : LocalKeyX.token,
                abandon == 'account' ? 'synthetic-B' : 'synthetic-token',
              ),
            );
          }
          if (abandon == 'locale') Get.locale = const Locale('es');
          if (abandon == 'course') controller.courseId = 'other-course';
          if (abandon == 'closed') {
            Get.delete<CourseDetailsController>(force: true);
          }
          response.complete(fixtureResponse(courseFixture('synthetic-course')));
          await pending;
          expect(controller.course.value, isNull);
          expect(count, 1);
        },
        () => MockClient((_) {
          count++;
          return response.future;
        }),
      );
    });
  }

  testWidgets(
    'newer same-course load wins without replacing its reactive container',
    (tester) async {
      final first = Completer<http.Response>();
      var count = 0;
      await http.runWithClient(
        () async {
          final controller = await mountCourse(tester);
          final reactive = controller.course;
          final pending = controller.getData();
          await tester.pump();
          await controller.getData();
          first.complete(
            fixtureResponse(
              courseFixture('synthetic-course')..[NameX.courseName] = 'Old',
            ),
          );
          await pending;
          expect(identical(controller.course, reactive), isTrue);
          expect(controller.course.value!.name, 'Newest');
          expect(count, 2);
        },
        () => MockClient((_) {
          count++;
          return count == 1
              ? first.future
              : Future.value(
                fixtureResponse(
                  courseFixture('synthetic-course')
                    ..[NameX.courseName] = 'Newest',
                ),
              );
        }),
      );
    },
  );

  testWidgets(
    'anonymous course reload retires prior content and sends no protected request',
    (tester) async {
      var count = 0;
      await http.runWithClient(
        () async {
          final controller = await mountCourse(tester);
          await controller.getData();
          await tester.runAsync(() => LocalDataX.remove(LocalKeyX.token));
          await expectLater(controller.getData(), throwsA(anything));
          expect(count, 1);
          expect(controller.course.value, isNull);
        },
        () => MockClient((_) async {
          count++;
          return fixtureResponse(courseFixture('synthetic-course'));
        }),
      );
    },
  );

  testWidgets('wrong-course response is rejected before publication', (
    tester,
  ) async {
    await http.runWithClient(
      () async {
        final controller = await mountCourse(tester);
        await expectLater(controller.getData(), throwsA(anything));
        expect(controller.course.value, isNull);
      },
      () => MockClient(
        (_) async => fixtureResponse(courseFixture('other-course')),
      ),
    );
  });

  for (final abandon in ['account', 'closed', 'reload']) {
    testWidgets(
      'video return after dwell cannot mutate or restore controls for abandoned $abandon',
      (tester) async {
        var requests = 0;
        var orientations = 0;
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, (call) async {
              if (call.method == 'SystemChrome.setPreferredOrientations') {
                orientations++;
              }
              return null;
            });
        addTearDown(
          () => TestDefaultBinaryMessengerBinding
              .instance
              .defaultBinaryMessenger
              .setMockMethodCallHandler(SystemChannels.platform, null),
        );
        await http.runWithClient(
          () async {
            final controller = await mountCourse(tester);
            await controller.getData();
            final pending = controller.onTapLessonVideo(0);
            await tester.pumpAndSettle();
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 5100)),
            );
            if (abandon == 'account') {
              await tester.runAsync(
                () => LocalDataX.put(LocalKeyX.userid, 'synthetic-B'),
              );
            }
            if (abandon == 'closed') {
              Get.delete<CourseDetailsController>(force: true);
            }
            if (abandon == 'reload') await controller.getData();
            Get.back();
            await tester.pumpAndSettle();
            await pending;
            expect(requests, abandon == 'reload' ? 2 : 1);
            expect(orientations, 0);
            expect(
              controller.course.value!.activities.first.isCompleted,
              isFalse,
            );
          },
          () => MockClient((_) async {
            requests++;
            return fixtureResponse(courseFixture('synthetic-course'));
          }),
        );
      },
    );
  }
}
