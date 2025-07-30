// ignore_for_file: avoid_print

part 'lib/console_color_status.dart';
part 'lib/console_ansi_color.dart';

class ConsoleUtilX {
  static void log(
    String message, {
    ConsoleColorStatus color = ConsoleColorStatus.white,
  }) {
    String colorCode = _getColorCode(color);
    _printMessage('$colorCode$message${ConsoleAnsiColorX.reset}');
  }

  static void error(String message) {
    String colorCode = _getColorCode(ConsoleColorStatus.red);
    _printMessage('$colorCode$message${ConsoleAnsiColorX.reset}');
  }

  static void warn(String message) {
    String colorCode = _getColorCode(ConsoleColorStatus.yellow);
    _printMessage('$colorCode$message${ConsoleAnsiColorX.reset}');
  }

  static void debug(String message) {
    String colorCode = _getColorCode(ConsoleColorStatus.cyan);
    _printMessage('$colorCode$message${ConsoleAnsiColorX.reset}');
  }

  static void _printMessage(String message) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern
        .allMatches(message)
        .forEach(
          (match) => print(match.group(0)),
        ); // On other platforms, print normally
  }

  static String _getColorCode(ConsoleColorStatus color) {
    switch (color) {
      case ConsoleColorStatus.red:
        return ConsoleAnsiColorX.red;
      case ConsoleColorStatus.green:
        return ConsoleAnsiColorX.green;
      case ConsoleColorStatus.yellow:
        return ConsoleAnsiColorX.yellow;
      case ConsoleColorStatus.blue:
        return ConsoleAnsiColorX.blue;
      case ConsoleColorStatus.magenta:
        return ConsoleAnsiColorX.magenta;
      case ConsoleColorStatus.cyan:
        return ConsoleAnsiColorX.cyan;
      case ConsoleColorStatus.white:
        return ConsoleAnsiColorX.white;
    }
  }
}
