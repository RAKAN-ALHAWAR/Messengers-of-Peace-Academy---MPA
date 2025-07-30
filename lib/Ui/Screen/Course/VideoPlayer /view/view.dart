import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../../Config/config.dart';
import '../../../../Widget/widget.dart';
import '../controller/controller.dart';
import 'sections/regular_player.dart';
import 'sections/youtube_player.dart';

class VideoPlayerView extends GetView<VideoPlayerController> {
  const VideoPlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    /// Video player view
    return Scaffold(
      backgroundColor: Colors.black,

      /// App bar for portrait mode
      appBar:
          MediaQuery.of(context).orientation == Orientation.portrait
              ? AppBar(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                title: TextX(
                  'Video Player',
                  style: TextStyleX.titleMedium,
                  color: Colors.white,
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: Get.back,
                ),
                systemOverlayStyle: const SystemUiOverlayStyle(
                  statusBarColor: Colors.black,
                  statusBarIconBrightness: Brightness.light,
                ),
              )
              : null,

      /// Body
      body: SafeArea(
        child: Obx(() {
          /// Loading state
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          /// Error state
          if (controller.hasError.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  TextX(
                    controller.errorMessage.value,
                    style: TextStyleX.titleMedium,
                    color: Colors.white,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: Get.back,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorX.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: TextX('Back'),
                  ),
                ],
              ),
            );
          }

          /// Video player
          return Center(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    controller.isYouTubeVideo.value
                        ? const YoutubePlayerSection()
                        : const RegularPlayerSection(),
              ),
            ),
          );
        }),
      ),
    );
  }
}
