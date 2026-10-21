import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Ui/Screen/Loading/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Loading/view/view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory dir;
  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('mopa-security-probe');
    Hive.init(dir.path);
    HiveX.box = await Hive.openBox('app');
  });
  tearDownAll(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });

  testWidgets('actual signed-out LoadingView reaches login', (tester) async {
    Get.testMode = true;
    final app = Get.put(AppControllerX(), permanent: true);
    Get.put(LoadingController());
    final initialRevision = LocalDataX.sessionRevision;
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/loading-test',
        getPages: [
          GetPage(name: '/loading-test', page: () => const LoadingView()),
          GetPage(
            name: RouteNameX.login,
            page: () => const Scaffold(body: Text('Login reached')),
          ),
        ],
      ),
    );
    for (var i = 0; i < 15; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
    final revision = LocalDataX.sessionRevision;
    final reachedLogin = find.text('Login reached').evaluate().isNotEmpty;

    await tester.pumpWidget(const SizedBox());
    Get.reset();

    expect(
      reachedLogin,
      isTrue,
      reason: 'signed-out startup must reach its destination',
    );
    expect(app.isLogin.value, isFalse);
    expect(revision, initialRevision);
  });
}
