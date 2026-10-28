// Slice S5: each guard of the auth screens, one question at a time. A late
// answer must be dropped when the controller, its registration, the app
// controller, the route or the account changed while the request was in flight.
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
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Core/Helper/http/http.dart';
import 'package:messengersofpeace/Core/Service/session_lease.dart';
import 'package:messengersofpeace/Data/Model/auth/otp.dart';
import 'package:messengersofpeace/Data/Model/user/user.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Ui/Screen/Auth/CompleteAccountInfo/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Auth/ForgotPassword/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Auth/ForgotPasswordReset/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Auth/Login/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Auth/OTP/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Auth/SignUp/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Loading/controller/controller.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import 'password_reset_test.dart'
    show accepted, controllerTest, flushResponse, openReset, openRequest;
import 'session_lifecycle_test.dart' show syntheticUser;

const loginJson = '{"userid":"synthetic-A","token":"synthetic-token-A"}';
const failureJson = '{"status":"error","message":"Synthetic failure"}';

/// One way for the screen to change while its request is in flight.
enum Change {
  closed,
  closedStillRegistered,
  route,
  replacedInstance,
  appReplaced,
  appUnregistered,
}

/// A second live instance of [T] takes the registration; the first stays open.
void replaceRegistration<T extends GetxController>(T Function() create) {
  GetInstance().markAsDirty<T>();
  Get.put(create());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late AppControllerX app;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-atoms-s5-');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('app');
    await HttpX.init();
  });
  setUp(() async {
    Get.testMode = true;
    Get.locale = const Locale('en');
    await HiveX.removeAll();
    app = Get.put(AppControllerX(), permanent: true);
  });
  tearDown(() {
    ToastX.dismiss();
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    for (final name in [
      'plugins.flutter.io/google_sign_in',
      'plugins.flutter.io/url_launcher',
    ]) {
      messenger.setMockMethodCallHandler(MethodChannel(name), null);
    }
    Get.reset();
  });
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  /// Changes the app controller or the route; [onClose] and [onReplace] do the
  /// screen-specific part (closing or re-registering the controller).
  Future<void> change(
    WidgetTester tester,
    Change how, {
    required void Function() onClose,
    required void Function() onReplace,
    void Function()? onCloseOnly,
  }) async {
    switch (how) {
      case Change.closed:
        onClose();
      case Change.closedStillRegistered:
        onCloseOnly!();
      case Change.route:
        Get.toNamed('/other');
        await tester.pumpAndSettle();
      case Change.replacedInstance:
        onReplace();
      case Change.appReplaced:
        Get.delete<AppControllerX>(force: true);
        app = Get.put(AppControllerX(), permanent: true);
      case Change.appUnregistered:
        Get.delete<AppControllerX>(force: true);
    }
  }

  // ===========================================================================
  // Login

  group('Login', () {
    Future<LoginController> mount(WidgetTester tester) async {
      final controller = Get.put(LoginController());
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/login-test',
          getPages: [
            GetPage(
              name: '/login-test',
              page: () => Scaffold(
                body: Form(key: controller.formKey, child: const SizedBox()),
              ),
            ),
            GetPage(
              name: '/other',
              page: () => const Scaffold(body: Text('Other fixture')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      controller.email.text = 'first@example.invalid';
      controller.password.text = 'Synthetic-password-1';
      return controller;
    }

    Future<void> changeLogin(WidgetTester tester, Change how) => change(
      tester,
      how,
      onClose: () => Get.delete<LoginController>(force: true),
      onReplace: () => replaceRegistration(LoginController.new),
      // Closed without leaving the registry: only `isClosed` can tell.
      // ignore: invalid_use_of_protected_member
      onCloseOnly: () => Get.find<LoginController>().onDelete(),
    );

    for (final how in [Change.appReplaced, Change.appUnregistered]) {
      testWidgets('a sign-in is dropped when the app controller is ${how.name}', (
        tester,
      ) async {
        var count = 0;
        final response = Completer<http.Response>();
        await http.runWithClient(
          () async {
            final controller = await mount(tester);
            final pending = controller.onLogin();
            await tester.pump();
            await changeLogin(tester, how);
            response.complete(http.Response(loginJson, 200));
            await pending;
            await tester.pump();
            expect(count, 1);
            expect(LocalDataX.userid, isEmpty);
            Get.delete<LoginController>(force: true);
          },
          () => MockClient((_) {
            count++;
            return response.future;
          }),
        );
      });
    }

    for (final how in [
      Change.closed,
      Change.closedStillRegistered,
      Change.route,
      Change.replacedInstance,
      Change.appReplaced,
    ]) {
      testWidgets('a failing sign-in after the screen is ${how.name} '
          'writes nothing it does not own', (tester) async {
        final response = Completer<http.Response>();
        await http.runWithClient(
          () async {
            final controller = await mount(tester);
            final pending = controller.onLogin();
            await tester.pump();
            await changeLogin(tester, how);
            response.complete(http.Response(failureJson, 200));
            await pending;
            await tester.pump();
            // The lease covers closed, route and app: none of them shows the
            // error. The busy flag is released only by the live instance of
            // this route, so a closed, left or replaced controller keeps it,
            // while a replaced app controller does not take that right away.
            expect(
              controller.buttonStateLogin.value,
              switch (how) {
                Change.replacedInstance => ButtonStateEX.failed,
                Change.appReplaced => ButtonStateEX.normal,
                _ => ButtonStateEX.loading,
              },
            );
            expect(controller.isLoading.value, how == Change.appReplaced
                ? isFalse
                : isTrue);
            await tester.pump(const Duration(seconds: 5));
          },
          () => MockClient((_) => response.future),
        );
      });
    }

    testWidgets('a closed controller ignores a login tap', (tester) async {
      var count = 0;
      await http.runWithClient(
        () async {
          final controller = await mount(tester);
          Get.delete<LoginController>(force: true);
          await controller.onLogin();
          await tester.pump();
          expect(count, 0);
          expect(controller.isLoading.value, isFalse);
          expect(controller.buttonStateLogin.value, ButtonStateEX.normal);
        },
        () => MockClient((_) async {
          count++;
          return http.Response(loginJson, 200);
        }),
      );
    });

    group('Google', () {
      /// The sign-in sheet; [signIn] decides when and how it ends.
      void sheet(Completer<void> signIn, List<String> calls) {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('plugins.flutter.io/google_sign_in'),
              (call) async {
                calls.add(call.method);
                if (call.method == 'signIn') {
                  await signIn.future;
                  throw PlatformException(code: 'synthetic_failure');
                }
                return null;
              },
            );
      }

      testWidgets('a closed controller ignores a Google tap', (tester) async {
        final calls = <String>[];
        sheet(Completer<void>(), calls);
        final controller = await mount(tester);
        Get.delete<LoginController>(force: true);
        await controller.onLoginWithGoogle();
        await tester.pump();
        expect(calls, isNot(contains('signIn')));
        expect(controller.isLoading.value, isFalse);
        expect(controller.buttonStateGoogle.value, ButtonStateEX.normal);
      });

      for (final how in [Change.closed, Change.route, Change.appReplaced]) {
        testWidgets('a failing Google sign-in after the screen is ${how.name} '
            'writes nothing', (tester) async {
          final signIn = Completer<void>();
          sheet(signIn, []);
          final controller = await mount(tester);
          final pending = controller.onLoginWithGoogle();
          await tester.pump();
          await changeLogin(tester, how);
          signIn.complete();
          await pending;
          await tester.pump();
          // A replaced app controller still lets this live screen unlock.
          final unlocked = how == Change.appReplaced;
          expect(controller.isLoading.value, isNot(unlocked));
          expect(
            controller.buttonStateGoogle.value,
            unlocked ? ButtonStateEX.normal : ButtonStateEX.loading,
          );
          await tester.pump(const Duration(seconds: 5));
        });
      }
    });
  });

  // ===========================================================================
  // OTP

  group('OTP', () {
    Future<OTPController> mount(WidgetTester tester) async {
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
              name: '/other',
              page: () => const Scaffold(body: Text('Other fixture')),
            ),
            GetPage(
              name: RouteNameX.completeAccountInfo,
              page: () => const Scaffold(body: Text('Completion destination')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      Get.toNamed(
        '/otp-test',
        arguments: OtpX(
          isSignUp: true,
          isPhone: false,
          email: 'first@example.invalid',
          userid: 'synthetic-A',
        ),
      );
      await tester.pumpAndSettle();
      final controller = Get.put(OTPController());
      controller.otpCode.text = '123456';
      return controller;
    }

    Future<void> changeOtp(WidgetTester tester, Change how) => change(
      tester,
      how,
      onClose: () => Get.delete<OTPController>(force: true),
      onReplace: () => replaceRegistration(OTPController.new),
    );

    for (final how in [Change.appReplaced, Change.appUnregistered]) {
      testWidgets('a verification is dropped when the app controller is ${how.name}', (
        tester,
      ) async {
        var count = 0;
        final response = Completer<http.Response>();
        await http.runWithClient(
          () async {
            final controller = await mount(tester);
            final pending = controller.onVerify();
            await tester.pump();
            await changeOtp(tester, how);
            response.complete(
              http.Response('{"token":"synthetic-token-A"}', 200),
            );
            await pending;
            await tester.pump();
            expect(count, 1);
            expect(LocalDataX.userid, isEmpty);
            expect(find.text('Completion destination'), findsNothing);
            Get.delete<OTPController>(force: true);
          },
          () => MockClient((_) {
            count++;
            return response.future;
          }),
        );
      });
    }

    for (final how in [Change.closed, Change.route, Change.appReplaced]) {
      testWidgets('a failing verification after the screen is ${how.name} '
          'writes nothing', (tester) async {
        final response = Completer<http.Response>();
        await http.runWithClient(
          () async {
            final controller = await mount(tester);
            final pending = controller.onVerify();
            await tester.pump();
            await changeOtp(tester, how);
            response.complete(http.Response(failureJson, 200));
            await pending;
            await tester.pump();
            expect(controller.isLoading.value, isTrue);
            expect(controller.buttonState.value, ButtonStateEX.loading);
            Get.delete<OTPController>(force: true);
            await tester.pump(const Duration(seconds: 5));
          },
          () => MockClient((_) => response.future),
        );
      });
    }

    for (final how in [Change.closed, Change.route, Change.appReplaced]) {
      testWidgets('a resend answered after the screen is ${how.name} '
          'writes nothing', (tester) async {
        final response = Completer<http.Response>();
        await http.runWithClient(
          () async {
            final controller = await mount(tester);
            controller.start.value = 50;
            final pending = controller.onResend();
            await tester.pump();
            await changeOtp(tester, how);
            response.complete(
              http.Response('{"status":"success","message":"Resent"}', 200),
            );
            await pending;
            await tester.pump();
            expect(controller.isLoadingResendAgain.value, isTrue);
            expect(controller.start.value, 50);
            expect(find.text('Resent'), findsNothing);
            Get.delete<OTPController>(force: true);
          },
          () => MockClient((_) => response.future),
        );
      });
    }

    testWidgets('a closed controller ignores verify and resend taps', (
      tester,
    ) async {
      var count = 0;
      await http.runWithClient(
        () async {
          final controller = await mount(tester);
          Get.delete<OTPController>(force: true);
          await controller.onVerify();
          await controller.onResend();
          await tester.pump();
          expect(count, 0);
          expect(controller.isLoading.value, isFalse);
          expect(controller.isLoadingResendAgain.value, isFalse);
        },
        () => MockClient((_) async {
          count++;
          return http.Response('{}', 200);
        }),
      );
    });

    testWidgets('a closed controller neither restarts nor rewinds its timer', (
      tester,
    ) async {
      final controller = await mount(tester);
      controller.start.value = 50;
      Get.delete<OTPController>(force: true);
      final stopped = controller.timer;
      controller.didChangeAppLifecycleState(AppLifecycleState.resumed);
      controller.startTimer();
      expect(controller.start.value, 50);
      expect(controller.timer, same(stopped));
      expect(controller.timer!.isActive, isFalse);
    });
  });

  // ===========================================================================
  // SignUp

  group('SignUp', () {
    Future<SignUpController> mount(WidgetTester tester) async {
      final controller = Get.put(SignUpController());
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/signup-test',
          getPages: [
            GetPage(
              name: '/signup-test',
              page: () => Scaffold(
                body: Form(key: controller.formKey, child: const SizedBox()),
              ),
            ),
            GetPage(
              name: '/other',
              page: () => const Scaffold(body: Text('Other fixture')),
            ),
            GetPage(
              name: RouteNameX.otp,
              page: () => const Scaffold(body: Text('OTP destination')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      controller.email.text = 'first@example.invalid';
      controller.verificationMethod = 'Email';
      return controller;
    }

    Future<void> changeSignUp(WidgetTester tester, Change how) => change(
      tester,
      how,
      onClose: () => Get.delete<SignUpController>(force: true),
      onReplace: () => replaceRegistration(SignUpController.new),
    );

    for (final how in [Change.appReplaced, Change.appUnregistered]) {
      testWidgets('a sign-up is dropped when the app controller is ${how.name}', (
        tester,
      ) async {
        final response = Completer<http.Response>();
        await http.runWithClient(() async {
          final controller = await mount(tester);
          final pending = controller.onSignUp();
          await tester.pump();
          await changeSignUp(tester, how);
          response.complete(http.Response('{"userid":"synthetic-A"}', 200));
          await tester.pump();
          await tester.pump(const Duration(seconds: 1));
          await pending;
          await tester.pumpAndSettle();
          expect(find.text('OTP destination'), findsNothing);
          expect(controller.buttonState.value, ButtonStateEX.loading);
          Get.delete<SignUpController>(force: true);
        }, () => MockClient((_) => response.future));
      });
    }

    for (final how in [Change.closed, Change.route, Change.appReplaced]) {
      testWidgets('a failing sign-up after the screen is ${how.name} '
          'writes nothing', (tester) async {
        final response = Completer<http.Response>();
        await http.runWithClient(() async {
          final controller = await mount(tester);
          final pending = controller.onSignUp();
          await tester.pump();
          await changeSignUp(tester, how);
          response.complete(http.Response(failureJson, 200));
          await pending;
          await tester.pump();
          expect(controller.isLoading.value, isTrue);
          expect(controller.buttonState.value, ButtonStateEX.loading);
          Get.delete<SignUpController>(force: true);
          await tester.pump(const Duration(seconds: 5));
        }, () => MockClient((_) => response.future));
      });
    }

    testWidgets('a closed controller ignores a sign-up tap', (tester) async {
      var count = 0;
      await http.runWithClient(
        () async {
          final controller = await mount(tester);
          Get.delete<SignUpController>(force: true);
          await controller.onSignUp();
          await tester.pump();
          expect(count, 0);
          expect(controller.isLoading.value, isFalse);
        },
        () => MockClient((_) async {
          count++;
          return http.Response('{"userid":"synthetic-A"}', 200);
        }),
      );
    });

    group('links', () {
      /// The browser: [canLaunch] decides when the check ends.
      void browser(Completer<void> canLaunch, List<String> launched) {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('plugins.flutter.io/url_launcher'),
              (call) async {
                if (call.method == 'canLaunch') {
                  await canLaunch.future;
                  return true;
                }
                if (call.method == 'launch') launched.add('launch');
                return true;
              },
            );
      }

      final links = <String, void Function(SignUpController)>{
        'contact us': (c) => c.onContactUs(),
        'terms': (c) => c.onTermsAccepted(),
        'privacy policy': (c) => c.onPrivacyPolicy(),
      };
      for (final (link, how) in [
        for (final name in links.keys)
          for (final how in [null, Change.closed, Change.route]) (name, how),
      ]) {
        testWidgets(
          how == null
              ? 'the $link link opens when the screen stays'
              : 'the $link link does not open after the screen is ${how.name}',
          (tester) async {
            final canLaunch = Completer<void>();
            final launched = <String>[];
            browser(canLaunch, launched);
            final controller = await mount(tester);
            links[link]!(controller);
            await tester.pump();
            if (how != null) await changeSignUp(tester, how);
            canLaunch.complete();
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 50)),
            );
            await tester.pump();
            expect(launched, how == null ? ['launch'] : isEmpty);
          },
        );
      }
    });
  });

  // ===========================================================================
  // CompleteAccountInfo

  group('CompleteAccountInfo', () {
    late CompleteAccountInfoController controller;
    UserX account(String id) => UserX(
      id: id,
      username: 'synthetic',
      firstname: 'Test',
      lastname: 'User',
      email: 'test@example.invalid',
      lang: 'en',
      customfields: [],
      city: '',
      image: '',
      points: 0,
    );

    setUp(() async {
      await HiveX.box.put('userid', 'synthetic-user');
      await HiveX.box.put('token', 'synthetic-token');
      Get.delete<AppControllerX>(force: true);
      app = Get.put(AppControllerX()..user = account('synthetic-user').obs);
      controller = Get.put(CompleteAccountInfoController());
    });

    /// Everything that can end this controller's right to write.
    final changes = <String, void Function()>{
      // Closed, but still the registered instance: only `isClosed` can tell.
      'closed': () => controller.onDelete(),
      'replaced instance': () =>
          replaceRegistration(CompleteAccountInfoController.new),
      'app replaced': () {
        Get.delete<AppControllerX>(force: true);
        Get.put(AppControllerX()..user = account('synthetic-user').obs);
      },
      'app unregistered': () => Get.delete<AppControllerX>(force: true),
      'account changed': () => app.user.value = account('synthetic-other'),
    };

    for (final entry in changes.entries) {
      testWidgets('a late reference answer is dropped when ${entry.key}', (
        tester,
      ) async {
        final response = Completer<http.Response>();
        await http.runWithClient(() async {
          final pending = controller.loadCountries();
          await tester.pump();
          entry.value();
          response.complete(
            http.Response(
              jsonEncode([
                {'code': 'SA', 'name': 'Saudi Arabia', 'dial_code': '+966'},
              ]),
              200,
            ),
          );
          await pending;
          await tester.pump();
          expect(controller.countriesList, isEmpty);
        }, () => MockClient((_) => response.future));
      });
    }

    testWidgets('a late reference answer is kept while nothing changed', (
      tester,
    ) async {
      await http.runWithClient(
        () async {
          await controller.loadCountries();
          expect(controller.countriesList, hasLength(1));
        },
        () => MockClient(
          (_) async => http.Response(
            jsonEncode([
              {'code': 'SA', 'name': 'Saudi Arabia', 'dial_code': '+966'},
            ]),
            200,
          ),
        ),
      );
    });

    testWidgets('a closed controller sends no save', (tester) async {
      var count = 0;
      await http.runWithClient(
        () async {
          controller.onDelete();
          await controller.onEdit();
          expect(count, 0);
          expect(controller.isLoading.value, isFalse);
        },
        () => MockClient((_) async {
          count++;
          return http.Response('{}', 200);
        }),
      );
    });
  });

  // ===========================================================================
  // ForgotPassword (request a code)

  group('ForgotPassword', () {
    Future<void> leave(WidgetTester tester) async {
      Get.key.currentState!.pop();
      await tester.pumpAndSettle();
      Get.toNamed('/other');
      await tester.pumpAndSettle();
    }

    controllerTest('a closed controller ignores a tap', (tester) async {
      final controller = await openRequest(tester);
      var count = 0;
      await http.runWithClient(
        () async {
          Get.delete<ForgotPasswordController>(force: true);
          await controller.onResetPassword();
          expect(count, 0);
          expect(controller.isLoading.value, isFalse);
        },
        () => MockClient((_) async {
          count++;
          return accepted();
        }),
      );
      await tester.pumpWidget(const SizedBox());
    });

    controllerTest('a controller closed before the failure leaves no state', (
      tester,
    ) async {
      final controller = await openRequest(tester);
      final response = Completer<http.Response>();
      await http.runWithClient(() async {
        controller.onResetPassword();
        await flushResponse(tester);
        await leave(tester);
        response.complete(
          http.Response(failureJson, 200),
        );
        await flushResponse(tester);
        await tester.pump(const Duration(seconds: 3));
        expect(controller.isLoading.value, isTrue);
        expect(controller.buttonState.value, ButtonStateEX.loading);
      }, () => MockClient((_) => response.future));
    });

    controllerTest('a controller closed while the failed button waits keeps it', (
      tester,
    ) async {
      final controller = await openRequest(tester);
      await http.runWithClient(() async {
        controller.onResetPassword();
        await flushResponse(tester);
        // The request failed: the button shows it and a timer resets it.
        expect(controller.buttonState.value, ButtonStateEX.failed);
        await leave(tester);
        await tester.pump(const Duration(seconds: 3));
        expect(controller.buttonState.value, ButtonStateEX.failed);
      }, () => MockClient((_) async => http.Response(failureJson, 200)));
    });
  });

  // ===========================================================================
  // ForgotPasswordReset (reset, then sign in)

  group('ForgotPasswordReset', () {
    setUp(() async {
      await HiveX.box.put(LocalKeyX.userid, 'existing-synthetic-user');
      await HiveX.box.put(LocalKeyX.token, 'existing-synthetic-token');
      await HiveX.box.put(LocalKeyX.route, '/existing-synthetic-route');
      app.isLogin.value = false;
    });

    Future<void> leave(WidgetTester tester) async {
      Get.key.currentState!.pop();
      await tester.pumpAndSettle();
      Get.toNamed('/other');
      await tester.pumpAndSettle();
    }

    /// Reset accepted, then the sign-in calls wait on [login] and [profile].
    MockClient server({
      Completer<http.Response>? login,
      Completer<http.Response>? profile,
    }) => MockClient((request) async {
      final function = request.url.queryParameters['wsfunction']!;
      if (function.contains('reset_password')) return accepted();
      if (function.contains('login_user')) {
        return login?.future ??
            http.Response(
              jsonEncode({
                'userid': 'synthetic-A',
                'token': 'synthetic-token-A',
              }),
              200,
            );
      }
      return profile?.future ??
          http.Response(jsonEncode(syntheticUser('synthetic-A')), 200);
    });

    controllerTest('a controller closed during the sign-in login call stops there', (
      tester,
    ) async {
      final controller = await openReset(tester);
      final login = Completer<http.Response>();
      await http.runWithClient(() async {
        await tester.runAsync(() async {
          final pending = controller.onResetPassword();
          await Future<void>.delayed(const Duration(milliseconds: 50));
          Get.delete<ForgotPasswordResetController>(force: true);
          login.complete(
            http.Response(
              jsonEncode({
                'userid': 'synthetic-A',
                'token': 'synthetic-token-A',
              }),
              200,
            ),
          );
          await pending;
        });
        await tester.pumpWidget(const SizedBox());
        // Nothing of the new sign-in was stored and the screen did not move.
        expect(LocalDataX.userid, 'existing-synthetic-user');
        expect(Get.currentRoute, RouteNameX.forgotPasswordReset);
        expect(controller.buttonState.value, ButtonStateEX.loading);
      }, () => server(login: login));
    });

    controllerTest('a controller closed during the profile call removes the credentials', (
      tester,
    ) async {
      final controller = await openReset(tester);
      final profile = Completer<http.Response>();
      var profileAsked = false;
      await http.runWithClient(() async {
        await tester.runAsync(() async {
          final pending = controller.onResetPassword();
          while (LocalDataX.userid != 'synthetic-A') {
            await Future<void>.delayed(const Duration(milliseconds: 5));
          }
          profileAsked = true;
          Get.delete<ForgotPasswordResetController>(force: true);
          profile.complete(
            http.Response(jsonEncode(syntheticUser('synthetic-A')), 200),
          );
          await pending;
        });
        await tester.pumpWidget(const SizedBox());
        expect(profileAsked, isTrue);
        expect(LocalDataX.userid, isEmpty);
        expect(Get.find<AppControllerX>().isLogin.value, isFalse);
        expect(controller.buttonState.value, ButtonStateEX.loading);
      }, () => server(profile: profile));
    });

    controllerTest('credentials replaced during the profile call are not overwritten', (
      tester,
    ) async {
      final controller = await openReset(tester);
      final profile = Completer<http.Response>();
      await http.runWithClient(() async {
        await tester.runAsync(() async {
          final pending = controller.onResetPassword();
          while (LocalDataX.userid != 'synthetic-A') {
            await Future<void>.delayed(const Duration(milliseconds: 5));
          }
          await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
          await LocalDataX.put(LocalKeyX.token, 'synthetic-token-B');
          await LocalDataX.put(LocalKeyX.route, '/b-route');
          profile.complete(
            http.Response(jsonEncode(syntheticUser('synthetic-A')), 200),
          );
          await pending;
        });
        await tester.pumpAndSettle();
        expect(LocalDataX.userid, 'synthetic-B');
        expect(LocalDataX.route, '/b-route');
        expect(Get.find<AppControllerX>().isLogin.value, isFalse);
        expect(Get.currentRoute, RouteNameX.login);
      }, () => server(profile: profile));
    });

    controllerTest('a controller closed during the success delay does not navigate', (
      tester,
    ) async {
      final controller = await openReset(tester);
      await http.runWithClient(() async {
        await tester.runAsync(() async {
          final pending = controller.onResetPassword();
          while (controller.buttonState.value != ButtonStateEX.success) {
            await Future<void>.delayed(const Duration(milliseconds: 5));
          }
          Get.delete<ForgotPasswordResetController>(force: true);
          await pending;
        });
        await tester.pumpWidget(const SizedBox());
        expect(Get.currentRoute, RouteNameX.forgotPasswordReset);
      }, () => server());
    });

    controllerTest('a controller closed after a failed reset keeps the busy state', (
      tester,
    ) async {
      final controller = await openReset(tester);
      final response = Completer<http.Response>();
      await http.runWithClient(() async {
        controller.onResetPassword();
        await flushResponse(tester);
        await leave(tester);
        response.complete(http.Response(failureJson, 200));
        await flushResponse(tester);
        await tester.pump(const Duration(seconds: 3));
        expect(controller.isLoading.value, isTrue);
        expect(controller.buttonState.value, ButtonStateEX.loading);
      }, () => MockClient((_) => response.future));
    });

    controllerTest('a controller closed while the failed button waits keeps it', (
      tester,
    ) async {
      final controller = await openReset(tester);
      await http.runWithClient(() async {
        controller.onResetPassword();
        await flushResponse(tester);
        expect(controller.buttonState.value, ButtonStateEX.failed);
        await leave(tester);
        await tester.pump(const Duration(seconds: 3));
        expect(controller.buttonState.value, ButtonStateEX.failed);
      }, () => MockClient((_) async => http.Response(failureJson, 200)));
    });

    controllerTest('a closed controller ignores a tap', (tester) async {
      final controller = await openReset(tester);
      var count = 0;
      await http.runWithClient(
        () async {
          Get.delete<ForgotPasswordResetController>(force: true);
          await controller.onResetPassword();
          expect(count, 0);
          expect(controller.isLoading.value, isFalse);
        },
        () => MockClient((_) async {
          count++;
          return accepted();
        }),
      );
      await tester.pumpWidget(const SizedBox());
    });
  });

  // ===========================================================================
  // Loading

  group('Loading', () {
    setUp(() => HiveX.box.put(LocalKeyX.route, RouteNameX.login));

    Future<(LoadingController, List<Completer<SessionLeaseX?>>)> mount(
      WidgetTester tester,
    ) async {
      final gates = <Completer<SessionLeaseX?>>[];
      Get.delete<AppControllerX>(force: true);
      Get.put<AppControllerX>(_GatedApp(gates), permanent: true);
      final controller = Get.put(LoadingController());
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/loading-test',
          getPages: [
            GetPage(
              name: '/loading-test',
              page: () => const Scaffold(body: Text('Loading fixture')),
            ),
            GetPage(
              name: RouteNameX.login,
              page: () => const Scaffold(body: Text('Login reached')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      return (controller, gates);
    }

    testWidgets('a ready lease is used while the screen stays', (tester) async {
      final (controller, gates) = await mount(tester);
      final pending = controller.init();
      gates.single.complete(SessionLeaseX.capture());
      await pending;
      controller.finish();
      await tester.pumpAndSettle();
      expect(find.text('Login reached'), findsOneWidget);
    });

    testWidgets('a ready lease is dropped when the screen was closed', (
      tester,
    ) async {
      final (controller, gates) = await mount(tester);
      final pending = controller.init();
      Get.delete<LoadingController>(force: true);
      gates.single.complete(SessionLeaseX.capture());
      await pending;
      controller.finish();
      await tester.pumpAndSettle();
      expect(find.text('Login reached'), findsNothing);
    });

    testWidgets('an older startup answer cannot become the ready lease', (
      tester,
    ) async {
      final (controller, gates) = await mount(tester);
      final first = controller.init();
      final second = controller.init();
      gates.last.complete(null);
      await second;
      gates.first.complete(SessionLeaseX.capture());
      await first;
      controller.finish();
      await tester.pumpAndSettle();
      expect(find.text('Login reached'), findsNothing);
    });
  });
}

/// An app controller whose startup waits for the test.
class _GatedApp extends AppControllerX {
  _GatedApp(this.gates);
  final List<Completer<SessionLeaseX?>> gates;

  @override
  Future<SessionLeaseX?> init() {
    final gate = Completer<SessionLeaseX?>();
    gates.add(gate);
    return gate.future;
  }
}
