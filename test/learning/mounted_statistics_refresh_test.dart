import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Core/Helper/http/http.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Database/config/database_end_point.dart';
import 'package:messengersofpeace/Data/Model/user/user.dart';
import 'package:messengersofpeace/Ui/Screen/Home/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Home/view/view.dart';
import 'package:messengersofpeace/Ui/Screen/Profile/ProfileDetails/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Profile/ProfileDetails/view/view.dart';
import 'package:messengersofpeace/Ui/Section/UserStat/user_statistics.dart';

import 'empty_home_test.dart'
    show functionOf, fixtureResponse, userFixture, statsFixture, homeResponse;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp(
      'mopa-mounted-statistics-',
    );
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('app');
    HttpX.init();
  });
  tearDown(() => Get.reset());
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  for (final profile in [false, true]) {
    test(
      '${profile ? 'Profile' : 'Home'} forced refresh exposes failure and preserves snapshot',
      () async {
        Get.testMode = true;
        Get.locale = const Locale('en');
        await LocalDataX.put(LocalKeyX.userid, 'synthetic-A');
        await LocalDataX.put(LocalKeyX.token, 'synthetic-token');
        Get.put(
          AppControllerX()
            ..user = UserX.fromJson(userFixture('synthetic-A')).obs,
        );
        final home = profile ? null : Get.put(HomeController());
        final details = profile ? Get.put(ProfileDetailsController()) : null;
        var fail = false;
        await http.runWithClient(
          () async {
            if (profile) {
              await details!.getData();
            } else {
              await home!.getData();
            }
            final before =
                profile ? details!.statistics.value : home!.statistics.value;
            final timestamp = profile ? details!.lastUpdate : home!.lastUpdate;
            fail = true;
            await expectLater(
              profile
                  ? details!.getData(force: true)
                  : home!.getData(force: true),
              throwsA(anything),
            );
            expect(
              profile ? details!.statistics.value : home!.statistics.value,
              same(before),
            );
            expect(profile ? details!.lastUpdate : home!.lastUpdate, timestamp);
          },
          () => MockClient((request) async {
            if (fail) return fixtureResponse({}, 500);
            final method = request.url.queryParameters['wsfunction']!;
            if (method == functionOf(DBEndPointX.postGetBadges))
              return fixtureResponse(<Object>[]);
            return fixtureResponse(homeResponse(method, empty: true));
          }),
        );
      },
    );
  }

  testWidgets('Profile course return updates mounted statistics immediately', (
    tester,
  ) async {
    Get.testMode = true;
    Get.locale = const Locale('en');
    await tester.runAsync(() async {
      await LocalDataX.put(LocalKeyX.userid, 'synthetic-A');
      await LocalDataX.put(LocalKeyX.token, 'synthetic-token');
    });
    Get.put(
      AppControllerX()..user = UserX.fromJson(userFixture('synthetic-A')).obs,
    );
    final details = Get.put(ProfileDetailsController());
    var minutes = '0';
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await http.runWithClient(
      () async {
        await tester.pumpWidget(
          GetMaterialApp(
            initialRoute: '/profile',
            getPages: [
              GetPage(name: '/profile', page: () => const ProfileDetailsView()),
              GetPage(
                name: RouteNameX.myCourses,
                page: () => const Scaffold(body: Text('Enrolled courses')),
              ),
            ],
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<UserStatisticsSection>(find.byType(UserStatisticsSection))
              .statistics
              .minutes,
          '0',
        );
        final navigation = details.onCoursesAttended();
        await tester.pumpAndSettle();
        expect(find.text('Enrolled courses'), findsOneWidget);
        minutes = '17';
        Get.back();
        await tester.pumpAndSettle();
        await navigation;
        expect(
          tester
              .widget<UserStatisticsSection>(find.byType(UserStatisticsSection))
              .statistics
              .minutes,
          '17',
        );
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
      },
      () => MockClient((request) async {
        final method = request.url.queryParameters['wsfunction']!;
        if (method == functionOf(DBEndPointX.postGetUserStatistics))
          return fixtureResponse({...statsFixture(), NameX.minutes: minutes});
        if (method == functionOf(DBEndPointX.postGetBadges))
          return fixtureResponse(<Object>[]);
        return fixtureResponse(homeResponse(method, empty: true));
      }),
    );
  });

  for (final profile in [false, true]) {
    testWidgets(
      '${profile ? 'Profile' : 'Home'} refresh updates mounted statistics',
      (tester) async {
        Get.testMode = true;
        Get.locale = const Locale('en');
        await tester.runAsync(() async {
          await LocalDataX.put(LocalKeyX.userid, 'synthetic-A');
          await LocalDataX.put(LocalKeyX.token, 'synthetic-token');
        });
        Get.put(
          AppControllerX()
            ..user = UserX.fromJson(userFixture('synthetic-A')).obs,
          permanent: true,
        );
        final home = profile ? null : Get.put(HomeController());
        final details = profile ? Get.put(ProfileDetailsController()) : null;
        var minutes = 0;
        tester.view.physicalSize = const Size(1200, 1800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await http.runWithClient(
          () async {
            await tester.pumpWidget(
              GetMaterialApp(
                home: profile ? const ProfileDetailsView() : const HomeView(),
              ),
            );
            await tester.pumpAndSettle();
            final section = find.byType(UserStatisticsSection);
            expect(
              tester.widget<UserStatisticsSection>(section).statistics.minutes,
              '0',
            );
            final initialStatistics =
                profile ? details!.statistics : home!.statistics;
            final initialUser = profile ? details!.user : home!.user;
            minutes = 17;
            if (profile) {
              details!.lastUpdate = DateTime(2000);
              await details.getData();
            } else {
              await home!.getData(force: true);
            }
            await tester.pumpAndSettle();
            final actual =
                tester
                    .widget<UserStatisticsSection>(section)
                    .statistics
                    .minutes;
            expect(actual, '17');
            expect(
              profile ? details!.statistics : home!.statistics,
              same(initialStatistics),
            );
            expect(profile ? details!.user : home!.user, same(initialUser));
            await tester.pumpWidget(const SizedBox());
            await tester.pumpAndSettle();
            // Root tabs replace views while retaining their controllers.
            minutes = 29;
            await tester.pumpWidget(
              GetMaterialApp(
                home: profile ? const ProfileDetailsView() : const HomeView(),
              ),
            );
            await tester.pumpAndSettle();
            expect(
              tester.widget<UserStatisticsSection>(section).statistics.minutes,
              '29',
            );
            await tester.pumpWidget(const SizedBox());
            await tester.pumpAndSettle();
          },
          () => MockClient((request) async {
            final method = request.url.queryParameters['wsfunction']!;
            if (method == functionOf(DBEndPointX.postGetUserStatistics) &&
                minutes > 0) {
              return fixtureResponse({
                ...statsFixture(),
                NameX.minutes: '$minutes',
              });
            }
            if (method == functionOf(DBEndPointX.postGetBadges)) {
              return fixtureResponse(<Object>[]);
            }
            return fixtureResponse(homeResponse(method, empty: true));
          }),
        );
      },
    );
  }
}
