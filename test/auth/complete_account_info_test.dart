import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image_picker/image_picker.dart';
import 'package:messengersofpeace/Config/config.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Core/Error/error.dart';
import 'package:messengersofpeace/Core/Helper/http/http.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Model/user/user.dart';
import 'package:messengersofpeace/Ui/Screen/Auth/CompleteAccountInfo/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Auth/CompleteAccountInfo/view/view.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late CompleteAccountInfoController controller;
  late List<http.Request> requests;

  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-completion-test-');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('app');
    HttpX.init();
  });
  setUp(() async {
    Get.testMode = true;
    await HiveX.box.clear();
    await HiveX.box.put('userid', 'synthetic-user');
    await HiveX.box.put('token', 'synthetic-token');
    requests = [];
    Get.put(
      AppControllerX()
        ..user =
            UserX(
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
    controller = Get.put(CompleteAccountInfoController());
  });
  tearDown(() {
    ToastX.dismiss();
    Get.reset();
  });
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  Future<http.Response> referenceResponse(http.Request request) async {
    requests.add(request);
    // Every HTTP call is intercepted; fixtures never contain service credentials.
    final function = request.url.queryParameters['wsfunction'] ?? '';
    if (function.toLowerCase().contains('countr')) {
      return http.Response(
        jsonEncode([
          {'code': 'SA', 'name': 'Saudi Arabia', 'dial_code': '+966'},
        ]),
        200,
      );
    }
    if (function.toLowerCase().contains('lang')) {
      return http.Response(
        jsonEncode([
          {'code': 'en', 'name': 'English'},
        ]),
        200,
      );
    }
    return http.Response('{"status":"success","message":"Saved"}', 200);
  }

  Future<void> mount(WidgetTester tester, {bool dark = false}) async {
    await tester.pumpWidget(
      GetMaterialApp(
        locale: const Locale('en'),
        theme: ThemeData(brightness: dark ? Brightness.dark : Brightness.light),
        initialRoute: '/completion-test',
        getPages: [
          GetPage(
            name: '/completion-test',
            page: () => const CompleteAccountInfoView(),
          ),
          GetPage(
            name: RouteNameX.root,
            page: () => const Scaffold(body: Text('Root destination')),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  void validValues() {
    controller.birthDate = DateTime(1990);
    controller.dateOfBirth.text = 'Chosen date';
    controller.whatsapp.text = '501234567';
    controller.city.text = 'Damascus';
    controller.changeCountry('Saudi Arabia');
    controller.changeLanguage('English');
    controller.changeHowToFindUs(controller.howToFindUsList.first);
  }

  testWidgets('empty required selections are field errors and send no update', (
    tester,
  ) async {
    await http.runWithClient(() async {
      await mount(tester);
      controller.birthDate = DateTime(1990);
      controller.dateOfBirth.text = 'Chosen date';
      controller.whatsapp.text = '501234567';
      controller.city.text = 'Riyadh';
      controller.isSaudiUniversity.value = true;
      await tester.pumpAndSettle();
      final loaded = requests.length;
      await controller.onEdit();
      await tester.pumpAndSettle();
      expect(requests.length, loaded);
      expect(find.text('Please select a country'), findsOneWidget);
      expect(find.text('Please select a language'), findsOneWidget);
      expect(find.text('Please select a how to find us'), findsOneWidget);
      expect(find.text('Please select a university'), findsOneWidget);
      expect(controller.gender.value, 'male');
      final countryError = tester.getRect(find.text('Please select a country'));
      expect(countryError.top, greaterThanOrEqualTo(0));
      expect(
        countryError.bottom,
        lessThanOrEqualTo(tester.view.physicalSize.height),
      );
    }, () => MockClient(referenceResponse));
  });

  testWidgets(
    'parent rebuild keeps successful reference data and entered values',
    (tester) async {
      await http.runWithClient(() async {
        await mount(tester);
        final loaded = requests.length;
        controller.city.text = 'Damascus';
        controller.changeCountry('Saudi Arabia');
        await tester.pumpAndSettle();
        await mount(tester, dark: true);
        expect(requests.length, loaded);
        expect(controller.city.text, 'Damascus');
        expect(controller.country.value, 'Saudi Arabia');
      }, () => MockClient(referenceResponse));
    },
  );

  for (final underage in [false, true]) {
    testWidgets(
      'DOB ${underage ? 'underage' : 'missing'} is visible and blocks requests',
      (tester) async {
        await http.runWithClient(() async {
          await mount(tester);
          validValues();
          controller.birthDate = underage ? DateTime.now() : null;
          await tester.pumpAndSettle();
          final loaded = requests.length;
          await controller.onEdit();
          await tester.pumpAndSettle();
          final message =
              underage ? 'You must be at least 18 years old' : 'Date Required';
          expect(find.text(message), findsOneWidget);
          expect(requests.length, loaded);
          final error = tester.getRect(find.text(message));
          expect(error.top, greaterThanOrEqualTo(0));
          expect(error.bottom, lessThan(600));
        }, () => MockClient(referenceResponse));
      },
    );
  }

  testWidgets('failed reference load retries and then remains cached', (
    tester,
  ) async {
    var fail = true;
    await http.runWithClient(
      () async {
        await mount(tester);
        expect(tester.takeException(), isA<ErrorX>());
        expect(controller.countriesList, isEmpty);
        fail = false;
        await tester.tap(find.text('Try again'));
        await tester.pumpAndSettle();
        expect(controller.countriesList.single.name, 'Saudi Arabia');
        final loaded = requests.length;
        await mount(tester);
        expect(requests.length, loaded);
      },
      () => MockClient((request) async {
        if (fail) {
          requests.add(request);
          return http.Response(
            '{"status":"error","message":"Synthetic reference failure"}',
            200,
          );
        }
        return referenceResponse(request);
      }),
    );
  });

  testWidgets(
    'Others and university requirements follow visible conditional fields',
    (tester) async {
      await http.runWithClient(() async {
        await mount(tester);
        validValues();
        controller.changeHowToFindUs('Others');
        controller.changeIsSaudiUniversity(true);
        await tester.pumpAndSettle();
        final loaded = requests.length;
        await controller.onEdit();
        await tester.pumpAndSettle();
        expect(find.text('Required'), findsOneWidget);
        expect(find.text('Please select a university'), findsOneWidget);
        expect(requests.length, loaded);
        controller.howToFindUsOthers.text = 'Synthetic referral';
        controller.changeIsSaudiUniversity(false);
        await tester.pumpAndSettle();
        expect(controller.formKey.currentState!.validate(), isTrue);
        expect(find.text('Please select a university'), findsNothing);
        expect(controller.city.text, 'Damascus');
      }, () => MockClient(referenceResponse));
    },
  );

  testWidgets('server failure retains fields and allows a second attempt', (
    tester,
  ) async {
    await http.runWithClient(
      () async {
        await mount(tester);
        validValues();
        await tester.pumpAndSettle();
        final loaded = requests.length;
        await controller.onEdit();
        await tester.pump();
        expect(requests.length, loaded + 1);
        expect(controller.isLoading.value, isFalse);
        expect(controller.buttonState.value, ButtonStateEX.failed);
        expect(controller.city.text, 'Damascus');
        expect(controller.country.value, 'Saudi Arabia');
        expect(find.text('Synthetic update failure'), findsOneWidget);
        await controller.onEdit();
        await tester.pump();
        expect(requests.length, loaded + 2);
        expect(requests.last.bodyFields['customfields[1][value]'], 'male');
        await tester.pump(const Duration(seconds: 5));
      },
      () => MockClient((request) async {
        if (request.bodyFields.containsKey('profile[city]')) {
          requests.add(request);
          return http.Response(
            '{"status":"error","message":"Synthetic update failure"}',
            200,
          );
        }
        return referenceResponse(request);
      }),
    );
  });

  for (final abandon in [
    'closed',
    'token',
    'user',
    'owner',
    'same-value',
    'aba',
  ]) {
    testWidgets(
      'pending completion ignores abandoned $abandon and sends no photo',
      (tester) async {
        final response = Completer<http.Response>();
        await http.runWithClient(
          () async {
            await mount(tester);
            validValues();
            controller.image = XFile('${directory.path}/unused-photo.png');
            await tester.pumpAndSettle();
            final pending = controller.onEdit();
            await tester.pump();
            final loaded = requests.length;
            await controller.onEdit();
            expect(
              requests.length,
              loaded,
              reason: 'No concurrent second submission',
            );
            if (abandon == 'closed') {
              Get.delete<CompleteAccountInfoController>(force: true);
            } else if (abandon == 'token') {
              await tester.runAsync(
                () => HiveX.box.put('token', 'replacement-synthetic-token'),
              );
            } else if (abandon == 'user') {
              controller.app.user.value.id = 'replacement-user';
            } else if (abandon == 'same-value') {
              await tester.runAsync(
                () => LocalDataX.put(LocalKeyX.token, 'synthetic-token'),
              );
            } else if (abandon == 'aba') {
              await tester.runAsync(() async {
                await LocalDataX.put(LocalKeyX.token, 'replacement-token');
                await LocalDataX.put(LocalKeyX.token, 'synthetic-token');
              });
            } else {
              Get.delete<CompleteAccountInfoController>(force: true);
              Get.put(CompleteAccountInfoController());
            }
            response.complete(
              http.Response('{"status":"success","message":"Saved"}', 200),
            );
            await pending;
            await tester.pump();
            expect(requests.length, loaded);
            expect(find.text('Saved'), findsNothing);
            expect(find.text('Root destination'), findsNothing);
          },
          () => MockClient((request) async {
            if (request.bodyFields.containsKey('profile[city]')) {
              requests.add(request);
              return response.future;
            }
            return referenceResponse(request);
          }),
        );
      },
    );
  }

  testWidgets('success navigates once after acknowledgement', (tester) async {
    await http.runWithClient(() async {
      await mount(tester);
      validValues();
      await tester.pumpAndSettle();
      final loaded = requests.length;
      final pending = controller.onEdit();
      await tester.pump();
      expect(find.text('Saved'), findsOneWidget);
      expect(requests.length, loaded + 1);
      await tester.pump(const Duration(seconds: 1));
      await pending;
      await tester.pumpAndSettle();
      expect(find.text('Root destination'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    }, () => MockClient(referenceResponse));
  });

  testWidgets('photo failure reports partial save and keeps entered data', (
    tester,
  ) async {
    // Missing local file exercises the real upload error path before network.
    await http.runWithClient(() async {
      await mount(tester);
      validValues();
      controller.image = XFile('${directory.path}/missing-photo.png');
      await tester.pumpAndSettle();
      final loaded = requests.length;
      await tester.runAsync(controller.onEdit);
      await tester.pump();
      expect(requests.length, loaded + 1);
      expect(
        find.text(
          'Profile information saved, but the photo could not be uploaded. Please try again.',
        ),
        findsOneWidget,
      );
      expect(find.text('Saved'), findsNothing);
      expect(find.text('Root destination'), findsNothing);
      expect(controller.city.text, 'Damascus');
      expect(controller.isLoading.value, isFalse);
      await tester.pump(const Duration(seconds: 5));
    }, () => MockClient(referenceResponse));
  });

  testWidgets(
    'server photo failure reports partial save after real multipart request',
    (tester) async {
      final photo = File('${directory.path}/synthetic-photo.png');
      await tester.runAsync(() => photo.writeAsBytes([1, 2, 3]));
      var uploads = 0;
      await http.runWithClient(
        () async {
          await mount(tester);
          validValues();
          controller.image = XFile(photo.path);
          await tester.pumpAndSettle();
          await tester.runAsync(controller.onEdit);
          await tester.pump();
          expect(uploads, 1);
          expect(
            find.text(
              'Profile information saved, but the photo could not be uploaded. Please try again.',
            ),
            findsOneWidget,
          );
          expect(find.text('Saved'), findsNothing);
          expect(find.text('Root destination'), findsNothing);
          expect(controller.isLoading.value, isFalse);
          await tester.pump(const Duration(seconds: 5));
        },
        () => MockClient((request) async {
          if ((request.headers['content-type'] ?? '').startsWith(
            'multipart/',
          )) {
            uploads++;
            return http.Response(
              '{"status":"error","message":"Synthetic photo failure"}',
              200,
            );
          }
          return referenceResponse(request);
        }),
      );
    },
  );

  testWidgets(
    'session replacement during success delay prevents navigation and button writes',
    (tester) async {
      await http.runWithClient(() async {
        await mount(tester);
        validValues();
        await tester.pumpAndSettle();
        final pending = controller.onEdit();
        await tester.pump();
        expect(controller.buttonState.value, ButtonStateEX.success);
        await tester.runAsync(
          () => HiveX.box.put('token', 'replacement-after-save'),
        );
        await tester.pump(const Duration(seconds: 5));
        await pending;
        expect(find.text('Root destination'), findsNothing);
        expect(controller.buttonState.value, ButtonStateEX.success);
      }, () => MockClient(referenceResponse));
    },
  );

  testWidgets(
    'stale completion form cannot start a mutation under a new generation',
    (tester) async {
      await http.runWithClient(() async {
        await mount(tester);
        validValues();
        await tester.pumpAndSettle();
        final loaded = requests.length;
        await tester.runAsync(
          () => LocalDataX.put(LocalKeyX.token, 'synthetic-token'),
        );
        await controller.onEdit();
        expect(requests.length, loaded);
        expect(controller.isLoading.value, isFalse);
      }, () => MockClient(referenceResponse));
    },
  );
}
