import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Data/Model/event.dart';
import 'package:messengersofpeace/Ui/Screen/Events/EventDetails/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Events/EventDetails/view/view.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Ui/Widget/Basic/Utils/future_builder.dart';

Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

class FixtureEventController extends EventDetailsController {
  int requests = 0;
  @override
  Future<void> getData() async {
    requests++;
  }
}

EventX event(String name) => EventX(
  id: 'synthetic-event',
  name: name,
  description: 'Synthetic description',
  location: 'Synthetic location',
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    final scratch = await Directory.systemTemp.createTemp('mopa-future-tests-');
    Hive.init(scratch.path);
    HiveX.box = await Hive.openBox('synthetic-future');
  });
  tearDownAll(() async {
    await Hive.close();
  });

  testWidgets('parent rebuild retains one request and one success callback', (
    tester,
  ) async {
    var fetches = 0;
    var successes = 0;
    late StateSetter rebuild;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (_, setState) {
            rebuild = setState;
            return FutureBuilderX<String>(
              future: () async {
                fetches++;
                return 'Synthetic loaded row';
              },
              onSuccess: () {
                successes++;
              },
              child: (data) => Text(data),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    rebuild(() {});
    await tester.pumpAndSettle();
    rebuild(() {});
    await tester.pumpAndSettle();
    expect(fetches, 1);
    expect(successes, 1);
    expect(find.text('Synthetic loaded row'), findsOneWidget);
  });

  testWidgets(
    'loading and error callbacks occur once; retry starts exactly one request',
    (tester) async {
      var fetches = 0;
      var loading = 0;
      var errors = 0;
      var retries = 0;
      final first = Completer<String>();
      final key = GlobalKey<FutureBuilderXState<String>>();
      late StateSetter rebuild;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (_, setState) {
              rebuild = setState;
              return FutureBuilderX<String>(
                key: key,
                future: () {
                  fetches++;
                  return fetches == 1
                      ? first.future
                      : Future<String>.error(StateError('Synthetic failure'));
                },
                isHideIfError: true,
                onLoading: () {
                  loading++;
                },
                onError: () {
                  errors++;
                },
                onRetry: () {
                  retries++;
                },
                child: Text.new,
              );
            },
          ),
        ),
      );
      await tester.pump();
      rebuild(() {});
      await tester.pump();
      expect(fetches, 1);
      expect(loading, 1);
      first.completeError(StateError('Synthetic failure'));
      await tester.pumpAndSettle();
      rebuild(() {});
      await tester.pumpAndSettle();
      expect(errors, 1);
      expect(fetches, 1);
      key.currentState!.onRefresh();
      await tester.pumpAndSettle();
      expect(fetches, 2);
      expect(retries, 1);
      expect(errors, 2);
      expect(loading, 2);
    },
  );

  testWidgets('completion after disposal cannot call screen callbacks', (
    tester,
  ) async {
    final pending = Completer<String>();
    var completions = 0;
    await tester.pumpWidget(
      host(
        FutureBuilderX<String>(
          future: () => pending.future,
          onSuccess: () {
            completions++;
          },
          onError: () {
            completions++;
          },
          child: Text.new,
        ),
      ),
    );
    await tester.pumpWidget(const SizedBox());
    pending.complete('Abandoned synthetic data');
    await tester.pump();
    expect(completions, 0);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'event detail body reflects repeated edits without request loops',
    (tester) async {
      Get.testMode = true;
      Get.locale = const Locale('en');
      late FixtureEventController controller;
      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/',
          getPages: [
            GetPage(
              name: '/',
              page: () => const Scaffold(body: Text('Synthetic root')),
            ),
            GetPage(
              name: '/event',
              binding: BindingsBuilder(() {
                controller = FixtureEventController();
                Get.put<EventDetailsController>(controller);
              }),
              page: () => const EventDetailsView(),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
      Get.toNamed('/event', arguments: event('Initial synthetic event'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Initial synthetic event'), findsOneWidget);
      controller.eventDetails.value = event('First synthetic edit');
      await tester.pumpAndSettle();
      expect(find.text('First synthetic edit'), findsOneWidget);
      controller.eventDetails.value = event('Second synthetic edit');
      await tester.pumpAndSettle();
      expect(find.text('Second synthetic edit'), findsOneWidget);
      expect(controller.requests, 1);
      await tester.pumpWidget(const SizedBox());
      Get.reset();
    },
  );
  testWidgets(
    'changed business key ignores old success and fetches new data once',
    (tester) async {
      var active = 'course-A';
      final pending = {
        'course-A': Completer<String>(),
        'course-B': Completer<String>(),
      };
      final requested = <String>[];
      var successes = 0;
      late StateSetter rebuild;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (_, setState) {
              rebuild = setState;
              return FutureBuilderX<String>(
                requestKey: active,
                future: () {
                  requested.add(active);
                  return pending[active]!.future;
                },
                onSuccess: () {
                  successes++;
                },
                child: Text.new,
              );
            },
          ),
        ),
      );
      await tester.pump();
      rebuild(() {
        active = 'course-B';
      });
      await tester.pump();
      pending['course-B']!.complete('Current course B');
      await tester.pumpAndSettle();
      pending['course-A']!.complete('Obsolete course A');
      await tester.pumpAndSettle();
      expect(requested, ['course-A', 'course-B']);
      expect(find.text('Current course B'), findsOneWidget);
      expect(find.text('Obsolete course A'), findsNothing);
      expect(successes, 1);
    },
  );

  testWidgets(
    'explicit refresh invokes latest callback once without a retry event',
    (tester) async {
      final key = GlobalKey<FutureBuilderXState<String>>();
      var fetches = 0;
      var retries = 0;
      var response = 'First response';
      late StateSetter rebuild;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (_, setState) {
              rebuild = setState;
              final nextResponse = response;
              return FutureBuilderX<String>(
                key: key,
                requestKey: 'stable-input',
                future: () async {
                  fetches++;
                  return nextResponse;
                },
                onRetry: () {
                  retries++;
                },
                child: Text.new,
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      rebuild(() {
        response = 'Refreshed response';
      });
      await tester.pumpAndSettle();
      expect(fetches, 1);
      final refresh = key.currentState!.refresh();
      await tester.pumpAndSettle();
      await refresh;
      expect(fetches, 2);
      expect(retries, 0);
      expect(find.text('Refreshed response'), findsOneWidget);
    },
  );

  testWidgets(
    'same-account reauthentication invalidates retained data without parent update',
    (tester) async {
      await tester.runAsync(() async {
        LocalDataX.put(LocalKeyX.userid, 'synthetic-A');
        LocalDataX.put(LocalKeyX.token, 'synthetic-token');
        await HiveX.box.flush();
      });
      var fetches = 0;
      await tester.pumpWidget(
        host(
          FutureBuilderX<String>(
            future: () async {
              fetches++;
              return 'Load $fetches';
            },
            child: Text.new,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        LocalDataX.put(LocalKeyX.token, 'synthetic-token');
        await HiveX.box.flush();
      });
      await tester.pumpAndSettle();
      expect(fetches, 2);
      expect(find.text('Load 2'), findsOneWidget);
      expect(find.text('Load 1'), findsNothing);
    },
  );

  testWidgets('account switch retires completed data without parent update', (
    tester,
  ) async {
    await tester.runAsync(() async {
      LocalDataX.put(LocalKeyX.userid, 'completed-A');
      await HiveX.box.flush();
    });
    final current = Completer<String>();
    var fetches = 0;
    await tester.pumpWidget(
      host(
        FutureBuilderX<String>(
          future: () {
            fetches++;
            return LocalDataX.userid == 'completed-A'
                ? Future.value('Completed account A data')
                : current.future;
          },
          child: Text.new,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Completed account A data'), findsOneWidget);
    await tester.runAsync(() async {
      LocalDataX.put(LocalKeyX.userid, 'completed-B');
      LocalDataX.put(LocalKeyX.token, 'completed-B-token');
      await HiveX.box.flush();
    });
    await tester.pump();
    await tester.pump();
    expect(fetches, 2);
    expect(find.text('Completed account A data'), findsNothing);
    current.complete('Completed account B data');
    await tester.pumpAndSettle();
    expect(find.text('Completed account B data'), findsOneWidget);
  });

  for (final failed in [false, true]) {
    testWidgets(
      'account switch suppresses stale ${failed ? 'failure' : 'data'} and callback before parent update',
      (tester) async {
        await tester.runAsync(() async {
          LocalDataX.put(LocalKeyX.userid, 'synthetic-A');
          LocalDataX.put(LocalKeyX.token, 'synthetic-A-token');
          await HiveX.box.flush();
        });
        final pending = Completer<String>();
        final current = Completer<String>();
        var fetches = 0;
        var callbacks = 0;
        await tester.pumpWidget(
          host(
            FutureBuilderX<String>(
              future: () {
                fetches++;
                return LocalDataX.userid == 'synthetic-A'
                    ? pending.future
                    : current.future;
              },
              onSuccess: () {
                callbacks++;
              },
              onError: () {
                callbacks++;
              },
              child: Text.new,
            ),
          ),
        );
        await tester.pump();
        await tester.runAsync(() async {
          LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
          LocalDataX.put(LocalKeyX.token, 'synthetic-B-token');
          await HiveX.box.flush();
        });
        if (failed) {
          pending.completeError(StateError('Abandoned account A error'));
        } else {
          pending.complete('Abandoned account A data');
        }
        await tester.pump();
        await tester.pump();
        expect(callbacks, 0);
        expect(fetches, 2);
        expect(find.text('Abandoned account A data'), findsNothing);
        current.complete('Current account B data');
        await tester.pumpAndSettle();
        expect(find.text('Current account B data'), findsOneWidget);
        expect(callbacks, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'synchronous failure and nullable success obey callback and empty policy',
    (tester) async {
      var errors = 0;
      await tester.pumpWidget(
        host(
          FutureBuilderX<String>(
            future: () => throw StateError('Synthetic synchronous failure'),
            isHideIfError: true,
            onError: () {
              errors++;
            },
            child: Text.new,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(errors, 1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      var successes = 0;
      await tester.pumpWidget(
        host(
          FutureBuilderX<String?>(
            future: () async => null,
            isHideIfEmpty: true,
            onSuccess: () {
              successes++;
            },
            child: (_) => const Text('Unexpected empty content'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(successes, 1);
      expect(find.text('Unexpected empty content'), findsNothing);
    },
  );
}
