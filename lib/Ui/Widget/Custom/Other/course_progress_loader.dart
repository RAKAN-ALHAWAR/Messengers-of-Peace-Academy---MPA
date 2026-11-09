import 'package:flutter/widgets.dart';

import '../../../../Config/Translation/translation.dart';
import '../../../../Core/Service/course_progress.dart';
import '../../../../Data/Model/course/course_progress.dart';
import '../../Basic/Utils/future_builder.dart';

/// Mounted cards request progress lazily. The parent lists own their refresh
/// and supply a new course snapshot on return from the detail screen.
class CourseProgressLoader extends StatelessWidget {
  const CourseProgressLoader({
    super.key,
    required this.courseId,
    required this.snapshot,
    required this.builder,
  });

  final String courseId;
  final Object snapshot;
  final Widget Function(CourseProgressX?) builder;

  @override
  Widget build(BuildContext context) => FutureBuilderX<CourseProgressX?>(
    requestKey: (courseId, snapshot, TranslationX.getLanguageCode),
    future: () => CourseProgressStoreX.load(courseId),
    loading: builder(null),
    child: builder,
  );
}
