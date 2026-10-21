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
import 'package:messengersofpeace/Core/Service/session_lease.dart';
import 'package:messengersofpeace/Data/data.dart';

Map<String, dynamic> syntheticUser(String id) => {
  'id': id,
  'username': 'synthetic',
  'email': 'test@example.invalid',
  'firstname': 'Test',
  'lastname': 'User',
  'customfields': <dynamic>[],
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp(
      'mopa-session-lifecycle-',
    );
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('app');
    await HttpX.init();
  });
  setUp(() async {
    Get.testMode = true;
    await HiveX.removeAll();
  });
  tearDown(() {
    Get.delete<AppControllerX>(force: true);
    Get.reset();
  });
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test(
    'already signed-out startup preserves its identity generation',
    () async {
      await LocalDataX.put(LocalKeyX.route, RouteNameX.login);
      final app = Get.put(AppControllerX());
      final revision = LocalDataX.sessionRevision;
      expect(await app.init(), isNotNull);
      expect(await app.init(), isNotNull);
      expect(LocalDataX.sessionRevision, revision);
    },
  );

  test('startup with an ID but no token sends no profile request', () async {
    await LocalDataX.put(LocalKeyX.userid, 'synthetic-A');
    await LocalDataX.put(LocalKeyX.route, RouteNameX.root);
    var count = 0;
    await http.runWithClient(
      () async {
        final app = Get.put(AppControllerX());
        await app.init();
        expect(count, 0);
        expect(app.isLogin.value, isFalse);
        expect(LocalDataX.userid, isEmpty);
        expect(LocalDataX.route, RouteNameX.login);
      },
      () => MockClient((_) async {
        count++;
        return http.Response(jsonEncode(syntheticUser('synthetic-A')), 200);
      }),
    );
  });

  test('late startup A profile cannot replace B state', () async {
    await LocalDataX.put(LocalKeyX.userid, 'synthetic-A');
    await LocalDataX.put(LocalKeyX.token, 'synthetic-token-A');
    final response = Completer<http.Response>();
    await http.runWithClient(() async {
      final app = Get.put(AppControllerX());
      final pending = app.init();
      await Future<void>.delayed(Duration.zero);
      await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
      await LocalDataX.put(LocalKeyX.token, 'synthetic-token-B');
      response.complete(
        http.Response(jsonEncode(syntheticUser('synthetic-A')), 200),
      );
      await pending;
      expect(LocalDataX.userid, 'synthetic-B');
      // A must not populate the user slot at all.
      var initialized = false;
      try {
        app.user;
        initialized = true;
      } catch (_) {}
      expect(initialized, isFalse);
    }, () => MockClient((_) => response.future));
  });

  testWidgets('concurrent expiry clears once without a server logout', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await LocalDataX.put(LocalKeyX.userid, 'synthetic-A');
      await LocalDataX.put(LocalKeyX.token, 'synthetic-token-A');
    });
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/home-test',
        getPages: [
          GetPage(
            name: '/home-test',
            page: () => const Scaffold(body: Text('Home')),
          ),
          GetPage(
            name: RouteNameX.login,
            page: () => const Scaffold(body: Text('Login destination')),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    var count = 0;
    await http.runWithClient(
      () async {
        final app =
            (await tester.runAsync(
              () async => Get.put(AppControllerX(), permanent: true),
            ))!;
        final lease = SessionLeaseX.capture();
        final revision = LocalDataX.sessionRevision;
        await tester.runAsync(() async {
          SessionExpiryX.report(lease);
          SessionExpiryX.report(lease);
          await Future<void>.delayed(const Duration(milliseconds: 20));
        });
        await tester.pumpAndSettle();
        expect(LocalDataX.userid, isEmpty);
        expect(LocalDataX.token, isEmpty);
        expect(LocalDataX.sessionRevision, revision + 2);
        expect(app.isLogin.value, isFalse);
        expect(count, 0);
        expect(find.text('Login destination'), findsOneWidget);
      },
      () => MockClient((_) async {
        count++;
        return http.Response('{}', 200);
      }),
    );
  });
  test('concurrent startup only publishes its newest request', () async {
    await LocalDataX.put(LocalKeyX.userid, 'synthetic-A');
    await LocalDataX.put(LocalKeyX.token, 'synthetic-token-A');
    final first = Completer<http.Response>();
    var count = 0;
    await http.runWithClient(
      () async {
        final app = Get.put(AppControllerX());
        final old = app.init();
        await Future<void>.delayed(Duration.zero);
        await app.init();
        expect(app.user.value.firstname, 'Newest');
        first.complete(
          http.Response(
            jsonEncode(syntheticUser('synthetic-A')..['firstname'] = 'Old'),
            200,
          ),
        );
        expect(await old, isNull);
        expect(app.user.value.firstname, 'Newest');
        expect(count, 2);
      },
      () => MockClient((_) {
        count++;
        return count == 1
            ? first.future
            : Future.value(
              http.Response(
                jsonEncode(
                  syntheticUser('synthetic-A')..['firstname'] = 'Newest',
                ),
                200,
              ),
            );
      }),
    );
  });

  test('ordinary HTTP failure preserves the signed-in identity', () async {
    await LocalDataX.put(LocalKeyX.userid, 'synthetic-A');
    await LocalDataX.put(LocalKeyX.token, 'synthetic-token-A');
    final app = Get.put(AppControllerX());
    final lease = SessionLeaseX.capture();
    await http.runWithClient(() async {
      await expectLater(app.init(), throwsA(anything));
      expect(lease.isCurrent, isTrue);
      expect(app.isLogin.value, isTrue);
    }, () => MockClient((_) async => http.Response('{}', 403)));
  });

  testWidgets(
    'clearing A never redirects a B login completed during storage flush',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/race-test',
          getPages: [
            GetPage(
              name: '/race-test',
              page: () => const Scaffold(body: Text('Current destination')),
            ),
            GetPage(
              name: RouteNameX.login,
              page: () => const Scaffold(body: Text('Login destination')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await LocalDataX.put(LocalKeyX.userid, 'synthetic-A');
        await LocalDataX.put(LocalKeyX.token, 'synthetic-token-A');
        final app = Get.put(AppControllerX(), permanent: true);
        final clearing = app.clearLocalSession(SessionLeaseX.capture());
        final writes = [
          LocalDataX.put(LocalKeyX.userid, 'synthetic-B'),
          LocalDataX.put(LocalKeyX.token, 'synthetic-token-B'),
          LocalDataX.put(LocalKeyX.route, RouteNameX.root),
        ];
        app.isLogin.value = true;
        await Future.wait(writes);
        await clearing;
        expect(LocalDataX.userid, 'synthetic-B');
        expect(app.isLogin.value, isTrue);
      });
      await tester.pumpAndSettle();
      expect(find.text('Current destination'), findsOneWidget);
      expect(find.text('Login destination'), findsNothing);
    },
  );
}
