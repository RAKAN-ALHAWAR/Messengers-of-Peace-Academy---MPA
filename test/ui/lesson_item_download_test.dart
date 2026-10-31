import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Ui/Widget/Custom/Other/lesson_item_on_accordion.dart';

Future<void> _pump(
  WidgetTester tester, {
  bool isCompleted = false,
  bool showDownloadIcon = false,
  bool isDownloading = false,
  double? progress,
  TextDirection direction = TextDirection.ltr,
}) => tester.pumpWidget(
  MaterialApp(
    home: Directionality(
      textDirection: direction,
      child: Scaffold(
        body: LessonItemOnAccordion(
          icon: IconX.description,
          name: 'Summary',
          isCompleted: isCompleted,
          showDownloadIcon: showDownloadIcon,
          isDownloading: isDownloading,
          downloadProgress: progress,
        ),
      ),
    ),
  ),
);

void main() {
  final downloadIcon = find.byIcon(IconX.download);
  final checkIcon = find.byIcon(IconX.check);
  final ring = find.byType(CircularProgressIndicator);

  testWidgets('a file row not yet downloaded shows the download icon', (
    tester,
  ) async {
    await _pump(tester, showDownloadIcon: true);
    expect(downloadIcon, findsOneWidget);
    expect(checkIcon, findsNothing);
    expect(ring, findsNothing);
  });

  testWidgets('a running download shows the percent and a determinate ring', (
    tester,
  ) async {
    await _pump(
      tester,
      showDownloadIcon: true,
      isDownloading: true,
      progress: 0.456,
    );
    expect(find.text('45%'), findsOneWidget);
    final indicator = tester.widget<CircularProgressIndicator>(ring);
    expect(indicator.value, 0.456);
    expect(downloadIcon, findsNothing);
  });

  testWidgets('an unknown total shows an indeterminate ring, no percent', (
    tester,
  ) async {
    await _pump(tester, showDownloadIcon: true, isDownloading: true);
    expect(tester.widget<CircularProgressIndicator>(ring).value, isNull);
    expect(find.textContaining('%'), findsNothing);
    expect(downloadIcon, findsNothing);
  });

  testWidgets('the percent reads left to right inside an Arabic row', (
    tester,
  ) async {
    await _pump(
      tester,
      showDownloadIcon: true,
      isDownloading: true,
      progress: 0.07,
      direction: TextDirection.rtl,
    );
    expect(find.text('7%'), findsOneWidget);
  });

  testWidgets('done shows the checkmark and no download mark', (tester) async {
    await _pump(tester, showDownloadIcon: true, isCompleted: true);
    expect(checkIcon, findsOneWidget);
    expect(downloadIcon, findsNothing);
    expect(ring, findsNothing);
  });

  testWidgets('other rows (video, quiz) keep their look: no extra mark', (
    tester,
  ) async {
    await _pump(tester);
    expect(downloadIcon, findsNothing);
    expect(checkIcon, findsNothing);
    expect(ring, findsNothing);
    await _pump(tester, isCompleted: true);
    expect(checkIcon, findsOneWidget);
  });
}
