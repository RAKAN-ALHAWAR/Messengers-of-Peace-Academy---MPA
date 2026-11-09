import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:messengersofpeace/Config/Route/route_list.dart';
import 'package:messengersofpeace/Config/Translation/translation.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Core/Service/session_lease.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Data/Database/account_deletion.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Ui/Screen/Profile/AccountDeletion/view.dart';
import 'package:messengersofpeace/Ui/Screen/Profile/ProfileDetails/controller/controller.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

const requestFunction = 'local_user_anonymizer_request_self_anonymisation';
const confirmFunction = 'local_user_anonymizer_confirm_self_anonymisation';
final challengeId = 'a' * 64;

http.Response jsonResponse(Object value, [int status = 200]) =>
    http.Response(jsonEncode(value), status);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late AppControllerX app;
  late ProfileDetailsController profile;
  late DateTime now;
  late List<String> calls;
  FutureOr<http.Response> Function(http.Request)? confirm;
  FutureOr<http.Response> Function(http.Request)? requestCode;
  const pathChannel = MethodChannel('plugins.flutter.io/path_provider');

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-delete-');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('delete-account');
  });

  setUp(() async {
    Get.testMode = true;
    Get.locale = const Locale('en');
    await HiveX.box.clear();
    await HiveX.box.put('userid', 'user-A');
    await HiveX.box.put('token', 'synthetic-A-token');
    await HiveX.box.put('user-A:offline-course', 'private');
    await HiveX.box.put('user-B:offline-course', 'keep');
    await HiveX.box.put('themeIsDark', true);
    app = Get.put(AppControllerX(), permanent: true);
    profile = Get.put(ProfileDetailsController());
    now = DateTime(2026, 11, 9);
    calls = [];
    confirm = null;
    requestCode = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, (_) async => directory.path);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathChannel, null);
    Get.reset();
  });

  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  MockClient client() => MockClient((request) async {
    expect(request.method, 'POST');
    expect(request.url.scheme, 'https');
    expect(request.url.path, '/webservice/rest/server.php');
    expect(request.url.hasQuery, isFalse);
    expect(request.followRedirects, isFalse);
    expect(request.headers['accept'], 'application/json');
    final fields = request.bodyFields;
    expect(fields['wstoken'] == 'synthetic-A-token', isTrue);
    expect(fields['moodlewsrestformat'], 'json');
    final function = fields['wsfunction']!;
    calls.add(function);
    final keys = {'wstoken', 'wsfunction', 'moodlewsrestformat'};
    if (function == requestFunction) {
      expect(fields.keys, unorderedEquals(keys));
      return requestCode?.call(request) ??
          jsonResponse({'requestid': challengeId, 'expiresin': 300});
    }
    expect(function, confirmFunction);
    expect(
      fields.keys,
      unorderedEquals({...keys, 'requestid', 'code', 'confirm'}),
    );
    expect(fields['requestid'] == challengeId, isTrue);
    expect(fields['confirm'], '1');
    return confirm?.call(request) ??
        jsonResponse({'status': 'anonymised', 'logoutrequired': true});
  });

  Future<void> open(WidgetTester tester, {bool profileButton = false}) async {
    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('en'),
        theme: ThemeX.light,
        translations: TranslationX(),
        initialRoute: '/account',
        getPages: [
          GetPage(
            name: '/account',
            page: () => Scaffold(
              body: TextButton(
                onPressed: profileButton
                    ? profile.onDeleteAccount
                    : () => Get.to(
                        () => AccountDeletionView(
                          session: SessionLeaseX.capture(),
                          app: app,
                          now: () => now,
                        ),
                      ),
                child: const Text('Open deletion'),
              ),
            ),
          ),
          GetPage(
            name: RouteNameX.login,
            page: () =>
                Scaffold(body: Text((Get.arguments as String?)?.tr ?? 'Login')),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open deletion'));
    await tester.pumpAndSettle();
  }

  Future<void> send(WidgetTester tester) async {
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.ensureVisible(find.text('Send confirmation code'));
    await tester.tap(find.text('Send confirmation code'));
    await tester.pumpAndSettle();
  }

  Future<void> enter(WidgetTester tester, String code) async {
    await tester.enterText(find.byType(TextFieldX), code);
    await tester.pumpAndSettle();
  }

  Future<void> pressConfirm(WidgetTester tester) async {
    final button = find.text('Confirm account deletion');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
  }

  testWidgets('profile button opens explanation without sending anything', (
    tester,
  ) async {
    await http.runWithClient(() async {
      await open(tester, profileButton: true);
      expect(find.textContaining('encrypted recovery copy'), findsOneWidget);
      expect(find.widgetWithText(AppBarX, 'Delete account'), findsOneWidget);
      final sendButton = tester.widget<ButtonStateX>(
        find.widgetWithText(ButtonStateX, 'Send confirmation code'),
      );
      expect(sendButton.disabled, isTrue);
      await tester.tap(find.byType(BackButtonX));
      await tester.pumpAndSettle();
      expect(calls, isEmpty);
      expect(LocalDataX.userid, 'user-A');
    }, client);
  });

  testWidgets(
    'requires explicit confirm, sends leading zero, cleans only the owner, and opens login',
    (tester) async {
      final own = Directory(
        '${directory.path}/course-downloads/${base64Url.encode(utf8.encode('user-A'))}',
      );
      final other = Directory(
        '${directory.path}/course-downloads/${base64Url.encode(utf8.encode('user-B'))}',
      );
      await tester.runAsync(() async {
        await own.create(recursive: true);
        await other.create(recursive: true);
        await File('${own.path}/private.txt').writeAsString('private');
        await File('${other.path}/keep.txt').writeAsString('keep');
      });
      confirm = (request) {
        expect(request.bodyFields['code'] == '012345', isTrue);
        return jsonResponse({'status': 'anonymised', 'logoutrequired': true});
      };
      await http.runWithClient(() async {
        await open(tester);
        await send(tester);
        await enter(tester, '٠١٢٣٤٥');
        expect(calls, [requestFunction]);
        expect(LocalDataX.userid, 'user-A');
        await tester.runAsync(() async {
          await pressConfirm(tester);
          for (var i = 0; i < 30 && Get.currentRoute != RouteNameX.login; i++) {
            await Future<void>.delayed(const Duration(milliseconds: 10));
            await tester.pump();
          }
        });
        await tester.pumpAndSettle();
        expect(calls, [requestFunction, confirmFunction]);
        expect(LocalDataX.userid, isEmpty);
        expect(LocalDataX.token, isEmpty);
        expect(HiveX.box.containsKey('user-A:offline-course'), isFalse);
        expect(HiveX.box.get('user-B:offline-course'), 'keep');
        expect(HiveX.box.get('themeIsDark'), true);
        expect(own.existsSync(), isFalse);
        expect(File('${other.path}/keep.txt').existsSync(), isTrue);
        expect(
          find.textContaining('Account deletion confirmed'),
          findsOneWidget,
        );
        expect(
          Navigator.of(tester.element(find.byType(Scaffold))).canPop(),
          isFalse,
        );
      }, client);
    },
  );

  testWidgets(
    'request in flight disables repeated sends and leaving sends no confirmation',
    (tester) async {
      final pending = Completer<http.Response>();
      requestCode = (_) => pending.future;
      await http.runWithClient(() async {
        await open(tester);
        await tester.tap(find.byType(CheckboxListTile));
        await tester.pump();
        final button = find.text('Send confirmation code');
        await tester.ensureVisible(button);
        await tester.tap(button);
        await tester.tap(button);
        for (var i = 0; i < 5 && calls.isEmpty; i++) {
          await tester.pump(const Duration(milliseconds: 20));
        }
        expect(calls, [requestFunction]);
        Get.back();
        await tester.pumpAndSettle();
        pending.complete(
          jsonResponse({'requestid': challengeId, 'expiresin': 300}),
        );
        await tester.pumpAndSettle();
        expect(calls, [requestFunction]);
        expect(LocalDataX.userid, 'user-A');
      }, client);
    },
  );

  testWidgets(
    'wrong code is shown on the field; five rejections require a new code',
    (tester) async {
      confirm = (_) => jsonResponse({
        'exception': 'moodle_exception',
        'errorcode': 'confirmationinvalid',
      });
      await http.runWithClient(() async {
        await open(tester);
        await send(tester);
        await enter(tester, '123');
        await pressConfirm(tester);
        expect(calls, [requestFunction]);
        expect(find.text('Enter all six digits.'), findsOneWidget);
        for (var attempt = 0; attempt < 5; attempt++) {
          await enter(tester, '012345');
          await pressConfirm(tester);
          await tester.pumpAndSettle();
          if (attempt == 0) {
            expect(
              find.text('The code is invalid. Check it and try again.'),
              findsOneWidget,
            );
          }
        }
        expect(find.byType(TextFieldX), findsNothing);
        expect(
          find.textContaining('The code expired or reached'),
          findsOneWidget,
        );
        expect(
          calls.where((function) => function == confirmFunction).length,
          5,
        );
        expect(LocalDataX.userid, 'user-A');
      }, client);
    },
  );

  testWidgets(
    'expires and resends only after the cooldown; handles server send limit',
    (tester) async {
      var sends = 0;
      requestCode = (_) => ++sends == 1
          ? jsonResponse({'requestid': challengeId, 'expiresin': 300})
          : jsonResponse({'errorcode': 'requestlimited'});
      await http.runWithClient(() async {
        await open(tester);
        await send(tester);
        expect(
          tester
              .widget<TextButton>(
                find.widgetWithText(TextButton, 'Resend in 60 s'),
              )
              .onPressed,
          isNull,
        );
        now = now.add(const Duration(minutes: 5, seconds: 1));
        await tester.pump(const Duration(seconds: 1));
        expect(find.byType(TextFieldX), findsNothing);
        await tester.tap(find.text('Send a new code'));
        await tester.pumpAndSettle();
        expect(calls, [requestFunction, requestFunction]);
        expect(
          find.textContaining('The send limit was reached'),
          findsOneWidget,
        );
        expect(
          tester
              .widget<TextButton>(
                find.widgetWithText(TextButton, 'Resend in 60 s'),
              )
              .onPressed,
          isNull,
        );
      }, client);
    },
  );

  testWidgets('a replacement token cannot confirm an existing challenge', (
    tester,
  ) async {
    await http.runWithClient(() async {
      await open(tester);
      await send(tester);
      await enter(tester, '012345');
      await tester.runAsync(
        () => LocalDataX.put(LocalKeyX.token, 'synthetic-B-token'),
      );
      await pressConfirm(tester);
      await tester.pumpAndSettle();
      expect(find.textContaining('Your session changed'), findsOneWidget);
      expect(calls, [requestFunction]);
    }, client);
  });

  testWidgets('unreadable confirmation is uncertain and cannot be resent', (
    tester,
  ) async {
    confirm = (_) => http.Response('not json', 200);
    await http.runWithClient(() async {
      await open(tester);
      await send(tester);
      await enter(tester, '012345');
      await pressConfirm(tester);
      await tester.pumpAndSettle();
      expect(
        find.textContaining('We could not confirm whether'),
        findsOneWidget,
      );
      expect(find.text('Confirm account deletion'), findsNothing);
      expect(find.text('Return to sign in'), findsOneWidget);
      expect(calls, [requestFunction, confirmFunction]);
      expect(LocalDataX.userid, 'user-A');
    }, client);
  });

  testWidgets(
    'confirm in flight cannot be repeated and a timeout is uncertain',
    (tester) async {
      final pending = Completer<http.Response>();
      confirm = (_) => pending.future;
      await http.runWithClient(() async {
        await open(tester);
        await send(tester);
        await enter(tester, '012345');
        await pressConfirm(tester);
        expect(
          tester
              .widget<ButtonStateX>(
                find.widgetWithText(ButtonStateX, 'Confirm account deletion'),
              )
              .disabled,
          isTrue,
        );
        expect(find.byType(BackButtonX), findsNothing);
        await tester.pump(const Duration(seconds: 21));
        await tester.pumpAndSettle();
        expect(calls, [requestFunction, confirmFunction]);
        expect(
          find.textContaining('We could not confirm whether'),
          findsOneWidget,
        );
        expect(find.text('Confirm account deletion'), findsNothing);
        pending.complete(
          jsonResponse({'status': 'anonymised', 'logoutrequired': true}),
        );
        await tester.pumpAndSettle();
        expect(LocalDataX.userid, 'user-A');
      }, client);
    },
  );

  testWidgets(
    'code form fits a narrow phone with larger system text and keyboard',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await http.runWithClient(() async {
        await open(tester);
        await tester.ensureVisible(find.byType(CheckboxListTile));
        await send(tester);
        await tester.ensureVisible(find.byType(TextFieldX));
        await enter(tester, '012345');
        tester.view.viewInsets = const FakeViewPadding(bottom: 260);
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Confirm account deletion'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          find.text('Confirm account deletion').hitTestable(),
          findsOneWidget,
        );
        expect(calls, [requestFunction]);
      }, client);
    },
  );

  test(
    'known Moodle errors in 200 responses remain explicit and never retry',
    () async {
      final errors = {
        'postrequired': AccountDeletionError.unavailable,
        'protecteduser': AccountDeletionError.protectedAccount,
        'confirmcheck': AccountDeletionError.consentRequired,
        'confirmationinvalid': AccountDeletionError.invalidCode,
        'confirmationexpired': AccountDeletionError.expiredCode,
        'requestlimited': AccountDeletionError.rateLimited,
        'requestbusy': AccountDeletionError.busy,
        'confirmationdeliveryfailed': AccountDeletionError.deliveryFailed,
        'recoverysize': AccountDeletionError.recoveryBlocked,
        'recoveryconflict': AccountDeletionError.recoveryBlocked,
        'operationfailed': AccountDeletionError.outcomeUnknown,
        'invalidtoken': AccountDeletionError.sessionExpired,
      };
      final session = SessionLeaseX.capture();
      for (final entry in errors.entries) {
        confirm = (_) => jsonResponse({
          'exception': 'moodle_exception',
          'errorcode': entry.key,
          'debuginfo': 'private',
        });
        await http.runWithClient(() async {
          await expectLater(
            AccountDeletionApi().confirm(
              session,
              AccountDeletionChallenge(challengeId, 300),
              '012345',
            ),
            throwsA(
              isA<AccountDeletionException>().having(
                (error) => error.reason,
                'reason',
                entry.value,
              ),
            ),
          );
        }, client);
      }
      expect(calls, List.filled(errors.length, confirmFunction));
    },
  );

  test('signed-out protected deep links redirect to sign in', () async {
    await LocalDataX.remove(LocalKeyX.userid);
    await LocalDataX.remove(LocalKeyX.token);
    for (final route in [
      RouteNameX.root,
      RouteNameX.courseDetails,
      RouteNameX.notifications,
    ]) {
      final page = RouteListX.routes.singleWhere((page) => page.name == route);
      expect(page.middlewares!.single.redirect(route)?.name, RouteNameX.login);
    }
  });
}
