part of '../../widget.dart';

class BackButtonX extends StatelessWidget {
  const BackButtonX({
    this.onTap,
    this.color,
    this.background,
    this.backValue,
    super.key,
  });
  final Function()? onTap;
  final Color? color;
  final Color? background;
  final dynamic backValue;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: StyleX.hPaddingApp),
          child: InkWell(
            onTap: onTap ?? () => Get.back(result: backValue),
            borderRadius: BorderRadius.circular(100),
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                color: background ?? Colors.transparent,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: Icon(
                  size: 24,
                  Icons.arrow_back,
                  color: color ?? Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
