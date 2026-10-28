import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Debug-only API response recorder used to diagnose real server payloads.
///
/// Off unless the app is a debug build started with
/// `--dart-define=MOPA_CAPTURE=true`. Each response is written to
/// `<app documents>/api-capture/<n>-<wsfunction>.json`. The URL (which carries
/// the wstoken) is never stored, and token-like keys in the body are masked.
class HttpDebugCaptureX {
  static const _enabled = bool.fromEnvironment('MOPA_CAPTURE');
  static const _maskedKeys = {'token', 'wstoken', 'privatetoken', 'password'};
  static int _counter = 0;

  static bool get isEnabled => kDebugMode && _enabled;

  static Future<void> record(String url, int statusCode, String body) async {
    if (!isEnabled) return;
    try {
      final function =
          Uri.parse(url).queryParameters['wsfunction'] ?? 'unknown';
      final directory = await getApplicationDocumentsDirectory();
      final folder = Directory('${directory.path}/api-capture');
      await folder.create(recursive: true);
      _counter++;
      final name = '${_counter.toString().padLeft(4, '0')}-$function.json';
      final payload = {
        'function': function,
        'status': statusCode,
        'body': _mask(_tryDecode(body)),
      };
      await File('${folder.path}/$name').writeAsString(
        const JsonEncoder.withIndent('  ').convert(payload),
      );
    } catch (_) {
      // Best-effort diagnostics: a capture failure must never affect the app.
    }
  }

  static Object? _tryDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  static Object? _mask(Object? value) {
    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(
          key,
          _maskedKeys.contains(key.toString().toLowerCase())
              ? '<masked>'
              : _mask(item),
        ),
      );
    }
    if (value is List) return value.map(_mask).toList();
    return value;
  }
}
