import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:messengersofpeace/Core/Helper/http/http.dart';
import 'package:messengersofpeace/Core/Service/session_lease.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Model/course/my_course.dart';
import 'package:messengersofpeace/Data/Model/notification.dart';
import 'package:messengersofpeace/Ui/Screen/My/MyCourses/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/My/MyCourses/view/view.dart';
import 'package:messengersofpeace/Ui/Screen/Notifications/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Notifications/view/view.dart';
import 'package:messengersofpeace/Ui/Widget/Custom/Card/notification_card.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

MyCourse fixture(int i) => MyCourse(
  id: '$i',
  fullName: 'Course $i',
  lang: 'en',
  image: '',
  totalSections: 1,
  completedSections: 0,
  completionPercent: 0,
  enrolled: true,
);

class _Courses extends MyCoursesController {
  _Courses(this.count);
  final int count;
  @override
  Future<void> getData({SessionLeaseX? owner}) async =>
      myCourses.assignAll(List.generate(count, fixture));
}

class _Notices extends NotificationsController {
  _Notices(this.count);
  final int count;
  @override
  Future<void> getData() async => notifications.assignAll(
    List.generate(
      count,
      (i) => NotificationX(
        id: '$i',
        eventtype: '',
        subject: 'Notice $i',
        fullmessage: '',
        timecreated: '2026-10-01T12:00:00',
        read: false,
      ),
    ),
  );
}

void main() {
  late Directory directory;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-vertical-feed');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('app');
    HttpX.init();
  });
  setUp(() async {
    Get.testMode = true;
    Get.locale = const Locale('en');
    await LocalDataX.put(LocalKeyX.userid, 'synthetic-user');
    await LocalDataX.put(LocalKeyX.token, 'synthetic-token');
  });
  tearDown(() {
    ToastX.dismiss();
    Get.reset();
  });
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });
  for (final retired in [false, true]) {
    test(
      'mycourses ${retired ? 'closed' : 'anonymous'} owner issues no read',
      () async {
        final controller = Get.put(MyCoursesController());
        if (retired) {
          Get.delete<MyCoursesController>();
        } else {
          await LocalDataX.remove(LocalKeyX.userid);
          await LocalDataX.remove(LocalKeyX.token);
        }
        var calls = 0;
        await http.runWithClient(
          () async {
            if (retired) {
              await controller.getData();
            } else {
              await expectLater(controller.getData(), throwsA(anything));
            }
          },
          () => MockClient((_) async {
            calls++;
            return http.Response('[]', 200);
          }),
        );
        expect(calls, 0);
      },
    );
  }
  for (final count in [0, 1, 20, 100, 1000]) {
    for (final notices in [true, false]) {
      testWidgets(
        '${notices ? 'Notifications' : 'MyCourses'} $count rows remain lazy and reachable',
        (tester) async {
          tester.view.physicalSize = const Size(400, 700);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          if (notices) {
            Get.put<NotificationsController>(_Notices(count));
          } else {
            Get.put<MyCoursesController>(_Courses(count));
          }
          await tester.pumpWidget(
            GetMaterialApp(
              locale: const Locale('en'),
              home: notices ? const NotificationsView() : const MyCoursesView(),
            ),
          );
          await tester.pumpAndSettle();
          final type = notices ? NotificationCard : ImageNetworkX;
          final mounted = find.byType(type).evaluate().length;
          expect(mounted, lessThanOrEqualTo(25));
          expect(mounted, count == 0 ? 0 : greaterThan(0));
          if (count >= 100) {
            expect(
              find.text('${notices ? 'Notice' : 'Course'} ${count - 1}'),
              findsNothing,
            );
            final scroll = tester.state<ScrollableState>(
              find.byType(Scrollable).first,
            );
            // Variable-height lazy lists refine their extent after layout.
            for (var jump = 0; jump < 5; jump++) {
              scroll.position.jumpTo(scroll.position.maxScrollExtent);
              await tester.pumpAndSettle();
              if (find
                  .text('${notices ? 'Notice' : 'Course'} ${count - 1}')
                  .evaluate()
                  .isNotEmpty) {
                break;
              }
            }
            expect(
              find.text('${notices ? 'Notice' : 'Course'} ${count - 1}'),
              findsOneWidget,
            );
            expect(find.byType(type).evaluate().length, lessThanOrEqualTo(25));
          }
          await tester.pumpWidget(const SizedBox());
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
  for (final change in ['session', 'locale', 'disposed', 'newer']) {
    test('mycourses rejects late $change result', () async {
      final c = Get.put(MyCoursesController());
      final pending = Completer<http.Response>();
      final issued = Completer<void>();
      var calls = 0;
      await http.runWithClient(
        () async {
          final old = c.getData();
          await issued.future;
          switch (change) {
            case 'session':
              await LocalDataX.put(LocalKeyX.userid, 'replacement');
            case 'locale':
              Get.locale = const Locale('es');
            case 'disposed':
              Get.delete<MyCoursesController>();
            case 'newer':
              await c.getData();
          }
          pending.complete(
            http.Response(jsonEncode([fixture(1).toJson()]), 200),
          );
          await old;
        },
        () => MockClient((_) async {
          calls++;
          if (calls == 1) {
            issued.complete();
            return pending.future;
          }
          return http.Response(jsonEncode([fixture(2).toJson()]), 200);
        }),
      );
      expect(c.myCourses.map((e) => e.id), change == 'newer' ? ['2'] : isEmpty);
    });
  }
  testWidgets('return from a course reads fresh rows despite retained loader', (
    tester,
  ) async {
    final c = Get.put(MyCoursesController());
    var calls = 0;
    await http.runWithClient(
      () async {
        await tester.pumpWidget(
          GetMaterialApp(
            locale: const Locale('en'),
            initialRoute: '/enrolled',
            getPages: [
              GetPage(name: '/enrolled', page: () => const MyCoursesView()),
              GetPage(
                name: RouteNameX.courseDetails,
                page: () => const Scaffold(body: Text('Course details')),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Course 1'), findsOneWidget);
        await tester.tap(find.text('Course 1'));
        await tester.pumpAndSettle();
        expect(find.text('Course details'), findsOneWidget);
        Get.back();
        await tester.pumpAndSettle();
        expect(calls, 2);
        expect(find.text('Course 2'), findsOneWidget);
        expect(c.myCourses.single.id, '2');
        await tester.pumpWidget(const SizedBox());
      },
      () => MockClient((_) async {
        calls++;
        return http.Response(jsonEncode([fixture(calls).toJson()]), 200);
      }),
    );
  });
}
