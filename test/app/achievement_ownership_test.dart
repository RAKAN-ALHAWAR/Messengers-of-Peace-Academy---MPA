import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Core/Helper/http/http.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Database/config/database_end_point.dart';
import 'package:messengersofpeace/Data/Model/user/user.dart';
import 'package:messengersofpeace/Ui/Screen/Badges/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/My/MyAchievements/controller/controller.dart';

String function(String endpoint) =>
    Uri.parse(endpoint).queryParameters['wsfunction']!;
http.Response response(Object value) => http.Response.bytes(
  utf8.encode(jsonEncode(value)),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);
Map<String, Object> badge(String name) => {
  NameX.id: name,
  NameX.badgeName: name,
  NameX.requiredPoints: 10,
  NameX.description: 'Fixture',
  NameX.earned: false,
};
Map<String, Object> point(String name) => {
  NameX.id: name,
  NameX.myActivityName: name,
  NameX.points: 7,
  NameX.dateTime: '2026-10-01T12:00:00',
};
UserX user(String id) => UserX.fromJson({
  NameX.id: id,
  NameX.username: id,
  NameX.email: 'test@example.invalid',
  NameX.points: 0,
});
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late AppControllerX app;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp(
      'mopa-achievement-owner-',
    );
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('synthetic');
    HttpX.init();
  });
  setUp(() async {
    Get.testMode = true;
    Get.locale = const Locale('en');
    await LocalDataX.put(LocalKeyX.userid, 'synthetic-A');
    await LocalDataX.put(LocalKeyX.token, 'synthetic-token');
    app = Get.put<AppControllerX>(
      AppControllerX()..user = user('synthetic-A').obs,
    );
  });
  tearDown(() => Get.reset());
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });
  for (final kind in ['badges', 'achievements']) {
    test('$kind anonymous loader sends no protected request', () async {
      await LocalDataX.remove(LocalKeyX.userid);
      var requests = 0;
      await http.runWithClient(
        () async {
          if (kind == 'badges') {
            expect(
              await Get.put<BadgesController>(BadgesController()).getData(),
              isEmpty,
            );
          } else {
            final c = Get.put<MyAchievementsController>(
              MyAchievementsController(),
            );
            await c.getData();
            expect(c.badges, isEmpty);
            expect(c.currentBadge, isNull);
          }
          expect(requests, 0);
        },
        () => MockClient((request) async {
          requests++;
          return response(
            request.url.queryParameters['wsfunction'] ==
                    function(DBEndPointX.postGetBadges)
                ? [badge('unowned')]
                : [point('unowned')],
          );
        }),
      );
    });
    for (final retired in ['session', 'locale', 'disposal']) {
      test(
        '$kind retires a late $retired response before follow-up or publication',
        () async {
          final badges =
              kind == 'badges'
                  ? Get.put<BadgesController>(BadgesController())
                  : null;
          final achievements =
              kind == 'achievements'
                  ? Get.put<MyAchievementsController>(
                    MyAchievementsController(),
                  )
                  : null;
          final pending = Completer<http.Response>();
          final started = Completer<void>();
          var requests = 0;
          await http.runWithClient(
            () async {
              final Future<dynamic> work =
                  badges != null ? badges.getData() : achievements!.getData();
              await started.future;
              if (retired == 'session') {
                await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
                app.user.value = user('synthetic-B');
              } else if (retired == 'locale') {
                Get.locale = const Locale('es');
              } else if (badges != null) {
                await Get.delete<BadgesController>();
              } else {
                await Get.delete<MyAchievementsController>();
              }
              pending.complete(response([badge('obsolete')]));
              Object? result;
              try {
                result = await work;
              } catch (_) {
                /* Safe numeric/state assertions below; never dump request errors. */
              }
              expect(requests, 1);
              if (badges != null) {
                expect(result, isEmpty);
              } else {
                expect(achievements!.badges, isEmpty);
                expect(achievements.myActivityPoints, isEmpty);
                expect(achievements.currentBadge, isNull);
              }
            },
            () => MockClient((request) async {
              requests++;
              if (requests == 1) {
                started.complete();
                return pending.future;
              }
              return response([point('obsolete')]);
            }),
          );
        },
      );
    }
  }
  test('mismatched app user cannot select a previous account badge', () async {
    final c = Get.put<MyAchievementsController>(MyAchievementsController());
    var requests = 0;
    await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
    await http.runWithClient(
      () async {
        await c.getData();
        expect(requests, 0);
        expect(c.currentBadge, isNull);
        expect(c.badges, isEmpty);
      },
      () => MockClient((request) async {
        requests++;
        return response(
          request.url.queryParameters['wsfunction'] ==
                  function(DBEndPointX.postGetBadges)
              ? [badge('old-user-badge')]
              : [point('new-user-point')],
        );
      }),
    );
  });
  test(
    'second-stage failure preserves the coherent previous same-owner snapshot',
    () async {
      final c = Get.put<MyAchievementsController>(MyAchievementsController());
      var fail = false;
      await http.runWithClient(
        () async {
          await c.getData();
          expect(c.currentBadge?.name, 'original');
          fail = true;
          await expectLater(c.getData(), throwsA(anything));
          expect(c.badges.single.name, 'original');
          expect(c.myActivityPoints.single.activityName, 'original');
          expect(c.currentBadge?.name, 'original');
        },
        () => MockClient((request) async {
          if (request.url.queryParameters['wsfunction'] ==
              function(DBEndPointX.postGetBadges)) {
            return response([badge(fail ? 'partial' : 'original')]);
          }
          return response(
            fail
                ? {'status': 'failed', 'message': 'Synthetic history failure'}
                : [point('original')],
          );
        }),
      );
    },
  );
  test(
    'new-owner second-stage failure never publishes either old or partial badge',
    () async {
      final c = Get.put<MyAchievementsController>(MyAchievementsController());
      var fail = false;
      await http.runWithClient(
        () async {
          await c.getData();
          await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
          app.user.value = user('synthetic-B');
          fail = true;
          await expectLater(c.getData(), throwsA(anything));
          expect(c.badges, isEmpty);
          expect(c.myActivityPoints, isEmpty);
          expect(c.currentBadge, isNull);
        },
        () => MockClient((request) async {
          if (request.url.queryParameters['wsfunction'] ==
              function(DBEndPointX.postGetBadges)) {
            return response([badge(fail ? 'partial-B' : 'original-A')]);
          }
          return response(
            fail
                ? {'status': 'failed', 'message': 'Synthetic history failure'}
                : [point('original-A')],
          );
        }),
      );
    },
  );
  test(
    'overlapping load generation keeps the newest complete snapshot',
    () async {
      final c = Get.put<MyAchievementsController>(MyAchievementsController());
      final pending = Completer<http.Response>();
      final started = Completer<void>();
      var requests = 0;
      await http.runWithClient(
        () async {
          final older = c.getData();
          await started.future;
          await c.getData();
          pending.complete(response([badge('obsolete')]));
          await older;
          expect(requests, 3);
          expect(c.badges.single.name, 'current');
          expect(c.myActivityPoints.single.activityName, 'current');
          expect(c.currentBadge?.name, 'current');
        },
        () => MockClient((request) async {
          requests++;
          if (requests == 1) {
            started.complete();
            return pending.future;
          }
          return response(
            request.url.queryParameters['wsfunction'] ==
                    function(DBEndPointX.postGetBadges)
                ? [badge('current')]
                : [point('current')],
          );
        }),
      );
    },
  );
  test('empty new badge snapshot clears the old current badge', () async {
    final c = Get.put<MyAchievementsController>(MyAchievementsController());
    var empty = false;
    await http.runWithClient(
      () async {
        await c.getData();
        empty = true;
        await c.getData();
        expect(c.currentBadge, isNull);
        expect(c.badges, isEmpty);
      },
      () => MockClient((request) async {
        return response(
          request.url.queryParameters['wsfunction'] ==
                  function(DBEndPointX.postGetBadges)
              ? (empty ? [] : [badge('original')])
              : [point('history')],
        );
      }),
    );
  });
  for (final retired in ['session', 'locale', 'disposal']) {
    test(
      'second-stage pending snapshot is atomic and retires after $retired',
      () async {
        final c = Get.put<MyAchievementsController>(MyAchievementsController());
        final pending = Completer<http.Response>();
        final started = Completer<void>();
        var interim = -1;
        await http.runWithClient(
          () async {
            final work = c.getData();
            await started.future;
            interim = c.badges.length;
            if (retired == 'session') {
              await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
              app.user.value = user('synthetic-B');
            } else if (retired == 'locale') {
              Get.locale = const Locale('es');
            } else {
              await Get.delete<MyAchievementsController>();
            }
            pending.complete(response([point('obsolete')]));
            try {
              await work;
            } catch (_) {}
            expect(interim, 0);
            expect(c.badges, isEmpty);
            expect(c.myActivityPoints, isEmpty);
            expect(c.currentBadge, isNull);
          },
          () => MockClient((request) async {
            if (request.url.queryParameters['wsfunction'] ==
                function(DBEndPointX.postGetBadges)) {
              return response([badge('partial')]);
            }
            started.complete();
            return pending.future;
          }),
        );
      },
    );
  }
  test(
    'badge catalog keeps the newer load and retires the older result',
    () async {
      final c = Get.put<BadgesController>(BadgesController());
      final pending = Completer<http.Response>();
      final started = Completer<void>();
      var requests = 0;
      await http.runWithClient(
        () async {
          final older = c.getData();
          await started.future;
          final newer = await c.getData();
          pending.complete(response([badge('obsolete')]));
          expect(await older, isEmpty);
          expect(newer.single.name, 'current');
          expect(requests, 2);
        },
        () => MockClient((request) async {
          requests++;
          if (requests == 1) {
            started.complete();
            return pending.future;
          }
          return response([badge('current')]);
        }),
      );
    },
  );

  test(
    'existing badge threshold and last-item fallback selection is unchanged',
    () async {
      final c = Get.put<MyAchievementsController>(MyAchievementsController());
      await http.runWithClient(
        () async {
          await c.getData();
          expect(c.currentBadge?.name, 'first');
          app.user.value.points = 100;
          await c.getData();
          expect(c.currentBadge?.name, 'last');
        },
        () => MockClient(
          (request) async => response(
            request.url.queryParameters['wsfunction'] ==
                    function(DBEndPointX.postGetBadges)
                ? [badge('first'), badge('last')]
                : [point('history')],
          ),
        ),
      );
    },
  );
  test(
    'anonymous achievements do not read an uninitialized app user',
    () async {
      await LocalDataX.remove(LocalKeyX.userid);
      await Get.delete<AppControllerX>(force: true);
      Get.put<AppControllerX>(AppControllerX());
      final c = Get.put<MyAchievementsController>(MyAchievementsController());
      var requests = 0;
      await http.runWithClient(
        () async {
          await c.getData();
          expect(requests, 0);
          expect(c.currentBadge, isNull);
        },
        () => MockClient((request) async {
          requests++;
          return response([]);
        }),
      );
    },
  );
}
