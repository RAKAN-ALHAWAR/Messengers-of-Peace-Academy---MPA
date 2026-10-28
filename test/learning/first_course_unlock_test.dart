import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:messengersofpeace/Core/Helper/http/http.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Data/Database/config/database_end_point.dart';
import 'package:messengersofpeace/Data/Model/user/user.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Ui/Screen/Course/AllCourses/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Home/controller/controller.dart';
import 'package:messengersofpeace/Data/Model/course/first_course_unlock.dart';
import 'package:messengersofpeace/Data/Model/course/level.dart';
import 'package:messengersofpeace/Data/Model/course/mini_course.dart';

MiniCourseX course(String id, {bool open = false, bool done = false}) =>
    MiniCourseX(
      id: id,
      name: id,
      image: '',
      numSections: 1,
      completionPercent: done ? 100 : 0,
      isOpen: open,
      isCompleted: done,
      numCompletionSections: 0,
    );

LevelX level(
  String id,
  List<MiniCourseX> courses, {
  bool open = false,
  bool done = false,
}) => LevelX(
  id: id,
  name: id,
  totalCourses: courses.length,
  completedCourses: courses.where((c) => c.isCompleted).length,
  completionPercent: done ? 100 : 0,
  isOpen: open,
  isCompleted: done,
  courses: courses,
);

List<String> openIds(List<LevelX> levels) => [
  for (final l in levels)
    for (final c in l.courses)
      if (c.isOpen) c.id,
];

void main() {
  test('every course closed: the first course of the first level opens', () {
    final levels = [
      level('L1', [course('a'), course('b')]),
      level('L2', [course('c')]),
    ];
    openFirstCourseIfNoneOpen(levels);
    expect(levels[0].isOpen, isTrue);
    expect(openIds(levels), ['a']);
    expect(levels[1].isOpen, isFalse);
  });

  test('completed levels and courses are skipped', () {
    final levels = [
      level('L1', [course('a', done: true)], open: true, done: true),
      level('L2', [course('b', done: true), course('c'), course('d')]),
    ];
    openFirstCourseIfNoneOpen(levels);
    expect(levels[1].isOpen, isTrue);
    expect(openIds(levels), ['c']);
  });

  test('an already open course changes nothing', () {
    final levels = [
      level('L1', [
        course('a', done: true),
        course('b', open: true),
      ], open: true),
      level('L2', [course('c')]),
    ];
    openFirstCourseIfNoneOpen(levels);
    expect(openIds(levels), ['b']);
    expect(levels[1].isOpen, isFalse);
  });

  test('no levels or nothing left to open changes nothing', () {
    openFirstCourseIfNoneOpen(<LevelX>[]);
    final levels = [
      level('L1', [course('a', done: true)], open: true, done: true),
    ];
    openFirstCourseIfNoneOpen(levels);
    expect(openIds(levels), isEmpty);
  });

  group(
    'screens apply the same rule to a server answer with no open course',
    () {
      late Directory directory;
      setUpAll(() async {
        directory = await Directory.systemTemp.createTemp('mopa-unlock-');
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
        Get.delete<AppControllerX>(force: true);
        Get.reset();
      });
      tearDownAll(() async {
        await Hive.close();
        await directory.delete(recursive: true);
      });

      String fn(String endpoint) =>
          Uri.parse(endpoint).queryParameters['wsfunction']!;
      http.Response closedLevels(http.Request request) {
        final function = request.url.queryParameters['wsfunction'];
        Object body = <Object>[];
        if (function == fn(DBEndPointX.postGetLevelsWithCourses)) {
          body = [
            {
              NameX.levelId: 'L1',
              NameX.levelName: 'L1',
              NameX.totalCourses: 2,
              NameX.completedCourses: 0,
              NameX.completionPercent: 0,
              NameX.isOpen: false,
              NameX.isCompleted: false,
              NameX.courses: [
                for (final id in ['19', '20'])
                  {
                    NameX.courseId: id,
                    NameX.courseName: id,
                    NameX.image: '',
                    NameX.numSections: 1,
                    NameX.completionPercent: 0,
                    NameX.isOpen: false,
                    NameX.isCompleted: false,
                    NameX.completedTopicsTotal: 0,
                  },
              ],
            },
          ];
        } else if (function == fn(DBEndPointX.postGetUser)) {
          body = {
            NameX.id: 'synthetic-A',
            NameX.username: 'synthetic-A',
            NameX.email: 'a@example.invalid',
            NameX.firstname: 'A',
          };
        } else if (function == fn(DBEndPointX.postGetUserStatistics)) {
          body = {
            NameX.completedCourses: '0',
            NameX.minutes: '0',
            NameX.points: '0',
            NameX.certificates: '0',
            NameX.quizzes: '0',
          };
        } else if (function == fn(DBEndPointX.postGetMeetings)) {
          body = {NameX.meetings: <Object>[]};
        }
        return http.Response(jsonEncode(body), 200);
      }

      test('Courses opens the first course and its level', () async {
        final controller = Get.put(AllCoursesController());
        await http.runWithClient(
          () => controller.getData(),
          () => MockClient((request) async => closedLevels(request)),
        );
        expect(controller.levels.single.isOpen, isTrue);
        expect(openIds(controller.levels), ['19']);
      });

      test('Home opens the same course and selects its level', () async {
        final controller = Get.put(HomeController());
        await http.runWithClient(
          () => controller.getData(),
          () => MockClient((request) async => closedLevels(request)),
        );
        expect(openIds(controller.levels), ['19']);
        expect(controller.currentLevel.value?.id, 'L1');
      });
    },
  );
}
