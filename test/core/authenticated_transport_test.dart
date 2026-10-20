import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:messengersofpeace/Core/Error/error.dart';
import 'package:messengersofpeace/Core/Helper/http/http.dart';
import 'package:messengersofpeace/Core/Service/session_lease.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Database/remote/remote_data.dart';
import 'package:messengersofpeace/Data/Model/basic/data_source_param.dart';

void main() {
  const url = 'https://synthetic.invalid/?wstoken=synthetic-token';
  late Directory directory;
  late List<SessionLeaseX> expirations;
  late StreamSubscription<SessionLeaseX> subscription;
  final unauthorized = isA<ErrorX>().having((e) => e.errorCode, 'status', 401);
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa_transport');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('app');
    HttpX.init();
  });
  setUp(() async {
    await HiveX.box.clear();
    await LocalDataX.put(LocalKeyX.userid, 'synthetic-A');
    await LocalDataX.put(LocalKeyX.token, 'synthetic-token');
    expirations = [];
    subscription = SessionExpiryX.events.listen(expirations.add);
  });
  tearDown(() async => subscription.cancel());
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  for (final body in ['', 'Expired', '[]', '{"error":"expired"}']) {
    test(
      '401 is authoritative before typed decode or fallback: $body',
      () async {
        await http.runWithClient(() async {
          await expectLater(
            HttpX.get<Map<String, dynamic>>(
              url: url,
              fallbackResponse: const {'fallback': true},
            ),
            throwsA(unauthorized),
          );
        }, () => MockClient((_) async => http.Response(body, 401)));
        expect(expirations, hasLength(1));
      },
    );
  }
  test(
    'explicit ignored401 fallback remains available without expiry',
    () async {
      await http.runWithClient(() async {
        expect(
          await HttpX.get<Map<String, dynamic>>(
            url: url,
            ignoreUnauthorized: true,
            fallbackResponse: const {'fallback': true},
          ),
          {'fallback': true},
        );
      }, () => MockClient((_) async => http.Response('Expired', 401)));
      expect(expirations, isEmpty);
    },
  );
  for (final status in [403, 500]) {
    test('$status never expires the session', () async {
      await http.runWithClient(() async {
        await expectLater(
          HttpX.get<Map<String, dynamic>>(url: url),
          throwsA(isA<ErrorX>().having((e) => e.errorCode, 'status', status)),
        );
      }, () => MockClient((_) async => http.Response('error', status)));
      expect(expirations, isEmpty);
    });
  }
  test('timeout never expires the session', () async {
    await http.runWithClient(() async {
      await expectLater(HttpX.get(url: url), throwsA(isA<ErrorX>()));
    }, () => MockClient((_) async => throw TimeoutException('synthetic')));
    expect(expirations, isEmpty);
  });
  test('late A401 does not expire B', () async {
    final response = Completer<http.Response>();
    await http.runWithClient(() async {
      final pending = HttpX.get(url: url);
      final assertion = expectLater(pending, throwsA(unauthorized));
      await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
      await LocalDataX.put(LocalKeyX.token, 'synthetic-B-token');
      response.complete(http.Response('', 401));
      await assertion;
    }, () => MockClient((_) => response.future));
    expect(expirations, isEmpty);
    expect(LocalDataX.userid, 'synthetic-B');
  });
  test('public wire401 cannot expire an unrelated user token', () async {
    await http.runWithClient(() async {
      await expectLater(
        HttpX.get(url: 'https://synthetic.invalid/?wstoken=public'),
        throwsA(unauthorized),
      );
    }, () => MockClient((_) async => http.Response('', 401)));
    expect(expirations, isEmpty);
  });
  test(
    'Moodle invalidtoken expires once; HTTP401 is not emitted twice',
    () async {
      for (final status in [200, 401]) {
        expirations.clear();
        await http.runWithClient(
          () async {
            await expectLater(
              RemoteDataSourceX.get<Map<String, dynamic>>(
                url,
                param: DataSourceParamX(languageCode: 'ar'),
              ),
              throwsA(unauthorized),
            );
          },
          () => MockClient(
            (_) async => http.Response('{"errorcode":"invalidtoken"}', status),
          ),
        );
        expect(expirations, hasLength(1));
      }
    },
  );
  test(
    'legacy unowned cache cannot supply authenticated data on failure',
    () async {
      await LocalDataX.put('synthetic-cache', {'private': 'account-A'});
      await http.runWithClient(() async {
        await expectLater(
          RemoteDataSourceX.get<Map<String, dynamic>>(
            url,
            param: DataSourceParamX(
              languageCode: 'ar',
              localCacheKey: 'synthetic-cache',
            ),
          ),
          throwsA(isA<ErrorX>()),
        );
      }, () => MockClient((_) async => http.Response('', 500)));
    },
  );
  test('late successful A response cannot reach B or populate cache', () async {
    final response = Completer<http.Response>();
    await http.runWithClient(() async {
      final pending = RemoteDataSourceX.get<Map<String, dynamic>>(
        url,
        param: DataSourceParamX(
          languageCode: 'ar',
          localCacheKey: 'synthetic-cache',
        ),
      );
      final assertion = expectLater(pending, throwsA(isA<ErrorX>()));
      await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
      response.complete(http.Response('{"private":"account-A"}', 200));
      await assertion;
    }, () => MockClient((_) => response.future));
    expect(HiveX.box.containsKey('synthetic-cache'), isFalse);
  });
}
