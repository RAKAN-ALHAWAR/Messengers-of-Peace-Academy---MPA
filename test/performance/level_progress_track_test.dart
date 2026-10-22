import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Config/Translation/translation.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Model/course/level.dart';
import 'package:messengersofpeace/Data/Model/user/user.dart';
import 'package:messengersofpeace/Ui/Screen/Home/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Home/view/sectinos/levels_progress.dart';

LevelX level(int index) => LevelX(
  id: 'synthetic-level-$index',
  name: 'Synthetic level $index',
  totalCourses: 0,
  completedCourses: 0,
  completionPercent: 0,
  isOpen: index == 2,
  isCompleted: index < 2,
  courses: [],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late Directory evidence;
  late HomeController controller;
  setUpAll(() async {
    await (FontLoader('IBMPlexSansArabic')
          ..addFont(
            rootBundle.load('assets/fonts/IBMPlexSansArabic-Regular.ttf'),
          )
          ..addFont(
            rootBundle.load('assets/fonts/IBMPlexSansArabic-SemiBold.ttf'),
          )
          ..addFont(rootBundle.load('assets/fonts/IBMPlexSansArabic-Bold.ttf')))
        .load();
    await (FontLoader('Icon_x')
      ..addFont(rootBundle.load('assets/fonts/Icon_x.ttf'))).load();
    directory = await Directory.systemTemp.createTemp('mopa-level-track-');
    evidence = await Directory.systemTemp.createTemp(
      'mopa-level-track-renders-',
    );
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('app');
  });
  setUp(() {
    Get.testMode = true;
    Get.locale = const Locale('en');
    Get.put(
      AppControllerX()
        ..user =
            UserX.fromJson({
              NameX.id: 'synthetic-user',
              NameX.username: 'synthetic',
              NameX.email: 'test@example.invalid',
              NameX.firstname: 'Test',
            }).obs,
    );
    controller = Get.put(HomeController());
  });
  tearDown(() => Get.reset());
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  Future<void> mount(
    WidgetTester tester,
    int count, {
    String locale = 'en',
    double width = 400,
    double scale = 1,
  }) async {
    tester.view.physicalSize = Size(width, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    controller.levels.assignAll(List.generate(count, level));
    await tester.pumpWidget(
      GetMaterialApp(
        theme: ThemeX.light,
        locale: Locale(locale),
        translations: TranslationX(),
        builder:
            (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(scale)),
              child: child!,
            ),
        home: const Scaffold(
          body: SingleChildScrollView(
            child: RepaintBoundary(
              key: ValueKey('level-progress-capture'),
              child: LevelsProgressSection(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  }

  Future<void> noNetwork(Future<void> Function() body) => http.runWithClient(
    body,
    () => MockClient(
      (_) async => throw StateError('Unexpected synthetic HTTP request'),
    ),
  );

  Finder decoration() => find.byWidgetPredicate(
    (w) =>
        w is DecoratedBox &&
        w.decoration is BoxDecoration &&
        (w.decoration as BoxDecoration).gradient == ColorX.gold2Gradient,
  );

  ScrollableState horizontal(WidgetTester tester) => tester
      .stateList<ScrollableState>(find.byType(Scrollable))
      .firstWhere(
        (s) => axisDirectionToAxis(s.position.axisDirection) == Axis.horizontal,
      );

  Future<void> last(WidgetTester tester) async {
    final scroll = horizontal(tester);
    scroll.position.jumpTo(scroll.position.maxScrollExtent);
    await tester.pumpAndSettle();
  }

  Future<void> capture(WidgetTester tester, String name) async {
    // Entrance timers can be pending while pumpAndSettle sees no scheduled
    // animation frame. Render evidence only after the real entrance completes.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey('level-progress-capture')),
    );
    final image = await tester.runAsync(() => boundary.toImage());
    final data = await tester.runAsync(
      () => image!.toByteData(format: ui.ImageByteFormat.png),
    );
    final path = '${evidence.path}/$name.png';
    await tester.runAsync(
      () => File(path).writeAsBytes(data!.buffer.asUint8List()),
    );
    image!.dispose();
    debugPrint('LEVEL_RENDER $path');
  }

  Future<Color> linePixel(WidgetTester tester, double logicalX) async {
    final finder = find.byKey(const ValueKey('level-progress-line'));
    final widget = tester.widget<CustomPaint>(finder);
    final size = tester.getSize(finder);
    final recorder = ui.PictureRecorder();
    widget.painter!.paint(Canvas(recorder), size);
    final picture = recorder.endRecording();
    final image = await tester.runAsync(
      () => picture.toImage(size.width.ceil(), size.height.ceil()),
    );
    final data = await tester.runAsync(
      () => image!.toByteData(format: ui.ImageByteFormat.rawRgba),
    );
    final direction = Directionality.of(tester.element(finder));
    final x =
        (direction == TextDirection.rtl ? size.width - logicalX - 1 : logicalX)
            .floor();
    final offset = (23 * size.width.ceil() + x) * 4;
    final color = Color.fromARGB(
      data!.getUint8(offset + 3),
      data.getUint8(offset),
      data.getUint8(offset + 1),
      data.getUint8(offset + 2),
    );
    image!.dispose();
    picture.dispose();
    return color;
  }

  testWidgets('normal four-level geometry uses full label font metrics', (
    tester,
  ) async {
    await noNetwork(() async {
      await mount(tester, 4);
      final label = find.text('4');
      final paragraph = tester.renderObject<RenderParagraph>(label);
      debugPrint(
        'LEVEL_NORMAL decoratedHeight=${tester.getSize(decoration()).height} labelLayout=${paragraph.size.height} labelPaint=${tester.getRect(label).height}',
      );
      expect(tester.getSize(decoration()).height, 89);
      expect(tester.getRect(label).height, paragraph.size.height);
      final images = tester.widgetList<Image>(find.byType(Image));
      expect(
        images.every((image) => image.width == 46 && image.height == 46),
        isTrue,
      );
      final first = find.descendant(
        of: find.byKey(const ValueKey('level-progress-item-0')),
        matching: find.byType(Image),
      );
      final open = find.descendant(
        of: find.byKey(const ValueKey('level-progress-item-2')),
        matching: find.byType(Image),
      );
      expect(tester.getRect(first).top - tester.getRect(open).top, 5);
      final viewport = tester.getRect(
        find.byKey(const ValueKey('level-progress-viewport')),
      );
      final finalBadge = find.descendant(
        of: find.byKey(const ValueKey('level-progress-item-3')),
        matching: find.byType(Image),
      );
      expect(tester.getRect(first).left, viewport.left);
      expect(tester.getRect(finalBadge).right, viewport.right);
      expect(find.byIcon(IconX.lock), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
      await capture(tester, 'normal-four-levels');
      await finish(tester);
    });
  });

  for (final count in [0, 1, 20, 100, 1000]) {
    testWidgets('$count levels mount viewport-bounded actual badge images', (
      tester,
    ) async {
      final errors = <FlutterErrorDetails>[];
      final report = FlutterError.onError;
      FlutterError.onError = errors.add;
      late int images;
      late int fitted;
      var lastImages = 0;
      var reached = false;
      try {
        await noNetwork(() async {
          await mount(tester, count);
          images = find.byType(Image).evaluate().length;
          fitted = find.byType(FittedBox).evaluate().length;
          if (count > 0) {
            await last(tester);
            lastImages = find.byType(Image).evaluate().length;
            reached = find.text('$count').evaluate().length == 1;
          }
          await finish(tester);
        });
      } finally {
        FlutterError.onError = report;
      }
      debugPrint(
        'LEVEL_TRACK count=$count mountedImages=$images lastImages=$lastImages reached=$reached',
      );
      expect(images, lessThanOrEqualTo(14));
      expect(images, count == 0 ? 0 : greaterThan(0));
      expect(fitted, 0);
      expect(lastImages, lessThanOrEqualTo(14));
      if (count > 0) expect(reached, isTrue);
      expect(errors, isEmpty);
    });
  }

  for (final locale in ['en', 'ar', 'es', 'fil']) {
    for (final width in [240.0, 400.0]) {
      for (final scale in [1.0, 3.0, 5.0]) {
        testWidgets(
          'full last number readable $locale width=$width scale=$scale',
          (tester) async {
            await noNetwork(() async {
              await mount(
                tester,
                1000,
                locale: locale,
                width: width,
                scale: scale,
              );
              await last(tester);
              final label = find.text('1000');
              expect(label, findsOneWidget);
              final paragraph = tester.renderObject<RenderParagraph>(label);
              expect(paragraph.text.toPlainText(), '1000');
              expect(paragraph.textDirection, TextDirection.ltr);
              expect(paragraph.didExceedMaxLines, isFalse);
              expect(
                paragraph.getMaxIntrinsicWidth(double.infinity),
                lessThanOrEqualTo(paragraph.size.width + 0.1),
              );
              final viewport = tester.getRect(
                find.byKey(const ValueKey('level-progress-viewport')),
              );
              final rect = tester.getRect(label);
              expect(rect.left, greaterThanOrEqualTo(viewport.left - 0.1));
              expect(rect.right, lessThanOrEqualTo(viewport.right + 0.1));
              expect(rect.bottom, lessThanOrEqualTo(viewport.bottom + 0.1));
              expect(
                find.byType(Image).evaluate().length,
                lessThanOrEqualTo(14),
              );
              if (scale > 1) {
                expect(tester.getSize(decoration()).height, greaterThan(89));
              }
              if (locale == 'ar' && width == 240 && scale == 5) {
                await capture(tester, 'rtl-narrow-scale5-last');
              }
              expect(tester.takeException(), isNull);
              await finish(tester);
            });
          },
        );
      }
    }
  }

  for (final locale in ['en', 'ar']) {
    testWidgets(
      'continuous full-track completion line and RTL scroll $locale',
      (tester) async {
        await noNetwork(() async {
          await mount(tester, 1000, locale: locale);
          controller.levels.assignAll(
            List.generate(
              1000,
              (i) => LevelX(
                id: '$i',
                name: 'Synthetic',
                totalCourses: 0,
                completedCourses: 0,
                completionPercent: 0,
                isOpen: false,
                isCompleted: i.isEven,
                courses: [],
              ),
            ),
          );
          await tester.pumpAndSettle();
          final scroll = horizontal(tester);
          final width = scroll.position.viewportDimension;
          expect(await linePixel(tester, width / 2), ColorX.yellow.shade400);
          final track = scroll.position.maxScrollExtent + width;
          scroll.position.jumpTo(track / 2 - width / 2);
          await tester.pumpAndSettle();
          expect(await linePixel(tester, width / 4), ColorX.yellow.shade400);
          expect(
            await linePixel(tester, width * 3 / 4),
            ColorX.yellow.shade100,
          );
          await last(tester);
          expect(await linePixel(tester, width / 2), ColorX.yellow.shade100);
          final semantics = find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.value == '50%',
          );
          expect(semantics, findsOneWidget);
          await finish(tester);
        });
      },
    );
  }

  testWidgets(
    'live level replacement after end scroll retires old range and progress',
    (tester) async {
      await noNetwork(() async {
        await mount(tester, 1000);
        await last(tester);
        controller.levels.assignAll([level(0)]);
        await tester.pumpAndSettle();
        expect(find.text('1'), findsOneWidget);
        expect(find.text('1000'), findsNothing);
        expect(horizontal(tester).position.maxScrollExtent, 0);
        expect(
          find.byWidgetPredicate(
            (w) => w is Semantics && w.properties.value == '100%',
          ),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
        await finish(tester);
      });
    },
  );
}
