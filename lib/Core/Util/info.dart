import 'package:yaml/yaml.dart';
import 'package:flutter/services.dart';

class InfoUtilX {
  static String name = '';
  static String description = '';
  static String version = '';
  static String author = '';

  static Future<void> init() async {
    Map yaml = {};
    try {
      yaml = loadYaml(await rootBundle.loadString("pubspec.yaml"));
    } catch (_) {}
    name = yaml["name"] ?? "";
    description = yaml["description"] ?? "";
    version = yaml["version"] ?? "";
    author = yaml["author"] ?? "";
  }
}
