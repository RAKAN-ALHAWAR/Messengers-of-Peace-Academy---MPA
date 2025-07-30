import 'package:flutter/material.dart';
import '../../../../Config/config.dart';
import '../../../../Core/core.dart';
import '../../widget.dart';

class OptionCardX extends StatelessWidget {
  final String title;
  final IconData? icon;
  final void Function()? onTap;
  final bool isDanger;
  final Widget? child;
  final double marginBottom;

  const OptionCardX({
    required this.title,
    this.icon,
    this.onTap,
    this.child,
    this.isDanger = false,
    this.marginBottom = 12,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ContainerX(
        radius: StyleX.radiusMd,
        isBorder: false,
        height: 56,
        margin: EdgeInsets.only(bottom: marginBottom),
        padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 12),
        child: Row(
          children: [
            if (icon != null)
              Container(
                height: 36,
                width: 36,
                margin: EdgeInsets.only(
                  right: DeviseX.isLTR ? 10.0 : 0.0,
                  left: DeviseX.isLTR ? 0 : 14,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 26,
                  ),
                ),
              ),
            Expanded(
              child: TextX(
                title,
                style: TextStyleX.bodyLarge,
                color: isDanger ? ColorX.danger : null,
              ),
            ),
            child != null
                ? child!
                : Container(
                  margin: EdgeInsets.only(
                    left: DeviseX.isLTR ? 22 : 5,
                    right: DeviseX.isLTR ? 5 : 22,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: isDanger ? ColorX.danger : ColorX.grey.shade500,
                    size: 16,
                  ),
                ),
          ],
        ),
      ),
    );
  }
}
