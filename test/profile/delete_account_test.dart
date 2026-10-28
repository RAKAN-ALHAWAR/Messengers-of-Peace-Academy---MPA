import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Ui/Screen/Profile/ProfileDetails/controller/controller.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProfileDetailsController controller;
  late List<Uri> launched;
  late bool launchResult;

  setUpAll(() async {
    final directory = await Directory.systemTemp.createTemp('mopa-delete-');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('delete-account');
  });

  setUp(() {
    Get.testMode = true;
    launched = [];
    launchResult = true;
    Get.put(AppControllerX());
    controller = Get.put(ProfileDetailsController())
      ..launcher = (url) async {
        launched.add(url);
        return launchResult;
      };
  });

  tearDown(() {
    ToastX.dismiss();
    Get.reset();
  });

  Future<void> openDialog(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(home: const Scaffold(body: SizedBox())),
    );
    controller.onDeleteAccount();
    await tester.pumpAndSettle();
  }

  testWidgets('confirm opens the data deletion request page', (tester) async {
    await openDialog(tester);
    expect(find.textContaining('cannot be undone'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(launched.map((u) => u.toString()), [
      ProfileDetailsController.dataDeletionRequestUrl,
    ]);
    expect(
      ProfileDetailsController.dataDeletionRequestUrl,
      'https://mopacademy.org/admin/tool/dataprivacy/createdatarequest.php',
    );
    expect(find.textContaining('cannot be undone'), findsNothing);
  });

  testWidgets('cancel does not open anything', (tester) async {
    await openDialog(tester);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(launched, isEmpty);
    expect(find.textContaining('cannot be undone'), findsNothing);
  });

  testWidgets('a failed launch shows an error toast', (tester) async {
    launchResult = false;
    await openDialog(tester);

    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(launched, hasLength(1));
    expect(
      find.text('Could not open the page, please try again'),
      findsOneWidget,
    );
    // Let the toast timer finish.
    await tester.pump(const Duration(seconds: 10));
  });
}
