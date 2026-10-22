import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:messengersofpeace/Config/Translation/translation.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Model/course/my_course.dart';
import 'package:messengersofpeace/Data/Model/my_certificate.dart';
import 'package:messengersofpeace/Data/Model/meeting.dart';
import 'package:messengersofpeace/Ui/Screen/My/MyCertificates/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/My/MyCertificates/view/view.dart';
import 'package:messengersofpeace/Ui/Screen/Meeting/AllMeetings/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Meeting/AllMeetings/view/view.dart';
import 'package:messengersofpeace/Ui/Widget/Basic/Utils/future_builder.dart';
import 'package:messengersofpeace/Ui/Widget/Custom/Card/certificate_card.dart';
import 'package:messengersofpeace/Ui/Widget/Custom/Card/meeting_card.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

MyCourse course(int i) => MyCourse(
  id: '$i',
  fullName: 'Course $i',
  lang: 'en',
  image: '',
  totalSections: 1,
  completedSections: 0,
  completionPercent: 0,
  enrolled: true,
);
MyCertificate certificate(String name) => MyCertificate(
  name: name,
  courseName: 'Synthetic course',
  shareUrl: '',
  downloadUrl: '',
  issuedDate: '2026-10-01',
);
MeetingX meeting(String name) => MeetingX(
  id: name,
  courseId: 'synthetic',
  name: name,
  description: '',
  lecturer: '',
  datetime: DateTime(2027),
  day: '',
  date: '',
  timeRange: '12 PM',
  type: '',
  location: '',
  url: '',
  status: '',
);

class Certificates extends MyCertificatesController {
  Certificates(this.count);
  final int count;
  @override
  Future<void> getData() async {
    courses = List.generate(count, course);
    certificates = List.generate(
      count,
      (i) => certificate('${LocalDataX.userid} certificate $i'),
    );
    isLoading.value = false;
  }
}

class Meetings extends AllMeetingsController {
  Meetings(this.count);
  final int count;
  @override
  Future<void> getData() async {
    allMeetings = List.generate(
      count,
      (i) => meeting('${LocalDataX.userid} meeting $i'),
    );
    selectedMeetings.assignAll(allMeetings);
    isLoading.value = false;
  }
}

Widget host(Widget child, {String locale = 'en', double scale = 1}) =>
    GetMaterialApp(
      locale: Locale(locale),
      translations: TranslationX(),
      supportedLocales: TranslationX.locales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      builder:
          (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
      home: child,
    );
void viewport(WidgetTester tester, double width) {
  tester.view.physicalSize = Size(width, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory tmp;
  setUpAll(() async {
    tmp = await Directory.systemTemp.createTemp('mopa-counterparts-');
    Hive.init(tmp.path);
    HiveX.box = await Hive.openBox('synthetic');
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
  for (final count in [0, 1, 20, 100, 1000]) {
    for (final kind in ['certificates', 'grades', 'meetings']) {
      testWidgets('$kind mounts bounded rows for $count records', (
        tester,
      ) async {
        viewport(tester, 400);
        late Widget view;
        late Type row;
        if (kind == 'meetings') {
          Get.put<AllMeetingsController>(Meetings(count));
          view = const AllMeetingsView();
          row = MeetingCardX;
        } else {
          final c = Get.put<MyCertificatesController>(Certificates(count));
          if (kind == 'certificates') c.tabController.value = 2;
          view = const MyCertificatesView();
          row =
              kind == 'certificates'
                  ? CertificateCard
                  : CircularPercentIndicator;
        }
        final errors = <FlutterErrorDetails>[];
        final previous = FlutterError.onError;
        FlutterError.onError = errors.add;
        try {
          await tester.pumpWidget(host(view));
          await tester.pumpAndSettle();
        } finally {
          FlutterError.onError = previous;
        }
        final mounted = find.byType(row).evaluate().length;
        // Numeric synthetic diagnostics are intentionally free of request data.
        debugPrint(
          'COUNTERPART kind=$kind records=$count mounted=$mounted layoutErrors=${errors.length}',
        );
        expect(errors.length, 0);
        expect(mounted, lessThanOrEqualTo(16));
        if (count > 0) expect(mounted, greaterThan(0));
        await tester.pumpWidget(const SizedBox());
      });
    }
  }
  for (final kind in ['certificates', 'meetings']) {
    testWidgets(
      '$kind keeps its session observer after load and replaces account rows',
      (tester) async {
        viewport(tester, 400);
        late Widget view;
        if (kind == 'certificates') {
          final c = Get.put<MyCertificatesController>(Certificates(1));
          c.tabController.value = 2;
          view = const MyCertificatesView();
        } else {
          Get.put<AllMeetingsController>(Meetings(1));
          view = const AllMeetingsView();
        }
        await tester.pumpWidget(host(view));
        await tester.pumpAndSettle();
        expect(find.byType(FutureBuilderX<void>), findsOneWidget);
        await tester.runAsync(() async {
          await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
          await HiveX.box.flush();
        });
        await tester.pumpAndSettle();
        expect(
          find.text(
            'synthetic-A ${kind == 'certificates' ? 'certificate' : 'meeting'} 0',
          ),
          findsNothing,
        );
        expect(
          find.text(
            'synthetic-B ${kind == 'certificates' ? 'certificate' : 'meeting'} 0',
          ),
          findsOneWidget,
        );
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
  for (final locale in ['ar', 'en', 'es', 'fil']) {
    for (final width in [320.0, 400.0]) {
      for (final scale in [1.0, 2.0]) {
        testWidgets(
          'certificate actions fit $locale width$width scale$scale with callbacks',
          (tester) async {
            viewport(tester, width);
            var downloads = 0;
            var shares = 0;
            await tester.pumpWidget(
              host(
                Scaffold(
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: CertificateCard(
                        certificate: certificate(
                          'A complete certificate title',
                        ),
                        onDownloadCertificate: (_) => downloads++,
                        onShareCertificate: (_) => shares++,
                      ),
                    ),
                  ),
                ),
                locale: locale,
                scale: scale,
              ),
            );
            await tester.pumpAndSettle();
            expect(tester.takeException(), isNull);
            await tester.ensureVisible(find.text('Download'.tr));
            await tester.tap(find.text('Download'.tr));
            await tester.ensureVisible(find.text('Share'.tr));
            await tester.tap(find.text('Share'.tr));
            expect(downloads, 1);
            expect(shares, 1);
            await tester.pumpWidget(const SizedBox());
          },
        );
      }
    }
  }
}
