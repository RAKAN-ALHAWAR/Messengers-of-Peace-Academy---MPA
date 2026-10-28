import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Data/Model/auth/otp.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Ui/Screen/Auth/OTP/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Auth/OTP/view/view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final scratch = await Directory.systemTemp.createTemp('mopa-otp-dispose');
    Hive.init(scratch.path);
    HiveX.box = await Hive.openBox('synthetic-otp-dispose');
  });
  setUp(() {
    Get.testMode = true;
    Get.locale = const Locale('en');
    Get.put(AppControllerX(), permanent: true);
  });
  tearDown(() => Get.reset());
  tearDownAll(() async => Hive.close());

  // The same page and binding as route_list.dart for this screen.
  List<GetPage<dynamic>> pages() => [
    GetPage(name: RouteNameX.login, page: () => const Text('Login fixture')),
    GetPage(
      name: RouteNameX.otp,
      page: () => const OTPView(),
      binding: BindingsBuilder(() => Get.lazyPut(() => OTPController())),
    ),
  ];

  OtpX args() =>
      OtpX(email: 'a@example.invalid', isSignUp: false, isPhone: false);

  Future<void> pumpFor(WidgetTester tester, int frames) async {
    for (var i = 0; i < frames; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> mount(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        smartManagement: SmartManagement.full,
        initialRoute: RouteNameX.login,
        getPages: pages(),
      ),
    );
    await tester.pumpAndSettle();
    Get.toNamed(RouteNameX.otp, arguments: args());
    // The OTP page runs a countdown timer, so it never settles.
    await pumpFor(tester, 10);
  }

  testWidgets('leaving the OTP page after typing a code throws nothing', (
    tester,
  ) async {
    await mount(tester);
    await tester.enterText(find.byType(TextField).first, '123456');
    await tester.pump();
    expect(Get.find<OTPController>().otpCode.text, '123456');

    Get.offAllNamed(RouteNameX.login);
    // Pump through the transition and the disposal after it.
    await pumpFor(tester, 20);

    expect(tester.takeException(), isNull);
    expect(Get.isRegistered<OTPController>(), isFalse);
  });

  testWidgets('typing while the OTP page is leaving throws nothing', (
    tester,
  ) async {
    await mount(tester);

    Get.offAllNamed(RouteNameX.login);
    await tester.pump(const Duration(milliseconds: 50));
    // The old page is still on screen during its exit transition, and its
    // controller is still alive until the route is disposed after it.
    expect(find.byType(TextField), findsWidgets);
    expect(Get.isRegistered<OTPController>(), isTrue);
    await tester.enterText(find.byType(TextField).first, '654321');
    await pumpFor(tester, 20);

    expect(tester.takeException(), isNull);
  });
}
