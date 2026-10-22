import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:messengersofpeace/Core/Helper/http/http.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Model/course/level.dart';
import 'package:messengersofpeace/Data/Model/course/mini_course.dart';
import 'package:messengersofpeace/Ui/Screen/Course/AllCourses/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Course/AllCourses/view/view.dart';
import 'package:messengersofpeace/Ui/Widget/Custom/Card/course_card.dart';

import 'counterpart_lists_test.dart' show host, viewport;

http.Response fixtureResponse(Object data) => http.Response(
  jsonEncode(data),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

MiniCourseX course(int i, {String? name}) => MiniCourseX(
  id: '$i',
  name: name ?? 'Course $i',
  image: '',
  numSections: 5,
  completionPercent: 20,
  isOpen: i.isEven,
  isCompleted: false,
  numCompletionSections: 1,
);
LevelX level(int i, int count, {String? name}) => LevelX(
  id: '$i',
  name: 'Level $i',
  totalCourses: count,
  completedCourses: 0,
  completionPercent: 0,
  isOpen: true,
  isCompleted: false,
  courses: List.generate(count, (i) => course(i, name: name)),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  setUpAll(() async {
    final fonts =
        FontLoader('IBMPlexSansArabic')
          ..addFont(
            rootBundle.load('assets/fonts/IBMPlexSansArabic-Regular.ttf'),
          )
          ..addFont(
            rootBundle.load('assets/fonts/IBMPlexSansArabic-SemiBold.ttf'),
          )
          ..addFont(rootBundle.load('assets/fonts/IBMPlexSansArabic-Bold.ttf'));
    await fonts.load();
    await (FontLoader('Icon_x')
      ..addFont(rootBundle.load('assets/fonts/Icon_x.ttf'))).load();
    directory = await Directory.systemTemp.createTemp('mopa-carousel-');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('app');
    HttpX.init();
  });
  setUp(() async {
    Get.testMode = true;
    Get.locale = const Locale('en');
    await LocalDataX.put(LocalKeyX.userid, 'synthetic-A');
    await LocalDataX.put(LocalKeyX.token, 'synthetic-token');
    Get.put(AllCoursesController());
  });
  tearDown(() => Get.reset());
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });
  for (final count in [0, 1, 20, 100, 1000]) {
    for (final horizontal in [false, true]) {
      testWidgets(
        '${horizontal ? 'courses' : 'levels'} $count mount bounded cards',
        (tester) async {
          viewport(tester, 400);
          final data = List.generate(
            horizontal ? 1 : count,
            (i) => level(i, horizontal ? count : 1).toJson(),
          );
          await http.runWithClient(() async {
            await tester.pumpWidget(host(const AllCoursesView()));
            await tester.pumpAndSettle();
            final mounted = find.byType(CourseCard).evaluate().length;
            debugPrint(
              'CAROUSEL axis=${horizontal ? 'horizontal' : 'vertical'} records=$count mounted=$mounted',
            );
            expect(mounted, lessThanOrEqualTo(12));
            expect(mounted, count == 0 ? 0 : greaterThan(0));
            if (count >= 100) {
              final scrolls = tester.stateList<ScrollableState>(
                find.byType(Scrollable),
              );
              final scroll = scrolls.firstWhere(
                (s) =>
                    horizontal
                        ? axisDirectionToAxis(s.position.axisDirection) ==
                            Axis.horizontal
                        : axisDirectionToAxis(s.position.axisDirection) ==
                            Axis.vertical,
              );
              for (var i = 0; i < 6; i++) {
                scroll.position.jumpTo(scroll.position.maxScrollExtent);
                await tester.pumpAndSettle();
              }
              expect(
                find.text('${horizontal ? 'Course' : 'Level'} ${count - 1}'),
                findsOneWidget,
              );
              expect(
                find.byType(CourseCard).evaluate().length,
                lessThanOrEqualTo(12),
              );
            }
            await tester.pumpWidget(const SizedBox());
          }, () => MockClient((_) async => fixtureResponse(data)));
        },
      );
    }
  }
  for (final locale in ['ar', 'en', 'es', 'fil']) {
    for (final width in [320.0, 400.0]) {
      testWidgets('full course titles fit $locale width$width scale2', (
        tester,
      ) async {
        viewport(tester, width);
        const title =
            'عنوان الدورة كامل بلا اختصار A complete course title that wraps onto many lines';
        await http.runWithClient(
          () async {
            await tester.pumpWidget(
              host(const AllCoursesView(), locale: locale, scale: 2),
            );
            await tester.pumpAndSettle();
              await tester.pump(const Duration(seconds: 1));
              await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            expect(find.text(title), findsWidgets);
            for (final paragraph in tester.renderObjectList<RenderParagraph>(
              find.text(title),
            )) {
              expect(paragraph.didExceedMaxLines, isFalse);
            }
            if (autoUpdateGoldenFiles && locale == 'ar' && width == 400) {
              await expectLater(
                find.byType(AllCoursesView),
                matchesGoldenFile(
                  Uri.file('/private/tmp/mopa-course-carousel-ar-20261022.png'),
                ),
              );
            }
            await tester.pumpWidget(const SizedBox());
          },
          () => MockClient(
            (_) async => fixtureResponse([level(0, 2, name: title).toJson()]),
          ),
        );
      });
    }
  }
}
