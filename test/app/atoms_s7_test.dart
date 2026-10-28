import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Core/Helper/http/http.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Model/event.dart';
import 'package:messengersofpeace/Data/Model/user/user.dart';
import 'package:messengersofpeace/Ui/Screen/Badges/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Blog/Blog/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Events/CalendarEvents/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Events/EventDetails/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Meeting/AllMeetings/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/My/MyAchievements/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/My/MyCertificates/controller/controller.dart';

//==============================================================================
// Fixtures

http.Response json(Object value) => http.Response(jsonEncode(value), 200);

Map<String, Object> eventData(String name) => {
  NameX.id: 'synthetic-event',
  NameX.name: name,
  NameX.location: 'Synthetic location',
  NameX.source: 'user',
  NameX.userId: 'synthetic-user',
  NameX.isnow: false,
  NameX.startTime: 1700000000,
  NameX.description: 'Synthetic description',
};

UserX user(String id) => UserX.fromJson({
  NameX.id: id,
  NameX.username: id,
  NameX.email: 'test@example.invalid',
  NameX.points: 0,
});

/// Answers with a held reply for the first [held] requests, then at once.
MockClient heldClient(
  List<Completer<http.Response>> log, {
  int held = 1,
  Object later = const [],
}) => MockClient((request) {
  if (log.length < held) {
    final reply = Completer<http.Response>();
    log.add(reply);
    return reply.future;
  }
  log.add(Completer<http.Response>()..complete(json(later)));
  return log.last.future;
});

