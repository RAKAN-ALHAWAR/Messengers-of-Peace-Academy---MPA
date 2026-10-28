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
import 'package:messengersofpeace/Ui/Screen/Auth/ForgotPasswordReset/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Auth/ForgotPasswordReset/view/view.dart';
import 'package:messengersofpeace/Ui/Screen/Auth/Login/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Auth/Login/view/view.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final scratch = await Directory.systemTemp.createTemp('mopa-login-reentry');
    Hive.init(scratch.path);
    HiveX.box = await Hive.openBox('synthetic-login-reentry');
    HttpX.init();
  });
  setUp(() {
    Get.testMode = true;
    Get.locale = const Locale('en');
    Get.put(AppControllerX(), permanent: true);
  });
  tearDown(() => Get.reset());
  tearDownAll(() async => Hive.close());

  // The same pages and bindings as route_list.dart for this flow.
  List<GetPage<dynamic>> pages() => [
    GetPage(
      name: RouteNameX.login,
      page: () => const LoginView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => LoginController())),
    ),
    GetPage(
      name: RouteNameX.forgotPassword,
      page: () => const Scaffold(body: Text('Forgot fixture')),
    ),
    GetPage(
      name: RouteNameX.forgotPasswordReset,
      page: () => const ForgotPasswordResetView(),
      binding: BindingsBuilder(
        () => Get.lazyPut(() => ForgotPasswordResetController()),
      ),
    ),
  ];

  // Login -> forgot password -> reset -> sign-in fails -> back to login. The
  // old Login route and a new one would share one type-keyed controller, and
  // removing the old route would delete the new page's controller.
  testWidgets(
    'login shown after a reset without sign-in has live text fields',
    (tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          smartManagement: SmartManagement.full,
          initialRoute: RouteNameX.login,
          getPages: pages(),
        ),
      );
      await tester.pumpAndSettle();
      Get.toNamed(RouteNameX.forgotPassword);
      await tester.pumpAndSettle();
      Get.offAndToNamed(
        RouteNameX.forgotPasswordReset,
        arguments: {NameX.email: 'a@example.invalid', NameX.otp: '123456'},
      );
      await tester.pumpAndSettle();
      final reset = Get.find<ForgotPasswordResetController>();
      reset.password.text = 'Synthetic1!';
      reset.rePassword.text = 'Synthetic1!';

      // The reset is accepted, the sign-in is refused.
      await http.runWithClient(
        () async {
          reset.onResetPassword();
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 10));
          await tester.pump(const Duration(seconds: 1));
        },
        () => MockClient((request) async {
          final accepted = request.url.queryParameters['wsfunction']!.contains(
            'reset_password',
          );
          return http.Response(
            accepted ? '{"status":"success"}' : '{"errorcode":"invalidlogin"}',
            200,
          );
        }),
      );

      // Let the route transition finish, the old route is disposed after it.
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(Get.currentRoute, RouteNameX.login);
      expect(Get.isRegistered<LoginController>(), isTrue);
      expect(Get.find<LoginController>().isClosed, isFalse);
      expect(tester.takeException(), isNull);
      await tester.enterText(
        find.byType(TextFormField).first,
        'a@example.invalid',
      );
      expect(tester.takeException(), isNull);
      expect(Get.find<LoginController>().email.text, 'a@example.invalid');
      ToastX.dismiss();
      await tester.pumpAndSettle(const Duration(seconds: 1));
    },
  );
}
