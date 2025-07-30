class StringUtilX{

  /// Separating connected words like: SakerDakak -> Saker Dakak
  static String addSpaceBeforeUpperCase(String val) {
    return val[0] +
        val.substring(1).replaceAllMapped(RegExp(r'([A-Z])'), (match) {
          return ' ${match.group(1)}';
        });
  }

  static String wrap(String text, int maxLineLength) {
    final buffer = StringBuffer();
    final words = text.split(' ');
    int currentLineLength = 0;

    for (final word in words) {
      if (currentLineLength + word.length + 1 > maxLineLength) {
        buffer.write('\n');
        currentLineLength = 0;
      }
      if (currentLineLength > 0) {
        buffer.write(' ');
        currentLineLength += 1;
      }
      buffer.write(word);
      currentLineLength += word.length;
    }

    return buffer.toString();
  }
}