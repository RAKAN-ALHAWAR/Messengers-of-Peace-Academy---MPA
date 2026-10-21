import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Ui/Screen/Profile/EditProfile/controller/controller.dart';

import 'profile_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final harness = ProfileHarness();
  setUpAll(harness.initialize);
  setUp(harness.reset);
  tearDown(harness.cleanUp);
  tearDownAll(harness.close);

  Future<File> photo(WidgetTester tester, String name) async {
    final file = File('${harness.directory.path}/$name.png');
    await tester.runAsync(
      () => file.writeAsBytes(
        base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4z8DwHwAFgAI/ScLbtAAAAABJRU5ErkJggg==',
        ),
      ),
    );
    return file;
  }

  Future<void> changeGeneration(WidgetTester tester, String mode) async {
    if (mode == 'closed') {
      Get.delete<EditProfileController>(force: true);
    } else if (mode == 'owner') {
      Get.delete<EditProfileController>(force: true);
      Get.put(EditProfileController());
    } else {
      await tester.runAsync(() async {
        if (mode == 'same-value') {
          await LocalDataX.put(LocalKeyX.token, 'synthetic-token');
        } else if (mode == 'aba') {
          await LocalDataX.put(LocalKeyX.token, 'synthetic-token-B');
          await LocalDataX.put(LocalKeyX.token, 'synthetic-token');
        } else {
          await LocalDataX.put(LocalKeyX.userid, 'synthetic-user-B');
          await LocalDataX.put(LocalKeyX.token, 'synthetic-token-B');
          harness.app.user.value = syntheticProfile()..id = 'synthetic-user-B';
        }
      });
    }
    // Retiring the form also retires its delayed entrance animations. Drain
    // those bounded, mounted-guarded callbacks before test teardown.
    if (mode != 'closed' && mode != 'owner') {
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    }
  }

  testWidgets(
    'reference failure plus unrelated save preserves original full phone',
    (tester) async {
      harness.failReferences = true;
      await http.runWithClient(() async {
        await harness.mount(tester);
        harness.controller.city.text = 'Aleppo';
        final pending = harness.controller.onEdit();
        await tester.pump();
        expect(harness.lastUpdate?['customfields[2][value]'], '+963944123456');
        expect(harness.lastUpdate?['customfields[11][value]'], '+963');
        expect(harness.lastUpdate?['customfields[0][value]'], 'Arabic');
        expect(harness.lastUpdate?['customfields[9][value]'], 'Syria');
        await tester.pump(const Duration(seconds: 1));
        await pending;
        await tester.pumpAndSettle();
        expect(find.text('Profile base'), findsOneWidget);
        await tester.pump(const Duration(seconds: 5));
      }, harness.client);
    },
  );

  for (final mode in ['closed', 'account', 'same-value', 'aba', 'owner']) {
    testWidgets('delayed update ignores $mode and sends no avatar or refresh', (
      tester,
    ) async {
      final response = Completer<http.Response>();
      harness.onUpdate = () => response.future;
      await http.runWithClient(() async {
        await harness.mount(tester);
        harness.controller.image = XFile((await photo(tester, mode)).path);
        final pending = harness.controller.onEdit();
        await tester.pump();
        await harness.controller.onEdit();
        expect(harness.updateCalls, 1);
        await changeGeneration(tester, mode);
        response.complete(
          http.Response('{"status":"success","message":"Profile saved"}', 200),
        );
        await pending;
        await tester.pump();
        expect(harness.photoCalls, 0);
        expect(harness.refreshCalls, 0);
        expect(find.text('Profile saved'), findsNothing);
        expect(Get.currentRoute, '/profile-test');
      }, harness.client);
    });
  }

  testWidgets('stale mounted form cannot start a new save', (tester) async {
    await http.runWithClient(() async {
      await harness.mount(tester);
      await changeGeneration(tester, 'account');
      await harness.controller.onEdit();
      expect(harness.updateCalls, 0);
      expect(harness.photoCalls, 0);
    }, harness.client);
  });

  testWidgets('photo failure retry uploads only photo unless text changed', (
    tester,
  ) async {
    harness.failPhoto = true;
    await http.runWithClient(() async {
      await harness.mount(tester);
      harness.controller.image = XFile((await photo(tester, 'retry')).path);
      await tester.runAsync(harness.controller.onEdit);
      await tester.pump();
      expect(harness.updateCalls, 1);
      expect(harness.photoCalls, 1);
      expect(harness.refreshCalls, 0);
      expect(harness.controller.isLoading.value, isFalse);
      expect(
        find.text(
          'Profile information saved, but the photo could not be uploaded. Please try again.',
        ),
        findsOneWidget,
      );
      expect(Get.currentRoute, '/profile-test');
      expect(harness.controller.city.text, 'Damascus');
      // A second explicit failed upload must not repeat the acknowledged text.
      await tester.runAsync(harness.controller.onEdit);
      expect(harness.updateCalls, 1);
      expect(harness.photoCalls, 2);
      harness.controller.city.text = 'Aleppo';
      await tester.runAsync(harness.controller.onEdit);
      expect(harness.updateCalls, 2);
      expect(harness.photoCalls, 3);
      expect(harness.lastUpdate?['profile[city]'], 'Aleppo');
      harness.failPhoto = false;
      await tester.runAsync(harness.controller.onEdit);
      await tester.pumpAndSettle();
      expect(harness.updateCalls, 2);
      expect(harness.photoCalls, 4);
      expect(harness.refreshCalls, 1);
      expect(find.text('Profile base'), findsOneWidget);
      await tester.pump(const Duration(seconds: 5));
    }, harness.client);
  });

  testWidgets(
    'selected photo and profile fields are snapshotted before awaiting update',
    (tester) async {
      final response = Completer<http.Response>();
      harness.onUpdate = () => response.future;
      harness.failPhoto = true;
      await http.runWithClient(() async {
        await harness.mount(tester);
        final first = await photo(tester, 'snapshot');
        harness.controller.image = XFile(first.path);
        late Future<void> pending;
        await tester.runAsync(() async {
          pending = harness.controller.onEdit();
          await Future<void>.delayed(Duration.zero);
        });
        harness.controller.city.text = 'Aleppo';
        harness.controller.image = XFile(
          '${harness.directory.path}/missing-new-photo.png',
        );
        await tester.runAsync(() async {
          response.complete(
            http.Response(
              '{"status":"success","message":"Profile saved"}',
              200,
            ),
          );
          await pending;
        });
        expect(harness.lastUpdate?['profile[city]'], 'Damascus');
        expect(
          harness.photoCalls,
          1,
          reason: 'Original snapshotted file reached multipart transport',
        );
        await tester.pump(const Duration(seconds: 5));
      }, harness.client);
    },
  );

  testWidgets('late refresh cannot replace the next account', (tester) async {
    final response = Completer<http.Response>();
    harness.onRefresh = () => response.future;
    await http.runWithClient(() async {
      await harness.mount(tester);
      final oldUser = harness.app.user.value.toJson();
      final pending = harness.controller.onEdit();
      await tester.pump();
      expect(harness.refreshCalls, 1);
      await changeGeneration(tester, 'account');
      response.complete(http.Response(jsonEncode(oldUser), 200));
      await pending;
      expect(harness.app.user.value.id, 'synthetic-user-B');
      expect(Get.currentRoute, '/profile-test');
    }, harness.client);
  });

  testWidgets(
    'session changes during success delay prevent pop and timer writes',
    (tester) async {
      await http.runWithClient(() async {
        await harness.mount(tester);
        final pending = harness.controller.onEdit();
        await tester.pump();
        expect(harness.controller.buttonState.value, ButtonStateEX.success);
        await changeGeneration(tester, 'same-value');
        await tester.pump(const Duration(seconds: 5));
        await pending;
        expect(Get.currentRoute, '/profile-test');
        expect(harness.controller.buttonState.value, ButtonStateEX.success);
      }, harness.client);
    },
  );

  testWidgets('closing disposes username and email controllers', (
    tester,
  ) async {
    final username = harness.controller.username;
    final email = harness.controller.email;
    Get.delete<EditProfileController>(force: true);
    expect(() => username.addListener(() {}), throwsFlutterError);
    expect(() => email.addListener(() {}), throwsFlutterError);
  });

  testWidgets(
    'late photo picker result is discarded after same-value login generation changes',
    (tester) async {
      const channel = MethodChannel('plugins.flutter.io/image_picker');
      final result = Completer<String?>();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (_) => result.future);
      try {
        await http.runWithClient(() async {
          await harness.mount(tester);
          Get.bottomSheet(const SizedBox(height: 100));
          await tester.pumpAndSettle();
          final pending = harness.controller.changeImage();
          await tester.pump();
          await changeGeneration(tester, 'same-value');
          result.complete('${harness.directory.path}/picker-result.png');
          await pending;
          await tester.pumpAndSettle();
          expect(harness.controller.image, isNull);
        }, harness.client);
      } finally {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      }
    },
  );

  testWidgets(
    'late reference results cannot write after login generation changes',
    (tester) async {
      final response = Completer<http.Response>();
      harness.onReference = () => response.future;
      await http.runWithClient(() async {
        final pending = harness.controller.getData();
        await tester.pump();
        expect(harness.referenceCalls, 3);
        await changeGeneration(tester, 'same-value');
        response.complete(
          http.Response(
            '[{"code":"ZZ","name":"Stale reference","dial_code":"+000"}]',
            200,
          ),
        );
        await pending;
        expect(harness.controller.countriesList, isEmpty);
        expect(harness.controller.languagesList, isEmpty);
        expect(harness.controller.phoneCodesList, isEmpty);
        expect(harness.controller.country.value, 'Syria');
        expect(harness.controller.countryCode.value, '+963');
      }, harness.client);
    },
  );

  testWidgets(
    'late photo response cannot start a refresh for the next account',
    (tester) async {
      final response = Completer<http.Response>();
      harness.onPhoto = () => response.future;
      await http.runWithClient(() async {
        await harness.mount(tester);
        harness.controller.image = XFile(
          (await photo(tester, 'late-photo')).path,
        );
        late Future<void> pending;
        await tester.runAsync(() async {
          pending = harness.controller.onEdit();
          await Future<void>.delayed(const Duration(milliseconds: 20));
        });
        expect(harness.photoCalls, 1);
        await changeGeneration(tester, 'account');
        await tester.runAsync(() async {
          response.complete(
            http.Response('{"status":"success","message":"Photo saved"}', 200),
          );
          await pending;
        });
        expect(harness.refreshCalls, 0);
        expect(harness.app.user.value.id, 'synthetic-user-B');
        expect(Get.currentRoute, '/profile-test');
      }, harness.client);
    },
  );

  testWidgets('closing cancels the success delay and its continuation', (
    tester,
  ) async {
    await http.runWithClient(() async {
      await harness.mount(tester);
      final pending = harness.controller.onEdit();
      await tester.pump();
      expect(harness.controller.buttonState.value, ButtonStateEX.success);
      Get.delete<EditProfileController>(force: true);
      await pending;
      expect(Get.currentRoute, '/profile-test');
    }, harness.client);
  });
}
