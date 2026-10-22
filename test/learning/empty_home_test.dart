import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
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
import 'package:messengersofpeace/Ui/Screen/Home/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Home/view/view.dart';
import 'package:messengersofpeace/Ui/Screen/Home/view/sectinos/current_level.dart';
import 'package:messengersofpeace/Ui/Screen/Home/view/sectinos/level_progress_card.dart';
import 'package:messengersofpeace/Ui/Screen/Home/view/sectinos/levels_progress.dart';
import 'package:messengersofpeace/Ui/Screen/Home/view/sectinos/my_progress.dart';
import 'package:messengersofpeace/Ui/Screen/Home/view/sectinos/nav_cards.dart';
import 'package:messengersofpeace/Ui/Widget/Custom/Other/empty_message.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

String functionOf(String endpoint) =>
    Uri.parse(endpoint).queryParameters['wsfunction']!;
http.Response fixtureResponse(Object value, [int status = 200]) =>
    http.Response(jsonEncode(value), status);
Map<String, Object> userFixture(String id, {String first = 'Before'}) => {
  NameX.id: id,
  NameX.username: id,
  NameX.email: '$id@example.invalid',
  NameX.firstname: first,
};
Map<String, Object> statsFixture() => {
  NameX.completedCourses: '0',
  NameX.minutes: '0',
  NameX.points: '0',
  NameX.certificates: '0',
  NameX.quizzes: '0',
};
Map<String, Object> levelFixture(String id) => {
  NameX.levelId: id,
  NameX.levelName: id,
  NameX.totalCourses: 0,
  NameX.completedCourses: 0,
  NameX.completionPercent: 0,
  NameX.isOpen: true,
  NameX.isCompleted: false,
  NameX.courses: <Object>[],
};
Object homeResponse(
  String function, {
  String id = 'synthetic-A',
  bool empty = false,
  String first = 'After',
}) {
  if (function == functionOf(DBEndPointX.postGetUser)) {
    return userFixture(id, first: first);
  }
  if (function == functionOf(DBEndPointX.postGetUserStatistics)) {
    return statsFixture();
  }
  if (function == functionOf(DBEndPointX.postGetLevelsWithCourses)) {
    return empty
        ? <Object>[]
        : [levelFixture('$id-${Get.locale?.languageCode}')];
  }
  if (function == functionOf(DBEndPointX.postGetMeetings)) {
    return {NameX.meetings: <Object>[]};
  }
  if (function == functionOf(DBEndPointX.postGetNotifications)) {
    return <Object>[];
  }
  throw StateError('Unexpected synthetic request category');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late AppControllerX app;
  late HomeController controller;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-home-');
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
    app = Get.put(
      AppControllerX()..user = UserX.fromJson(userFixture('synthetic-A')).obs,
      permanent: true,
    );
    controller = Get.put(HomeController());
  });
  tearDown(() {
    ToastX.dismiss();
    Get.delete<HomeController>(force: true);
    Get.delete<AppControllerX>(force: true);
    Get.reset();
  });
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test(
    'empty levels complete a valid Home load without inventing a level',
    () async {
      var count = 0;
      await http.runWithClient(
        () async {
          await controller.getData();
          expect(count, 5);
          expect(controller.isInit, isTrue);
          expect(controller.levels, isEmpty);
          expect(controller.currentLevel.value, isNull);
          expect(controller.statistics.value.minutes, '0');
        },
        () => MockClient((request) async {
          count++;
          return fixtureResponse(
            homeResponse(
              request.url.queryParameters['wsfunction']!,
              empty: true,
            ),
          );
        }),
      );
    },
  );

  testWidgets(
    'empty Home renders existing empty UI while statistics and navigation remain',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await http.runWithClient(
        () async {
          await tester.pumpWidget(GetMaterialApp(home: const HomeView()));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.byType(EmptyMessage), findsOneWidget);
          expect(find.byType(LevelProgressCard), findsNothing);
          expect(find.byType(LevelsProgressSection), findsNothing);
          expect(find.byType(CurrentLevelSection), findsNothing);
          expect(find.byType(MyProgressSection), findsOneWidget);
          expect(find.byType(NavCardsSection), findsOneWidget);
        },
        () => MockClient(
          (request) async => fixtureResponse(
            homeResponse(
              request.url.queryParameters['wsfunction']!,
              empty: true,
            ),
          ),
        ),
      );
    },
  );

  test(
    'one-minute Home cache is owned by its account generation and locale',
    () async {
      var count = 0;
      await http.runWithClient(
        () async {
          await controller.getData();
          await controller.getData();
          expect(count, 5);
          await LocalDataX.put(LocalKeyX.token, 'synthetic-token');
          await controller.getData();
          expect(count, 10);
          await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
          app.user.value = UserX.fromJson(userFixture('synthetic-B'));
          await controller.getData();
          expect(count, 15);
          expect(controller.user.value.id, 'synthetic-B');
          Get.locale = const Locale('es');
          await controller.getData();
          expect(count, 20);
          expect(controller.levels.single.id, 'synthetic-B-es');
          controller.lastUpdate = DateTime(2000);
          await controller.getData();
          expect(count, 25);
        },
        () => MockClient((request) async {
          count++;
          return fixtureResponse(
            homeResponse(
              request.url.queryParameters['wsfunction']!,
              id: LocalDataX.userid,
            ),
          );
        }),
      );
    },
  );

  test(
    'Home publishes its five-call snapshot only after every response succeeds',
    () async {
      final pending = <String, Completer<http.Response>>{};
      final started = Completer<void>();
      await http.runWithClient(
        () async {
          final load = controller.getData();
          await started.future;
          pending[functionOf(DBEndPointX.postGetUser)]!.complete(
            fixtureResponse(userFixture('synthetic-A', first: 'After')),
          );
          await Future<void>.delayed(Duration.zero);
          expect(app.user.value.firstname, 'Before');
          for (final entry in pending.entries) {
            if (!entry.value.isCompleted) {
              entry.value.complete(fixtureResponse(homeResponse(entry.key)));
            }
          }
          await load;
          expect(app.user.value.firstname, 'After');
          expect(controller.isInit, isTrue);
        },
        () => MockClient((request) {
          final function = request.url.queryParameters['wsfunction']!;
          final response = Completer<http.Response>();
          pending[function] = response;
          if (pending.length == 5) started.complete();
          return response.future;
        }),
      );
    },
  );

  for (final abandon in ['session', 'locale', 'closed', 'newer-load']) {
    test(
      'pending Home ignores $abandon before publishing any shared state',
      () async {
        final pending = <Completer<http.Response>>[];
        final started = Completer<void>();
        var count = 0;
        await http.runWithClient(
          () async {
            final load = controller.getData();
            await started.future;
            if (abandon == 'session') {
              await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
              app.user.value = UserX.fromJson(userFixture('synthetic-B'));
            }
            if (abandon == 'locale' || abandon == 'newer-load') {
              Get.locale = const Locale('es');
            }
            if (abandon == 'closed') Get.delete<HomeController>(force: true);
            if (abandon == 'newer-load') await controller.getData();
            for (final item in pending) {
              if (!item.isCompleted) item.complete(fixtureResponse(<Object>[]));
            }
            await load;
            expect(app.user.value.firstname, 'Before');
            if (abandon != 'newer-load') {
              expect(controller.isInit, isFalse);
              expect(controller.levels, isEmpty);
            } else {
              expect(controller.levels.single.id, 'synthetic-A-es');
            }
          },
          () => MockClient((request) {
            count++;
            final function = request.url.queryParameters['wsfunction']!;
            if (count > 5) {
              return Future.value(
                fixtureResponse(homeResponse(function, first: 'Before')),
              );
            }
            final response = Completer<http.Response>();
            pending.add(response);
            if (count == 5) started.complete();
            return response.future;
          }),
        );
      },
    );
  }

  testWidgets(
    'notification result from A cannot update B or issue a B followup',
    (tester) async {
      var count = 0;
      await http.runWithClient(
        () async {
          await tester.pumpWidget(
            GetMaterialApp(
              initialRoute: '/home-test',
              getPages: [
                GetPage(
                  name: '/home-test',
                  page: () => const Scaffold(body: SizedBox()),
                ),
                GetPage(
                  name: RouteNameX.notifications,
                  page: () => const Scaffold(body: SizedBox()),
                ),
              ],
            ),
          );
          await tester.pumpAndSettle();
          final pending = controller.onNotifications();
          await tester.pumpAndSettle();
          await tester.runAsync(
            () => LocalDataX.put(LocalKeyX.userid, 'synthetic-B'),
          );
          Get.back(result: 9);
          await tester.pumpAndSettle();
          await pending;
          expect(controller.unreadNotificationsCount.value, 0);
          expect(count, 0);
        },
        () => MockClient((_) async {
          count++;
          return fixtureResponse(<Object>[]);
        }),
      );
    },
  );
  test('anonymous Home reload sends no protected request', () async {
    await LocalDataX.remove(LocalKeyX.token);
    var count = 0;
    await http.runWithClient(
      () async {
        await expectLater(controller.getData(), throwsA(anything));
        expect(count, 0);
        expect(controller.isInit, isFalse);
      },
      () => MockClient((_) async {
        count++;
        return fixtureResponse(<Object>[]);
      }),
    );
  });

  test(
    'Home refuses a profile for another identity before publishing its snapshot',
    () async {
      await http.runWithClient(
        () async {
          await expectLater(controller.getData(), throwsA(anything));
          expect(app.user.value.id, 'synthetic-A');
          expect(app.user.value.firstname, 'Before');
          expect(controller.isInit, isFalse);
          expect(controller.levels, isEmpty);
        },
        () => MockClient(
          (request) async => fixtureResponse(
            homeResponse(
              request.url.queryParameters['wsfunction']!,
              id: 'synthetic-B',
            ),
          ),
        ),
      );
    },
  );

  test(
    'concurrent equivalent Home reads share one pending five-call snapshot',
    () async {
      final responses = <(String, Completer<http.Response>)>[];
      final started = Completer<void>();
      await http.runWithClient(
        () async {
          final first = controller.getData();
          await started.future;
          final second = controller.getData();
          expect(responses.length, 5);
          for (final response in responses) {
            response.$2.complete(fixtureResponse(homeResponse(response.$1)));
          }
          await Future.wait([first, second]);
          expect(controller.isInit, isTrue);
        },
        () => MockClient((request) {
          final response = Completer<http.Response>();
          responses.add((request.url.queryParameters['wsfunction']!, response));
          if (responses.length == 5) started.complete();
          return response.future;
        }),
      );
    },
  );
}
