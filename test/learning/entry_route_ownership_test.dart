import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Core/Error/error.dart';
import 'package:messengersofpeace/Core/Helper/http/http.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Database/config/database_end_point.dart';
import 'package:messengersofpeace/Data/Model/user/user.dart';
import 'package:messengersofpeace/Ui/Screen/Profile/ProfileDetails/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Home/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Home/view/view.dart';
import 'package:messengersofpeace/Ui/Screen/Profile/ProfileDetails/view/view.dart';
import 'package:messengersofpeace/Ui/Section/UserStat/user_statistics.dart';
import 'package:messengersofpeace/Ui/Section/GeneralState/error.dart';
import 'empty_home_test.dart'
    show functionOf, fixtureResponse, userFixture, homeResponse;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory dir;
  setUpAll(() async {
    dir = await Directory.systemTemp.createTemp('mopa-entry-scope-');
    Hive.init(dir.path);
    HiveX.box = await Hive.openBox('app');
    HttpX.init();
  });
  setUp(() async {
    Get.testMode = true;
    Get.locale = const Locale('en');
    await LocalDataX.put(LocalKeyX.userid, 'synthetic-A');
    await LocalDataX.put(LocalKeyX.token, 'synthetic-token');
  });
  tearDown(() => Get.reset());
  tearDownAll(() async {
    await Hive.close();
    await dir.delete(recursive: true);
  });
  testWidgets(
    'independent Profile return refresh retires if origin disappears while first read is pending',
    (tester) async {
      final app = Get.put(
        AppControllerX()..user = UserX.fromJson(userFixture('synthetic-A')).obs,
        permanent: true,
      );
      final controller = Get.put(ProfileDetailsController(), permanent: true);
      final pending = Completer<http.Response>();
      var requests = 0;
      var userCalls = 0;
      await http.runWithClient(
        () async {
          await tester.pumpWidget(
            GetMaterialApp(
              initialRoute: '/origin',
              getPages: [
                GetPage(
                  name: '/origin',
                  page: () => const Scaffold(body: Text('Profile origin')),
                ),
                GetPage(
                  name: RouteNameX.myCourses,
                  page: () => const Scaffold(body: Text('Child')),
                ),
                GetPage(
                  name: '/replacement',
                  page: () => const Scaffold(body: Text('Replacement')),
                ),
              ],
            ),
          );
          await tester.pumpAndSettle();
          await controller.getData();
          expect(requests, 3);
          expect(app.user.value.firstname, 'Before');
          final navigation = controller.onCoursesAttended();
          await tester.pumpAndSettle();
          Get.back();
          await tester.pumpAndSettle();
          expect(requests, 4);
          Get.offAllNamed('/replacement');
          await tester.pumpAndSettle();
          expect(controller.isClosed, isFalse);
          pending.complete(
            fixtureResponse(userFixture('synthetic-A', first: 'After')),
          );
          await navigation;
          await tester.pumpAndSettle();
          final actual = app.user.value.firstname;
          final observedRequests = requests;
          await tester.pumpWidget(const SizedBox());
          await tester.pumpAndSettle();
          expect(actual, 'Before');
          expect(observedRequests, 4);
        },
        () => MockClient((request) async {
          requests++;
          final method = request.url.queryParameters['wsfunction']!;
          if (method == functionOf(DBEndPointX.postGetUser)) {
            userCalls++;
            if (userCalls == 2) return pending.future;
            return fixtureResponse(userFixture('synthetic-A'));
          }
          if (method == functionOf(DBEndPointX.postGetBadges)) {
            return fixtureResponse(<Object>[]);
          }
          return fixtureResponse(homeResponse(method, empty: true));
        }),
      );
    },
  );
  for (final profile in [false, true]) {
    testWidgets(
      'independent retained ${profile ? 'Profile' : 'Home'} rebuild reuses request and remount refreshes once',
      (tester) async {
        Get.put(
          AppControllerX()
            ..user = UserX.fromJson(userFixture('synthetic-A')).obs,
          permanent: true,
        );
        final home =
            profile ? null : Get.put(HomeController(), permanent: true);
        final details =
            profile
                ? Get.put(ProfileDetailsController(), permanent: true)
                : null;
        var calls = 0;
        var minutes = '0';
        late StateSetter rebuild;
        tester.view.physicalSize = const Size(1200, 1800);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        Widget mount() => StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return GetMaterialApp(
              home: profile ? const ProfileDetailsView() : const HomeView(),
            );
          },
        );
        await http.runWithClient(
          () async {
            await tester.pumpWidget(mount());
            await tester.pumpAndSettle();
            final perEntry = profile ? 3 : 5;
            expect(calls, perEntry);
            rebuild(() {});
            await tester.pumpAndSettle();
            expect(calls, perEntry);
            if (profile) {
              await details!.getData();
              await details.getData();
            } else {
              await home!.getData();
              await home.getData();
            }
            expect(calls, perEntry);
            await tester.pumpWidget(const SizedBox());
            await tester.pumpAndSettle();
            minutes = '29';
            await tester.pumpWidget(mount());
            await tester.pumpAndSettle();
            expect(calls, perEntry * 2);
            expect(
              tester
                  .widget<UserStatisticsSection>(
                    find.byType(UserStatisticsSection),
                  )
                  .statistics
                  .minutes,
              '29',
            );
            await tester.pumpWidget(const SizedBox());
            await tester.pumpAndSettle();
          },
          () => MockClient((request) async {
            calls++;
            final method = request.url.queryParameters['wsfunction']!;
            if (method == functionOf(DBEndPointX.postGetUserStatistics)) {
              return fixtureResponse({
                NameX.completedCourses: '0',
                NameX.minutes: minutes,
                NameX.points: '0',
                NameX.certificates: '0',
                NameX.quizzes: '0',
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

  for (final profile in [false, true]) {
    testWidgets(
      'repeated ${profile ? 'Profile' : 'Home'} course tap retains the real return refresh',
      (tester) async {
        Get.put(
          AppControllerX()
            ..user = UserX.fromJson(userFixture('synthetic-A')).obs,
          permanent: true,
        );
        final details =
            profile
                ? Get.put(ProfileDetailsController(), permanent: true)
                : null;
        final home =
            profile ? null : Get.put(HomeController(), permanent: true);
        final perLoad = profile ? 3 : 5;
        var calls = 0;
        var minutes = '0';
        await http.runWithClient(
          () async {
            await tester.pumpWidget(
              GetMaterialApp(
                initialRoute: '/origin',
                getPages: [
                  GetPage(name: '/origin', page: () => const Scaffold()),
                  GetPage(
                    name: RouteNameX.myCourses,
                    page: () => const Scaffold(body: Text('Child')),
                  ),
                ],
              ),
            );
            await tester.pumpAndSettle();
            if (profile) {
              await details!.getData();
            } else {
              await home!.getData();
            }
            expect(calls, perLoad);
            Future<void> navigate() =>
                profile ? details!.onCoursesAttended() : home!.onMyCourses();
            final first = navigate();
            final second = navigate();
            await tester.pumpAndSettle();
            expect(Get.currentRoute, RouteNameX.myCourses);
            minutes = '17';
            Get.back();
            await tester.pumpAndSettle();
            await Future.wait([first, second]);
            final actual =
                profile
                    ? details!.statistics.value.minutes
                    : home!.statistics.value.minutes;
            final observedCalls = calls;
            await tester.pumpWidget(const SizedBox());
            await tester.pumpAndSettle();
            expect(actual, '17');
            expect(observedCalls, perLoad * 2);
          },
          () => MockClient((request) async {
            calls++;
            final method = request.url.queryParameters['wsfunction']!;
            if (method == functionOf(DBEndPointX.postGetUserStatistics)) {
              return fixtureResponse({
                NameX.completedCourses: '0',
                NameX.minutes: minutes,
                NameX.points: '0',
                NameX.certificates: '0',
                NameX.quizzes: '0',
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

  for (final profile in [false, true]) {
    testWidgets(
      'independent failed ${profile ? 'Profile' : 'Home'} remount surfaces error instead of cached freshness',
      (tester) async {
        Get.put(
          AppControllerX()
            ..user = UserX.fromJson(userFixture('synthetic-A')).obs,
          permanent: true,
        );
        final home =
            profile ? null : Get.put(HomeController(), permanent: true);
        final details =
            profile
                ? Get.put(ProfileDetailsController(), permanent: true)
                : null;
        var fail = false;
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
            final before =
                profile ? details!.statistics.value : home!.statistics.value;
            final timestamp = profile ? details!.lastUpdate : home!.lastUpdate;
            await tester.pumpWidget(const SizedBox());
            await tester.pumpAndSettle();
            fail = true;
            await tester.pumpWidget(
              GetMaterialApp(
                home: profile ? const ProfileDetailsView() : const HomeView(),
              ),
            );
            await tester.pumpAndSettle();
            expect(
              tester.takeException(),
              isA<ErrorX>().having(
                (e) => e.errorCode,
                'expected synthetic status',
                500,
              ),
            );
            expect(find.byType(ErrorView), findsOneWidget);
            expect(find.byType(UserStatisticsSection), findsNothing);
            expect(
              profile ? details!.statistics.value : home!.statistics.value,
              same(before),
            );
            expect(profile ? details!.lastUpdate : home!.lastUpdate, timestamp);
            await tester.pumpWidget(const SizedBox());
            await tester.pumpAndSettle();
          },
          () => MockClient((request) async {
            if (fail) return fixtureResponse({}, 500);
            final method = request.url.queryParameters['wsfunction']!;
            if (method == functionOf(DBEndPointX.postGetBadges)) {
              return fixtureResponse(<Object>[]);
            }
            return fixtureResponse(homeResponse(method, empty: true));
          }),
        );
      },
    );
  }
  for (final abandon in ['session', 'locale', 'controller', 'route']) {
    testWidgets(
      'independent Profile return abandons $abandon before starting refresh',
      (tester) async {
        Get.put(
          AppControllerX()
            ..user = UserX.fromJson(userFixture('synthetic-A')).obs,
          permanent: true,
        );
        final controller = Get.put(ProfileDetailsController(), permanent: true);
        var calls = 0;
        await http.runWithClient(
          () async {
            await tester.pumpWidget(
              GetMaterialApp(
                initialRoute: '/origin',
                getPages: [
                  GetPage(name: '/origin', page: () => const Scaffold()),
                  GetPage(
                    name: RouteNameX.editProfile,
                    page: () => const Scaffold(),
                  ),
                  GetPage(name: '/replacement', page: () => const Scaffold()),
                ],
              ),
            );
            await tester.pumpAndSettle();
            await controller.getData();
            expect(calls, 3);
            final navigation = controller.onEditPersonalData();
            await tester.pumpAndSettle();
            if (abandon == 'session') {
              await tester.runAsync(
                () => LocalDataX.put(LocalKeyX.userid, 'synthetic-B'),
              );
            }
            if (abandon == 'locale') Get.locale = const Locale('es');
            if (abandon == 'controller') {
              await Get.delete<ProfileDetailsController>(force: true);
              Get.put(ProfileDetailsController(), permanent: true);
            }
            if (abandon == 'route') {
              Get.offAllNamed('/replacement');
            } else {
              Get.back();
            }
            await tester.pumpAndSettle();
            await navigation;
            expect(calls, 3);
            await tester.pumpWidget(const SizedBox());
            await tester.pumpAndSettle();
          },
          () => MockClient((request) async {
            calls++;
            final method = request.url.queryParameters['wsfunction']!;
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
