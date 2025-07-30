import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:messengersofpeace/Config/Translation/translation.dart';
import 'package:video_player/video_player.dart' as video_player;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerController extends GetxController {
  //============================================================================
  // Variables

  /// Video URL from previous screen
  String url = Get.arguments ?? '';

  /// Loading state
  final isLoading = true.obs;

  /// Error state
  final hasError = false.obs;

  /// Error message
  final errorMessage = ''.obs;

  /// YouTube video type
  final isYouTubeVideo = false.obs;

  /// YouTube video player controller
  YoutubePlayerController? youtubeController;

  /// Regular video player controller
  video_player.VideoPlayerController? videoPlayerController;

  //============================================================================
  // Functions

  /// Initialize video player
  void _initializeVideo() {
    if (url.isEmpty) {
      hasError.value = true;
      errorMessage.value = 'Video is not available';
      isLoading.value = false;
      return;
    }

    /// Check if the URL is a YouTube URL
    if (_isYouTubeUrl(url)) {
      _initializeYouTubePlayer();
    } else {
      _initializeRegularPlayer();
    }
  }

  /// Check if the URL is a YouTube URL
  bool _isYouTubeUrl(String url) {
    return url.contains('youtube.com') ||
        url.contains('youtu.be') ||
        url.contains('youtube-nocookie.com');
  }

  /// Initialize YouTube player
  void _initializeYouTubePlayer() {
    try {
      /// Convert URL to video ID
      final videoId = YoutubePlayer.convertUrlToId(url);

      /// Check if the video ID is valid
      if (videoId != null) {
        /// Set YouTube video type
        isYouTubeVideo.value = true;

        /// Initialize YouTube player controller
        youtubeController = YoutubePlayerController(
          initialVideoId: videoId,
          flags: YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
            enableCaption: true,
            captionLanguage: TranslationX.getLanguageCode,
            showLiveFullscreenButton: false,
          ),
        );

        /// Set loading state to false
        isLoading.value = false;
      } else {
        /// Set error message
        throw Exception('Invalid YouTube URL');
      }
    } catch (e) {
      /// Set error message
      hasError.value = true;
      errorMessage.value = 'Video is not available';

      /// Set loading state to false
      isLoading.value = false;
    }
  }

  /// Initialize regular video player
  void _initializeRegularPlayer() {
    try {
      /// Set YouTube video type to false
      isYouTubeVideo.value = false;

      /// Initialize regular video player controller
      videoPlayerController = video_player.VideoPlayerController.networkUrl(
        Uri.parse(url),
      );

      /// Initialize regular video player controller
      videoPlayerController!
          .initialize()
          .then((_) {
            /// Set loading state to false
            isLoading.value = false;
          })
          .catchError((error) {
            /// Set error message
            hasError.value = true;
            errorMessage.value = 'Video is not available';

            /// Set loading state to false
            isLoading.value = false;
          });
    } catch (e) {
      /// Set error message
      hasError.value = true;
      errorMessage.value = 'Video is not available';

      /// Set loading state to false
      isLoading.value = false;
    }
  }

  /// Toggle play/pause
  void togglePlayPause() {
    if (isYouTubeVideo.value) {
      /// Check if the video is playing
      if (youtubeController?.value.isPlaying == true) {
        /// Pause the video
        youtubeController?.pause();
      } else {
        /// Play the video
        youtubeController?.play();
      }
    } else {
      /// Check if the video is playing
      if (videoPlayerController?.value.isPlaying == true) {
        /// Pause the video
        videoPlayerController?.pause();
      } else {
        /// Play the video
        videoPlayerController?.play();
      }
    }
  }

  /// Toggle mute
  void toggleMute() {
    if (isYouTubeVideo.value) {
      /// Mute the video
      youtubeController?.mute();
    } else {
      /// Get current volume
      final currentVolume = videoPlayerController?.value.volume ?? 0.0;

      /// Set volume
      videoPlayerController?.setVolume(currentVolume > 0.0 ? 0.0 : 1.0);
    }
  }

  /// Seek to a specific position in the video
  void seekTo(Duration position) {
    if (isYouTubeVideo.value) {
      /// Seek to a specific position in the video
      youtubeController?.seekTo(position);
    } else {
      /// Seek to a specific position in the video
      videoPlayerController?.seekTo(position);
    }
  }

  /// Get current position
  Duration get currentPosition {
    if (isYouTubeVideo.value) {
      /// Get current position from YouTube player
      return youtubeController?.value.position ?? Duration.zero;
    } else {
      /// Get current position from regular video player
      return videoPlayerController?.value.position ?? Duration.zero;
    }
  }

  /// Get total duration
  Duration get totalDuration {
    if (isYouTubeVideo.value) {
      /// Get total duration from YouTube player
      return youtubeController?.value.metaData.duration ?? Duration.zero;
    } else {
      /// Get total duration from regular video player
      return videoPlayerController?.value.duration ?? Duration.zero;
    }
  }

  /// Check if the video is playing
  bool get isPlaying {
    if (isYouTubeVideo.value) {
      /// Check if the video is playing from YouTube player
      return youtubeController?.value.isPlaying ?? false;
    } else {
      /// Check if the video is playing from regular video player
      return videoPlayerController?.value.isPlaying ?? false;
    }
  }

  /// Format duration
  String formatDuration(Duration duration) {
    /// Format duration
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    /// Get hours
    final hours = twoDigits(duration.inHours);

    /// Get minutes
    final minutes = twoDigits(duration.inMinutes.remainder(60));

    /// Get seconds
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    /// Return formatted duration
    return duration.inHours > 0
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  /// Toggle full screen
  void toggleFullScreen() {
    /// Check if the device is in landscape mode
    if (MediaQuery.of(Get.context!).orientation == Orientation.landscape) {
      /// Set preferred orientations to portrait
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } else {
      /// Set preferred orientations to landscape
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
  }

  //============================================================================
  // Lifecycle

  @override
  void onInit() {
    super.onInit();

    /// Initialize video player
    _initializeVideo();
  }

  @override
  void onClose() {
    /// Dispose YouTube player
    youtubeController?.dispose();

    /// Dispose regular video player
    videoPlayerController?.dispose();
    super.onClose();
  }
}
