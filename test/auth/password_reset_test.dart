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
import 'package:messengersofpeace/Ui/Screen/Auth/ForgotPassword/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Auth/ForgotPasswordReset/controller/controller.dart';

const successMessage =
    'Password changed successfully. Please sign in with your new password.';
const requestEmail = 'synthetic@example.invalid';
const requestPassword = 'Synthetic1!';

http.Response accepted() => http.Response(
  jsonEncode({'status': 'success', 'message': 'Synthetic accepted'}),
  200,
);
http.Response rejected() => http.Response(
  jsonEncode({'status': 'error', 'message': 'Synthetic rejected'}),
  200,
);

// The outer Overlay isolates auth from the separately repaired Get snackbar
// compatibility defect. It is test scaffolding, not a product workaround.
Widget host(List<GetPage<dynamic>> pages) => GetMaterialApp(
  builder:
      (context, child) =>
          Overlay(initialEntries: [OverlayEntry(builder: (_) => child!)]),
  initialRoute: RouteNameX.root,
  getPages: [
    GetPage(
      name: RouteNameX.root,
      page: () => const Scaffold(body: Text('Root fixture')),
    ),
    GetPage(
      name: RouteNameX.login,
      page: () => const Scaffold(body: Text('Login fixture')),
    ),
    GetPage(
      name: '/other',
      page: () => const Scaffold(body: Text('Other fixture')),
    ),
    GetPage(
      name: RouteNameX.otp,
      page: () => const Scaffold(body: Text('OTP fixture')),
    ),
    ...pages,
  ],
);

Future<ForgotPasswordResetController> openReset(WidgetTester tester) async {
  late ForgotPasswordResetController controller;
  await tester.pumpWidget(
    host([
      GetPage(
        name: RouteNameX.forgotPasswordReset,
        binding: BindingsBuilder(() {
          controller = Get.put(ForgotPasswordResetController());
        }),
        page:
            () => Scaffold(
              body: Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: controller.password,
                      validator: ValidatorX.password,
                    ),
                    TextFormField(
                      controller: controller.rePassword,
                      validator:
                          (value) => ValidatorX.rePassword(
                            value,
                            controller.password.text,
                          ),
                    ),
                  ],
                ),
              ),
            ),
      ),
    ]),
  );
  await tester.pumpAndSettle();
  Get.toNamed(
    RouteNameX.forgotPasswordReset,
    arguments: {NameX.email: requestEmail, NameX.otp: '123456'},
  );
  await tester.pumpAndSettle();
  controller.password.text = requestPassword;
  controller.rePassword.text = requestPassword;
  return controller;
}

Future<ForgotPasswordController> openRequest(WidgetTester tester) async {
  late ForgotPasswordController controller;
  await tester.pumpWidget(
    host([
      GetPage(
        name: RouteNameX.forgotPassword,
        binding: BindingsBuilder(() {
          controller = Get.put(ForgotPasswordController());
        }),
        page:
            () => Scaffold(
              body: Form(
                key: controller.formKey,
                child: TextFormField(
                  controller: controller.email,
                  validator: ValidatorX.email,
                ),
              ),
            ),
      ),
    ]),
  );
  await tester.pumpAndSettle();
  Get.toNamed(RouteNameX.forgotPassword);
  await tester.pumpAndSettle();
  controller.email.text = requestEmail;
  return controller;
}

Future<void> flushResponse(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 10));
}

Future<void> cleanHost(WidgetTester tester) async {
  for (var i = 0; i < 20; i++) {
    await tester.pump(const Duration(seconds: 1));
  }
  Get.closeAllSnackbars();
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpWidget(const SizedBox());
  Get.reset();
}

