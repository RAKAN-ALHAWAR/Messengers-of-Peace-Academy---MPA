import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Core/Helper/http/http.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Data/Model/course/mini_course.dart';
import 'package:messengersofpeace/Data/Model/course/my_course.dart';
import 'package:messengersofpeace/Data/Model/user/user.dart';
import 'package:messengersofpeace/Data/Database/config/database_end_point.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Ui/Screen/Course/AllCourses/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Home/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/My/MyCourses/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Profile/ProfileDetails/controller/controller.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

MiniCourseX openCourse() => MiniCourseX(
  id: '19',
  name: 'Entry exam',
  image: '',
  numSections: 1,
  completionPercent: 0,
  isOpen: true,
  isCompleted: false,
  numCompletionSections: 0,
);

MyCourse enrolledCourse() => MyCourse(
  id: '19',
  fullName: 'Entry exam',
  lang: 'en',
  image: '',
  totalSections: 1,
  completedSections: 0,
  completionPercent: 0,
  enrolled: true,
);

/// Valid empty answers for every read a refresh after a return can issue.
http.Response answer(http.Request request) {
  final function = request.url.queryParameters['wsfunction'];
  Object body = <Object>[];
  if (function ==
      Uri.parse(DBEndPointX.postGetUser).queryParameters['wsfunction']) {
    body = {
      NameX.id: 'synthetic-A',
      NameX.username: 'synthetic-A',
      NameX.email: 'a@example.invalid',
      NameX.firstname: 'A',
    };
  } else if (function ==
      Uri.parse(
        DBEndPointX.postGetUserStatistics,
      ).queryParameters['wsfunction']) {
    body = {
      NameX.completedCourses: '0',
      NameX.minutes: '0',
      NameX.points: '0',
      NameX.certificates: '0',
      NameX.quizzes: '0',
    };
  } else if (function ==
      Uri.parse(DBEndPointX.postGetMeetings).queryParameters['wsfunction']) {
    body = {NameX.meetings: <Object>[]};
  }
  return http.Response(jsonEncode(body), 200);
}

Widget stub() => const Scaffold(body: SizedBox());

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-root-tap-');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('app');
    HttpX.init();
  });
  setUp(() async {
    Get.testMode = true;
    Get.locale = const Locale('en');
    await HiveX.removeAll();
    await LocalDataX.put(LocalKeyX.userid, 'synthetic-A');
    await LocalDataX.put(LocalKeyX.token, 'synthetic-token');
    Get.put(
      AppControllerX()
        ..user = UserX.fromJson({
          NameX.id: 'synthetic-A',
          NameX.username: 'synthetic-A',
          NameX.email: 'a@example.invalid',
          NameX.firstname: 'A',
        }).obs,
      permanent: true,
    );
  });
  tearDown(() {
    ToastX.dismiss();
    Get.delete<AppControllerX>(force: true);
    Get.reset();
  });
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  /// The real launch path: loading screen, then offAllNamed to the root page.
  Future<void> bootRoot(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: RouteNameX.loading,
        getPages: [
          GetPage(name: RouteNameX.loading, page: stub),
          GetPage(name: RouteNameX.root, page: stub),
          GetPage(name: RouteNameX.courseDetails, page: stub),
          GetPage(name: RouteNameX.myCourses, page: stub),
        ],
      ),
    );
    await tester.pumpAndSettle();
    Get.offAllNamed(RouteNameX.root);
    await tester.pumpAndSettle();
    expect(Get.currentRoute, RouteNameX.root);
  }

  Future<void> expectOpensDetails(
    WidgetTester tester,
    Future<void> Function() tap,
  ) async {
    await http.runWithClient(() async {
      final navigation = tap();
      await tester.pumpAndSettle();
      expect(Get.currentRoute, RouteNameX.courseDetails);
      expect(Get.arguments, '19');
      Get.back();
      await tester.pumpAndSettle();
      await navigation;
    }, () => MockClient((request) async => answer(request)));
  }

  testWidgets('Courses tab card opens the details on a fresh root page', (
    tester,
  ) async {
    final controller = Get.put(AllCoursesController());
    await bootRoot(tester);
    await expectOpensDetails(
      tester,
      () => controller.onCourseTap(openCourse()),
    );
  });

  testWidgets('Home course card opens the details on a fresh root page', (
    tester,
  ) async {
    final controller = Get.put(HomeController());
    await bootRoot(tester);
    await expectOpensDetails(
      tester,
      () => controller.onCourseTap(openCourse()),
    );
  });

  testWidgets(
    'Profile courses attended opens My Courses on a fresh root page',
    (tester) async {
      final controller = Get.put(ProfileDetailsController());
      await bootRoot(tester);
      await http.runWithClient(() async {
        final navigation = controller.onCoursesAttended();
        await tester.pumpAndSettle();
        expect(Get.currentRoute, RouteNameX.myCourses);
        Get.back();
        await tester.pumpAndSettle();
        await navigation;
      }, () => MockClient((request) async => answer(request)));
    },
  );

  testWidgets('My Courses card opens the details from a pushed page', (
    tester,
  ) async {
    final controller = Get.put(MyCoursesController());
    await bootRoot(tester);
    Get.toNamed(RouteNameX.myCourses);
    await tester.pumpAndSettle();
    await expectOpensDetails(
      tester,
      () => controller.onTapCourse(enrolledCourse()),
    );
  });

  testWidgets('a card tap whose page was left gives no refresh after return', (
    tester,
  ) async {
    final controller = Get.put(AllCoursesController());
    await bootRoot(tester);
    var requests = 0;
    await http.runWithClient(
      () async {
        final navigation = controller.onCourseTap(openCourse());
        await tester.pumpAndSettle();
        expect(Get.currentRoute, RouteNameX.courseDetails);
        // The root page is replaced while the details page is open.
        Get.offAllNamed(RouteNameX.root);
        await tester.pumpAndSettle();
        await navigation;
        expect(requests, 0);
      },
      () => MockClient((request) async {
        requests++;
        return http.Response('[]', 200);
      }),
    );
  });
}
