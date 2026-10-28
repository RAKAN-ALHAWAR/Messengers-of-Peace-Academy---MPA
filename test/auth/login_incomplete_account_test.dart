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
import 'package:messengersofpeace/Ui/Screen/Auth/Login/controller/controller.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

// The exact reply seen from the server for an account whose profile is not
// fully set up: HTTP 200 with a Moodle exception and an Arabic message.
const incompleteMessage = 'تهيئة حساب المستخدم لم تكتمل بعد';
const incompleteBody =
    '{"exception":"core\\\\exception\\\\moodle_exception",'
    '"errorcode":"usernotfullysetup","message":"$incompleteMessage"}';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-login-incomplete-');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('app');
    await HttpX.init();
  });
  setUp(() async {
    Get.testMode = true;
    await HiveX.removeAll();
    Get.put(AppControllerX(), permanent: true);
  });
  tearDown(() {
    ToastX.dismiss();
    Get.delete<LoginController>(force: true);
    Get.delete<AppControllerX>(force: true);
    Get.reset();
  });
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  testWidgets(
    'an incomplete account keeps its session and goes to complete its data',
    (tester) async {
      final controller = Get.put(LoginController());
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: RouteNameX.login,
          getPages: [
            GetPage(
              name: RouteNameX.login,
              page: () => Scaffold(
                body: Form(key: controller.formKey, child: const SizedBox()),
              ),
            ),
            GetPage(
              name: RouteNameX.completeAccountInfo,
              page: () => const Scaffold(body: Text('Complete destination')),
            ),
            GetPage(
              name: RouteNameX.root,
              page: () => const Scaffold(body: Text('Root destination')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      controller.email.text = 'first@example.invalid';
      controller.password.text = 'Synthetic-password-1';
      var count = 0;
      await http.runWithClient(
        () async {
          await tester.runAsync(controller.onLogin);
          await tester.pump();
          await tester.pumpAndSettle();
          expect(count, 2);
          // No message that blocks the user: the session is kept and the screen
          // for the missing data opens, with a profile made from what is known.
          expect(find.text('Complete destination'), findsOneWidget);
          expect(find.text(incompleteMessage), findsNothing);
          expect(Get.arguments, {'profileMissing': true});
          expect(LocalDataX.userid, 'synthetic-A');
          expect(LocalDataX.token, 'synthetic-token-A');
          expect(LocalDataX.route, RouteNameX.completeAccountInfo);
          final app = Get.find<AppControllerX>();
          expect(app.isLogin.value, isTrue);
          expect(app.user.value.id, 'synthetic-A');
          expect(app.user.value.username, 'first@example.invalid');
        },
        () => MockClient((_) async {
          count++;
          return http.Response(
            count == 1
                ? '{"userid":"synthetic-A","token":"synthetic-token-A"}'
                : incompleteBody,
            200,
            // The Arabic message needs the same charset the server declares.
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }),
      );
    },
  );
}
