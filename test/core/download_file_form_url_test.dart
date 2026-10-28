import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messengersofpeace/Core/Service/download_file_form_url.dart';

/// Answers every request with one fixed response, no network involved.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({this.status = 200, this.headers = const {}, List<int>? body})
    : body = Uint8List.fromList(body ?? [1, 2, 3, 4]);
  final int status;
  final Map<String, List<String>> headers;
  final Uint8List body;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromBytes(body, status, headers: headers);

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('mopa_download'));
  tearDown(() => dir.deleteSync(recursive: true));

  /// Runs one download against a fake server, returns the result flag.
  Future<bool> run(
    String url,
    String name,
    _FakeAdapter adapter,
  ) => DownloadFileFormUrl.download(
    url,
    name,
    dio: Dio()..httpClientAdapter = adapter,
    getDirectory: () async => (dir, false),
  );

  /// Names of the files that ended up in the target directory.
  List<String> saved() =>
      dir.listSync().map((e) => e.uri.pathSegments.last).toList()..sort();

  group('result flag', () {
    test('true only when the file was saved', () async {
      final ok = await run(
        'https://x.test/a/lesson.pdf',
        'lesson',
        _FakeAdapter(headers: {'content-type': ['application/pdf']}),
      );
      expect(ok, isTrue);
      expect(saved(), ['lesson.pdf']);
      expect(File('${dir.path}/lesson.pdf').readAsBytesSync(), [1, 2, 3, 4]);
    });

    test('false for an invalid url, a bad status and no leftovers', () async {
      expect(await run('', 'x', _FakeAdapter()), isFalse);
      expect(await run('not a url', 'x', _FakeAdapter()), isFalse);
      expect(
        await run('https://x.test/f.pdf', 'x', _FakeAdapter(status: 404)),
        isFalse,
      );
      expect(saved(), isEmpty);
    });
  });

  group('file name', () {
    test('keeps Arabic letters and only strips illegal characters', () async {
      await run(
        'https://x.test/f.pdf',
        'دورة السلام: درس 1/2?',
        _FakeAdapter(headers: {'content-type': ['application/pdf']}),
      );
      expect(saved(), ['دورة_السلام_درس_12.pdf']);
    });

    test('falls back to a plain name when nothing is left', () async {
      await run(
        'https://x.test/f.pdf',
        '???',
        _FakeAdapter(headers: {'content-type': ['application/pdf']}),
      );
      expect(saved(), ['file.pdf']);
    });

    test('long Arabic names stay under the file system limit', () async {
      await run(
        'https://x.test/f.pdf',
        'س' * 300,
        _FakeAdapter(headers: {'content-type': ['application/pdf']}),
      );
      expect(saved().single.codeUnits.length, lessThan(100));
    });
  });

  group('extension', () {
    test('Content-Disposition wins over Content-Type and url', () async {
      await run(
        'https://x.test/download.php',
        'a',
        _FakeAdapter(
          headers: {
            'content-disposition': ['attachment; filename="report.docx"'],
            'content-type': ['application/octet-stream'],
          },
        ),
      );
      expect(saved(), ['a.docx']);
    });

    test('reads the RFC 5987 filename* form with an Arabic name', () async {
      await run(
        'https://x.test/download',
        'a',
        _FakeAdapter(
          headers: {
            'content-disposition': [
              "attachment; filename*=UTF-8''%D8%AF%D8%B1%D8%B3.pdf",
            ],
          },
        ),
      );
      expect(saved(), ['a.pdf']);
    });

    test('Content-Type decides when there is no disposition', () async {
      await run(
        'https://x.test/download.php',
        'a',
        _FakeAdapter(headers: {'content-type': ['image/jpeg; charset=x']}),
      );
      expect(saved(), ['a.jpg']);
    });

    test('falls back to the url extension, never a blind png', () async {
      await run(
        'https://x.test/pluginfile.php/1/mod/content/1/book.epub?token=1',
        'a',
        _FakeAdapter(headers: {'content-type': ['application/octet-stream']}),
      );
      expect(saved(), ['a.epub']);
    });

    test('no known extension means no extension at all', () async {
      await run(
        'https://x.test/download.php',
        'a',
        _FakeAdapter(headers: {'content-type': ['application/octet-stream']}),
      );
      expect(saved(), ['a']);
    });
  });

  group('non-file responses', () {
    test('an HTML login page is a failure and is not saved', () async {
      final ok = await run(
        'https://x.test/pluginfile.php/1/file.pdf',
        'a',
        _FakeAdapter(
          headers: {'content-type': ['text/html; charset=utf-8']},
          body: '<html>login</html>'.codeUnits,
        ),
      );
      expect(ok, isFalse);
      expect(saved(), isEmpty);
    });

    test('a Moodle JSON error body is a failure as well', () async {
      final ok = await run(
        'https://x.test/f.pdf',
        'a',
        _FakeAdapter(
          headers: {'content-type': ['application/json']},
          body: '{"errorcode":"invalidtoken"}'.codeUnits,
        ),
      );
      expect(ok, isFalse);
      expect(saved(), isEmpty);
    });

    test('an attached HTML file is still a real file', () async {
      final ok = await run(
        'https://x.test/f',
        'a',
        _FakeAdapter(
          headers: {
            'content-type': ['text/html'],
            'content-disposition': ['attachment; filename="page.html"'],
          },
        ),
      );
      expect(ok, isTrue);
      expect(saved(), ['a.html']);
    });
  });
}
