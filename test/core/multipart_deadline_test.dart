import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:messengersofpeace/Core/Error/error.dart';
import 'package:messengersofpeace/Core/Helper/http/http.dart';
import 'package:messengersofpeace/Data/data.dart';

class _StreamClient extends http.BaseClient {
  _StreamClient(this.response);
  final Future<http.StreamedResponse> Function() response;
  bool closed = false;
  int requests = 0;
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    requests++;
    return response();
  }

  @override
  void close() {
    closed = true;
  }
}

void main() {
  late Directory directory;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa_multipart');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('app');
    HttpX.init();
  });
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });
  for (final put in [false, true]) {
    Future<dynamic> upload() =>
        put
            ? HttpX.putFiles(
              url: 'https://synthetic.invalid/upload',
              files: {},
              timeout: const Duration(milliseconds: 30),
            )
            : HttpX.postFiles(
              url: 'https://synthetic.invalid/upload',
              files: {},
              timeout: const Duration(milliseconds: 30),
            );
    test(
      '${put ? 'PUT' : 'POST'} deadline covers stalled response body',
      () async {
        var cancelled = false;
        final body = StreamController<List<int>>(
          onCancel: () {
            cancelled = true;
          },
        );
        final client = _StreamClient(
          () async => http.StreamedResponse(body.stream, 200),
        );
        final watch = Stopwatch()..start();
        await http.runWithClient(() async {
          await expectLater(
            upload(),
            throwsA(isA<ErrorX>().having((e) => e.errorCode, 'status', 408)),
          );
        }, () => client);
        expect(watch.elapsed, lessThan(const Duration(seconds: 1)));
        expect(client.closed, isTrue);
        expect(cancelled, isTrue);
        expect(client.requests, 1);
        await body.close();
      },
    );
    test(
      '${put ? 'PUT' : 'POST'} deadline covers absent response headers',
      () async {
        final headers = Completer<http.StreamedResponse>();
        final client = _StreamClient(() => headers.future);
        await http.runWithClient(() async {
          await expectLater(
            upload(),
            throwsA(isA<ErrorX>().having((e) => e.errorCode, 'status', 408)),
          );
        }, () => client);
        expect(client.closed, isTrue);
        expect(client.requests, 1);
        headers.complete(http.StreamedResponse(const Stream.empty(), 200));
        await Future<void>.delayed(Duration.zero);
      },
    );
    test(
      '${put ? 'PUT' : 'POST'} complete acknowledgement is decoded',
      () async {
        final client = _StreamClient(
          () async =>
              http.StreamedResponse(Stream.value('{"ok":true}'.codeUnits), 200),
        );
        await http.runWithClient(() async {
          expect(await upload(), {'ok': true});
        }, () => client);
        expect(client.closed, isTrue);
        expect(client.requests, 1);
      },
    );
  }
  test(
    'multipart acknowledgement size is bounded without Content-Length',
    () async {
      final client = _StreamClient(
        () async => http.StreamedResponse(
          Stream.value(List<int>.filled(16 * 1024 * 1024 + 1, 32)),
          200,
        ),
      );
      await http.runWithClient(() async {
        await expectLater(
          HttpX.postFiles(url: 'https://synthetic.invalid/upload', files: {}),
          throwsA(isA<ErrorX>().having((e) => e.errorCode, 'status', 413)),
        );
      }, () => client);
      expect(client.closed, isTrue);
    },
  );
}
