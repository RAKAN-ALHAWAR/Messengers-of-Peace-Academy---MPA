import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Config/Translation/translation.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Core/Helper/http/http.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Database/config/database_end_point.dart';
import 'package:messengersofpeace/Data/Model/user/user.dart';
import 'package:messengersofpeace/Ui/Screen/Badges/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Badges/view/view.dart';
import 'package:messengersofpeace/Ui/Screen/ActivityPionts/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/ActivityPionts/view/view.dart';
import 'package:messengersofpeace/Ui/Screen/My/MyAchievements/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/My/MyAchievements/view/view.dart';
import 'package:messengersofpeace/Ui/Widget/Custom/Card/badge_card.dart';
import 'package:messengersofpeace/Ui/Widget/Custom/Other/points_card.dart';
import 'package:messengersofpeace/Ui/Widget/Custom/Other/gradient_progress_bar.dart';
import 'package:messengersofpeace/Ui/Screen/Profile/ProfileDetails/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Profile/ProfileDetails/view/sections/under_appbar.dart';
import 'package:messengersofpeace/Data/Model/badge.dart';

String function(String endpoint) =>
    Uri.parse(endpoint).queryParameters['wsfunction']!;
http.Response response(Object value) => http.Response.bytes(
  utf8.encode(jsonEncode(value)),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);
