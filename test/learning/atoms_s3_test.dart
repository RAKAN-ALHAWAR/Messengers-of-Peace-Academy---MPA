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
import 'package:messengersofpeace/Ui/Widget/widget.dart';

// Atom tests for the Home controller (slice S3). Each test removes nothing:
// it holds one ownership atom (closed, registered instance, app controller,
// generation, locale) as the only thing that stops a stale answer.

String functionOf(String endpoint) =>
    Uri.parse(endpoint).queryParameters['wsfunction']!;
http.Response fixtureResponse(Object value) =>
    http.Response(jsonEncode(value), 200);
Map<String, Object> userFixture(String id, {String first = 'Before'}) => {
  NameX.id: id,
  NameX.username: id,
  NameX.email: '$id@example.invalid',
  NameX.firstname: first,
};
Object homeResponse(String function, {String first = 'After'}) {
  if (function == functionOf(DBEndPointX.postGetUser)) {
    return userFixture('synthetic-A', first: first);
  }
  if (function == functionOf(DBEndPointX.postGetUserStatistics)) {
    return {
      NameX.completedCourses: '0',
      NameX.minutes: '0',
      NameX.points: '0',
      NameX.certificates: '0',
      NameX.quizzes: '0',
    };
  }
  if (function == functionOf(DBEndPointX.postGetLevelsWithCourses)) {
    return [
      {
        NameX.levelId: 'level',
        NameX.levelName: 'level',
        NameX.totalCourses: 0,
        NameX.completedCourses: 0,
        NameX.completionPercent: 0,
        NameX.isOpen: true,
        NameX.isCompleted: false,
        NameX.courses: <Object>[],
      },
    ];
  }
  if (function == functionOf(DBEndPointX.postGetMeetings)) {
    return {NameX.meetings: <Object>[]};
  }
  if (function == functionOf(DBEndPointX.postGetNotifications)) {
    return <Object>[];
  }
  throw StateError('Unexpected synthetic request category');
}

/// Closes without HomeController.onClose, so no generation counter moves.
class _SilentHome extends HomeController {
  @override
  // ignore: must_call_super
  void onClose() {}
}

/// Holds every request until the test answers, and counts them.
class _Held {
  final calls = <(String, Completer<http.Response>)>[];
  final allSent = Completer<void>();

  MockClient get client => MockClient((request) {
    final answer = Completer<http.Response>();
    calls.add((request.url.queryParameters['wsfunction']!, answer));
    if (calls.length == 5) allSent.complete();
    return answer.future;
  });

