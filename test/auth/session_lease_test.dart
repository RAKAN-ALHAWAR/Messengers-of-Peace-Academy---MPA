import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Core/Error/error.dart';
import 'package:messengersofpeace/Core/Helper/http/http.dart';
import 'package:messengersofpeace/Core/Service/controller_lease.dart';
import 'package:messengersofpeace/Core/Service/route_origin.dart';
import 'package:messengersofpeace/Core/Service/session_lease.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Data/Database/remote/remote_data.dart';
import 'package:messengersofpeace/Data/Model/basic/data_source_param.dart';
import 'package:messengersofpeace/Data/data.dart';

/// Stands for any screen controller the helper guards.
class _Probe extends GetxController {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa_lease_test');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('app');
    await HttpX.init();
  });
  setUp(() async {
    await HiveX.box.clear();
    LocalDataX.put(LocalKeyX.userid, 'synthetic-A');
    LocalDataX.put(LocalKeyX.token, 'synthetic-token');
  });
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test(
    'session stream exposes updated identity and ignores preferences',
    () async {
      await Future<void>.delayed(Duration.zero);
      final revisions = <int>[];
      final identities = <String>[];
      final subscription = LocalDataX.sessionChanges.listen((revision) {
        revisions.add(revision);
        identities.add(LocalDataX.userid);
      });
      await LocalDataX.put(LocalKeyX.language, 'ar');
      await Future<void>.delayed(Duration.zero);
      expect(revisions, isEmpty);
      await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
      await Future<void>.delayed(Duration.zero);
      expect(revisions, [LocalDataX.sessionRevision]);
      expect(identities, ['synthetic-B']);
      await subscription.cancel();
    },
  );

  test('retired owner does not access disposed storage', () async {
    final lease = SessionLeaseX.capture(isActive: () => false);
    await HiveX.box.close();
    expect(lease.isCurrent, isFalse);
    HiveX.box = await Hive.openBox('app');
  });

  test('unrelated preferences keep a lease valid', () {
    final lease = SessionLeaseX.capture();
    LocalDataX.put(LocalKeyX.language, 'ar');
    expect(lease.isCurrent, isTrue);
  });
  test('same-value login write invalidates older work', () {
    final lease = SessionLeaseX.capture();
    LocalDataX.put(LocalKeyX.token, 'synthetic-token');
    expect(lease.isCurrent, isFalse);
  });
  test('A to B to A cannot revive abandoned work', () {
    final lease = SessionLeaseX.capture();
    LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
    LocalDataX.put(LocalKeyX.userid, 'synthetic-A');
    expect(lease.isCurrent, isFalse);
  });
  test('controller ownership and logout invalidate work', () {
    var active = true;
    final lease = SessionLeaseX.capture(isActive: () => active);
    active = false;
    expect(lease.isCurrent, isFalse);
    final next = SessionLeaseX.capture();
    LocalDataX.remove(LocalKeyX.token);
    expect(next.isCurrent, isFalse);
  });
  test(
    'low-level clear and restore cannot revive the previous session',
    () async {
      final lease = SessionLeaseX.capture();
      await HiveX.removeAll();
      await HiveX.put(key: LocalKeyX.userid, data: 'synthetic-A');
      await HiveX.put(key: LocalKeyX.token, data: 'synthetic-token');
      expect(lease.isCurrent, isFalse);
    },
  );
  test('expiry-driven credential removal invalidates a lease', () async {
    await LocalDataX.put(
      LocalKeyX.token,
      'synthetic-token',
      maxAge: const Duration(seconds: 1),
    );
    final lease = SessionLeaseX.capture();
    final revision = LocalDataX.sessionRevision;
    await HiveX.box.put(LocalKeyX.token, {
      'value': 'synthetic-token',
      'expiry': DateTime(2000).toIso8601String(),
    });
    expect(lease.isCurrent, isFalse);
    expect(LocalDataX.sessionRevision, greaterThan(revision));
  });
  test('expiry only reports current explicit user credentials', () {
    var events = 0;
    final subscription = SessionExpiryX.events.listen((_) => events++);
    addTearDown(subscription.cancel);
    final lease = SessionLeaseX.capture();
    expect(
      lease.authenticates('https://synthetic.invalid/?wstoken=synthetic-token'),
      isTrue,
    );
    expect(
      lease.authenticates('https://synthetic.invalid/?wstoken=public'),
      isFalse,
    );
    SessionExpiryX.report(lease);
    expect(events, 1);
    LocalDataX.remove(LocalKeyX.userid);
    SessionExpiryX.report(lease);
    SessionExpiryX.report(SessionLeaseX.capture());
    expect(events, 1);
  });

  group('ControllerLeaseX', () {
    setUp(() {
      Get.testMode = true;
      Get.locale = const Locale('en');
    });
    tearDown(Get.reset);

    // The registry is cleared without closing anything, then a new app takes
    // its place: the old one stays open but is no longer the registered one.
    AppControllerX putApp() {
      final app = Get.put(AppControllerX());
      addTearDown(() => app.onDelete());
      return app;
    }

    AppControllerX replaceApp() {
      Get.delete<AppControllerX>(force: true);
      return putApp();
    }

    group('owns', () {
      test('the open registered instance owns', () {
        final probe = Get.put(_Probe());
        expect(ControllerLeaseX.owns(probe), isTrue);
      });

      test('a controller that was never registered does not own', () {
        expect(ControllerLeaseX.owns(_Probe()), isFalse);
      });

      test('a closed controller does not own', () {
        final probe = Get.put(_Probe());
        probe.onDelete();
        expect(Get.isRegistered<_Probe>(), isTrue);
        expect(ControllerLeaseX.owns(probe), isFalse);
      });

      test('an open instance replaced by one of its type does not own', () {
        final first = Get.put(_Probe());
        Get.reset();
        final second = Get.put(_Probe());
        expect(first.isClosed, isFalse);
        expect(ControllerLeaseX.owns(first), isFalse);
        expect(ControllerLeaseX.owns(second), isTrue);
      });

      test('the app is not checked when none is passed', () {
        final probe = Get.put(_Probe());
        expect(ControllerLeaseX.owns(probe), isTrue);
        putApp();
        replaceApp();
        expect(ControllerLeaseX.owns(probe), isTrue);
      });

      test('a passed app must still be the registered app', () {
        final app = putApp();
        final probe = Get.put(_Probe());
        expect(ControllerLeaseX.owns(probe, app: app), isTrue);
        expect(ControllerLeaseX.owns(probe, withApp: true, app: app), isTrue);
        replaceApp();
        expect(ControllerLeaseX.owns(probe, app: app), isFalse);
        expect(ControllerLeaseX.owns(probe, withApp: true, app: app), isFalse);
      });

      test('a passed app that is no longer registered at all is not owned', () {
        final app = putApp();
        final probe = Get.put(_Probe());
        Get.delete<AppControllerX>(force: true);
        expect(ControllerLeaseX.owns(probe, app: app), isFalse);
      });

      test('a null app with withApp is not owned', () {
        putApp();
        final probe = Get.put(_Probe());
        expect(ControllerLeaseX.owns(probe, withApp: true), isFalse);
        expect(ControllerLeaseX.owns(probe, withApp: true, app: null), isFalse);
      });
    });

    group('capture', () {
      test('a fresh lease is current and keeps the session identity', () {
        final probe = Get.put(_Probe());
        final lease = ControllerLeaseX.capture(probe);
        expect(lease.isCurrent, isTrue);
        expect(lease.hasAuthenticatedIdentity, isTrue);
        LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
        expect(lease.isCurrent, isFalse);
      });

      test('a closed controller retires the lease, registered or not', () {
        final probe = Get.put(_Probe());
        final plain = ControllerLeaseX.capture(probe);
        final registered = ControllerLeaseX.capture(probe, registered: true);
        probe.onDelete();
        expect(plain.isCurrent, isFalse);
        expect(registered.isCurrent, isFalse);
      });

      test('a replaced instance retires the lease only when asked', () {
        final first = Get.put(_Probe());
        final plain = ControllerLeaseX.capture(first);
        final registered = ControllerLeaseX.capture(first, registered: true);
        Get.reset();
        Get.put(_Probe());
        expect(plain.isCurrent, isTrue);
        expect(registered.isCurrent, isFalse);
      });

      test('app taken at creation (field): a replaced app retires it', () {
        final field = putApp();
        final probe = Get.put(_Probe());
        final lease = ControllerLeaseX.capture(probe, app: field);
        expect(lease.isCurrent, isTrue);
        replaceApp();
        expect(lease.isCurrent, isFalse);
      });

      test('app taken at creation (field): already replaced is not owned', () {
        final field = putApp();
        final probe = Get.put(_Probe());
        replaceApp();
        expect(ControllerLeaseX.capture(probe, app: field).isCurrent, isFalse);
      });

      test('app taken at call time (local): the live app at the call owns', () {
        putApp();
        final probe = Get.put(_Probe());
        replaceApp();
        final local = Get.find<AppControllerX>();
        final lease = ControllerLeaseX.capture(probe, app: local);
        expect(lease.isCurrent, isTrue);
        replaceApp();
        expect(lease.isCurrent, isFalse);
      });

      test('a null app with withApp is not owned', () {
        putApp();
        final probe = Get.put(_Probe());
        final lease = ControllerLeaseX.capture(probe, withApp: true);
        expect(lease.hasAuthenticatedIdentity, isTrue);
        expect(lease.isCurrent, isFalse);
        final explicit = ControllerLeaseX.capture(
          probe,
          withApp: true,
          app: null,
        );
        expect(explicit.isCurrent, isFalse);
      });

      test('withApp with the live app is owned until it is replaced', () {
        final app = putApp();
        final probe = Get.put(_Probe());
        final lease = ControllerLeaseX.capture(probe, withApp: true, app: app);
        expect(lease.isCurrent, isTrue);
        replaceApp();
        expect(lease.isCurrent, isFalse);
      });

      test('an omitted app means atom 3 is not checked', () {
        putApp();
        final probe = Get.put(_Probe());
        final lease = ControllerLeaseX.capture(probe);
        replaceApp();
        Get.delete<AppControllerX>(force: true);
        expect(lease.isCurrent, isTrue);
      });

      test('a language switch retires the lease only when asked', () {
        final probe = Get.put(_Probe());
        final watching = ControllerLeaseX.capture(probe, locale: true);
        final ignoring = ControllerLeaseX.capture(probe);
        Get.locale = const Locale('es');
        expect(watching.isCurrent, isFalse);
        expect(ignoring.isCurrent, isTrue);
      });

      test('the language is the one read when the lease is captured', () {
        final probe = Get.put(_Probe());
        Get.locale = const Locale('es');
        final lease = ControllerLeaseX.capture(probe, locale: true);
        expect(lease.isCurrent, isTrue);
        Get.locale = const Locale('en');
        expect(lease.isCurrent, isFalse);
      });

      testWidgets('a left route retires the lease only when asked', (
        tester,
      ) async {
        await tester.pumpWidget(
          GetMaterialApp(
            initialRoute: '/a',
            getPages: [
              GetPage(name: '/a', page: () => const Text('a')),
              GetPage(name: '/b', page: () => const Text('b')),
            ],
          ),
        );
        await tester.pumpAndSettle();
        final probe = Get.put(_Probe());
        unawaited(Get.toNamed('/b'));
        await tester.pumpAndSettle();
        final origin = RouteOriginX.capture();
        final watching = ControllerLeaseX.capture(probe, origin: origin);
        final ignoring = ControllerLeaseX.capture(probe);
        expect(watching.isCurrent, isTrue);
        Get.back();
        await tester.pumpAndSettle();
        expect(watching.isCurrent, isFalse);
        expect(ignoring.isCurrent, isTrue);
      });

      test('a false site test (also) retires the lease', () {
        final probe = Get.put(_Probe());
        var generation = 1;
        final captured = generation;
        final lease = ControllerLeaseX.capture(
          probe,
          also: () => captured == generation,
        );
        expect(lease.isCurrent, isTrue);
        generation++;
        expect(lease.isCurrent, isFalse);
      });

      test('a retired owner lease retires the lease', () {
        final probe = Get.put(_Probe());
        var tapAlive = true;
        final tap = SessionLeaseX.capture(isActive: () => tapAlive);
        final owned = ControllerLeaseX.capture(probe, owner: tap);
        final free = ControllerLeaseX.capture(probe);
        expect(owned.isCurrent, isTrue);
        tapAlive = false;
        expect(owned.isCurrent, isFalse);
        expect(free.isCurrent, isTrue);
      });

      test('every option together retires on the first one that fails', () {
        final app = putApp();
        final probe = Get.put(_Probe());
        var site = true;
        final lease = ControllerLeaseX.capture(
          probe,
          registered: true,
          app: app,
          locale: true,
          owner: SessionLeaseX.capture(),
          also: () => site,
        );
        expect(lease.isCurrent, isTrue);
        site = false;
        expect(lease.isCurrent, isFalse);
      });
    });
  });

  group('AppControllerX stale work', () {
    // The same three things the app controller must survive while its own
    // storage writes are in flight: it is closed, a newer instance takes the
    // registry (the old one stays open), or a newer startup begins.
    final ownership = <String, Future<Object?>? Function(AppControllerX)>{
      'closing the app controller': (app) {
        app.onDelete();
        return null;
      },
      'replacing the registered app controller': (app) {
        Get.reset();
        final next = Get.put(AppControllerX());
        addTearDown(() => next.onDelete());
        return null;
      },
    };
    final interferences = <String, Future<Object?>? Function(AppControllerX)>{
      ...ownership,
      'a newer startup': (app) => app.init(),
    };
    const incomplete =
        '{"errorcode":"usernotfullysetup","message":"Profile not complete"}';

    AppControllerX newApp() {
      final app = Get.put(AppControllerX());
      addTearDown(() => app.onDelete());
      return app;
    }

    setUp(() async {
      Get.testMode = true;
      await LocalDataX.put(LocalKeyX.route, RouteNameX.root);
    });
    tearDown(Get.reset);

    for (final entry in interferences.entries) {
      test('${entry.key} retires a signed-out startup in flight', () async {
        await LocalDataX.remove(LocalKeyX.userid);
        await LocalDataX.remove(LocalKeyX.token);
        final app = newApp();
        final pending = app.init();
        final other = entry.value(app);
        expect(await pending, isNull);
        await other;
      });

      test('${entry.key} retires a clear of leftover credentials', () async {
        await LocalDataX.remove(LocalKeyX.token);
        final app = newApp();
        final pending = app.init();
        final other = entry.value(app);
        expect(await pending, isNull);
        await other;
      });

      test('${entry.key} retires an incomplete-profile clear', () async {
        final response = Completer<http.Response>();
        await http.runWithClient(() async {
          await Future<void>.delayed(Duration.zero);
          final app = newApp();
          final pending = app.init();
          Future<Object?>? other;
          final interfered = LocalDataX.sessionChanges.first.then(
            (_) => other = entry.value(app),
          );
          response.complete(http.Response(incomplete, 200));
          expect(await pending, isNull);
          await interfered;
          await other;
        }, () => MockClient((_) => response.future));
      });
    }

    for (final entry in ownership.entries) {
      testWidgets('${entry.key} stops the redirect of a clear in flight', (
        tester,
      ) async {
        await tester.pumpWidget(
          GetMaterialApp(
            initialRoute: '/home-test',
            getPages: [
              GetPage(
                name: '/home-test',
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
          final app = newApp();
          final clearing = app.clearLocalSession(SessionLeaseX.capture());
          entry.value(app);
          await clearing;
        });
        await tester.pumpAndSettle();
        expect(find.text('Current destination'), findsOneWidget);
        expect(find.text('Login destination'), findsNothing);
      });

      test('${entry.key} makes a plain clear request a no-op', () async {
        final app = newApp();
        entry.value(app);
        await app.clearLocalSession(SessionLeaseX.capture());
        expect(LocalDataX.userid, 'synthetic-A');
        expect(LocalDataX.token, 'synthetic-token');
        expect(app.isLogin.value, isTrue);
      });

      test('${entry.key} makes logOut a no-op', () async {
        final app = newApp();
        entry.value(app);
        await http.runWithClient(
          () => app.logOut(),
          () => MockClient((_) async => http.Response('{}', 200)),
        );
        expect(LocalDataX.userid, 'synthetic-A');
        expect(LocalDataX.token, 'synthetic-token');
        expect(app.isLogin.value, isTrue);
      });
    }
  });

  group('ErrorX.sessionChanged', () {
    const message = 'Session changed. Please try again.';

    test('keeps the translated message and the default code', () {
      final error = ErrorX.sessionChanged();
      expect(error.message, message);
      expect(error.errorCode, ErrorCodesX.unexpected);
      expect(error.details, isEmpty);
    });

    test(
      'is what the transport throws when the session changed mid-call',
      () async {
        const url = 'https://synthetic.invalid/?wstoken=synthetic-token';
        final response = Completer<http.Response>();
        await http.runWithClient(() async {
          final pending = RemoteDataSourceX.get<Map<String, dynamic>>(
            url,
            param: DataSourceParamX(languageCode: 'ar'),
          );
          final assertion = expectLater(
            pending,
            throwsA(
              isA<ErrorX>()
                  .having((e) => e.message, 'message', message)
                  .having((e) => e.errorCode, 'code', ErrorCodesX.unexpected),
            ),
          );
          await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
          response.complete(http.Response('{"private":"account-A"}', 200));
          await assertion;
        }, () => MockClient((_) => response.future));
      },
    );
  });
}
