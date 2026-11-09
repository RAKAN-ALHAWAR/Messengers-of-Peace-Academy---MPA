import 'package:yaml/yaml.dart';
import 'package:flutter/services.dart';

class InfoUtilX {
  static String name = '';
  static String description = '';
  static String version = '';
  static String author = '';
  static ({String version, String buildNumber})? installedRelease;

  static ({String version, String buildNumber})? get displayRelease {
    final installed = installedRelease;
    if (installed != null) return installed;

    // Older native binaries can run updated Dart code during development.
    final bundled = version.trim().split('+');
    if (bundled.length != 2 || bundled.any((part) => part.isEmpty)) return null;
    return (version: bundled[0], buildNumber: bundled[1]);
  }

  static const _packageChannel = MethodChannel('mopa/package_info');

  static Future<void> init() async {
    Map yaml = {};
    try {
      yaml = loadYaml(await rootBundle.loadString("pubspec.yaml"));
    } catch (_) {}
    name = yaml["name"] ?? "";
    description = yaml["description"] ?? "";
    version = yaml["version"] ?? "";
    author = yaml["author"] ?? "";
    installedRelease = null;
    try {
      final info = await _packageChannel.invokeMapMethod<String, String>(
        'getVersion',
      );
      final version = info?['version']?.trim();
      final build = info?['buildNumber']?.trim();
      if (version != null &&
          version.isNotEmpty &&
          build != null &&
          build.isNotEmpty) {
        installedRelease = (version: version, buildNumber: build);
      }
    } on MissingPluginException {
      // Only the Android and iOS runners provide installed package metadata.
    } on PlatformException {
      // Keep account access available if package metadata cannot be read.
    }
  }
}
