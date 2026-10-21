import 'dart:io';
import 'dart:convert';
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
import 'package:messengersofpeace/Ui/Screen/Auth/Login/controller/controller.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory dir;
  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('mopa-security-probe');
    Hive.init(dir.path);
    HiveX.box = await Hive.openBox('app');
    HttpX.init();
  });
  tearDownAll(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  for (final status in [200, 401]) {
    testWidgets('profile expiry $status leaves actual login usable', (
      tester,
    ) async {
      Get.testMode = true;
      await tester.runAsync(() async {
        Get.put(AppControllerX(), permanent: true);
      });
      final controller = Get.put(LoginController());
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: RouteNameX.login,
          getPages: [
            GetPage(
              name: RouteNameX.login,
              page:
                  () => Scaffold(
                    body: Form(
                      key: controller.formKey,
                      child: const SizedBox(),
                    ),
                  ),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      controller.email.text = 'test@example.invalid';
      controller.password.text = 'synthetic';
      var requests = 0;
      await http.runWithClient(
        () async {
          await tester.runAsync(controller.onLogin);
          await tester.pump();
        },
        () => MockClient((_) async {
          requests++;
          return requests == 1
              ? http.Response(
                jsonEncode({
                  'userid': 'synthetic-A',
                  'token': 'synthetic-A-token',
                }),
                200,
              )
              : http.Response('{"errorcode":"invalidtoken"}', status);
        }),
      );
      await tester.runAsync(() async {
        await HiveX.box.flush();
        await Future<void>.delayed(Duration.zero);
      });
      final stuck = controller.isLoading.value;
      final userCleared = LocalDataX.userid.isEmpty;
      ToastX.dismiss();
      await tester.pumpWidget(const SizedBox());
      Get.reset();

      expect(requests, 2);
      expect(userCleared, isTrue);
      expect(stuck, isFalse, reason: 'expiry must release login for retry');
      expect(controller.buttonStateLogin.value, ButtonStateEX.normal);
    });
  }
}
