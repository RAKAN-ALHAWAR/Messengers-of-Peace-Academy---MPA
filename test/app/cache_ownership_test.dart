import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Core/Error/error.dart';
import 'package:messengersofpeace/Core/Helper/http/http.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Database/config/database_end_point.dart';
import 'package:messengersofpeace/Data/Model/user/user.dart';
import 'package:messengersofpeace/Ui/Screen/Events/CalendarEvents/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Profile/ProfileDetails/controller/controller.dart';

String function(String endpoint) =>
    Uri.parse(endpoint).queryParameters['wsfunction']!;
http.Response response(Object value) => http.Response(jsonEncode(value), 200);
Map<String, Object> user(String id) => {
  NameX.id: id,
  NameX.username: id,
  NameX.email: '$id@example.invalid',
};
Map<String, Object> event(String id) => {
  NameX.id: id,
  NameX.location: 'Synthetic location',
  NameX.source: 'user',
  NameX.isnow: false,
  NameX.startTime: 1700000000,
};
Map<String, Object> statistics() => {
  NameX.completedCourses: '0',
  NameX.minutes: '0',
  NameX.points: '0',
  NameX.certificates: '0',
  NameX.quizzes: '0',
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-cache-tests-');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('synthetic-cache');
    HttpX.init();
  });
  setUp(() async {
    Get.testMode = true;
    Get.locale = const Locale('en');
    await LocalDataX.put(LocalKeyX.userid, 'synthetic-A');
    await LocalDataX.put(LocalKeyX.token, 'synthetic-token');
    Get.put(AppControllerX()..user = UserX.fromJson(user('initial')).obs);
  });
  tearDown(() => Get.reset());
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test(
    'retired protected screens cannot request through an anonymous identity',
    () async {
      final calendar = Get.put(CalendarController());
      final profile = Get.put(ProfileDetailsController());
      await LocalDataX.remove(LocalKeyX.userid);
      await LocalDataX.remove(LocalKeyX.token);
      var requests = 0;
      await http.runWithClient(
        () async {
          final unauthorized = isA<ErrorX>().having(
            (e) => e.errorCode,
            'status',
            401,
          );
          await expectLater(calendar.getData(), throwsA(unauthorized));
          await expectLater(profile.getData(), throwsA(unauthorized));
        },
        () => MockClient((_) async {
          requests++;
          return response({});
        }),
      );
      expect(requests, 0);
    },
  );
  test(
    'profile snapshot rejects a mismatched account before follow-up reads',
    () async {
      final profile = Get.put(ProfileDetailsController());
      var requests = 0;
      await http.runWithClient(
        () async {
          await expectLater(profile.getData(), throwsA(isA<ErrorX>()));
        },
        () => MockClient((_) async {
          requests++;
          return response(user('synthetic-other'));
        }),
      );
      expect(requests, 1);
      expect(Get.find<AppControllerX>().user.value.id, 'initial');
      expect(profile.isInit, isFalse);
    },
  );

  test('calendar cache is reused only for its session and locale', () async {
    final controller = Get.put(CalendarController());
    var requests = 0;
    await http.runWithClient(
      () async {
        await controller.getData();
        await controller.getData();
        expect(requests, 1);
        await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
        await controller.getData();
        expect(requests, 2);
        expect(controller.events.single.id, 'synthetic-B-en');
        Get.locale = const Locale('es');
        await controller.getData();
        expect(requests, 3);
        expect(controller.events.single.id, 'synthetic-B-es');
      },
      () => MockClient((request) async {
        requests++;
        return response([
          event('${LocalDataX.userid}-${Get.locale!.languageCode}'),
        ]);
      }),
    );
  });

  for (final abandonedBy in ['session', 'locale', 'disposal']) {
    test('calendar ignores result after $abandonedBy changes', () async {
      final controller = Get.put(CalendarController());
      final pending = Completer<http.Response>();
      final started = Completer<void>();
      await http.runWithClient(
        () async {
          final load = controller.getData();
          await started.future;
          if (abandonedBy == 'session') {
            await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
          } else if (abandonedBy == 'locale') {
            Get.locale = const Locale('es');
          } else {
            Get.delete<CalendarController>();
          }
          pending.complete(response([event('obsolete')]));
          await load;
          expect(controller.events, isEmpty);
          expect(controller.isInit, isFalse);
        },
        () => MockClient((request) {
          started.complete();
          return pending.future;
        }),
      );
    });
  }

  test('profile cache is reused only for its session and locale', () async {
    final controller = Get.put(ProfileDetailsController());
    var requests = 0;
    await http.runWithClient(
      () async {
        await controller.getData();
        await controller.getData();
        expect(requests, 3);
        await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
        await controller.getData();
        expect(requests, 6);
        expect(controller.user.value.id, 'synthetic-B');
        Get.locale = const Locale('es');
        await controller.getData();
        expect(requests, 9);
      },
      () => MockClient((request) async {
        requests++;
        final method = request.url.queryParameters['wsfunction'];
        if (method == function(DBEndPointX.postGetUser)) {
          return response(user(LocalDataX.userid));
        }
        if (method == function(DBEndPointX.postGetUserStatistics)) {
          return response(statistics());
        }
        return response([]);
      }),
    );
  });

  for (final abandonedBy in ['session', 'locale', 'disposal']) {
    test(
      'profile ignores late user result after $abandonedBy changes',
      () async {
        final controller = Get.put(ProfileDetailsController());
        final pending = Completer<http.Response>();
        final started = Completer<void>();
        var requests = 0;
        await http.runWithClient(
          () async {
            final load = controller.getData();
            await started.future;
            if (abandonedBy == 'session') {
              await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
            } else if (abandonedBy == 'locale') {
              Get.locale = const Locale('es');
            } else {
              Get.delete<ProfileDetailsController>();
            }
            pending.complete(response(user('obsolete')));
            await load;
            expect(requests, 1);
            expect(Get.find<AppControllerX>().user.value.id, 'initial');
            expect(controller.isInit, isFalse);
          },
          () => MockClient((request) async {
            requests++;
            if (requests == 1) {
              started.complete();
              return pending.future;
            }
            if (request.url.queryParameters['wsfunction'] ==
                function(DBEndPointX.postGetUserStatistics)) {
              return response(statistics());
            }
            return response([]);
          }),
        );
      },
    );
  }
  for (final pendingStage in ['statistics', 'badges']) {
    test(
      'profile retires pending $pendingStage without publishing partial user',
      () async {
        final controller = Get.put(ProfileDetailsController());
        final pending = Completer<http.Response>();
        final started = Completer<void>();
        var requests = 0;
        await http.runWithClient(
          () async {
            final load = controller.getData();
            await started.future;
            expect(Get.find<AppControllerX>().user.value.id, 'initial');
            await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
            pending.complete(
              response(pendingStage == 'badges' ? [] : statistics()),
            );
            await load;
            expect(requests, pendingStage == 'badges' ? 3 : 2);
            expect(Get.find<AppControllerX>().user.value.id, 'initial');
            expect(controller.isInit, isFalse);
          },
          () => MockClient((request) async {
            requests++;
            final method = request.url.queryParameters['wsfunction'];
            if (method == function(DBEndPointX.postGetUser)) {
              return response(user(LocalDataX.userid));
            }
            final isStatistics =
                method == function(DBEndPointX.postGetUserStatistics);
            if ((pendingStage == 'statistics' && isStatistics) ||
                (pendingStage == 'badges' && !isStatistics)) {
              started.complete();
              return pending.future;
            }
            return response(statistics());
          }),
        );
      },
    );
  }

  test('new calendar refresh retires an older in-flight result', () async {
    final controller = Get.put(CalendarController());
    final first = Completer<http.Response>();
    final started = Completer<void>();
    var requests = 0;
    await http.runWithClient(
      () async {
        final older = controller.getData();
        await started.future;
        await controller.getData(isMust: true);
        first.complete(response([event('obsolete')]));
        await older;
        expect(controller.events.single.id, 'current');
        expect(requests, 2);
      },
      () => MockClient((request) async {
        requests++;
        if (requests == 1) {
          started.complete();
          return first.future;
        }
        return response([event('current')]);
      }),
    );
  });

  test('empty badge snapshot clears the previous account badge', () async {
    final controller = Get.put(ProfileDetailsController());
    await http.runWithClient(
      () async {
        await controller.getData();
        expect(controller.currentBadge.value?.id, 'badge-A');
        await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
        await controller.getData();
        expect(controller.currentBadge.value, isNull);
      },
      () => MockClient((request) async {
        final method = request.url.queryParameters['wsfunction'];
        if (method == function(DBEndPointX.postGetUser)) {
          return response(user(LocalDataX.userid));
        }
        if (method == function(DBEndPointX.postGetUserStatistics)) {
          return response(statistics());
        }
        return response(
          LocalDataX.userid == 'synthetic-A'
              ? [
                {
                  NameX.id: 'badge-A',
                  NameX.badgeName: 'Synthetic badge',
                  NameX.requiredPoints: 1,
                  NameX.description: '',
                  NameX.earned: false,
                },
              ]
              : [],
        );
      }),
    );
  });
  for (final screen in ['calendar', 'profile']) {
    test(
      '$screen never accepts an older-owner cache after replacement load fails',
      () async {
        final calendar =
            screen == 'calendar' ? Get.put(CalendarController()) : null;
        final profile =
            screen == 'profile' ? Get.put(ProfileDetailsController()) : null;
        var fail = false;
        Future<void> load() =>
            calendar != null ? calendar.getData() : profile!.getData();
        await http.runWithClient(
          () async {
            await load();
            await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
            fail = true;
            await expectLater(load(), throwsA(anything));
          },
          () => MockClient((request) async {
            if (fail) {
              return response({
                'status': 'failed',
                'message': 'Synthetic failure',
              });
            }
            if (screen == 'calendar') return response([event('old-owner')]);
            final method = request.url.queryParameters['wsfunction'];
            if (method == function(DBEndPointX.postGetUser)) {
              return response(user(LocalDataX.userid));
            }
            if (method == function(DBEndPointX.postGetUserStatistics)) {
              return response(statistics());
            }
            return response([]);
          }),
        );
      },
    );
  }
}
