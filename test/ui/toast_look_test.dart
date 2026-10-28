import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

/// Height of the fake status bar, the toast must sit right under it.
const _statusBar = 40.0;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Real app font so the Arabic golden shows the real glyphs.
    final loader = FontLoader('IBMPlexSansArabic');
    for (final file in ['Regular', 'Medium', 'SemiBold']) {
      final bytes = File('assets/fonts/IBMPlexSansArabic-$file.ttf');
      loader.addFont(
        Future.value(ByteData.sublistView(bytes.readAsBytesSync())),
      );
    }
    await loader.load();
    // The icon font is not loaded in widget tests by default.
    final icons = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await icons.load();
  });
  setUp(() => Get.testMode = true);
  tearDown(Get.reset);

  /// Arabic RTL app with a fake status bar and a full screen page below.
  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      GetMaterialApp(
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar'),
        theme: ThemeData(fontFamily: 'IBMPlexSansArabic'),
        builder:
            (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(padding: const EdgeInsets.only(top: _statusBar)),
              child: child!,
            ),
        home: const Scaffold(backgroundColor: Colors.white),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('toast sits right under the status bar with the old margin', (
    tester,
  ) async {
    await pumpApp(tester);
    ToastX.success(message: 'تم الحفظ بنجاح');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    final rect = tester.getRect(find.byType(Material).last);
    expect(rect.top, _statusBar);
    expect(rect.left, StyleX.hPaddingApp);
    expect(rect.right, 400 - StyleX.hPaddingApp);
    ToastX.dismiss(); // no pending timer left behind
  });

  testWidgets('toast slides down from above the screen on entrance', (
    tester,
  ) async {
    await pumpApp(tester);
    ToastX.info(message: 'جاري التحميل');
    await tester.pump();
    final start = tester.getRect(find.byType(Material).last).bottom;
    expect(start, lessThanOrEqualTo(0), reason: 'starts above the screen');
    await tester.pump(const Duration(milliseconds: 250));
    final mid = tester.getRect(find.byType(Material).last).top;
    expect(mid, inExclusiveRange(-100, _statusBar));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.getRect(find.byType(Material).last).top, _statusBar);
    ToastX.dismiss();
  });

  testWidgets('toast does not animate when the system disables animations', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await pumpApp(tester);
    ToastX.info(message: 'جاري التحميل');
    await tester.pump();
    await tester.pump();
    expect(tester.getRect(find.byType(Material).last).top, _statusBar);
    ToastX.dismiss();
  });

  testWidgets('golden: success toast in Arabic RTL', (tester) async {
    await pumpApp(tester);
    ToastX.success(title: 'نجاح', message: 'تم تنزيل الملف بنجاح');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await expectLater(
      find.byType(GetMaterialApp),
      matchesGoldenFile('goldens/toast_success_ar.png'),
    );
    ToastX.dismiss();
  });

  testWidgets('golden: error toast in Arabic RTL', (tester) async {
    await pumpApp(tester);
    ToastX.error(message: 'حدث خطأ، حاول مرة أخرى');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await expectLater(
      find.byType(GetMaterialApp),
      matchesGoldenFile('goldens/toast_error_ar.png'),
    );
    ToastX.dismiss();
  });
}
