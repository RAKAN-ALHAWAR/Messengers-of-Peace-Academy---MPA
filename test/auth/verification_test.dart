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
import 'package:messengersofpeace/Data/Model/auth/otp.dart';
import 'package:messengersofpeace/Ui/Screen/Auth/OTP/controller/controller.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import 'session_lifecycle_test.dart' show syntheticUser;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late AppControllerX app;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-verification-');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('app');
    await HttpX.init();
  });
  setUp(() async {
    Get.testMode = true;
    await HiveX.removeAll();
    app = Get.put(AppControllerX(), permanent: true);
  });
  tearDown(() {
    ToastX.dismiss();
    Get.delete<OTPController>(force: true);
    Get.delete<AppControllerX>(force: true);
    Get.reset();
  });
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  Future<OTPController> mount(
    WidgetTester tester, {
    bool signUp = true,
    String? id = 'synthetic-A',
  }) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/entry',
        getPages: [
          GetPage(
            name: '/entry',
            page: () => const Scaffold(body: Text('Entry')),
          ),
          GetPage(
            name: '/otp-test',
            page: () => const Scaffold(body: Text('Verification')),
          ),
          GetPage(
            name: RouteNameX.login,
            page: () => const Scaffold(body: Text('Login destination')),
          ),
          GetPage(
            name: RouteNameX.completeAccountInfo,
            page: () => const Scaffold(body: Text('Completion destination')),
          ),
          GetPage(
            name: RouteNameX.forgotPasswordReset,
            page: () => const Scaffold(body: Text('Reset destination')),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    Get.toNamed(
      '/otp-test',
      arguments: OtpX(
        isSignUp: signUp,
        isPhone: false,
        email: 'first@example.invalid',
        userid: id,
      ),
    );
    await tester.pumpAndSettle();
    final controller = Get.put(OTPController());
    controller.otpCode.text = '123456';
    return controller;
  }

  testWidgets('missing verification ID sends no request and does not crash', (
    tester,
  ) async {
    var count = 0;
    await http.runWithClient(
      () async {
        final controller = await mount(tester, id: null);
        await controller.onVerify();
        await tester.pump();
        expect(count, 0);
        expect(app.isLogin.value, isFalse);
        expect(controller.buttonState.value, ButtonStateEX.failed);
        expect(
          find.text(
            'Your account still needs verification. Please contact support to recover verification access.',
          ),
          findsOneWidget,
        );
        Get.delete<OTPController>(force: true);
        await tester.pump(const Duration(seconds: 5));
      },
      () => MockClient((_) async {
        count++;
        return http.Response('{}', 200);
      }),
    );
  });

  testWidgets(
    'verified account without token offers sign-in without profile fetch',
    (tester) async {
      var count = 0;
      await http.runWithClient(
        () async {
          final controller = await mount(tester);
          await tester.runAsync(controller.onVerify);
          await tester.pumpAndSettle();
          expect(count, 1);
          expect(LocalDataX.userid, isEmpty);
          expect(LocalDataX.token, isEmpty);
          expect(app.isLogin.value, isFalse);
          expect(find.text('Login destination'), findsOneWidget);
          Get.delete<OTPController>(force: true);
        },
        () => MockClient((_) async {
          count++;
          return http.Response('{"status":"success"}', 200);
        }),
      );
    },
  );

  for (final abandon in ['closed', 'session', 'same-token', 'route']) {
    testWidgets(
      'pending verification ignores $abandon and rejects duplicates',
      (tester) async {
        var count = 0;
        final response = Completer<http.Response>();
        await http.runWithClient(
          () async {
            final controller = await mount(tester);
            final pending = controller.onVerify();
            await tester.pump();
            await controller.onVerify();
            await controller.onResend();
            expect(count, 1);
            if (abandon == 'closed') {
              Get.delete<OTPController>(force: true);
            } else if (abandon == 'route') {
              Get.toNamed(RouteNameX.login);
              await tester.pumpAndSettle();
            } else {
              await tester.runAsync(
                () => LocalDataX.put(
                  LocalKeyX.token,
                  abandon == 'session' ? 'synthetic-B' : '',
                ),
              );
            }
            response.complete(
              http.Response('{"token":"synthetic-token-A"}', 200),
            );
            await pending;
            await tester.pump();
            expect(count, 1);
            expect(LocalDataX.userid, isEmpty);
            expect(app.isLogin.value, isFalse);
            expect(find.text('Completion destination'), findsNothing);
            Get.delete<OTPController>(force: true);
          },
          () => MockClient((_) {
            count++;
            return response.future;
          }),
        );
      },
    );
  }

  testWidgets('reset verification preserves submitted email and code', (
    tester,
  ) async {
    final response = Completer<http.Response>();
    await http.runWithClient(() async {
      final controller = await mount(tester, signUp: false);
      final pending = controller.onVerify();
      await tester.pump();
      controller.otp.email = 'changed@example.invalid';
      controller.otpCode.text = '999999';
      response.complete(http.Response('{"status":"success"}', 200));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await pending;
      await tester.pumpAndSettle();
      expect(find.text('Reset destination'), findsOneWidget);
      expect(Get.arguments[NameX.email], 'first@example.invalid');
      expect(Get.arguments[NameX.otp], '123456');
      Get.delete<OTPController>(force: true);
    }, () => MockClient((_) => response.future));
  });

  testWidgets('pending resend is single and ignores closed controller', (
    tester,
  ) async {
    var count = 0;
    final response = Completer<http.Response>();
    await http.runWithClient(
      () async {
        final controller = await mount(tester);
        final pending = controller.onResend();
        await tester.pump();
        await controller.onResend();
        await controller.onVerify();
        expect(count, 1);
        Get.delete<OTPController>(force: true);
        response.complete(
          http.Response(
            '{"status":"success","message":"Synthetic resent"}',
            200,
          ),
        );
        await pending;
        await tester.pump();
        expect(find.text('Synthetic resent'), findsNothing);
        expect(controller.timer!.isActive, isFalse);
      },
      () => MockClient((_) {
        count++;
        return response.future;
      }),
    );
  });

  for (final mismatch in [false, true]) {
    testWidgets(
      'OTP profile ${mismatch ? 'mismatch rolls back' : 'success sets completion session'}',
      (tester) async {
        var count = 0;
        await http.runWithClient(
          () async {
            final controller = await mount(tester);
            await tester.runAsync(controller.onVerify);
            await tester.pumpAndSettle();
            expect(count, 2);
            expect(app.isLogin.value, !mismatch);
            expect(LocalDataX.userid, mismatch ? '' : 'synthetic-A');
            expect(
              LocalDataX.route,
              mismatch ? RouteNameX.login : RouteNameX.completeAccountInfo,
            );
            expect(
              find.text('Completion destination'),
              mismatch ? findsNothing : findsOneWidget,
            );
            Get.delete<OTPController>(force: true);
            await tester.pump(const Duration(seconds: 5));
          },
          () => MockClient((_) async {
            count++;
            return http.Response(
              count == 1
                  ? '{"token":"synthetic-token-A"}'
                  : jsonEncode(
                    syntheticUser(mismatch ? 'synthetic-B' : 'synthetic-A'),
                  ),
              200,
            );
          }),
        );
      },
    );
  }
  for (final abandon in ['closed', 'replacement', 'profile-error']) {
    testWidgets(
      'provisional verification profile $abandon cannot leave a partial session',
      (tester) async {
        var count = 0;
        late Completer<http.Response> profile;
        await http.runWithClient(
          () async {
            final controller = await mount(tester);
            await tester.runAsync(() async {
              profile = Completer<http.Response>();
              final pending = controller.onVerify();
              while (count < 2) {
                await Future<void>.delayed(const Duration(milliseconds: 1));
              }
              if (abandon == 'closed') {
                Get.delete<OTPController>(force: true);
              }
              if (abandon == 'replacement') {
                await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
                await LocalDataX.put(LocalKeyX.token, 'synthetic-token-B');
                app.isLogin.value = true;
              }
              profile.complete(
                http.Response(
                  abandon == 'profile-error'
                      ? '{"status":"error","message":"Synthetic profile failure"}'
                      : jsonEncode(syntheticUser('synthetic-A')),
                  200,
                ),
              );
              await pending;
            });
            await tester.pump();
            expect(count, 2);
            expect(
              LocalDataX.userid,
              abandon == 'replacement' ? 'synthetic-B' : '',
            );
            expect(app.isLogin.value, abandon == 'replacement');
            expect(find.text('Completion destination'), findsNothing);
            Get.delete<OTPController>(force: true);
            await tester.pump(const Duration(seconds: 5));
          },
          () => MockClient((_) {
            count++;
            return count == 1
                ? Future.value(
                  http.Response('{"token":"synthetic-token-A"}', 200),
                )
                : profile.future;
          }),
        );
      },
    );
  }
}
