import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:get/get.dart';

import '../../../../Config/config.dart';
import '../../../../Data/data.dart';
import '../../widget.dart';

class HtmlWidgetX extends StatelessWidget {
  final String html;
  final TextStyle? textStyle;
  const HtmlWidgetX({super.key, required this.html, this.textStyle});

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      context.isDarkMode
          ? html.replaceAllMapped(
            RegExp(
              r'color:\s*(rgb\((\d+),\s*(\d+),\s*(\d+)\)|#([0-9a-fA-F]{6})|black|white)',
              caseSensitive: false,
            ),
            (match) {
              if (match.group(1)?.startsWith('rgb(') ?? false) {
                final r = int.parse(match.group(2)!);
                final g = int.parse(match.group(3)!);
                final b = int.parse(match.group(4)!);
                if (r == g && g == b) {
                  return 'color: rgb(255, 255, 255)';
                }
                return 'color: rgb(0, 0, 0)';
              }
              if (match.group(1)?.startsWith('#') ?? false) {
                final hex = match.group(5)!;
                if (hex[0] == hex[1] && hex[2] == hex[3] && hex[4] == hex[5]) {
                  return 'color: #ffffff';
                }
                return 'color: #000000';
              }
              const colorMap = {'black': 'white', 'white': 'black'};
              return 'color: ${colorMap[match.group(1)?.toLowerCase()] ?? match.group(1)}';
            },
          )
          : html,
      customWidgetBuilder: (element) {
        if (element.localName == 'img') {
          return ImageNetworkX(
            imageUrl: element.attributes[NameX.src].toString(),
            width: double.maxFinite,
          );
        }
        return null;
      },
      textStyle: textStyle ?? TextStyleX.bodyMedium,
    );
  }
}
