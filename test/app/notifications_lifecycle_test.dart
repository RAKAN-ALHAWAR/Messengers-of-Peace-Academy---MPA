import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:messengersofpeace/Core/Helper/http/http.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Database/config/database_end_point.dart';
import 'package:messengersofpeace/Ui/Screen/Notifications/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Notifications/view/view.dart';
import 'package:messengersofpeace/Ui/Widget/widget.dart';

String function(String endpoint) =>
    Uri.parse(endpoint).queryParameters['wsfunction']!;
http.Response response(Object value) => http.Response(jsonEncode(value), 200);
List<Map<String, Object>> notifications() => [
  for (final id in ['first', 'second'])
    {
      NameX.id: id,
      NameX.subject: 'Synthetic $id',
      NameX.timeCreated: '2026-07-12 12:00:00',
      NameX.read: false,
    },
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late NotificationsController controller;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp(
      'mopa-notification-tests-',
    );
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('synthetic-notifications');
    HttpX.init();
  });
  setUp(() async {
    Get.testMode = true;
    await LocalDataX.put(LocalKeyX.userid, 'synthetic-A');
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
            page: () => const Scaffold(body: Text('Synthetic root')),
          ),
          GetPage(
            name: '/notifications',
            page: () => const NotificationsView(),
            binding: BindingsBuilder(() {
              controller = Get.put(NotificationsController());
            }),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final action in ['none', 'accepted', 'rejected']) {
    testWidgets('Back returns current unread count after $action mark-all', (
      tester,
    ) async {
      var reads = 0;
      await http.runWithClient(
        () async {
          await mount(tester);
          final result = Get.toNamed('/notifications');
          await tester.pumpAndSettle();
          expect(controller.getCountUnreadNotifications, 2);
          if (action != 'none') {
            controller.onMarkAllAsRead();
            await tester.pumpAndSettle();
            expect(reads, 1);
          }
          final expected = action == 'accepted' ? 0 : 2;
          expect(controller.getCountUnreadNotifications, expected);
          await tester.tap(find.byIcon(Icons.arrow_back));
          await tester.pumpAndSettle();
          expect(await result, expected);
          ToastX.dismiss();
          await tester.pumpWidget(const SizedBox());
        },
        () => MockClient((request) async {
          if (request.url.queryParameters['wsfunction'] ==
              function(DBEndPointX.postGetNotifications)) {
            return response(notifications());
          }
          reads++;
          return response({
            'status': action == 'rejected' ? 'failed' : 'success',
            'message': 'Synthetic acknowledgement',
          });
        }),
      );
    });
  }
  for (final abandonedBy in ['session', 'disposal']) {
    testWidgets(
      'late mark-all acknowledgement after $abandonedBy has no UI effect',
      (tester) async {
        final pending = Completer<http.Response>();
        var reads = 0;
        await http.runWithClient(
          () async {
            await mount(tester);
            Get.toNamed('/notifications');
            await tester.pumpAndSettle();
            controller.onMarkAllAsRead();
            controller.onMarkAllAsRead();
            await tester.pump();
            expect(reads, 1);
            if (abandonedBy == 'session') {
              await tester.runAsync(() async {
                await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
                await HiveX.box.flush();
              });
              await tester.pump();
              await tester.pump();
              expect(controller.isLoading.value, isFalse);
            } else {
              Get.back();
              await tester.pumpAndSettle();
            }
            pending.complete(response({'status': 'success'}));
            await tester.pumpAndSettle();
            await tester.pump(const Duration(seconds: 1));
            await tester.pumpAndSettle();
            expect(controller.getCountUnreadNotifications, 2);
            expect(
              find.text('All notifications have been marked as read'),
              findsNothing,
            );
            expect(tester.takeException(), isNull);
            ToastX.dismiss();
            await tester.pumpWidget(const SizedBox());
          },
          () => MockClient((request) {
            if (request.url.queryParameters['wsfunction'] ==
                function(DBEndPointX.postGetNotifications)) {
              return Future.value(response(notifications()));
            }
            reads++;
            return pending.future;
          }),
        );
      },
    );
  }
  testWidgets('a pending list cannot undo acknowledged mark-all', (
    tester,
  ) async {
    final stale = Completer<http.Response>();
    var lists = 0;
    await http.runWithClient(
      () async {
        await mount(tester);
        Get.toNamed('/notifications');
        await tester.pumpAndSettle();
        final pending = controller.getData();
        await tester.pump();
        controller.onMarkAllAsRead();
        await tester.pumpAndSettle();
        expect(controller.getCountUnreadNotifications, 0);
        stale.complete(response(notifications()));
        await pending;
        await tester.pumpAndSettle();
        final actual = controller.getCountUnreadNotifications;
        ToastX.dismiss();
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        expect(actual, 0);
      },
      () => MockClient((request) async {
        if (request.url.queryParameters['wsfunction'] ==
            function(DBEndPointX.postGetNotifications)) {
          lists++;
          return lists > 1 ? stale.future : response(notifications());
        }
        return response({'status': 'success'});
      }),
    );
  });
  for (final abandonedBy in ['session', 'locale', 'disposal']) {
    test('list load ignores late response after $abandonedBy', () async {
      Get.locale = const Locale('en');
      final controller = Get.put(NotificationsController());
      final pending = Completer<http.Response>();
      final started = Completer<void>();
      await http.runWithClient(
        () async {
          final load = controller.getData();
          await started.future;
          if (abandonedBy == 'session') {
            await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
          } else if (abandonedBy == 'locale') {
            Get.locale = const Locale('es');
          } else {
            Get.delete<NotificationsController>();
          }
          pending.complete(response(notifications()));
          await load;
          expect(controller.notifications, isEmpty);
        },
        () => MockClient((request) {
          started.complete();
          return pending.future;
        }),
      );
    });
  }
}
