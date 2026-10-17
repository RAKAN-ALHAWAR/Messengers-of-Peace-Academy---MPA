import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:messengersofpeace/Core/Error/error.dart';
import 'package:messengersofpeace/Core/Helper/http/http.dart';

void main() {
  for (final status in [302, 401, 403, 429, 500]) {
    test(
      'empty HTTP $status rejects rather than acknowledging a mutation',
      () async {
        await expectLater(
          HttpResponseX.call<dynamic>(http.Response('', status)),
          throwsA(
            isA<ErrorX>().having((error) => error.errorCode, 'status', status),
          ),
        );
      },
    );
  }

  for (final status in [200, 204]) {
    test('legitimate empty HTTP $status remains null', () async {
      expect(
        await HttpResponseX.call<dynamic>(http.Response('', status)),
        isNull,
      );
    });
  }

  for (final body in ['', '{"message":"Synthetic unauthorized"}']) {
    test(
      'explicit ignoreUnauthorized preserves fallback for body length ${body.length}',
      () async {
        expect(
          await HttpResponseX.call<dynamic>(
            http.Response(body, 401),
            'fallback',
            true,
          ),
          'fallback',
        );
      },
    );
  }

  test(
    'ignoreUnauthorized does not suppress another empty error status',
    () async {
      await expectLater(
        HttpResponseX.call<dynamic>(http.Response('', 403), null, true),
        throwsA(
          isA<ErrorX>().having((error) => error.errorCode, 'status', 403),
        ),
      );
    },
  );

  test('successful JSON and populated error details remain intact', () async {
    expect(
      await HttpResponseX.call<Map<String, dynamic>>(
        http.Response('{"status":"success"}', 200),
      ),
      {'status': 'success'},
    );
    await expectLater(
      HttpResponseX.call<dynamic>(
        http.Response('{"message":"Synthetic forbidden"}', 403),
      ),
      throwsA(
        isA<ErrorX>()
            .having((error) => error.errorCode, 'status', 403)
            .having(
              (error) => error.details['message'],
              'message',
              'Synthetic forbidden',
            ),
      ),
    );
  });

  test('informational response retains its explicit fallback policy', () async {
    expect(
      await HttpResponseX.call<dynamic>(http.Response('', 102), 'processing'),
      'processing',
    );
  });
}
