import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:messengersofpeace/Core/Error/error.dart';
import 'package:messengersofpeace/Core/Helper/http/http.dart';
import 'package:messengersofpeace/Data/data.dart';
import 'package:messengersofpeace/Data/Database/remote/remote_data.dart';
import 'package:messengersofpeace/Data/Model/basic/data_source_param.dart';

void main() {
  const authUrl = 'https://synthetic.invalid/?wstoken=synthetic-token';
  const publicUrl = 'https://synthetic.invalid/public';
  late Directory directory;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa_offline_cache');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('app');
    HttpX.init();
  });
  setUp(() async {
    await HiveX.box.clear();
    await LocalDataX.put(LocalKeyX.userid, 'synthetic-A');
    await LocalDataX.put(LocalKeyX.token, 'synthetic-token');
  });
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  Future<Map<String, dynamic>> read(String url, int status, String body) {
    return http.runWithClient(() async {
      final (data, _) = await RemoteDataSourceX.get<Map<String, dynamic>>(
        url,
        param: DataSourceParamX(
          languageCode: 'ar',
          localCacheKey: 'synthetic-cache',
        ),
      );
      return data;
    }, () => MockClient((_) async => http.Response(body, status)));
  }

  test(
    'authenticated request is served from the same user cache offline',
    () async {
      expect(await read(authUrl, 200, '{"private":"account-A"}'), {
        'private': 'account-A',
      });
      expect(await read(authUrl, 500, ''), {'private': 'account-A'});
    },
  );

  test('a different user gets no cached data of the previous user', () async {
    await read(authUrl, 200, '{"private":"account-A"}');
    await LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
    await expectLater(read(authUrl, 500, ''), throwsA(isA<ErrorX>()));
  });

  test(
    'old un-namespaced key is never read for an authenticated request',
    () async {
      await LocalDataX.put('synthetic-cache', {'private': 'legacy'});
      await expectLater(read(authUrl, 500, ''), throwsA(isA<ErrorX>()));
    },
  );

  test('unauthenticated request keeps the plain shared cache key', () async {
    await LocalDataX.remove(LocalKeyX.userid);
    await LocalDataX.remove(LocalKeyX.token);
    await read(publicUrl, 200, '{"public":"data"}');
    expect(HiveX.box.containsKey('synthetic-cache'), isTrue);
    expect(await read(publicUrl, 500, ''), {'public': 'data'});
  });
}
