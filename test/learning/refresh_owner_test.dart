import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Core/Helper/http/http.dart';
import 'package:messengersofpeace/Core/Service/session_lease.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Database/config/database_end_point.dart';
import 'package:messengersofpeace/Data/Model/user/user.dart';
import 'package:messengersofpeace/Ui/Screen/Home/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Profile/ProfileDetails/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/My/MyCourses/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Course/AllCourses/controller/controller.dart';

import 'empty_home_test.dart'
    show functionOf, fixtureResponse, userFixture, statsFixture, levelFixture;
import '../performance/vertical_feed_test.dart' show fixture;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-refresh-owner-');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('app');
    HttpX.init();
  });
  setUp(() async {
    Get.testMode = true;
    Get.locale = const Locale('en');
    await LocalDataX.put(LocalKeyX.userid, 'synthetic-A');
    await LocalDataX.put(LocalKeyX.token, 'synthetic-token');
    Get.put(
      AppControllerX()..user = UserX.fromJson(userFixture('synthetic-A')).obs,
    );
  });
  tearDown(() => Get.reset());
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });
  Object responseFor(String method) {
    if (method == functionOf(DBEndPointX.postGetUser)) {
      return userFixture('synthetic-A', first: 'After');
    }
    if (method == functionOf(DBEndPointX.postGetUserStatistics)) {
      return statsFixture();
    }
    if (method == functionOf(DBEndPointX.postGetLevelsWithCourses)) {
      return [levelFixture('loaded')];
    }
    if (method == functionOf(DBEndPointX.postMyCourses)) {
      return [fixture(1).toJson()];
    }
    if (method == functionOf(DBEndPointX.postGetMeetings)) {
      return {NameX.meetings: <Object>[]};
    }
    return <Object>[];
  }

  for (final kind in ['home', 'profile', 'mycourses', 'allcourses']) {
    for (final retiredBeforeStart in [false, true]) {
      test(
        '$kind rejects a refresh owner retired ${retiredBeforeStart ? 'before read' : 'while pending'}',
        () async {
          final home = kind == 'home' ? Get.put(HomeController()) : null;
          final profile =
              kind == 'profile' ? Get.put(ProfileDetailsController()) : null;
          final mine =
              kind == 'mycourses' ? Get.put(MyCoursesController()) : null;
          final all =
              kind == 'allcourses' ? Get.put(AllCoursesController()) : null;
          var active = !retiredBeforeStart;
          final owner = SessionLeaseX.capture(isActive: () => active);
          final pending = <(String, Completer<http.Response>)>[];
          final started = Completer<void>();
          final expected = kind == 'home' ? 5 : 1;
          await http.runWithClient(
            () async {
              final work = switch (kind) {
                'home' => home!.getData(force: true, owner: owner),
                'profile' => profile!.getData(force: true, owner: owner),
                'mycourses' => mine!.getData(owner: owner),
                _ => all!.getData(owner: owner),
              };
              if (!retiredBeforeStart) {
                await started.future;
                active = false;
                for (final request in pending) {
                  request.$2.complete(fixtureResponse(responseFor(request.$1)));
                }
              }
              await work;
              expect(pending.length, retiredBeforeStart ? 0 : expected);
              expect(Get.find<AppControllerX>().user.value.firstname, 'Before');
              if (home != null) expect(home.isInit, isFalse);
              if (profile != null) expect(profile.isInit, isFalse);
              if (mine != null) expect(mine.myCourses, isEmpty);
              if (all != null) expect(all.levels, isEmpty);
            },
            () => MockClient((request) {
              final held = Completer<http.Response>();
              pending.add((request.url.queryParameters['wsfunction']!, held));
              if (pending.length == expected) started.complete();
              return held.future;
            }),
          );
        },
      );
    }
  }
}
