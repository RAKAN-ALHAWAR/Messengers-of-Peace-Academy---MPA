import 'package:flutter_test/flutter_test.dart';
import 'package:messengersofpeace/Data/Model/course/activity.dart';

import 'lesson_counts_test.dart' show activityJson;

ActivityX _activity({
  required String cmId,
  String file = '',
  String video = '',
  String? quizId,
  num percent = 0,
  bool completed = false,
  bool downloaded = false,
}) => ActivityX.fromJson(
  activityJson(
    topicId: 1,
    cmId: cmId,
    file: file,
    video: video,
    quizId: quizId,
    percent: percent,
    completed: completed,
  ),
)..isFileDownloaded = downloaded;

void main() {
  group('section ring percent', () {
    test('a section with only a not downloaded file reads 0', () {
      final file = _activity(cmId: 'f', file: 'https://x.invalid/f');
      expect(ActivityX.topicPercent([file]), 0);
    });

    test('a section with only a downloaded file reads 100', () {
      final file = _activity(
        cmId: 'f',
        file: 'https://x.invalid/f',
        downloaded: true,
      );
      expect(file.progressPercent, 100);
      expect(ActivityX.topicPercent([file]), 100);
    });

    test(
      'a downloaded file counts as one finished activity in the average',
      () {
        final file = _activity(
          cmId: 'f',
          file: 'https://x.invalid/f',
          downloaded: true,
        );
        final video = _activity(cmId: 'v', video: 'https://x.invalid/v');
        expect(ActivityX.topicPercent([file, video]), 50);
      },
    );

    test('the server percent is used when nothing was downloaded', () {
      final video = _activity(
        cmId: 'v',
        video: 'https://x.invalid/v',
        percent: 40,
      );
      expect(video.progressPercent, 40);
      expect(ActivityX.topicPercent([video]), 40);
    });

    test('an empty section reads 0, never divides by zero', () {
      expect(ActivityX.topicPercent(const []), 0);
    });
  });

  group('a file download never turns the video or quiz of its activity done', () {
    ActivityX combined({bool downloaded = false, bool completed = false}) =>
        _activity(
          cmId: 'c',
          video: 'https://x.invalid/v',
          quizId: '7',
          file: 'https://x.invalid/f',
          completed: completed,
          percent: completed ? 100 : 0,
          downloaded: downloaded,
        );

    test('video and quiz rows keep the server state, the file row its own', () {
      final a = combined(downloaded: true);
      expect(a.isServerDone, isFalse);
      expect(a.isFileDone, isTrue);
      expect(a.progressPercent, 0);
      expect(ActivityX.topicPercent([a]), 0);
      expect(a.isDone, isFalse);
    });

    test('a finished video does not turn the not downloaded file done', () {
      final a = combined(completed: true);
      expect(a.isServerDone, isTrue);
      expect(a.isFileDone, isFalse);
      expect(a.isDone, isTrue);
      expect(ActivityX.topicPercent([a]), 100);
    });

    test('a file only activity is done by the local flag, as before', () {
      final f = _activity(
        cmId: 'f',
        file: 'https://x.invalid/f',
        downloaded: true,
      );
      expect(f.isFileDone, isTrue);
      expect(f.isDone, isTrue);
      expect(f.isServerDone, isFalse);
    });
  });
}
