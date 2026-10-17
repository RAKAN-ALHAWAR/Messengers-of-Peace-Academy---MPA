import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:messengersofpeace/Config/Route/route_list.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Ui/Widget/Basic/Alert/toast_presenter.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import 'package:messengersofpeace/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<GetPage<dynamic>> routes;
  setUpAll(() async {
    final directory = await Directory.systemTemp.createTemp('mopa_toast_test');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('synthetic');
    routes = List.of(RouteListX.routes);
  });
  setUp(() {
    Get.testMode = true;
    RouteListX.routes
      ..clear()
      ..addAll([
        GetPage(
          name: RouteNameX.loading,
          page: () => const Scaffold(body: Text('root')),
        ),
        GetPage(
          name: '/probe',
          page:
              () => const Scaffold(
                appBar: AppBarX(title: 'probe'),
                body: Text('probe body'),
              ),
        ),
      ]);
  });
  tearDown(() {
    ToastX.dismiss();
    Get.reset();
  });
  tearDownAll(() async {
    RouteListX.routes
      ..clear()
      ..addAll(routes);
    await Hive.close();
  });

  testWidgets('all toast types render under actual MyApp and Back still pops', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    for (final show in <VoidCallback>[
      () => ToastX.error(message: 'error fixture'),
      () => ToastX.success(message: 'success fixture'),
      () => ToastX.info(message: 'info fixture'),
    ]) {
      Get.toNamed('/probe');
      await tester.pumpAndSettle();
      show();
      await tester.pump();
      expect(find.byType(Dismissible), findsOneWidget);
      expect(Get.isSnackbarOpen, isFalse);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(Get.currentRoute, RouteNameX.loading);
      await tester.pump(const Duration(seconds: StyleX.toastSecond));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('replacement, explicit close and timeout never pop a page', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    Get.toNamed('/probe');
    await tester.pumpAndSettle();
    ToastX.error(message: 'old');
    await tester.pump();
    ToastX.success(message: 'replacement');
    await tester.pump();
    expect(find.text('old'), findsNothing);
    expect(find.text('replacement'), findsOneWidget);
    expect(find.byType(Dismissible), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    expect(find.text('replacement'), findsNothing);
    expect(Get.currentRoute, '/probe');
    ToastX.info(message: 'expires');
    await tester.pump();
    await tester.pump(const Duration(seconds: StyleX.toastSecond));
    expect(find.text('expires'), findsNothing);
    expect(Get.currentRoute, '/probe');
  });

  testWidgets('presenter tolerates absent and unmounted hosts', (tester) async {
    final presenter = ToastPresenterX();
    presenter.show(
      overlay: null,
      duration: Duration.zero,
      builder: (_) => const SizedBox(),
    );
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));
    final overlay = tester.state<OverlayState>(find.byType(Overlay).first);
    presenter.show(
      overlay: overlay,
      duration: const Duration(seconds: 1),
      builder: (_) => const Positioned(top: 0, child: Text('fixture')),
    );
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    presenter.dismiss();
    presenter.dismiss();
    presenter.show(
      overlay: overlay,
      duration: Duration.zero,
      builder: (_) => const SizedBox(),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
