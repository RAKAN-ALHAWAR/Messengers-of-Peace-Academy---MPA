import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Core/Helper/http/http.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Model/user/user.dart';
import 'package:messengersofpeace/Ui/Screen/Test/TestResults/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Test/TestResults/view/view.dart';
import 'quiz_flow_test.dart' show QuizHarness;
import 'result_integrity_test.dart' show resultJson, answerJson;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late QuizHarness h;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-quiz-visuals-');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('app');
    HttpX.init();
  });
  setUp(() async {
    Get.testMode = true;
    await HiveX.box.clear();
    await HiveX.box.put('userid', 'synthetic-user');
    await HiveX.box.put('token', 'synthetic-token');
    Get.put(
      AppControllerX()
        ..user = UserX(
          id: 'synthetic-user',
          username: 'synthetic',
          firstname: 'Test',
          lastname: 'User',
          email: 'test@example.invalid',
          lang: 'en',
          customfields: [],
          city: '',
          image: '',
          points: 0,
        ).obs,
    );
    h = QuizHarness();
  });
  tearDown(() => Get.reset());
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  RadioButtonX<int> choice(WidgetTester tester, int slot, int index) =>
      tester.widget<RadioButtonX<int>>(
        find.byKey(ValueKey('result-choice-$slot-$index')),
      );

  Color? textColor(WidgetTester tester, String text) =>
      tester.widget<Text>(find.text(text)).style?.color;

  testWidgets('chosen answers are green or red and the labels match', (
    tester,
  ) async {
    // Slot 7 chosen right (index 1), slot 2 chosen wrong (index 0).
    h.results = resultJson(
      answers: [
        answerJson(7, selected: 1, right: true),
        answerJson(2, selected: 0, right: false),
      ],
    );
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await http.runWithClient(() async {
      await tester.pumpWidget(
        GetMaterialApp(
          locale: const Locale('en'),
          initialRoute: '/base',
          getPages: [
            GetPage(name: '/base', page: () => const Scaffold()),
            GetPage(
              name: RouteNameX.testResults,
              page: () => const TestResultsView(),
              binding: BindingsBuilder(() {
                Get.lazyPut(() => TestResultsController());
              }),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      Get.toNamed(
        RouteNameX.testResults,
        arguments: [
          h.quiz,
          'synthetic-quiz',
          h.attempt,
          <int?>[0, 1],
          10,
          'synthetic-course',
        ],
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      final theme = Theme.of(tester.element(find.byType(TestResultsView)));

      // right answer: success fill, success border, green label
      expect(choice(tester, 7, 1).color, ColorX.successContainer);
      expect(choice(tester, 7, 1).borderColor, ColorX.success);
      expect(textColor(tester, 'Correct answer'), ColorX.success);

      // wrong answer: error fill, error border, red label
      expect(choice(tester, 2, 0).color, theme.colorScheme.errorContainer);
      expect(choice(tester, 2, 0).borderColor, theme.colorScheme.error);
      expect(textColor(tester, 'Incorrect answer'), theme.colorScheme.error);

      // not chosen: neutral fill and no border colour
      expect(choice(tester, 7, 0).color, theme.colorScheme.onInverseSurface);
      expect(choice(tester, 7, 0).borderColor, isNull);

      // the question label stays grey
      expect(
        textColor(tester, 'Question 1 of 2'),
        theme.colorScheme.onSurfaceVariant,
      );
      expect(tester.takeException(), isNull);
    }, h.client);
  });
}
