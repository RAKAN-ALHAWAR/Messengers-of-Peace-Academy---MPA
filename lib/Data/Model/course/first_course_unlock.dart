import 'level.dart';

/// Opens the first not-completed course locally when no level offers an open,
/// not-completed course. One function so Home and Courses agree.
// TEMP(backend): the backend should return is_open for the first course; drop
// this local unlock once it does.
void openFirstCourseIfNoneOpen(List<LevelX> levels) {
  final hasOpenCourse = levels.any(
    (level) =>
        level.isOpen &&
        !level.isCompleted &&
        level.courses.any((course) => course.isOpen && !course.isCompleted),
  );
  if (hasOpenCourse) return;
  final levelIndex = levels.indexWhere(
    (level) =>
        !level.isCompleted &&
        level.courses.any((course) => !course.isCompleted),
  );
  if (levelIndex == -1) return;
  final level = levels[levelIndex];
  level.isOpen = true;
  level.courses.firstWhere((course) => !course.isCompleted).isOpen = true;
}
