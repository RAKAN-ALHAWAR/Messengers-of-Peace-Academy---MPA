import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart' as vp;
import 'package:messengersofpeace/Ui/Screen/Course/VideoPlayer /controller/controller.dart';
import 'package:messengersofpeace/Ui/Screen/Course/VideoPlayer /view/sections/regular_player.dart';

class _Player extends vp.VideoPlayerController {
  _Player() : super.networkUrl(Uri.parse('https://synthetic.invalid/video'));
  Duration? requestedSeek;
  @override
  Future<void> play() async {
    value = value.copyWith(isPlaying: true);
  }

  @override
  Future<void> pause() async {
    value = value.copyWith(isPlaying: false);
  }

  @override
  Future<void> setVolume(double volume) async {
    value = value.copyWith(volume: volume);
  }

  @override
  Future<void> seekTo(Duration position) async {
    requestedSeek = position;
    value = value.copyWith(position: position);
  }
}

class _ScreenController extends VideoPlayerController {
  @override
  void onInit() {
    url = ''; // No native source is opened; the test supplies a notifier.
    super.onInit();
  }
}

void main() {
  testWidgets(
    'playback notifications update time, seek, play and mute controls',
    (tester) async {
      Get.testMode = true;
      final player = _Player();
      final controller = Get.put<VideoPlayerController>(_ScreenController());
      controller.videoPlayerController = player;
      player.value = const vp.VideoPlayerValue(
        duration: Duration(seconds: 100),
        position: Duration(seconds: 10),
      );
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(height: 300, child: RegularPlayerSection()),
          ),
        ),
      );
      expect(find.text('00:10'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      player.value = player.value.copyWith(
        position: const Duration(seconds: 40),
        isPlaying: true,
      );
      await tester.pump();
      expect(find.text('00:40'), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(tester.widget<Slider>(find.byType(Slider)).value, .4);
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pump();
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      await tester.tap(find.byIcon(Icons.volume_up));
      await tester.pump();
      expect(find.byIcon(Icons.volume_off), findsOneWidget);
      await tester.tap(find.byIcon(Icons.volume_off));
      await tester.pump();
      expect(find.byIcon(Icons.volume_up), findsOneWidget);
      final slider = tester.widget<Slider>(find.byType(Slider));
      slider.onChanged!(.7);
      await tester.pump();
      expect(player.requestedSeek, const Duration(seconds: 70));
      expect(find.text('01:10'), findsOneWidget);
      // A late platform position past the duration must not violate Slider range.
      player.value = player.value.copyWith(
        position: const Duration(seconds: 101),
      );
      await tester.pump();
      expect(tester.widget<Slider>(find.byType(Slider)).value, 1);
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
      Get.reset();
    },
  );
}
