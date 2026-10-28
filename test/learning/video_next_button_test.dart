import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Config/Translation/translation.dart';
import 'package:messengersofpeace/Ui/Screen/Course/VideoPlayer /controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Course/VideoPlayer /view/view.dart';

void main() {
  tearDown(() => Get.reset());

  Future<void> mountPlayer(WidgetTester tester, String locale) async {
    Get.testMode = true;
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      GetMaterialApp(
        translations: TranslationX(),
        locale: Locale(locale),
        initialRoute: '/entry',
        getPages: [
          GetPage(
            name: '/entry',
            page: () => const Scaffold(body: SizedBox()),
          ),
          GetPage(
            name: RouteNameX.videoPlayer,
            page: () => const VideoPlayerView(),
            binding: BindingsBuilder(() {
              Get.lazyPut(() => VideoPlayerController());
            }),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Next returns to the course page with the next result', (
    tester,
  ) async {
    await mountPlayer(tester, 'en');
    // An empty url shows the error state without opening a native player.
    final result = Get.toNamed(RouteNameX.videoPlayer, arguments: '');
    await tester.pumpAndSettle();
    expect(find.text('Next'), findsOneWidget);
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(await result, VideoPlayerController.nextResult);
    expect(Get.currentRoute, '/entry');
  });

  testWidgets('the Arabic label is translated', (tester) async {
    await mountPlayer(tester, 'ar');
    Get.toNamed(RouteNameX.videoPlayer, arguments: '');
    await tester.pumpAndSettle();
    expect(find.text('التالي'), findsOneWidget);
  });

  testWidgets('the system back button returns without a next result', (
    tester,
  ) async {
    await mountPlayer(tester, 'en');
    final result = Get.toNamed(RouteNameX.videoPlayer, arguments: '');
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(await result, isNull);
  });
}
