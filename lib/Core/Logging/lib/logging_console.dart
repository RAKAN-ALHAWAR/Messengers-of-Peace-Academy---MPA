part of '../logging.dart';

class LoggingConsoleX {
  static log(FlutterErrorDetails details) {
    _customErrorLogger(details);
  }

  static logger(Object error, StackTrace stack) {
    _customErrorLogger(FlutterErrorDetails(exception: error, stack: stack));
  }

  static void _customErrorLogger(FlutterErrorDetails details) {
    String border = "║       ";
    String errorMessage =
        '\n╔══════════════════════════════════════════════╡ ${details.library ?? "SEZARD"} ╞══════════════════════════════════════════════╗\n';
    errorMessage += "${border}Error Details:";
    errorMessage += "\n$border\n";
    errorMessage +=
        '${details.exceptionAsString().trim().split('\n').expand((line) => StringUtilX.wrap(line, 125).split('\n')).map((line) => '$border$line').toList().join('\n')}\n';
    errorMessage +=
        "╠----------------------------------------------------------------------------------------------------------------\n";
    if (details.context!=null && details.context.toString().isNotEmpty) {
      errorMessage += "${border}Context:";
      errorMessage += "\n$border\n";
      errorMessage += "${details.context
          .toString()
          .split('\n')
          .expand((line) => StringUtilX.wrap(line, 125).split('\n'))
          .map((line) => '$border$line')
          .toList()
          .join('\n')}\n";
      errorMessage +=
          "╠----------------------------------------------------------------------------------------------------------------\n";
    }
    if (details.stack.toString().isNotEmpty) {
      String linksInProject = details.stack
          .toString()
          .split('\n')
          .expand((line) => StringUtilX.wrap(line, 125).split('\n'))
          .where((line) {
            return line.contains("package:${InfoUtilX.name}");
          })
          .map((line) => '$border$line')
          .toList()
          .join('\n');
      if (linksInProject.isNotEmpty) {
        errorMessage += '${border}Links in the project';
        errorMessage += "\n$border\n";
        errorMessage += "$linksInProject\n";
        errorMessage +=
            "╠----------------------------------------------------------------------------------------------------------------\n";
      }
      String linksInEnv = details.stack
          .toString()
          .split('\n')
          .expand((line) => StringUtilX.wrap(line, 125).split('\n'))
          .where((line) {
            return !line.contains("package:${InfoUtilX.name}");
          })
          .map((line) => '$border$line')
          .toList()
          .join('\n');
      if (linksInEnv.isNotEmpty) {
        errorMessage += '${border}Links in the environment:';
        errorMessage += "\n$border\n";
        errorMessage += linksInEnv;
      }
    }

    errorMessage +=
        '\n╚═══════════════════════════════════════════════════════════════════════════════════════════════════════════════╝\n\n';

    ConsoleUtilX.error(errorMessage);
  }
}
