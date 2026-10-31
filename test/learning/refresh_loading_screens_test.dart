// Courses tab and Home show their loading sign while they refetch after the
// user returns from a course page, so stale progress never looks final.
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Core/Helper/http/http.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Data/Database/config/database_end_point.dart';
import 'package:messengersofpeace/Data/Model/user/user.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Ui/Screen/Course/AllCourses/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Course/AllCourses/view/sections/loading.dart';
import 'package:messengersofpeace/Ui/Screen/Course/AllCourses/view/view.dart';
import 'package:messengersofpeace/Ui/Screen/Home/controller/controller.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart' show ToastX;
import 'empty_home_test.dart'
    show functionOf, fixtureResponse, homeResponse, levelFixture, userFixture;
import 'root_course_tap_test.dart' show openCourse;

/// Serves the levels read: later reads can be held or refused by number
class _Server {
  int levelReads = 0;
  final Map<int, Completer<http.Response>> held = {};
  final Set<int> refused = {};

  Completer<http.Response> hold(int read) =>
      held[read] = Completer<http.Response>();

  http.Client client() => MockClient((request) async {
    final function = request.url.queryParameters['wsfunction']!;
    if (function != functionOf(DBEndPointX.postGetLevelsWithCourses)) {
      return fixtureResponse(homeResponse(function));
    }
    final read = ++levelReads;
    if (held.containsKey(read)) return held[read]!.future;
    if (refused.contains(read)) return http.Response('boom', 500);
    return fixtureResponse([levelFixture('Level $read')]);
  });
}

Future<void> boot(WidgetTester tester) async {
  await tester.pumpWidget(
    GetMaterialApp(
      initialRoute: '/home-test',
      getPages: [
        GetPage(
          name: '/home-test',
          page: () => const Scaffold(body: SizedBox()),
        ),
        GetPage(
          name: RouteNameX.courseDetails,
          page: () => const Scaffold(body: SizedBox()),
        ),
        GetPage(
          name: RouteNameX.myCourses,
          page: () => const Scaffold(body: SizedBox()),
        ),
      ],
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-refresh-screens-');
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
    Get.delete<AllCoursesController>(force: true);
    Get.delete<HomeController>(force: true);
    Get.delete<AppControllerX>(force: true);
    Get.reset();
  });
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  group('Courses tab', () {
    testWidgets('the sign is on while the levels refetch after a course page', (
      tester,
    ) async {
      final server = _Server();
      await http.runWithClient(() async {
        final controller = Get.put(AllCoursesController());
        await boot(tester);
        await controller.getData();
        expect(controller.isRefreshing.value, isFalse);
        final navigation = controller.onCourseTap(openCourse());
        await tester.pumpAndSettle();
        expect(Get.currentRoute, RouteNameX.courseDetails);
        expect(controller.isRefreshing.value, isFalse);
        final slow = server.hold(2);
        Get.back();
        await tester.pumpAndSettle();
        expect(server.levelReads, 2);
        expect(controller.isRefreshing.value, isTrue);
        expect(controller.levels.single.name, 'Level 1');
        slow.complete(fixtureResponse([levelFixture('Level 2')]));
        await navigation;
        expect(controller.isRefreshing.value, isFalse);
        expect(controller.levels.single.name, 'Level 2');
      }, server.client);
    });

    testWidgets('a failed refetch turns the sign off and keeps the levels', (
      tester,
    ) async {
      final server = _Server();
      await http.runWithClient(() async {
        final controller = Get.put(AllCoursesController());
        await boot(tester);
        await controller.getData();
        final navigation = controller.onCourseTap(openCourse());
        await tester.pumpAndSettle();
        final slow = server.hold(2);
        Get.back();
        await tester.pumpAndSettle();
        expect(controller.isRefreshing.value, isTrue);
        slow.complete(http.Response('boom', 500));
        await navigation;
        await tester.pump(const Duration(seconds: 10));
        expect(controller.isRefreshing.value, isFalse);
        expect(controller.levels.single.name, 'Level 1');
      }, server.client);
    });

    testWidgets('the screen shows the first-load skeleton over the levels', (
      tester,
    ) async {
      final server = _Server();
      await http.runWithClient(() async {
        final controller = Get.put(AllCoursesController());
        await tester.pumpWidget(
          const GetMaterialApp(home: Scaffold(body: AllCoursesView())),
        );
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
        await tester.pump(const Duration(seconds: 1));
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('Level 1'), findsOneWidget);
        expect(find.byType(AllCoursesLoading), findsNothing);

        controller.isRefreshing.value = true;
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(AllCoursesLoading), findsOneWidget);

        controller.isRefreshing.value = false;
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(AllCoursesLoading), findsNothing);
        expect(server.levelReads, 1);
      }, server.client);
    });

    testWidgets('a page closed during the refetch publishes nothing', (
      tester,
    ) async {
      final server = _Server();
      await http.runWithClient(() async {
        final controller = Get.put(AllCoursesController());
        await boot(tester);
        await controller.getData();
        final navigation = controller.onCourseTap(openCourse());
        await tester.pumpAndSettle();
        final slow = server.hold(2);
        Get.back();
        await tester.pumpAndSettle();
        expect(controller.isRefreshing.value, isTrue);
        // The page is gone before the answer, nothing may be published
        Get.delete<AllCoursesController>(force: true);
        slow.complete(fixtureResponse([levelFixture('Late')]));
        await navigation;
        expect(controller.levels.single.name, 'Level 1');
      }, server.client);
    });
  });

  group('Home', () {
    testWidgets('the sign is on while Home refetches after a course page', (
      tester,
    ) async {
      final server = _Server();
      await http.runWithClient(() async {
        final controller = Get.put(HomeController());
        await boot(tester);
        await controller.getData();
        expect(controller.isRefreshing.value, isFalse);
        final navigation = controller.onMyCourses();
        await tester.pumpAndSettle();
        expect(Get.currentRoute, RouteNameX.myCourses);
        expect(controller.isRefreshing.value, isFalse);
        final slow = server.hold(2);
        Get.back();
        await tester.pumpAndSettle();
        expect(server.levelReads, 2);
        expect(controller.isRefreshing.value, isTrue);
        expect(controller.levels.single.name, 'Level 1');
        slow.complete(fixtureResponse([levelFixture('Level 2')]));
        await navigation;
        expect(controller.isRefreshing.value, isFalse);
        expect(controller.levels.single.name, 'Level 2');
      }, server.client);
    });

    testWidgets('a failed refetch turns the sign off and keeps the levels', (
      tester,
    ) async {
      final server = _Server();
      await http.runWithClient(() async {
        final controller = Get.put(HomeController());
        await boot(tester);
        await controller.getData();
        final navigation = controller.onMyCourses();
        await tester.pumpAndSettle();
        final slow = server.hold(2);
        Get.back();
        await tester.pumpAndSettle();
        expect(controller.isRefreshing.value, isTrue);
        slow.complete(http.Response('boom', 500));
        await navigation;
        // The failure is reported once, then the old levels stay
        expect(tester.takeException(), isNotNull);
        await tester.pump(const Duration(seconds: 10));
        expect(controller.isRefreshing.value, isFalse);
        expect(controller.levels.single.name, 'Level 1');
      }, server.client);
    });
  });
}
