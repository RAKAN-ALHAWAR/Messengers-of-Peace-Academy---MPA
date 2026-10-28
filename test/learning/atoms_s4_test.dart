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
import 'package:messengersofpeace/Core/Service/session_lease.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Data/Database/config/database_end_point.dart';
import 'package:messengersofpeace/Data/Model/user/user.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Ui/Screen/Course/AllCourses/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/My/MyCourses/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Profile/ProfileDetails/controller/controller.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

import '../performance/vertical_feed_test.dart' show fixture;
import 'empty_home_test.dart'
    show functionOf, fixtureResponse, userFixture, statsFixture, levelFixture;
import 'root_course_tap_test.dart' show openCourse, enrolledCourse, stub;

/// Step 0 of slice S4: one test per guard of the course lists and the profile,
/// each watched red with that one guard removed from the controller.

class _Request {
  _Request(this.function);
  final String function;
  final reply = Completer<http.Response>();
  bool answered = false;
}

/// A server that holds every request until the test answers it.
class _Net {
  final requests = <_Request>[];

  http.Client client() => MockClient((request) {
    final held = _Request(request.url.queryParameters['wsfunction']!);
    requests.add(held);
    return held.reply.future;
  });

  Future<void> settle() =>
      Future<void>.delayed(const Duration(milliseconds: 20));

  void answer(int index, Object body) {
    requests[index].answered = true;
    requests[index].reply.complete(fixtureResponse(body));
  }

  /// Answers every request that appears, except the held ones, until quiet.
  Future<void> drain(
    Object Function(String function) body, {
    Set<int> hold = const {},
  }) async {
    for (var round = 0; round < 12; round++) {
      await settle();
      final open = [
        for (var i = 0; i < requests.length; i++)
          if (!requests[i].answered && !hold.contains(i)) i,
      ];
      if (open.isEmpty) return;
      for (final i in open) {
        answer(i, body(requests[i].function));
      }
    }
  }
}

Object bodyFor(String function, String tag) {
  if (function == functionOf(DBEndPointX.postGetUser)) {
    return userFixture('synthetic-A', first: tag);
  }
  if (function == functionOf(DBEndPointX.postGetUserStatistics)) {
    return statsFixture();
  }
  if (function == functionOf(DBEndPointX.postGetLevelsWithCourses)) {
    return [levelFixture(tag)];
  }
  if (function == functionOf(DBEndPointX.postMyCourses)) {
    return [fixture(tag == 'new' ? 2 : 1).toJson()];
  }
  return <Object>[];
}

/// What a controller shows: empty when no load was published.
List<String> shown(GetxController controller) {
  switch (controller) {
    case AllCoursesController all:
      return all.levels.map((level) => level.name).toList();
    case MyCoursesController mine:
      return mine.myCourses.map((course) => course.id).toList();
    case ProfileDetailsController profile:
      final appFirst = Get.find<AppControllerX>().user.value.firstname;
      return [
        if (profile.isInit) profile.user.value.firstname,
        if (appFirst != 'Before') 'app:$appFirst',
      ];
  }
  throw StateError('unknown controller');
}

List<String> newShown(String kind) => switch (kind) {
  'all' => ['new'],
  'mine' => ['2'],
  _ => ['new', 'app:new'],
};

GetxController putController(String kind) => switch (kind) {
  'all' => Get.put(AllCoursesController()),
  'mine' => Get.put(MyCoursesController()),
  _ => Get.put(ProfileDetailsController()),
};

Future<void> load(GetxController controller, {SessionLeaseX? owner}) =>
    switch (controller) {
      AllCoursesController all => all.getData(owner: owner),
      MyCoursesController mine => mine.getData(owner: owner),
      ProfileDetailsController profile => profile.getData(
        force: true,
        owner: owner,
      ),
      _ => throw StateError('unknown controller'),
    };

/// A refresh that always fails, so a refresh that was not dropped shows a toast.
class _AllRefresh extends AllCoursesController {
  int refreshes = 0;
  @override
  Future<void> getData({SessionLeaseX? owner}) async {
    refreshes++;
    throw StateError('refresh failed');
  }
}

class _MineRefresh extends MyCoursesController {
  int refreshes = 0;
  @override
  Future<void> getData({SessionLeaseX? owner}) async {
    refreshes++;
    throw StateError('refresh failed');
  }
}

