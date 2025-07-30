import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart' as video_player;

import '../../../../../../Config/config.dart';
import '../../controller/controller.dart';

class RegularPlayerSection extends GetView<VideoPlayerController> {
  const RegularPlayerSection({super.key});

  @override
  Widget build(BuildContext context) {
    if (controller.videoPlayerController == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Stack(
      children: [
        // مشغل الفيديو
        Center(
          child: AspectRatio(
            aspectRatio: controller.videoPlayerController!.value.aspectRatio,
            child: video_player.VideoPlayer(controller.videoPlayerController!),
          ),
        ),
        // أدوات التحكم
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // شريط التقدم
                Obx(() {
                  final position = controller.currentPosition;
                  final duration = controller.totalDuration;

                  return Row(
                    children: [
                      Text(
                        controller.formatDuration(position),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value:
                              duration.inMilliseconds > 0
                                  ? position.inMilliseconds /
                                      duration.inMilliseconds
                                  : 0.0,
                          min: 0.0,
                          max: 1.0,
                          activeColor: ColorX.primary,
                          inactiveColor: Colors.white.withValues(alpha: 0.3),
                          onChanged: (value) {
                            final newPosition = Duration(
                              milliseconds:
                                  (value * duration.inMilliseconds).round(),
                            );
                            controller.seekTo(newPosition);
                          },
                        ),
                      ),
                      Text(
                        controller.formatDuration(duration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 8),
                // أزرار التحكم
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        controller.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: controller.togglePlayPause,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.volume_up,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: controller.toggleMute,
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.fullscreen,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () {
                        // تبديل إلى وضع ملء الشاشة
                        controller.toggleFullScreen();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
