part of '../../widget.dart';

class TextX extends StatelessWidget {
  const TextX(
    this.data, {
    super.key,
    this.style,
    this.size,
    this.color,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines = 1000,
    this.fontWeight,
    this.textDirection,
    this.textDecoration,
  });
  final String data;
  final TextStyle? style;
  final Color? color;
  final TextAlign? textAlign;
  final FontWeight? fontWeight;
  final TextOverflow overflow;
  final int maxLines;
  final double? size;
  final TextDirection? textDirection;
  final TextDecoration? textDecoration;
  @override
  Widget build(BuildContext context) {
    return Text(
      data.tr,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: true,
      textDirection: textDirection,
      style:
          style?.copyWith(
            color: color,
            fontWeight: fontWeight,
            fontSize: size,
            decoration: textDecoration,
          ) ??
          TextStyleX.labelLarge.copyWith(
            color: color,
            fontWeight: fontWeight,
            fontSize: size,
            decoration: textDecoration,
          ),
      textAlign: textAlign,
    );
  }
}