  void answerAll() {
    for (final call in calls) {
      if (!call.$2.isCompleted) {
        call.$2.complete(fixtureResponse(homeResponse(call.$1)));
      }
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late AppControllerX app;
  late HomeController controller;
  var count = 0;

  /// Answers at once and counts every request.
  MockClient counting() => MockClient((request) async {
    count++;
    return fixtureResponse(
      homeResponse(request.url.queryParameters['wsfunction']!),
    );
  });

  /// A second live Home becomes the registered one; the first stays open.
  HomeController replaceHome() {
    GetInstance().resetInstance(clearRouteBindings: false);
    Get.put(app, permanent: true);
    return Get.put(HomeController());
  }

  /// The registered Home closes without moving any counter in onClose.
  HomeController useSilentHome() {
    Get.delete<HomeController>(force: true);
    final silent = Get.put<HomeController>(_SilentHome());
    addTearDown(silent.complaintController.dispose);
    return silent;
  }

  /// A second live app controller becomes the registered one.
  void replaceApp() {
    Get.delete<AppControllerX>(force: true);
    Get.put(
      AppControllerX()..user = UserX.fromJson(userFixture('synthetic-A')).obs,
      permanent: true,
    );
  }

  Future<void> pumpRoutes(WidgetTester tester) async {
    Widget page() => const Scaffold(body: SizedBox());
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/home-test',
        getPages: [
          GetPage(name: '/home-test', page: page),
          GetPage(name: RouteNameX.notifications, page: page),
          GetPage(name: RouteNameX.myCourses, page: page),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-home-atoms-');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('app');
    HttpX.init();
  });
  setUp(() async {
    Get.testMode = true;
    Get.locale = const Locale('en');
    count = 0;
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

  //============================================================================
  // getData lease: a pending load is published only by the Home that owns it

  test('pending load of a replaced Home instance publishes nothing', () async {
    final held = _Held();
    await http.runWithClient(() async {
      final load = controller.getData();
      await held.allSent.future;
      replaceHome();
      held.answerAll();
      await load;
      expect(controller.isInit, isFalse);
      expect(controller.levels, isEmpty);
      expect(app.user.value.firstname, 'Before');
    }, () => held.client);
  });

  test('pending load after the app controller is replaced publishes nothing',
      () async {
    final held = _Held();
    await http.runWithClient(() async {
      final load = controller.getData();
      await held.allSent.future;
      replaceApp();
      held.answerAll();
      await load;
      expect(controller.isInit, isFalse);
      expect(controller.levels, isEmpty);
      expect(app.user.value.firstname, 'Before');
    }, () => held.client);
  });

  test('pending load of a closed but still registered Home publishes nothing',
      () async {
    final silent = useSilentHome();
    final held = _Held();
    await http.runWithClient(() async {
      final load = silent.getData();
      await held.allSent.future;
      silent.onDelete();
      held.answerAll();
      await load;
      expect(silent.isClosed, isTrue);
      expect(silent.isInit, isFalse);
      expect(silent.levels, isEmpty);
      expect(app.user.value.firstname, 'Before');
    }, () => held.client);
  });

  //============================================================================
  // getData entry: a Home that no longer owns itself sends nothing

  test('a closed Home that is still registered sends no request', () async {
    controller.onDelete();
    await http.runWithClient(() async {
      await controller.getData();
      expect(count, 0);
    }, counting);
  });

  test('a replaced Home instance sends no request', () async {
    replaceHome();
    await http.runWithClient(() async {
      await controller.getData();
      expect(count, 0);
    }, counting);
  });

  test('a Home whose app controller was replaced sends no request', () async {
    replaceApp();
    await http.runWithClient(() async {
      await controller.getData();
      expect(count, 0);
    }, counting);
  });

  //============================================================================
  // onNotifications lease: the unread count is written only by the owner

  testWidgets('a notification return after the Home instance is replaced '
      'writes nothing', (tester) async {
    await http.runWithClient(() async {
      await pumpRoutes(tester);
      final pending = controller.onNotifications();
      await tester.pumpAndSettle();
      replaceHome();
      Get.back(result: 9);
      await tester.pumpAndSettle();
      await pending;
      expect(controller.unreadNotificationsCount.value, 0);
      expect(count, 0);
    }, counting);
  });

  testWidgets('a notification return after the app controller is replaced '
      'writes nothing', (tester) async {
    await http.runWithClient(() async {
      await pumpRoutes(tester);
      final pending = controller.onNotifications();
      await tester.pumpAndSettle();
      replaceApp();
      Get.back(result: 9);
      await tester.pumpAndSettle();
      await pending;
      expect(controller.unreadNotificationsCount.value, 0);
      expect(count, 0);
    }, counting);
  });

  testWidgets('a notification return after a newer tap writes nothing', (
    tester,
  ) async {
    await http.runWithClient(() async {
      await pumpRoutes(tester);
      final first = controller.onNotifications();
      await tester.pumpAndSettle();
      final second = controller.onNotifications();
      await tester.pumpAndSettle();
      await second;
      expect(count, 1);
      Get.back(result: 9);
      await tester.pumpAndSettle();
      await first;
      expect(controller.unreadNotificationsCount.value, 0);
    }, counting);
  });

  testWidgets('a notification return after a language change writes nothing', (
    tester,
  ) async {
    await http.runWithClient(() async {
      await pumpRoutes(tester);
      final pending = controller.onNotifications();
      await tester.pumpAndSettle();
      Get.locale = const Locale('es');
      Get.back(result: 9);
      await tester.pumpAndSettle();
      await pending;
      expect(controller.unreadNotificationsCount.value, 0);
      expect(count, 0);
    }, counting);
  });

  testWidgets('a notification return to a closed but registered Home writes '
      'nothing', (tester) async {
    final silent = useSilentHome();
    await http.runWithClient(() async {
      await pumpRoutes(tester);
      final pending = silent.onNotifications();
      await tester.pumpAndSettle();
      silent.onDelete();
      Get.back(result: 9);
      await tester.pumpAndSettle();
      await pending;
      expect(silent.isClosed, isTrue);
      expect(silent.unreadNotificationsCount.value, 0);
      expect(count, 0);
    }, counting);
  });

  //============================================================================
  // Progress refresh: a stale Home does not refresh after a child route returns

  testWidgets('MyCourses return after the Home instance is replaced does not '
      'refresh', (tester) async {
    await http.runWithClient(() async {
      await pumpRoutes(tester);
      await controller.getData();
      final navigation = controller.onMyCourses();
      await tester.pumpAndSettle();
      replaceHome();
      Get.back();
      await tester.pumpAndSettle();
      await navigation;
      expect(count, 5);
    }, counting);
  });

  testWidgets('MyCourses return after the app controller is replaced does not '
      'refresh', (tester) async {
    await http.runWithClient(() async {
      await pumpRoutes(tester);
      await controller.getData();
      final navigation = controller.onMyCourses();
      await tester.pumpAndSettle();
      replaceApp();
      Get.back();
      await tester.pumpAndSettle();
      await navigation;
      expect(count, 5);
    }, counting);
  });
}
