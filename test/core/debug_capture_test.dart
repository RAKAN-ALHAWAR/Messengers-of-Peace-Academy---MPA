import 'package:flutter_test/flutter_test.dart';
import 'package:messengersofpeace/Core/Helper/http/debug_capture.dart';

void main() {
  const secret = 'abcdef0123456789abcdef0123456789';

  group('capture masking', () {
    test('masks a token key in a map, as before', () {
      final out = HttpDebugCaptureX.mask({'token': secret, 'name': 'a'});
      expect(out, {'token': '<masked>', 'name': 'a'});
    });

    test('masks token=<value> inside a download url string', () {
      final url =
          'https://mopacademy.org/webservice/pluginfile.php/1/mod_resource/'
          'content/0/a.pdf?token=$secret&forcedownload=1';
      final out =
          HttpDebugCaptureX.mask({'download_url': url}) as Map<dynamic, dynamic>;
      expect(out['download_url'], isNot(contains(secret)));
      expect(
        out['download_url'],
        'https://mopacademy.org/webservice/pluginfile.php/1/mod_resource/'
        'content/0/a.pdf?token=<masked>&forcedownload=1',
      );
    });

    test('masks wstoken and privatetoken values, at the end or mid string', () {
      final out = HttpDebugCaptureX.mask([
        'https://x.test/a?wstoken=$secret',
        'https://x.test/a?x=1&privatetoken=$secret&y=2',
        'see https://x.test/a?TOKEN=$secret.',
      ]);
      final text = out.toString();
      expect(text, isNot(contains(secret)));
      expect(
        (out as List)[1],
        'https://x.test/a?x=1&privatetoken=<masked>&y=2',
      );
    });

    test('masks access_token= and the URL-encoded token%3D forms', () {
      final out = HttpDebugCaptureX.mask([
        'https://x.test/a?access_token=$secret&y=2',
        'https://x.test/r?u=https%3A%2F%2Fx.test%2Fa%3Ftoken%3D$secret%26y%3D2',
        'https://x.test/r?u=a%3Fwstoken%3D$secret',
      ]);
      expect(out.toString(), isNot(contains(secret)));
      expect(
        (out as List)[0],
        'https://x.test/a?access_token=<masked>&y=2',
      );
      expect(
        out[1],
        'https://x.test/r?u=https%3A%2F%2Fx.test%2Fa%3Ftoken%3D<masked>%26y%3D2',
      );
    });

    test('masks inside nested lists and maps', () {
      final out = HttpDebugCaptureX.mask({
        'activities': [
          {'download_url': 'https://x.test/a.pdf?token=$secret'},
        ],
      });
      expect(out.toString(), isNot(contains(secret)));
    });

    test('leaves strings without a token untouched', () {
      expect(
        HttpDebugCaptureX.mask('https://x.test/a.pdf?forcedownload=1'),
        'https://x.test/a.pdf?forcedownload=1',
      );
      expect(HttpDebugCaptureX.mask('a token is needed'), 'a token is needed');
    });
  });
}
