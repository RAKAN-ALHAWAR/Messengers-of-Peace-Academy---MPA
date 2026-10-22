import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:messengersofpeace/Core/Helper/http/http.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Database/config/database_end_point.dart';
import 'package:messengersofpeace/Data/Model/course/level.dart';
import 'package:messengersofpeace/Ui/Screen/My/MyCertificates/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Meeting/AllMeetings/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Course/AllCourses/controller/controller.dart';

String function(String endpoint) =>
    Uri.parse(endpoint).queryParameters['wsfunction']!;
http.Response response(Object value) => http.Response(jsonEncode(value), 200);
GetxController create(String kind) => switch (kind) {
  'certificates' => Get.put<MyCertificatesController>(
    MyCertificatesController(),
  ),
  'meetings' => Get.put<AllMeetingsController>(AllMeetingsController()),
  _ => Get.put<AllCoursesController>(AllCoursesController()),
};
Future<void> load(GetxController controller) =>
    (controller as dynamic).getData() as Future<void>;
int count(GetxController controller) => switch (controller) {
  MyCertificatesController c => c.certificates.length,
  AllMeetingsController c => c.allMeetings.length,
  AllCoursesController c => c.levels.length,
  _ => -1,
};
Object payload(http.Request request, String owner) {
  final method = request.url.queryParameters['wsfunction'];
  if (method == function(DBEndPointX.postGetMyCertificates)) {
    return [
      {
        NameX.certificateName: owner,
        NameX.courseName: 'Fixture',
        NameX.shareUrl: '',
        NameX.downloadUrl: '',
        NameX.issuedDate: '2026-10-01',
      },
    ];
  }
  if (method == function(DBEndPointX.postMyCourses)) return [];
  if (method == function(DBEndPointX.postGetLevelsWithCourses)) {
    return [
      LevelX(
        id: owner,
        name: owner,
        totalCourses: 0,
        completedCourses: 0,
        completionPercent: 0,
        isOpen: false,
        isCompleted: false,
        courses: [],
      ).toJson(),
    ];
  }
  return {
    NameX.meetings: [
      {
        NameX.id: owner,
        NameX.courseId: 'fixture',
        NameX.name: owner,
        NameX.description: '',
        NameX.lecturer: '',
        NameX.datetime: 1700000000,
        NameX.day: '',
        NameX.date: '',
        NameX.timeRange: '',
        NameX.type: '',
        NameX.location: '',
        NameX.url: '',
        NameX.status: '',
      },
    ],
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tmp;
  setUpAll(() async {
    tmp = await Directory.systemTemp.createTemp('mopa-counterpart-session-');
    Hive.init(tmp.path);
    HiveX.box = await Hive.openBox('synthetic');
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
    await tmp.delete(recursive: true);
  });
  for (final kind in ['certificates', 'meetings', 'courses']) {
    test(
      '$kind anonymous loader sends zero requests and clears owned data',
      () async {
        final c = create(kind);
        var calls = 0;
        await http.runWithClient(
          () async {
            await load(c);
            await LocalDataX.remove(LocalKeyX.userid);
            calls = 0;
            await load(c);
            expect(calls, 0);
            expect(count(c), 0);
          },
          () => MockClient((request) async {
            calls++;
            return response(payload(request, 'synthetic-A'));
          }),
        );
      },
    );
    for (final abandoned in ['session', 'locale', 'disposal']) {
      test(
        '$kind ignores $abandoned continuation before follow-up or publication',
        () async {
          final c = create(kind);
          final pending = Completer<http.Response>();
          final started = Completer<void>();
          var calls = 0;
          await http.runWithClient(
            () async {
              final work = load(c);
              await started.future;
              if (abandoned == 'session') {
                await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
              } else if (abandoned == 'locale') {
                Get.locale = const Locale('es');
              } else {
                if (c is MyCertificatesController) {
                  Get.delete<MyCertificatesController>();
                } else if (c is AllMeetingsController) {
                  Get.delete<AllMeetingsController>();
                } else {
                  Get.delete<AllCoursesController>();
                }
              }
              pending.complete(response(payloadForFirst(kind, 'obsolete')));
              try {
                await work;
              } catch (_) {
                /* Numeric assertions below distinguish retired work without dumping errors. */
              }
              expect(calls, 1);
              expect(count(c), 0);
            },
            () => MockClient((request) async {
              calls++;
              if (calls == 1) {
                started.complete();
                return pending.future;
              }
              return response(payload(request, 'obsolete'));
            }),
          );
        },
      );
    }
  }
  for (final kind in ['certificates', 'meetings']) {
    test(
      '$kind publishes an atomic snapshot and retires a pending second stage',
      () async {
        final c = create(kind);
        final pending = Completer<http.Response>();
        final started = Completer<void>();
        var calls = 0;
        var interim = -1;
        await http.runWithClient(
          () async {
            final work = load(c);
            await started.future;
            interim = count(c);
            await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
            pending.complete(
              response(kind == 'certificates' ? [] : {NameX.meetings: []}),
            );
            try {
              await work;
            } catch (_) {}
            expect(interim, 0);
            expect(count(c), 0);
            expect(calls, 2);
          },
          () => MockClient((request) async {
            calls++;
            if (calls == 2) {
              started.complete();
              return pending.future;
            }
            return response(payload(request, 'obsolete'));
          }),
        );
      },
    );
    test('$kind releases its tab notifier on controller disposal', () async {
      final c = create(kind);
      final notifier = (c as dynamic).tabController as ValueNotifier<int>;
      if (c is MyCertificatesController) {
        await Get.delete<MyCertificatesController>();
      } else {
        await Get.delete<AllMeetingsController>();
      }
      expect(() => notifier.addListener(() {}), throwsFlutterError);
    });
  }
}

Object payloadForFirst(String kind, String owner) {
  if (kind == 'certificates') {
    return [
      {
        NameX.certificateName: owner,
        NameX.courseName: 'Fixture',
        NameX.shareUrl: '',
        NameX.downloadUrl: '',
        NameX.issuedDate: '2026-10-01',
      },
    ];
  }
  if (kind == 'courses') {
    return [
      LevelX(
        id: owner,
        name: owner,
        totalCourses: 0,
        completedCourses: 0,
        completionPercent: 0,
        isOpen: false,
        isCompleted: false,
        courses: [],
      ).toJson(),
    ];
  }
  return {
    NameX.meetings: [
      {
        NameX.id: owner,
        NameX.courseId: 'fixture',
        NameX.name: owner,
        NameX.description: '',
        NameX.lecturer: '',
        NameX.datetime: 1700000000,
        NameX.day: '',
        NameX.date: '',
        NameX.timeRange: '',
        NameX.type: '',
        NameX.location: '',
        NameX.url: '',
        NameX.status: '',
      },
    ],
  };
}