void controllerTest(String name, Future<void> Function(WidgetTester) body) {
  testWidgets(name, (tester) async {
    try {
      await body(tester);
    } finally {
      await cleanHost(tester);
    }
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final scratch = await Directory.systemTemp.createTemp('mopa-auth-tests-');
    Hive.init(scratch.path);
    HiveX.box = await Hive.openBox('synthetic-auth');
    HttpX.init();
  });
  setUp(() async {
    Get.testMode = true;
    Get.locale = const Locale('en');
    await HiveX.box.clear();
    await HiveX.box.put(LocalKeyX.userid, 'existing-synthetic-user');
    await HiveX.box.put(LocalKeyX.token, 'existing-synthetic-token');
    await HiveX.box.put(LocalKeyX.route, '/existing-synthetic-route');
    Get.put(AppControllerX(), permanent: true).isLogin.value = false;
  });
  tearDown(() async {
    Get.reset();
  });
  tearDownAll(() async {
    await Hive.close();
  });

  controllerTest(
    'accepted reset sends one request, returns to login and never changes session',
    (tester) async {
      final controller = await openReset(tester);
      final requests = <http.Request>[];
      final client = MockClient((request) async {
        requests.add(request);
        if (request.url.queryParameters['wsfunction']!.contains(
          'reset_password',
        )) {
          return accepted();
        }
        return rejected();
      });
      await http.runWithClient(() async {
        controller.onResetPassword();
        await flushResponse(tester);
        controller
            .onResetPassword(); // An acknowledgement must never replay OTP.
        await tester.pump(const Duration(seconds: 2));
        await tester.pump(const Duration(seconds: 1));
      }, () => client);
      expect(requests.length, 1);
      expect(requests.single.bodyFields, {
        NameX.username: requestEmail,
        NameX.otp: '123456',
        NameX.newpassword: requestPassword,
      });
      expect(Get.currentRoute, RouteNameX.login);
      expect(find.text(successMessage), findsOneWidget);
      expect(LocalDataX.userid, 'existing-synthetic-user');
      expect(LocalDataX.token, 'existing-synthetic-token');
      expect(LocalDataX.route, '/existing-synthetic-route');
      expect(Get.find<AppControllerX>().isLogin.value, false);
    },
  );

  controllerTest(
    'rejected reset stays editable and retries once after failure',
    (tester) async {
      final controller = await openReset(tester);
      var calls = 0;
      final client = MockClient((_) async {
        calls++;
        return calls == 1 ? rejected() : accepted();
      });
      await http.runWithClient(() async {
        controller.onResetPassword();
        await flushResponse(tester);
        expect(controller.isLoading.value, false);
        expect(controller.buttonState.value, ButtonStateEX.failed);
        expect(Get.currentRoute, RouteNameX.forgotPasswordReset);
        expect(controller.password.text, requestPassword);
        controller.onResetPassword();
        await flushResponse(tester);
        await tester.pump(const Duration(seconds: 3));
        await tester.pump();
      }, () => client);
      expect(calls, 2);
      expect(Get.currentRoute, RouteNameX.login);
    },
  );

  controllerTest('duplicate reset submissions share one in-flight request', (
    tester,
  ) async {
    final controller = await openReset(tester);
    final pending = Completer<http.Response>();
    var calls = 0;
    await http.runWithClient(
      () async {
        controller.onResetPassword();
        controller.onResetPassword();
        await flushResponse(tester);
        expect(calls, 1);
        pending.complete(accepted());
        await flushResponse(tester);
        await tester.pump(const Duration(seconds: 3));
        await tester.pump();
      },
      () => MockClient((_) {
        calls++;
        return pending.future;
      }),
    );
    expect(calls, 1);
  });

  for (final shouldReject in [false, true]) {
    controllerTest(
      'disposed reset ignores late ${shouldReject ? 'failure' : 'success'}',
      (tester) async {
        final controller = await openReset(tester);
        final pending = Completer<http.Response>();
        var calls = 0;
        await http.runWithClient(
          () async {
            controller.onResetPassword();
            await flushResponse(tester);
            Get.key.currentState!.pop();
            await tester.pumpAndSettle();
            Get.toNamed('/other');
            await tester.pumpAndSettle();
            expect(controller.isClosed, true);
            pending.complete(shouldReject ? rejected() : accepted());
            await flushResponse(tester);
            await tester.pump(const Duration(seconds: 3));
            await tester.pump();
          },
          () => MockClient((_) {
            calls++;
            return pending.future;
          }),
        );
        expect(calls, 1);
        expect(Get.currentRoute, '/other');
        expect(find.text(successMessage), findsNothing);
        expect(find.text('Synthetic rejected'), findsNothing);
      },
    );
  }

  controllerTest('invalid new password is rejected before network', (
    tester,
  ) async {
    final controller = await openReset(tester);
    controller.password.text = 'short';
    controller.rePassword.text = 'short';
    var calls = 0;
    await http.runWithClient(
      () async {
        controller.onResetPassword();
        await flushResponse(tester);
      },
      () => MockClient((_) async {
        calls++;
        return accepted();
      }),
    );
    expect(calls, 0);
    expect(Get.currentRoute, RouteNameX.forgotPasswordReset);
    expect(controller.isLoading.value, false);
  });

  controllerTest(
    'forgot request captures submitted email and blocks duplicate requests',
    (tester) async {
      final controller = await openRequest(tester);
      final pending = Completer<http.Response>();
      var calls = 0;
      await http.runWithClient(
        () async {
          controller.onResetPassword();
          controller.onResetPassword();
          await flushResponse(tester);
          controller.email.text = 'different@example.invalid';
          pending.complete(accepted());
          await flushResponse(tester);
          await tester.pump(const Duration(seconds: 2));
          await tester.pump();
        },
        () => MockClient((_) {
          calls++;
          return pending.future;
        }),
      );
      expect(calls, 1);
      expect(Get.currentRoute, RouteNameX.otp);
      expect(Get.arguments.email, requestEmail);
    },
  );

  for (final shouldReject in [false, true]) {
    controllerTest(
      'disposed forgot request ignores late ${shouldReject ? 'failure' : 'success'}',
      (tester) async {
        final controller = await openRequest(tester);
        final pending = Completer<http.Response>();
        await http.runWithClient(() async {
          controller.onResetPassword();
          await flushResponse(tester);
          Get.key.currentState!.pop();
          await tester.pumpAndSettle();
          Get.toNamed('/other');
          await tester.pumpAndSettle();
          expect(controller.isClosed, true);
          pending.complete(shouldReject ? rejected() : accepted());
          await flushResponse(tester);
          await tester.pump(const Duration(seconds: 3));
          await tester.pump();
        }, () => MockClient((_) => pending.future));
        expect(Get.currentRoute, '/other');
        expect(find.text('Synthetic accepted'), findsNothing);
        expect(find.text('Synthetic rejected'), findsNothing);
      },
    );
  }

  controllerTest(
    'leaving forgot request during success delay suppresses OTP navigation',
    (tester) async {
      final controller = await openRequest(tester);
      await http.runWithClient(() async {
        controller.onResetPassword();
        await flushResponse(tester);
        expect(controller.buttonState.value, ButtonStateEX.success);
        Get.key.currentState!.pop();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 350));
        await tester.pump();
        expect(controller.isClosed, true);
        Get.toNamed('/other');
        await tester.pumpAndSettle();
        await tester.pump(const Duration(seconds: 2));
        await tester.pump();
      }, () => MockClient((_) async => accepted()));
      expect(Get.currentRoute, '/other');
    },
  );
}
