import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Model/event.dart';
import 'package:messengersofpeace/Ui/Screen/Events/CalendarEvents/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Events/EventDetails/controller/controller.dart';
import 'package:messengersofpeace/Ui/Widget/Basic/Input/text_field_time.dart';
import 'package:messengersofpeace/Ui/Widget/Custom/Card/event_card.dart';

EventX eventAt(String id, DateTime start) => EventX(
  id: id,
  name: id,
  description: '',
  location: '',
  timeStart: start.millisecondsSinceEpoch ~/ 1000,
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-calendar-tests-');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('synthetic-calendar');
  });
  tearDown(() => Get.reset());
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  testWidgets(
    'picker, day taps and week arrows filter the selected civil day',
    (tester) async {
      Get.testMode = true;
      Get.locale = const Locale('en');
      final controller = Get.put(CalendarController());
      final first = DateTime(2026, 7, 12);
      final picked = DateTime(2026, 7, 13);
      controller.events.value = [
        eventAt('first', first.add(const Duration(hours: 8))),
        eventAt('picked-noon', picked.add(const Duration(hours: 12))),
        eventAt('picked-midnight', picked),
        eventAt('next-week', DateTime(2026, 7, 20, 12)),
      ];
      await tester.pumpWidget(
        GetMaterialApp(home: const Scaffold(body: SizedBox())),
      );
      controller.selectDay(first);
      expect(controller.eventsOfDay.map((event) => event.id), ['first']);
      Get.bottomSheet(const SizedBox(height: 100));
      await tester.pumpAndSettle();
      controller.onChangeDateFromPicker(picked);
      await tester.pumpAndSettle();
      expect(controller.eventsOfDay.map((event) => event.id), [
        'picked-noon',
        'picked-midnight',
      ]);
      expect(controller.getEventByHour(12).single.id, 'picked-noon');
      expect(controller.getEventByHour(0).single.id, 'picked-midnight');
      expect(controller.weekDays.any((day) => day == picked), isTrue);
      expect(Get.isBottomSheetOpen, isFalse);
      controller.onNextWeek();
      expect(controller.selectedDate.value, DateTime(2026, 7, 20));
      expect(controller.eventsOfDay.single.id, 'next-week');
      controller.onPreviousWeek();
      expect(controller.selectedDate.value, picked);
      expect(controller.eventsOfDay.length, 2);
      controller.selectDay(first);
      expect(controller.eventsOfDay.single.id, 'first');
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'calendar, event card and event detail distinguish noon and midnight',
    (tester) async {
      Get.testMode = true;
      Get.locale = const Locale('en');
      final calendar = Get.put(CalendarController());
      final fixture = eventAt('synthetic', DateTime(2026, 7, 12, 12));
      final card = EventCard(event: fixture, color: Colors.blue, onTap: (_) {});
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/',
          getPages: [
            GetPage(name: '/', page: () => const Scaffold(body: SizedBox())),
            GetPage(
              name: '/detail',
              page: () => const Scaffold(body: SizedBox()),
              binding: BindingsBuilder(() {
                Get.put(EventDetailsController());
              }),
            ),
          ],
        ),
      );
      Get.toNamed('/detail', arguments: fixture);
      await tester.pumpAndSettle();
      final details = Get.find<EventDetailsController>();
      for (final entry
          in {
            0: '12:00 AM',
            11: '11:00 AM',
            12: '12:00 PM',
            13: '01:00 PM',
            23: '11:00 PM',
          }.entries) {
        final date = DateTime(2026, 7, 12, entry.key);
        expect(calendar.getHourShow(entry.key), entry.value);
        expect(card.getTimeShow(date), entry.value);
        expect(details.getTimeShow(date), entry.value);
      }
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('time fields initialize noon and midnight correctly', (
    tester,
  ) async {
    for (final hour in [0, 12, 13]) {
      final text = TextEditingController();
      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: TextFieldTimeX(
              key: ValueKey(hour),
              controller: text,
              hint: 'Synthetic time',
              initialTime: TimeOfDay(hour: hour, minute: 15),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        text.text,
        hour == 0
            ? '12:15 AM'
            : hour == 12
            ? '12:15 PM'
            : '01:15 PM',
      );
      await tester.pumpWidget(const SizedBox());
      text.dispose();
    }
  });
}
