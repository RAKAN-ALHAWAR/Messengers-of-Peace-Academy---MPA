import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:messengersofpeace/Core/core.dart';
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
        var refreshed = false;
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
            refreshed = true;
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
          },
          () => MockClient((request) async {
            final method = request.url.queryParameters['wsfunction']!;
            if (method == functionOf(DBEndPointX.postGetUserStatistics) &&
                refreshed) {
              return fixtureResponse({...statsFixture(), NameX.minutes: '17'});
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
