import 'package:flutter/material.dart';

import '../../widget.dart';

class MessageCardX extends StatelessWidget {
  const MessageCardX({super.key, required this.color, required this.text, this.icon});
  final MaterialColor color;
  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return ContainerX(
      width: double.maxFinite,
      color: color.shade50,
      borderColor: color.shade300,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if(icon!=null)
          Icon(
            icon,
            color: color.shade500,
          ),
          if(icon!=null)
          const SizedBox(width: 8),
          Flexible(
            child: TextX(
              text,
              color: color.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
