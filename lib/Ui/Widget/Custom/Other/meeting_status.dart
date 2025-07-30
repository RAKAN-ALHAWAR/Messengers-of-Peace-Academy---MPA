import 'package:flutter/material.dart';
import '../../../../Config/config.dart';
import '../../widget.dart';

class MeetingStatusX extends StatelessWidget {
  const MeetingStatusX({
    super.key,
    required this.isEnded,
    required this.status,
  });
  final bool isEnded;
  final String status;

  @override
  Widget build(BuildContext context) {
    return ContainerX(
      radius: 100,
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      margin: EdgeInsets.only(bottom: 8),
      isBorder: true,
      borderColor: isEnded ? Color(0xffF8B4B4) : Color(0xff84E1BC),
      color: isEnded ? Color(0xffFDF2F2) : Color(0xffF3FAF7),
      child: TextX(
        status,
        style: TextStyleX.labelMedium,
        color: isEnded ? Color(0xffF05252) : Color(0xff0E9F6E),
      ),
    );
  }
}
