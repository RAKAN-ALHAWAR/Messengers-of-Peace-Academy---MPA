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
import 'package:messengersofpeace/Core/Helper/http/http.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Database/config/database_end_point.dart';
import 'package:messengersofpeace/Data/Enum/event_option.dart';
import 'package:messengersofpeace/Data/Model/event.dart';
import 'package:messengersofpeace/Ui/Screen/Events/CalendarEvents/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Events/EventDetails/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Events/EventDetails/view/view.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

String function(String endpoint) =>
    Uri.parse(endpoint).queryParameters['wsfunction']!;
final event = EventX(
  id: 'synthetic-event',
  name: 'Synthetic deletable event',
  description: 'Fixture',
  location: 'Fixture',
  timeStart: 1700000000,
  timeDuration: 3600,
  courseId: null,
  instance: 0,
  source: 'user',
  meetingUrl: '',
  isNow: false,
  isRepeated: false,
  repeatCount: 0,
  endTime: null,
  userId: 'synthetic-user',
);

class FixtureEventController extends EventDetailsController {
  @override
  Future<void> getData() async {
    isShowActions.value = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late CalendarController calendar;
  late EventDetailsController details;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-delete-tests-');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('synthetic-delete');
    HttpX.init();
  });
  setUp(() async {
    Get.testMode = true;
    await LocalDataX.put(LocalKeyX.userid, 'synthetic-user');
    await LocalDataX.put(LocalKeyX.token, 'synthetic-token');
  });
  tearDown(() {
    ToastX.dismiss();
    Get.reset();
  });
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });
  Future<void> mount(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('en'),
        initialRoute: '/',
        getPages: [
          GetPage(
            name: '/',
            page: () => const Scaffold(body: Text('Underlying sentinel')),
          ),
          GetPage(
            name: '/replacement',
            page: () => const Scaffold(body: Text('Unrelated replacement')),
          ),
          GetPage(
            name: '/calendar-probe',
            page:
                () => Scaffold(
                  body: TextButton(
                    onPressed: () => calendar.onOpenEvent(event),
                    child: const Text('Open event'),
                  ),
                ),
            binding: BindingsBuilder(() {
              calendar = Get.put(CalendarController());
              calendar.events.value = [event];
            }),
          ),
          GetPage(
            name: RouteNameX.eventDetails,
            page: () => const EventDetailsView(),
            binding: BindingsBuilder(() {
              details = Get.put<EventDetailsController>(
                FixtureEventController(),
              );
            }),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    Get.toNamed('/calendar-probe');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open event'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();
  }

  for (final accepted in [true, false]) {
    testWidgets(
      '${accepted ? 'accepted' : 'rejected'} delete closes only owned routes and refreshes on success',
      (tester) async {
        var deletes = 0;
        var refreshes = 0;
        await http.runWithClient(
          () async {
            await mount(tester);
            await tester.tap(find.text('Delete this event only'));
            await tester.pumpAndSettle();
            expect(deletes, 1);
            if (accepted) {
              expect(Get.currentRoute, '/calendar-probe');
              expect(Get.isBottomSheetOpen, false);
              expect(refreshes, 1);
              expect(calendar.events, isEmpty);
              Get.back();
              await tester.pumpAndSettle();
              expect(find.text('Underlying sentinel'), findsOneWidget);
            } else {
              expect(Get.currentRoute, RouteNameX.eventDetails);
              expect(Get.isBottomSheetOpen, true);
              expect(refreshes, 0);
              expect(calendar.events.single.id, event.id);
              expect(details.isChanged.value, false);
              await tester.pump(const Duration(seconds: 4));
            }
            ToastX.dismiss();
            await tester.pumpWidget(const SizedBox());
          },
          () => MockClient((request) async {
            if (request.url.queryParameters['wsfunction'] ==
                function(DBEndPointX.postDeleteEvent)) {
              deletes++;
              return http.Response(
                jsonEncode({
                  'status': accepted ? 'success' : 'failed',
                  'message': 'Synthetic acknowledgement',
                }),
                200,
              );
            }
            refreshes++;
            return http.Response('[]', 200);
          }),
        );
      },
    );
  }
  testWidgets(
    'deletion abandoned with its detail never pops the replacement route',
    (tester) async {
      final pending = Completer<http.Response>();
      var deletes = 0;
      await http.runWithClient(
        () async {
          await mount(tester);
          final deletion = details.onDeleteEvent(EventOptionEX.single);
          await tester.pump();
          expect(deletes, 1);
          Get.back();
          await tester.pumpAndSettle();
          Get.back();
          await tester.pumpAndSettle();
          expect(Get.currentRoute, '/calendar-probe');
          pending.complete(http.Response('{"status":"success"}', 200));
          await deletion;
          await tester.pumpAndSettle();
          expect(Get.currentRoute, '/calendar-probe');
          expect(details.isChanged.value, false);
          ToastX.dismiss();
          await tester.pumpWidget(const SizedBox());
        },
        () => MockClient((request) {
          deletes++;
          return pending.future;
        }),
      );
    },
  );
  testWidgets(
    'duplicate deletion taps share one request and accepted deletion cannot replay',
    (tester) async {
      final pending = Completer<http.Response>();
      var requests = 0;
      await http.runWithClient(
        () async {
          await mount(tester);
          final first = details.onDeleteEvent(EventOptionEX.single);
          final duplicate = details.onDeleteEvent(EventOptionEX.future);
          final third = details.onDeleteEvent(EventOptionEX.all);
          await tester.pump();
          expect(requests, 1);
          expect(await duplicate, isFalse);
          expect(await third, isFalse);
          expect(details.isLoading.value, isTrue);
          pending.complete(http.Response('{"status":"success"}', 200));
          expect(await first, isTrue);
          expect(await details.onDeleteEvent(EventOptionEX.single), isFalse);
          expect(requests, 1);
          ToastX.dismiss();
          await tester.pumpWidget(const SizedBox());
        },
        () => MockClient((request) {
          requests++;
          return pending.future;
        }),
      );
    },
  );

  testWidgets('a dismissed delete sheet cannot pop a later unrelated page', (
    tester,
  ) async {
    final pending = Completer<http.Response>();
    var deletes = 0;
    var refreshes = 0;
    await http.runWithClient(
      () async {
        await mount(tester);
        await tester.tap(find.text('Delete this event only'));
        await tester.pump();
        expect(deletes, 1);
        Get.back();
        await tester.pumpAndSettle();
        Get.toNamed('/replacement');
        await tester.pumpAndSettle();
        pending.complete(http.Response('{"status":"success"}', 200));
        await tester.pumpAndSettle();
        expect(Get.currentRoute, '/replacement');
        expect(find.text('Unrelated replacement'), findsOneWidget);
        expect(refreshes, 1);
        Get.back();
        await tester.pumpAndSettle();
        expect(Get.currentRoute, '/calendar-probe');
        expect(calendar.events, isEmpty);
        ToastX.dismiss();
        await tester.pumpWidget(const SizedBox());
      },
      () => MockClient((request) {
        if (request.url.queryParameters['wsfunction'] ==
            function(DBEndPointX.postDeleteEvent)) {
          deletes++;
          return pending.future;
        }
        refreshes++;
        return Future.value(http.Response('[]', 200));
      }),
    );
  });
}
