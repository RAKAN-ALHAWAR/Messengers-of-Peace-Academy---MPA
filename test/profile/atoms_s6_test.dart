import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:messengersofpeace/Core/core.dart';
import 'package:messengersofpeace/Ui/Screen/Profile/EditProfile/controller/controller.dart';

import 'profile_harness.dart';

/// Each owner atom of EditProfileController alone, with the session storage
/// untouched, so only the atom under test can retire the pending save.
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

  void change(String mode) {
    switch (mode) {
      case 'closed-but-registered':
        harness.controller.onDelete();
      case 'second-instance':
        // Resetting the instances forgets the old controller without closing it.
        final app = harness.app;
        GetInstance().resetInstance(clearRouteBindings: false);
        Get.put(app);
        Get.put(EditProfileController());
      case 'app-replaced':
        Get.delete<AppControllerX>(force: true);
        Get.put(AppControllerX()..user = syntheticProfile().obs);
      case 'account-only':
        harness.app.user.value = syntheticProfile()..id = 'synthetic-user-B';
    }
  }

  for (final mode in [
    'closed-but-registered',
    'second-instance',
    'app-replaced',
    'account-only',
  ]) {
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
        expect(harness.updateCalls, 1);
        expect(harness.controller.ownsCurrentSession, isTrue);
        change(mode);
        expect(harness.controller.ownsCurrentSession, isFalse);
        response.complete(
          http.Response('{"status":"success","message":"Profile saved"}', 200),
        );
        await pending;
        await tester.pump();
        expect(harness.photoCalls, 0);
        expect(harness.refreshCalls, 0);
        expect(Get.currentRoute, '/profile-test');
      }, harness.client);
    });
  }
}