Future<void> flush() async {
  for (var i = 0; i < 5; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

class SilentBlogController extends BlogController {
  @override
  void onClose() {}
}

class SpyCalendarController extends CalendarController {
  int loads = 0;
  @override
  Future<void> getData({bool isMust = false}) async => loads++;
}

class SpyEventController extends EventDetailsController {
  int loads = 0;
  @override
  Future<void> getData() async => loads++;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-atoms-s7-');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('synthetic-atoms-s7');
    HttpX.init();
  });
  setUp(() async {
    Get.testMode = true;
    Get.locale = const Locale('en');
    await LocalDataX.put(LocalKeyX.userid, 'synthetic-user');
    await LocalDataX.put(LocalKeyX.token, 'synthetic-token');
  });
  tearDown(() => Get.reset());
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  //============================================================================
  // Blog: closed

  // BlogController.onClose bumps the generation, which alone retires a disposed
  // load; this controller skips that bump so only the closed atom is left.
  test('blog getData retires a response that arrives after disposal', () async {
    final blog = Get.put<BlogController>(SilentBlogController());
    final log = <Completer<http.Response>>[];
    await http.runWithClient(() async {
      final work = blog.getData();
      await flush();
      await Get.delete<BlogController>(force: true);
      log.single.complete(
        json({
          'entries': [
            {
              'id': 1,
              'subject': 'Retired',
              'summary': '',
              'tags': [],
              'attachmentfiles': [],
            },
          ],
          'totalentries': 1,
        }),
      );
      expect(await work, isEmpty);
      expect(blog.blogs, isEmpty);
    }, () => heldClient(log));
  });

  //============================================================================
  // Meetings and certificates: generation

  for (final kind in ['meetings', 'certificates']) {
    test('$kind newer load retires the older before its follow-up', () async {
      final Future<void> Function() load =
          kind == 'meetings'
              ? Get.put(AllMeetingsController()).getData
              : Get.put(MyCertificatesController()).getData;
      final log = <Completer<http.Response>>[];
      final Object empty = kind == 'meetings' ? {NameX.meetings: []} : [];
      await http.runWithClient(() async {
        final first = load();
        final second = load();
        await flush();
        expect(log, hasLength(2));
        log.first.complete(json(empty));
        await flush();
        // The older load stopped after its first answer: no third request.
        expect(log, hasLength(2));
        log.last.complete(json(empty));
        await Future.wait([first, second]);
      }, () => heldClient(log, held: 2, later: empty));
    });
  }

  //============================================================================
  // MyAchievements: app instance replaced

  test('achievements retire a pending load when the app is replaced', () async {
    Get.put<AppControllerX>(AppControllerX()..user = user('synthetic-user').obs);
    final achievements = Get.put(MyAchievementsController());
    final log = <Completer<http.Response>>[];
    await http.runWithClient(() async {
      final work = achievements.getData();
      await flush();
      await Get.delete<AppControllerX>(force: true);
      Get.put<AppControllerX>(
        AppControllerX()..user = user('synthetic-user').obs,
      );
      log.single.complete(json([]));
      await work;
      // Same user id on the new app is not enough: the old app is retired.
      expect(log, hasLength(1));
    }, () => heldClient(log));
  });

  //============================================================================
  // Badges: no app controller registered yet

  test('badges with no registered app controller load nothing', () async {
    final badges = Get.put(BadgesController());
    var requests = 0;
    await http.runWithClient(
      () async {
        expect(await badges.getData(), isEmpty);
        expect(requests, 0);
      },
      () => MockClient((request) async {
        requests++;
        return json([]);
      }),
    );
  });

  //============================================================================
  // EventDetails: getData

  Future<EventDetailsController> openDetails(WidgetTester tester) async {
    late EventDetailsController details;
    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('en'),
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => const Scaffold(body: Text('root'))),
          GetPage(
            name: RouteNameX.eventDetails,
            page: () => const Scaffold(body: Text('details')),
            binding: BindingsBuilder(() {
              details = Get.put<EventDetailsController>(
                EventDetailsController(),
              );
            }),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    Get.toNamed(
      RouteNameX.eventDetails,
      arguments: EventX.fromJson(eventData('Original')),
    );
    await tester.pumpAndSettle();
    return details;
  }

  for (final retired in ['disposal', 'newer load', 'locale']) {
    testWidgets('event details retire a stale answer after $retired', (
      tester,
    ) async {
      final log = <Completer<http.Response>>[];
      await http.runWithClient(
        () async {
          final details = await openDetails(tester);
          final first = details.getData();
          if (retired == 'newer load') details.getData();
          await tester.pump();
          if (retired == 'disposal') {
            await Get.delete<EventDetailsController>(force: true);
          } else if (retired == 'locale') {
            Get.locale = const Locale('es');
          }
          log.first.complete(json(eventData('Stale')));
          await tester.pump();
          await first;
          expect(details.eventDetails.value.name, 'Original');
          if (retired == 'newer load') {
            log.last.complete(json(eventData('Newest')));
            await tester.pump();
            expect(details.eventDetails.value.name, 'Newest');
          }
        },
        () => heldClient(log, held: retired == 'newer load' ? 2 : 1),
      );
    });
  }

  //============================================================================
  // Return from a pushed screen after the controller was disposed

  Future<void> mountPages(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('en'),
        initialRoute: '/',
        getPages: [
          GetPage(name: '/', page: () => const Scaffold(body: Text('root'))),
          for (final name in [
            RouteNameX.addEvent,
            RouteNameX.eventDetails,
            RouteNameX.editEvent,
          ])
            GetPage(name: name, page: () => const Scaffold(body: Text('page'))),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final disposed in [false, true]) {
    final tail = disposed ? 'after disposal' : 'while open';
    testWidgets('calendar add-event return $tail', (tester) async {
      await mountPages(tester);
      final calendar = SpyCalendarController();
      Get.put<CalendarController>(calendar);
      final done = calendar.onAddEvent();
      await tester.pumpAndSettle();
      if (disposed) await Get.delete<CalendarController>(force: true);
      Get.back(result: true);
      await tester.pumpAndSettle();
      await done;
      expect(calendar.loads, disposed ? 0 : 1);
    });
    testWidgets('calendar open-event return $tail', (tester) async {
      await mountPages(tester);
      final calendar = SpyCalendarController();
      Get.put<CalendarController>(calendar);
      calendar.onOpenEvent(EventX.fromJson(eventData('Opened')));
      await tester.pumpAndSettle();
      if (disposed) await Get.delete<CalendarController>(force: true);
      Get.back(result: true);
      await tester.pumpAndSettle();
      expect(calendar.loads, disposed ? 0 : 1);
    });
    testWidgets('event details edit return $tail', (tester) async {
      late SpyEventController details;
      await tester.pumpWidget(
        GetMaterialApp(
          locale: const Locale('en'),
          initialRoute: '/',
          getPages: [
            GetPage(name: '/', page: () => const Scaffold(body: Text('root'))),
            GetPage(
              name: RouteNameX.eventDetails,
              page: () => const Scaffold(body: Text('details')),
              binding: BindingsBuilder(() {
                details = SpyEventController();
                Get.put<EventDetailsController>(details);
              }),
            ),
            GetPage(
              name: RouteNameX.editEvent,
              page: () => const Scaffold(body: Text('edit')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      Get.toNamed(
        RouteNameX.eventDetails,
        arguments: EventX.fromJson(eventData('Original')),
      );
      await tester.pumpAndSettle();
      details.onEdit();
      await tester.pumpAndSettle();
      if (disposed) await Get.delete<EventDetailsController>(force: true);
      Get.back(result: true);
      await tester.pumpAndSettle();
      expect(details.isChanged.value, !disposed);
      expect(details.loads, disposed ? 0 : 1);
    });
  }
}
