import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../Config/config.dart';
import '../../../../Ui/Widget/widget.dart';

class SectionTitleX extends StatelessWidget {
  const SectionTitleX({
    super.key,
    required this.title,
    this.icon,
    this.showMore,
    this.iconSize = 22,
  });
  final IconData? icon;
  final double iconSize;
  final String title;
  final Function()? showMore;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            children: [
              if (icon != null)
                Icon(
                  icon,
                  color: Theme.of(context).primaryColor,
                  size: iconSize,
                ),
              if (icon != null) const SizedBox(width: 8),
              Flexible(
                child: TextX(
                  title,
                  color: Theme.of(context).primaryColor,
                  size: 16.0,
                  fontWeight: FontWeight.w600,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        if (showMore != null)
          InkWell(
            onTap: showMore,
            borderRadius: BorderRadius.circular(StyleX.radius),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: TextX("More", style: TextStyleX.labelLarge),
            ),
          ),
      ],
    ).marginOnly(bottom: 10);
  }
}
