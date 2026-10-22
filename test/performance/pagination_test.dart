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
import 'package:messengersofpeace/Ui/Screen/Blog/Blog/controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Blog/Blog/view/view.dart';

void main() {
  late Directory directory;
  late BlogController controller;
  late List<int> pages;
  late Future<http.Response> Function(int page) reply;
  Map<String, dynamic> entry(int id) => {
    'id': id,
    'subject': 'Article $id',
    'summary': '',
    'tags': [],
    'attachmentfiles': [],
  };
  http.Response response(List<int> ids, {Object? total = 1000}) =>
      http.Response(
        jsonEncode({
          'entries': ids.map(entry).toList(),
          if (total != null) 'totalentries': total,
        }),
        200,
      );
  Future<T> intercepted<T>(Future<T> Function() action) => http.runWithClient(
    action,
    () => MockClient((request) {
      final body = Uri.splitQueryString(request.body);
      final page = int.parse(body['page']!);
      pages.add(page);
      return reply(page);
    }),
  );
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa-pagination');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('app');
    HttpX.init();
  });
  setUp(() async {
    Get.testMode = true;
    Get.locale = const Locale('en');
    await HiveX.box.clear();
    await LocalDataX.put(LocalKeyX.userid, 'synthetic-user');
    await LocalDataX.put(LocalKeyX.token, 'synthetic-token');
    controller = Get.put(BlogController());
    pages = [];
    reply = (page) async => response(List.generate(10, (i) => page * 10 + i));
  });
  tearDown(() => Get.reset());
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('1000-entry archive fetches one page before first display', () async {
    await intercepted(() async {
      expect(await controller.getData(), hasLength(10));
      expect(pages, [0]);
      expect(controller.hasMore.value, isTrue);
    });
  });
  test(
    'one or zero entries finish from response total without extra request',
    () async {
      for (final ids in [
        <int>[],
        [1],
      ]) {
        pages.clear();
        reply = (_) async => response(ids, total: ids.length.toString());
        await intercepted(() async {
          await controller.getData();
          await controller.loadMore();
        });
        expect(controller.blogs, hasLength(ids.length));
        expect(controller.hasMore.value, isFalse);
        expect(pages, [0]);
      }
    },
  );
  test(
    'server page size is not assumed; final page and duplicates are handled',
    () async {
      reply =
          (page) async => response(
            page == 0
                ? [1, 2, 3]
                : page == 1
                ? [3, 4]
                : [5],
            total: 5,
          );
      await intercepted(() async {
        await controller.getData();
        await controller.loadMore();
        await controller.loadMore();
      });
      expect(pages, [0, 1, 2]);
      expect(controller.blogs.map((b) => b.id), ['1', '2', '3', '4', '5']);
      expect(controller.hasMore.value, isFalse);
    },
  );
  test('missing total stops on empty page without recursive fetch', () async {
    reply = (page) async => response(page == 0 ? [1] : [], total: null);
    await intercepted(() async {
      await controller.getData();
      expect(pages, [0]);
      await controller.loadMore();
      await controller.loadMore();
    });
    expect(pages, [0, 1]);
    expect(controller.hasMore.value, isFalse);
  });
  test('duplicate load-more calls share a single request', () async {
    final next = Completer<http.Response>();
    final issued = Completer<void>();
    reply = (page) async {
      if (page == 0) return response([1]);
      issued.complete();
      return next.future;
    };
    await intercepted(() async {
      await controller.getData();
      final first = controller.loadMore();
      await controller.loadMore();
      await issued.future;
      expect(pages, [0, 1]);
      next.complete(response([2]));
      await first;
    });
    expect(controller.blogs, hasLength(2));
  });
  test(
    'page failure preserves rows and retries same page only on demand',
    () async {
      var fail = true;
      reply =
          (page) async =>
              page == 1 && fail ? http.Response('', 500) : response([page + 1]);
      await intercepted(() async {
        await controller.getData();
        await controller.loadMore();
        expect(controller.loadMoreError.value, isNotNull);
        expect(controller.blogs, hasLength(1));
        fail = false;
        await controller.loadMore();
      });
      expect(pages, [0, 1, 1]);
      expect(controller.blogs, hasLength(2));
      expect(controller.loadMoreError.value, isNull);
    },
  );
  test(
    'repeated non-progressing page preserves archive and explicit retry',
    () async {
      reply = (_) async => response([1]);
      await intercepted(() async {
        await controller.getData();
        await controller.loadMore();
      });
      expect(pages, [0, 1]);
      expect(controller.loadMoreError.value, isNotNull);
      expect(controller.blogs, hasLength(1));
      expect(controller.hasMore.value, isTrue);
    },
  );
  for (final change in ['session', 'locale', 'closed', 'refresh']) {
    test(
      'late page after $change cannot append or replace current state',
      () async {
        final next = Completer<http.Response>();
        reply = (page) async => page == 0 ? response([1]) : next.future;
        await intercepted(() async {
          await controller.getData();
          final pending = controller.loadMore();
          switch (change) {
            case 'session':
              await LocalDataX.put(LocalKeyX.token, 'replacement');
            case 'locale':
              Get.locale = const Locale('ar');
            case 'closed':
              Get.delete<BlogController>();
            case 'refresh':
              reply = (_) async => response([9]);
              await controller.getData();
          }
          next.complete(response([2]));
          await pending;
        });
        expect(
          controller.blogs.map((b) => b.id),
          change == 'refresh' ? ['9'] : ['1'],
        );
      },
    );
  }
  testWidgets(
    'actual blog view loads one page and retries its failed next page',
    (tester) async {
      var fail = true;
      reply =
          (page) async =>
              page == 1 && fail
                  ? http.Response('', 500)
                  : response([page + 1], total: 2);
      await intercepted(() async {
        await tester.pumpWidget(
          GetMaterialApp(locale: const Locale('en'), home: const BlogView()),
        );
        await tester.pumpAndSettle();
        expect(pages, [0]);
        expect(find.text('Article 1'), findsOneWidget);
        await tester.tap(find.text('Load more'));
        await tester.pumpAndSettle();
        expect(
          find.text('Unable to load more articles. Please try again.'),
          findsOneWidget,
        );
        expect(find.text('Article 1'), findsOneWidget);
        fail = false;
        await tester.tap(find.text('Try again'));
        await tester.pumpAndSettle();
        expect(pages, [0, 1, 1]);
        expect(find.text('Article 2'), findsOneWidget);
        expect(find.text('Load more'), findsNothing);
        await tester.pumpWidget(const SizedBox());
      });
    },
  );
}