Map<String, Object> badge(int index) => {
  NameX.id: 'badge-$index',
  NameX.badgeName: 'Badge row $index',
  NameX.requiredPoints: index + 10,
  NameX.description: 'Full badge description $index',
  NameX.earned: true,
};
Map<String, Object> activity(int index) => {
  NameX.id: 'activity-$index',
  NameX.myActivityName: 'Activity row $index',
  NameX.note: 'Full activity note $index',
  NameX.points: 7,
};
Map<String, Object> history(int index, int count) => {
  NameX.id: 'history-$index',
  NameX.myActivityName: 'History row $index',
  NameX.points: 7,
  NameX.dateTime:
      DateTime(2025, 1, 1).add(Duration(days: count - index)).toIso8601String(),
};
Widget host(
  Widget child, {
  String locale = 'en',
  double scale = 1,
  Brightness brightness = Brightness.light,
}) => GetMaterialApp(
  locale: Locale(locale),
  translations: TranslationX(),
  theme: ThemeData(brightness: brightness),
  supportedLocales: TranslationX.locales,
  localizationsDelegates: const [
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ],
  builder:
      (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
  getPages: [
    GetPage(
      name: RouteNameX.badges,
      page: () => const Scaffold(body: Text('Synthetic badges destination')),
    ),
    GetPage(
      name: RouteNameX.activityPoints,
      page:
          () => const Scaffold(body: Text('Synthetic activities destination')),
    ),
  ],
  home: child,
);
void viewport(WidgetTester tester, {double width = 400}) {
  tester.view.physicalSize = Size(width, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-catalog-lists-');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('synthetic');
    HttpX.init();
    await initializeDateFormatting();
  });
  setUp(() async {
    Get.testMode = true;
    Get.locale = const Locale('en');
    await LocalDataX.put(LocalKeyX.userid, 'synthetic-A');
    await LocalDataX.put(LocalKeyX.token, 'synthetic-token');
    Get.put<AppControllerX>(
      AppControllerX()
        ..user =
            UserX.fromJson({
              NameX.id: 'synthetic-A',
              NameX.username: 'fixture',
              NameX.email: 'test@example.invalid',
              NameX.points: 0,
            }).obs,
    );
  });
  tearDown(() => Get.reset());
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });
  Widget view(String kind) {
    if (kind == 'badges') {
      Get.put<BadgesController>(BadgesController());
      return const BadgesView();
    }
    if (kind == 'catalog') {
      Get.put<ActivityPiontsController>(ActivityPiontsController());
      return const ActivityPiontsView();
    }
    Get.put<MyAchievementsController>(MyAchievementsController());
    return const MyAchievementsView();
  }

  MockClient client(String kind, int count, void Function() record) =>
      MockClient((request) async {
        record();
        final method = request.url.queryParameters['wsfunction'];
        if (method == function(DBEndPointX.postGetBadges)) {
          return response(List.generate(kind == 'history' ? 8 : count, badge));
        }
        if (method == function(DBEndPointX.postGetActivityPoints)) {
          return response(List.generate(count, activity));
        }
        return response(List.generate(count, (i) => history(i, count)));
      });
  for (final kind in ['badges', 'catalog', 'history']) {
    for (final count in [0, 1, 20, 100, 1000]) {
      testWidgets(
        '$kind $count rows mount within viewport and final row is reachable',
        (tester) async {
          viewport(tester);
          var requests = 0;
          final screen = view(kind);
          final prefix =
              kind == 'badges'
                  ? 'Badge row '
                  : kind == 'catalog'
                  ? 'Activity row '
                  : 'History row ';
          await http.runWithClient(() async {
            await tester.pumpWidget(host(screen));
            await tester.pumpAndSettle();
            final mounted =
                find
                    .byWidgetPredicate(
                      (widget) =>
                          widget is Text &&
                          (widget.data?.startsWith(prefix) ?? false),
                    )
                    .evaluate()
                    .length;
            final images = find.byType(Image).evaluate().length;
            debugPrint(
              'CATALOG kind=$kind records=$count mountedRows=$mounted mountedImages=$images',
            );
            expect(mounted, lessThanOrEqualTo(kind == 'badges' ? 16 : 24));
            expect(images, lessThanOrEqualTo(32));
            expect(requests, kind == 'history' ? 2 : 1);
            await tester.pumpWidget(host(screen, brightness: Brightness.dark));
            await tester.pumpAndSettle();
            expect(requests, kind == 'history' ? 2 : 1);
            if (kind == 'history') {
              expect(
                find.byType(BadgeCardX).evaluate().length,
                lessThanOrEqualTo(6),
              );
            }
            if (count > 0) {
              await tester.scrollUntilVisible(
                find.text('$prefix${count - 1}'),
                2400,
                scrollable: find.byType(Scrollable).last,
                maxScrolls: 150,
              );
              await tester.pump(const Duration(seconds: 1));
              await tester.pumpAndSettle();
              expect(find.text('$prefix${count - 1}'), findsOneWidget);
              final finalRows =
                  find
                      .byWidgetPredicate(
                        (widget) =>
                            widget is Text &&
                            (widget.data?.startsWith(prefix) ?? false),
                      )
                      .evaluate()
                      .length;
              final finalImages = find.byType(Image).evaluate().length;
              debugPrint(
                'CATALOG_END kind=$kind records=$count mountedRows=$finalRows mountedImages=$finalImages',
              );
              expect(finalRows, lessThanOrEqualTo(24));
              expect(finalImages, lessThanOrEqualTo(32));
            }
            expect(tester.takeException(), isNull);
            await tester.pumpWidget(const SizedBox());
          }, () => client(kind, count, () => requests++));
        },
      );
    }
  }
  testWidgets(
    'history retains all month headers, descending dates and six-badge preview',
    (tester) async {
      viewport(tester);
      final screen = view('history');
      await http.runWithClient(() async {
        await tester.pumpWidget(host(screen));
        await tester.pumpAndSettle();
        expect(find.byType(BadgeCardX), findsNWidgets(6));
        final c = Get.find<MyAchievementsController>();
        final groups = c.groupActivityPointsByMonth();
        expect(groups.length, greaterThan(1));
        for (final entry in groups.entries) {
          await tester.scrollUntilVisible(
            find.text(entry.key),
            600,
            scrollable: find.byType(Scrollable).last,
            maxScrolls: 150,
          );
          expect(find.text(entry.key), findsOneWidget);
        }
        final dates =
            c.myActivityPoints.map((point) => point.dateTime).toList();
        for (var i = 1; i < dates.length; i++) {
          expect(dates[i].isAfter(dates[i - 1]), isFalse);
        }
        await tester.pumpWidget(const SizedBox());
      }, () => client('history', 40, () {}));
    },
  );
  testWidgets(
    'global activity catalog preserves its existing anonymous endpoint policy',
    (tester) async {
      await tester.runAsync(() async {
        await LocalDataX.remove(LocalKeyX.userid);
        await HiveX.box.flush();
      });
      var requests = 0;
      await http.runWithClient(() async {
        await tester.pumpWidget(host(view('catalog')));
        await tester.pumpAndSettle();
        expect(requests, 1);
        expect(find.text('Activity row 0'), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
      }, () => client('catalog', 1, () => requests++));
    },
  );
  for (final locale in ['ar', 'en', 'es', 'fil']) {
    testWidgets(
      'history headers and dates fit $locale at320 and2x with Latin digits',
      (tester) async {
        viewport(tester, width: 320);
        final screen = view('history');
        await http.runWithClient(() async {
          await tester.pumpWidget(host(screen, locale: locale, scale: 2));
          await tester.pumpAndSettle();
          await tester.scrollUntilVisible(
            find.text('Points History'.tr),
            400,
            scrollable: find.byType(Scrollable).last,
            maxScrolls: 100,
          );
          await tester.pump(const Duration(seconds: 1));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final format = DateFormat('dd MMMM yyyy  h:mma', locale)
            ..useNativeDigits = false;
          final date =
              Get.find<MyAchievementsController>()
                  .myActivityPoints
                  .first
                  .dateTime;
          await tester.scrollUntilVisible(
            find.text(format.format(date)),
            300,
            scrollable: find.byType(Scrollable).last,
            maxScrolls: 100,
          );
          expect(find.text(format.format(date)), findsOneWidget);
          expect(RegExp('[٠-٩]').hasMatch(format.format(date)), isFalse);
          await tester.pumpWidget(const SizedBox());
        }, () => client('history', 1, () {}));
      },
    );
  }
  testWidgets(
    'achievement header links retain their destinations and loaded snapshot',
    (tester) async {
      viewport(tester);
      var requests = 0;
      await http.runWithClient(() async {
        await tester.pumpWidget(host(view('history')));
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Badges List'.tr));
        final actionRect = tester.getRect(find.text('Badges List'.tr));
        final headingRect = tester.getRect(find.text('Achieved Badges'.tr));
        if ((actionRect.top - headingRect.top).abs() < 1) {
          expect(actionRect.right, closeTo(400 - StyleX.hPaddingApp, 1));
        } else {
          expect(actionRect.left, closeTo(StyleX.hPaddingApp, 1));
        }
        await tester.tap(find.text('Badges List'.tr));
        await tester.pumpAndSettle();
        expect(find.text('Synthetic badges destination'), findsOneWidget);
        Get.back();
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('Activities List'.tr),
          300,
          scrollable: find.byType(Scrollable).last,
          maxScrolls: 100,
        );
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Activities List'.tr));
        await tester.pumpAndSettle();
        expect(find.text('Synthetic activities destination'), findsOneWidget);
        expect(requests, 2);
        await tester.pumpWidget(const SizedBox());
      }, () => client('history', 1, () => requests++));
    },
  );

  testWidgets(
    'mounted achievements replace an account snapshot through actual requests',
    (tester) async {
      viewport(tester);
      var requests = 0;
      await http.runWithClient(
        () async {
          await tester.pumpWidget(host(view('history')));
          await tester.pumpAndSettle();
          await tester.runAsync(() async {
            await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
            Get.find<AppControllerX>().user.value = UserX.fromJson({
              NameX.id: 'synthetic-B',
              NameX.username: 'fixture',
              NameX.email: 'test@example.invalid',
              NameX.points: 0,
            });
            await HiveX.box.flush();
          });
          await tester.pumpAndSettle();
          await tester.scrollUntilVisible(
            find.text('Owner synthetic-B'),
            300,
            scrollable: find.byType(Scrollable).last,
            maxScrolls: 100,
          );
          expect(find.text('Owner synthetic-A'), findsNothing);
          expect(find.text('Owner synthetic-B'), findsOneWidget);
          expect(requests, 4);
          await tester.pumpWidget(const SizedBox());
        },
        () => MockClient((request) async {
          requests++;
          if (request.url.queryParameters['wsfunction'] ==
              function(DBEndPointX.postGetBadges)) {
            return response([badge(0)]);
          }
          return response([
            {
              NameX.id: 'history-owner',
              NameX.myActivityName: 'Owner ${LocalDataX.userid}',
              NameX.points: 7,
              NameX.dateTime: '2026-10-01T12:00:00',
            },
          ]);
        }),
      );
    },
  );

  for (final locale in ['ar', 'en', 'es', 'fil']) {
    testWidgets('profile points counterpart fits $locale at320 and2x', (
      tester,
    ) async {
      viewport(tester, width: 320);
      final controller = Get.put<ProfileDetailsController>(
        ProfileDetailsController(),
      );
      controller.currentBadge.value = BadgeX.fromJson({
        ...badge(0),
        NameX.badgeName:
            'Full translated badge name with many words kept readable',
      });
      Get.find<AppControllerX>().user.value = UserX.fromJson({
        NameX.id: 'synthetic-A',
        NameX.username: 'fixture',
        NameX.email: 'test@example.invalid',
        NameX.points: 9223372036854775807,
      });
      await tester.pumpWidget(
        host(
          const Scaffold(
            body: SingleChildScrollView(
              child: ProfileDetailsUnderAppbarSection(),
            ),
          ),
          locale: locale,
          scale: 2,
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byType(PointsCardX), findsOneWidget);
      expect(find.textContaining('9223372036854775807'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  }
  testWidgets(
    'points card keeps normal height and existing clamped progress controls',
    (tester) async {
      viewport(tester);
      final missingThreshold = {...badge(0)}..remove(NameX.requiredPoints);
      expect(() => BadgeX.fromJson(missingThreshold), throwsA(isNotNull));
      for (final values in [(0, 0), (10, 0), (20, 10), (5, 10)]) {
        final model = BadgeX.fromJson({
          ...badge(0),
          NameX.requiredPoints: values.$2,
        });
        await tester.pumpWidget(
          host(
            Scaffold(
              body: SingleChildScrollView(
                child: PointsCardX(points: values.$1, badge: model),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(tester.getSize(find.byType(PointsCardX)).height, 160);
        final bar = find.descendant(
          of: find.byType(GradientProgressBar),
          matching: find.byType(FractionallySizedBox),
        );
        final factor = tester.widget<FractionallySizedBox>(bar).widthFactor!;
        expect(factor.isFinite, isTrue);
        expect(factor, values.$2 == 0 || values.$1 > values.$2 ? 1 : 0.5);
      }
      await tester.pumpWidget(const SizedBox());
    },
  );
  for (final kind in ['badges', 'catalog']) {
    for (final locale in ['ar', 'en', 'es', 'fil']) {
      testWidgets('$kind keeps full long text at320 and2x $locale', (
        tester,
      ) async {
        viewport(tester, width: 320);
        const title =
            'Full long name with many words عنوان طويل دون حذف contenido completo';
        const detail =
            'Full description with many words تفاصيل كاملة sin truncamiento';
        await http.runWithClient(
          () async {
            await tester.pumpWidget(host(view(kind), locale: locale, scale: 2));
            await tester.pumpAndSettle();
            await tester.scrollUntilVisible(
              find.text(title),
              300,
              scrollable: find.byType(Scrollable).last,
              maxScrolls: 100,
            );
            await tester.pumpAndSettle();
            expect(find.text(title), findsOneWidget);
            expect(find.textContaining(detail), findsOneWidget);
            for (final finder in [
              find.text(title),
              find.textContaining(detail),
            ]) {
              final paragraph = tester.renderObject<RenderParagraph>(finder);
              expect(paragraph.didExceedMaxLines, isFalse);
            }
            expect(tester.takeException(), isNull);
            await tester.pumpWidget(const SizedBox());
          },
          () => MockClient(
            (request) async => response([
              kind == 'badges'
                  ? {
                    ...badge(0),
                    NameX.badgeName: title,
                    NameX.description: detail,
                  }
                  : {
                    ...activity(0),
                    NameX.myActivityName: title,
                    NameX.note: detail,
                  },
            ]),
          ),
        );
      });
    }
  }
}
