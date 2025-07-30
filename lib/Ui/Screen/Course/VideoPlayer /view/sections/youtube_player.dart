import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../../../../Config/config.dart';
import '../../controller/controller.dart';

class YoutubePlayerSection extends GetView<VideoPlayerController> {
  const YoutubePlayerSection({super.key});

  @override
  Widget build(BuildContext context) {
    if (controller.youtubeController == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      },
      player: YoutubePlayer(
        controller: controller.youtubeController!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: ColorX.primary,
        topActions: <Widget>[
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              controller.youtubeController!.metadata.title,
              style: const TextStyle(color: Colors.white, fontSize: 18.0),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          if (MediaQuery.of(context).orientation == Orientation.landscape)
            IconButton(
              icon: const Icon(
                IconX.arrow_back,
                color: Colors.white,
                size: 25.0,
              ),
              onPressed: Get.back,
            ),
        ],
      ),
      builder:
          (context, player) => Column(
            children: [
              Expanded(child: player),
              Container(
                color: Colors.black.withValues(alpha: 0.8),
                padding: const EdgeInsets.all(16),
                child: Row(
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
                        controller.youtubeController?.toggleFullScreenMode();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
    );
  }
}
