import 'level.dart';

/// Opens the very first course (currently the entry exam) locally when no
/// level offers an open, not-completed course. It never opens any other
/// course: later courses follow the server's sequencing. One function so Home
/// and Courses agree.
// TEMP(backend): the backend should return is_open for the first course; drop
// this local unlock once it does.
void openFirstCourseIfNoneOpen(List<LevelX> levels) {
  if (levels.isEmpty || levels.first.courses.isEmpty) return;
  final hasOpenCourse = levels.any(
    (level) =>
        level.isOpen &&
        !level.isCompleted &&
        level.courses.any((course) => course.isOpen && !course.isCompleted),
  );
  if (hasOpenCourse) return;
  final first = levels.first.courses.first;
  if (first.isCompleted) return;
  levels.first.isOpen = true;
  first.isOpen = true;
}