class _ProfileRefresh extends ProfileDetailsController {
  int refreshes = 0;
  @override
  Future<void> getData({bool force = false, SessionLeaseX? owner}) async {
    refreshes++;
    throw StateError('refresh failed');
  }
}

UserX appUser() => UserX.fromJson(userFixture('synthetic-A'));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-atoms-s4-');
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
    Get.put(AppControllerX()..user = appUser().obs, permanent: true);
  });
  tearDown(() {
    ToastX.dismiss();
    Get.delete<AppControllerX>(force: true);
    Get.reset();
  });
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  group('getData: a late answer is dropped', () {
    for (final kind in ['all', 'mine', 'profile']) {
      Future<void> pending(
        Future<void> Function(GetxController controller, _Net net) arrange,
      ) async {
        final net = _Net();
        await http.runWithClient(() async {
          final controller = putController(kind);
          await arrange(controller, net);
        }, net.client);
      }

      test('$kind publishes when nothing changed', () async {
        await pending((controller, net) async {
          final work = load(controller);
          await net.drain((function) => bodyFor(function, 'new'));
          await work;
          expect(shown(controller), newShown(kind));
        });
      });

      test('$kind drops the answer when the controller closes', () async {
        await pending((controller, net) async {
          final work = load(controller);
          await net.settle();
          controller.onDelete();
          await net.drain((function) => bodyFor(function, 'new'));
          await work;
          expect(shown(controller), isEmpty);
        });
      });

      test('$kind drops the answer when the owner tap ends', () async {
        await pending((controller, net) async {
          var active = true;
          final owner = SessionLeaseX.capture(isActive: () => active);
          final work = load(controller, owner: owner);
          await net.settle();
          active = false;
          await net.drain((function) => bodyFor(function, 'new'));
          await work;
          expect(shown(controller), isEmpty);
        });
      });

      test('$kind drops the answer when the language changes', () async {
        await pending((controller, net) async {
          final work = load(controller);
          await net.settle();
          Get.locale = const Locale('ar');
          await net.drain((function) => bodyFor(function, 'new'));
          await work;
          expect(shown(controller), isEmpty);
        });
      });

      test('$kind keeps the newest load when an older one ends last', () async {
        await pending((controller, net) async {
          final first = load(controller);
          await net.settle();
          final second = load(controller);
          await net.settle();
          expect(net.requests.length, 2);
          net.answer(1, bodyFor(net.requests[1].function, 'new'));
          await net.drain((function) => bodyFor(function, 'new'), hold: {0});
          net.answer(0, bodyFor(net.requests[0].function, 'old'));
          await net.drain((function) => bodyFor(function, 'old'));
          await Future.wait([first, second]);
          expect(shown(controller), newShown(kind));
        });
      });
    }

    test('mine still publishes when another instance is registered', () async {
      // MyCourses.getData has no "still the registered instance" guard.
      final net = _Net();
      await http.runWithClient(() async {
        final first = Get.put(MyCoursesController());
        final work = first.getData();
        await net.settle();
        // The registry changes without closing the old instance.
        GetInstance().resetInstance(clearRouteBindings: false);
        Get.put(AppControllerX()..user = appUser().obs, permanent: true);
        Get.put(MyCoursesController());
        await net.drain((function) => bodyFor(function, 'new'));
        await work;
        expect(first.myCourses.map((course) => course.id), ['2']);
      }, net.client);
    });
  });

  group('course taps: the refresh after the page returns is dropped', () {
    Future<void> boot(WidgetTester tester, {bool pushMyCourses = false}) async {
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: RouteNameX.loading,
          getPages: [
            GetPage(name: RouteNameX.loading, page: stub),
            GetPage(name: RouteNameX.root, page: stub),
            GetPage(name: RouteNameX.courseDetails, page: stub),
            GetPage(name: RouteNameX.myCourses, page: stub),
            GetPage(name: RouteNameX.editProfile, page: stub),
          ],
        ),
      );
      await tester.pumpAndSettle();
      Get.offAllNamed(RouteNameX.root);
      await tester.pumpAndSettle();
      if (pushMyCourses) {
        Get.toNamed(RouteNameX.myCourses);
        await tester.pumpAndSettle();
      }
    }

    // Per kind: its controller, the tap, the page the tap opens, its refreshes.
    final kinds =
        <
          String,
          ({
            String destination,
            GetxController Function() put,
            Future<void> Function(GetxController) tap,
            int Function(GetxController) refreshes,
            void Function() replace,
          })
        >{
          'all': (
            destination: RouteNameX.courseDetails,
            put: () => Get.put<AllCoursesController>(_AllRefresh()),
            tap: (c) => (c as AllCoursesController).onCourseTap(openCourse()),
            refreshes: (c) => (c as _AllRefresh).refreshes,
            replace: () => Get.put<AllCoursesController>(_AllRefresh()),
          ),
          'mine': (
            destination: RouteNameX.courseDetails,
            put: () => Get.put<MyCoursesController>(_MineRefresh()),
            tap: (c) =>
                (c as MyCoursesController).onTapCourse(enrolledCourse()),
            refreshes: (c) => (c as _MineRefresh).refreshes,
            replace: () => Get.put<MyCoursesController>(_MineRefresh()),
          ),
          'profile': (
            destination: RouteNameX.editProfile,
            put: () => Get.put<ProfileDetailsController>(_ProfileRefresh()),
            tap: (c) => (c as ProfileDetailsController).onEditPersonalData(),
            refreshes: (c) => (c as _ProfileRefresh).refreshes,
            replace: () => Get.put<ProfileDetailsController>(_ProfileRefresh()),
          ),
        };

    /// Taps, runs [whileOpen] on the opened page, returns, and reports.
    Future<(GetxController, int, bool)> run(
      WidgetTester tester,
      String kind,
      void Function(GetxController controller)? whileOpen,
    ) async {
      final spec = kinds[kind]!;
      // Profile also reports a failed refresh to the console.
      final onError = FlutterError.onError;
      FlutterError.onError = (_) {};
      try {
        final controller = spec.put();
        await boot(tester, pushMyCourses: kind == 'mine');
        final tap = spec.tap(controller);
        await tester.pumpAndSettle();
        expect(Get.currentRoute, spec.destination);
        whileOpen?.call(controller);
        await tester.pumpAndSettle();
        if (Get.currentRoute == spec.destination) Get.back();
        await tester.pumpAndSettle();
        await tap;
        await tester.pump();
        final toast = find
            .textContaining('refresh failed')
            .evaluate()
            .isNotEmpty;
        final refreshes = spec.refreshes(controller);
        ToastX.dismiss();
        await tester.pumpAndSettle();
        return (controller, refreshes, toast);
      } finally {
        FlutterError.onError = onError;
      }
    }

    for (final kind in ['all', 'mine', 'profile']) {
      testWidgets('$kind refreshes when nothing changed', (tester) async {
        final (_, refreshes, toast) = await run(tester, kind, null);
        expect(refreshes, 1);
        expect(toast, isTrue);
      });

      testWidgets('$kind drops the refresh when the controller closes', (
        tester,
      ) async {
        final (_, refreshes, toast) = await run(
          tester,
          kind,
          (controller) => controller.onDelete(),
        );
        expect(refreshes, 0);
        expect(toast, isFalse);
      });

      testWidgets('$kind drops the refresh when the page was left', (
        tester,
      ) async {
        final (_, refreshes, toast) = await run(
          tester,
          kind,
          (_) => Get.offAllNamed(RouteNameX.root),
        );
        expect(refreshes, 0);
        expect(toast, isFalse);
      });

      testWidgets('$kind drops the refresh when the language changes', (
        tester,
      ) async {
        final (_, refreshes, toast) = await run(
          tester,
          kind,
          (_) => Get.locale = const Locale('ar'),
        );
        expect(refreshes, 0);
        expect(toast, isFalse);
      });
    }

    for (final kind in ['mine', 'profile']) {
      testWidgets('$kind drops the refresh when another instance replaced it', (
        tester,
      ) async {
        final (_, refreshes, toast) = await run(tester, kind, (_) {
          // The registry changes without closing the tapped instance.
          GetInstance().resetInstance(clearRouteBindings: false);
          Get.put(AppControllerX()..user = appUser().obs, permanent: true);
          kinds[kind]!.replace();
        });
        expect(refreshes, 0);
        expect(toast, isFalse);
      });
    }

    testWidgets('mine still refreshes when the app controller is replaced', (
      tester,
    ) async {
      // MyCourses.onTapCourse has no app controller guard.
      final (_, refreshes, toast) = await run(tester, 'mine', (_) {
        Get.delete<AppControllerX>(force: true);
        Get.put(AppControllerX()..user = appUser().obs, permanent: true);
      });
      expect(refreshes, 1);
      expect(toast, isTrue);
    });
  });
}
