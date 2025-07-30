part of '../../widget.dart';

class ImageNetworkX extends StatelessWidget {
  const ImageNetworkX({
    super.key,
    required this.imageUrl,
    this.color,
    this.backgroundLoading,
    this.height,
    this.width,
    this.radius = 0,
    this.isFile = false,
    this.fit = BoxFit.cover,
    this.failed,
    this.empty,
  });
  final String imageUrl;
  final Widget? failed;
  final Widget? empty;

  final double? height;
  final double? width;
  final BoxFit fit;
  final bool isFile;
  final Color? color;
  final Color? backgroundLoading;
  final double radius;
  @override
  Widget build(BuildContext context) {
    double getPaddingEmpty() => (width ?? height ?? 200) >= 200
        ? 50.0
        : (width ?? height ?? 100) >= 100
        ? 10.0
        : 2.0;

    String getImageEmpty() => (width ?? height ?? 160) >= 160
        ? context.isDarkMode ? ImageX.logoWhite : ImageX.logo
        : context.isDarkMode ? ImageX.logoWhite : ImageX.logo;
    buildImageType() {
      if (imageUrl.isEmpty) {
        return SizedBox(
          width: width,
          height: height,
          child: empty ??failed??
              Padding(
                padding: EdgeInsets.all(getPaddingEmpty()),
                child: Image.asset(
                  getImageEmpty(),
                ),
              ),
        );
      } else if (isFile) {
        return Image.file(
          File(imageUrl),
          height: height,
          width: width,
          fit: fit,
          color: color,
          errorBuilder: (context, error, stackTrace) => SizedBox(
            width: width,
            height: height,
            child: failed ??empty??
                Padding(
                    padding: EdgeInsets.all(getPaddingEmpty()),
                    child: Image.asset(getImageEmpty())),
          ),
        );
      } else {
        try{
          return Image.network(
            imageUrl,
            height: height,
            width: width,
            fit: fit,
            color: color,
            frameBuilder: (BuildContext context, Widget child, int? frame,
                bool? wasSynchronouslyLoaded) {
              if (frame == null) {
                return Container(
                  color: backgroundLoading ??
                      Theme.of(context).colorScheme.onPrimary,
                  width: width,
                  height: height,
                );
              }
              return child;
            },
            loadingBuilder: (BuildContext context, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress != null) {
                return Container(
                  color: backgroundLoading ??
                      Theme.of(context).colorScheme.onPrimary,
                  width: width,
                  height: height,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  ),
                );
              } else {
                return child;
              }
            },
            errorBuilder: (context, error, stackTrace) => SizedBox(
              width: width,
              height: height,
              child: failed ?? empty??
                  Padding(
                      padding: EdgeInsets.all(getPaddingEmpty()),
                      child: Image.asset(getImageEmpty())),
            ),
          );
        }catch(_){}
      }
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: buildImageType(),
    );
  }
}
