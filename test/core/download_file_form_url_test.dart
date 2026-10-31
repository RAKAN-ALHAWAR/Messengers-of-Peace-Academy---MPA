import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Offset, Size;

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

  group('Arabic Content-Disposition as the real server sends it', () {
    // Dart reads header bytes as Latin-1, so a UTF-8 Arabic file name reaches
    // the app as mojibake with non-ASCII characters (seen on the iOS
    // simulator, Uri.decodeFull threw "Illegal percent encoding" on it).
    final mojibake = latin1.decode(utf8.encode('أساسيات الدعوة.pdf'));

    test('a raw non-ASCII name still gives the extension', () async {
      final ok = await run(
        'https://x.test/pluginfile.php/1/mod_resource/content/0/a.pdf',
        'lesson',
        _FakeAdapter(
          headers: {
            'content-type': ['application/pdf'],
            'content-disposition': ['inline; filename="$mojibake"'],
          },
        ),
      );
      expect(ok, isTrue);
      expect(saved(), ['lesson.pdf']);
    });

    test('a stray percent sign in the name never fails the download', () async {
      final ok = await run(
        'https://x.test/f',
        'lesson',
        _FakeAdapter(
          headers: {
            'content-disposition': ['attachment; filename="100% done.pdf"'],
          },
        ),
      );
      expect(ok, isTrue);
      expect(saved(), ['lesson.pdf']);
    });
  });

  group('progress', () {
    test('reports received and total, ending complete', () async {
      final calls = <(int, int)>[];
      await DownloadFileFormUrl.download(
        'https://x.test/f.pdf',
        'a',
        dio: Dio()
          ..httpClientAdapter = _FakeAdapter(
            headers: {
              'content-type': ['application/pdf'],
              'content-length': ['4'],
            },
          ),
        getDirectory: () async => (dir, false),
        onProgress: (received, total) => calls.add((received, total)),
      );
      expect(calls, isNotEmpty);
      expect(calls.last, (4, 4));
    });

    test('an unknown total is reported as -1, never a fake size', () async {
      final calls = <(int, int)>[];
      await DownloadFileFormUrl.download(
        'https://x.test/f.pdf',
        'a',
        dio: Dio()
          ..httpClientAdapter = _FakeAdapter(
            headers: {'content-type': ['application/pdf']},
          ),
        getDirectory: () async => (dir, false),
        onProgress: (received, total) => calls.add((received, total)),
      );
      expect(calls, isNotEmpty);
      expect(calls.every((c) => c.$2 <= 0), isTrue);
    });
  });

  group('saved copy', () {
    Future<String?> find(String name) => DownloadFileFormUrl.findSaved(
      name,
      getDirectory: () async => (dir, false),
    );

    test('finds the file saved by an earlier download, any extension', () async {
      await run(
        'https://x.test/f.pdf',
        'دورة السلام',
        _FakeAdapter(headers: {'content-type': ['application/pdf']}),
      );
      final path = await find('دورة السلام');
      expect(path, isNotNull);
      expect(path!.endsWith('دورة_السلام.pdf'), isTrue);
    });

    test('is null when nothing was saved, a .part file does not count', () async {
      expect(await find('lesson'), isNull);
      File('${dir.path}/lesson.part').writeAsBytesSync([1]);
      expect(await find('lesson'), isNull);
    });

    test('another file with a longer name is not mistaken for it', () async {
      File('${dir.path}/lesson_two.pdf').writeAsBytesSync([1]);
      expect(await find('lesson'), isNull);
    });

    test('a name with a dot never matches another file', () async {
      File('${dir.path}/lesson.v2.pdf').writeAsBytesSync([1]);
      expect(await find('lesson'), isNull);
      File('${dir.path}/lesson_v2.pdf').writeAsBytesSync([1]);
      final path = await find('lesson.v2');
      expect(path, isNotNull);
      expect(path!.endsWith('lesson_v2.pdf'), isTrue);
    });

    test('two files with the same long name stay two files, found by cmId', () async {
      final course = 'دورة ' * 30;
      final one = '${course}_ملخص الدرس الأول';
      final two = '${course}_ملخص الدرس الثاني';
      // The caller puts the cmId first, so the cut never removes it
      await run('https://x.test/1.pdf', '101_$one',
          _FakeAdapter(headers: {'content-type': ['application/pdf']}, body: [1]));
      await run('https://x.test/2.pdf', '102_$two',
          _FakeAdapter(headers: {'content-type': ['application/pdf']}, body: [2]));
      expect(saved().length, 2, reason: 'the second must not overwrite the first');
      final first = await find('101_$one');
      final second = await find('102_$two');
      expect(first, isNotNull);
      expect(second, isNotNull);
      expect(first, isNot(second));
      expect(File(first!).readAsBytesSync(), [1]);
      expect(File(second!).readAsBytesSync(), [2]);
    });

    test('a file saved under the old scheme is not opened for a new name', () async {
      File('${dir.path}/Course_Summary.pdf').writeAsBytesSync([1]);
      expect(await find('101_Course_Summary'), isNull);
    });

    test('the share sheet gets a non empty origin, centered, for the iPad', () {
      final params = DownloadFileFormUrl.shareParamsFor(
        '/tmp/a.pdf',
        const Size(820, 1180),
      );
      final origin = params.sharePositionOrigin!;
      expect(origin.isEmpty, isFalse);
      expect(origin.center, const Offset(410, 590));
      expect(params.files!.single.path, '/tmp/a.pdf');
    });

    test('openSaved says whether a copy was found', () async {
      expect(
        await DownloadFileFormUrl.openSaved(
          'lesson',
          getDirectory: () async => (dir, false),
        ),
        isFalse,
      );
      File('${dir.path}/lesson.pdf').writeAsBytesSync([1]);
      expect(
        await DownloadFileFormUrl.openSaved(
          'lesson',
          getDirectory: () async => (dir, false),
        ),
        isTrue,
      );
    });
  });

  group('leftovers', () {
    test('a failure after the body arrived leaves no .part file', () async {
      // The final name is taken by a folder, so the rename step throws
      Directory('${dir.path}/a.pdf').createSync();
      final ok = await run(
        'https://x.test/f.pdf',
        'a',
        _FakeAdapter(headers: {'content-type': ['application/pdf']}),
      );
      expect(ok, isFalse);
      expect(File('${dir.path}/a.part').existsSync(), isFalse);
    });
  });
}
