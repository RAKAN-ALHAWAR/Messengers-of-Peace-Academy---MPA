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
import 'package:messengersofpeace/Data/Model/event.dart';
import 'package:messengersofpeace/Ui/Screen/Events/CalendarEvents/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Events/EventDetails/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Events/EventDetails/view/view.dart';

String function(String endpoint) =>
    Uri.parse(endpoint).queryParameters['wsfunction']!;
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-calendar-return-');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('synthetic-return');
    HttpX.init();
  });
  setUp(() async {
    Get.testMode = true;
    await LocalDataX.put(LocalKeyX.userid, 'synthetic-user');
    await LocalDataX.put(LocalKeyX.token, 'synthetic-token');
  });
  tearDown(() => Get.reset());
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });
  for (final edited in [true, false]) {
    testWidgets(
      edited
          ? 'acknowledged edit then native Back refreshes calendar once'
          : 'unchanged toolbar Back skips calendar refresh',
      (tester) async {
        late CalendarController calendar;
        var acknowledged = false;
        var refreshes = 0;
        var detailLoads = 0;
        final original = EventX.fromJson(eventData('Original event'));
        await http.runWithClient(
          () async {
            await tester.pumpWidget(
              GetMaterialApp(
                locale: const Locale('en'),
                initialRoute: '/',
                getPages: [
                  GetPage(
                    name: '/',
                    page:
                        () => Scaffold(
                          body: TextButton(
                            onPressed: () => calendar.onOpenEvent(original),
                            child: const Text('Open event'),
                          ),
                        ),
                    binding: BindingsBuilder(() {
                      calendar = Get.put(CalendarController());
                      calendar.events.value = [original];
                    }),
                  ),
                  GetPage(
                    name: RouteNameX.eventDetails,
                    page: () => const EventDetailsView(),
                    binding: BindingsBuilder(() {
                      Get.put<EventDetailsController>(EventDetailsController());
                    }),
                  ),
                  GetPage(
                    name: RouteNameX.editEvent,
                    page:
                        () => Scaffold(
                          body: TextButton(
                            onPressed: () {
                              acknowledged = true;
                              Get.back(result: true);
                            },
                            child: const Text('Acknowledge synthetic edit'),
                          ),
                        ),
                  ),
                ],
              ),
            );
            await tester.pumpAndSettle();
            await tester.tap(find.text('Open event'));
            await tester.pumpAndSettle();
            if (edited) {
              await tester.tap(find.byIcon(Icons.edit));
              await tester.pumpAndSettle();
              await tester.tap(find.text('Acknowledge synthetic edit'));
              await tester.pumpAndSettle();
              expect(find.text('Edited event'), findsOneWidget);
              expect(detailLoads, 2);
              Get.back();
            } else {
              await tester.tap(find.byIcon(Icons.arrow_back));
            }
            await tester.pumpAndSettle();
            expect(Get.currentRoute, '/');
            expect(refreshes, edited ? 1 : 0);
            expect(
              calendar.events.single.name,
              edited ? 'Edited event' : 'Original event',
            );
            await tester.pumpWidget(const SizedBox());
          },
          () => MockClient((request) async {
            if (request.url.queryParameters['wsfunction'] ==
                function(DBEndPointX.postGetEvents)) {
              refreshes++;
              return http.Response(
                jsonEncode([
                  eventData(acknowledged ? 'Edited event' : 'Original event'),
                ]),
                200,
              );
            }
            detailLoads++;
            return http.Response(
              jsonEncode(
                eventData(acknowledged ? 'Edited event' : 'Original event'),
              ),
              200,
            );
          }),
        );
      },
    );
  }
}
