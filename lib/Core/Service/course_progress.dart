import 'dart:async';
import 'dart:collection';

import '../../Config/Translation/translation.dart';
import '../../Data/Model/course/course.dart';
import '../../Data/Model/course/course_progress.dart';
import '../../Data/data.dart';
import 'session_lease.dart';

/// The catalog has no lesson counts. Reuse detail results across mounted
/// cards without keeping activity payloads, media links, or persisted progress.
class CourseProgressStoreX {
  static const _maxEntries = 64;
  static const _maxConcurrent = 4;
  static const _reuseFor = Duration(minutes: 1);
  static (int, String)? _scope;
  static final _recent = <String, (CourseProgressX, DateTime)>{};
  static final _pending = <String, Future<CourseProgressX?>>{};
  static final _waiting = Queue<Completer<void>>();
  static int _active = 0;

  static (int, String) get _currentScope =>
      (LocalDataX.sessionRevision, TranslationX.getLanguageCode);

  static void _prepareScope() {
    final scope = _currentScope;
    if (_scope == scope) return;
    _scope = scope;
    _recent.clear();
    _pending.clear();
  }

  static Future<CourseProgressX?> load(String courseId) async {
    _prepareScope();
    final scope = _currentScope;
    final lease = SessionLeaseX.capture(
      isActive: () => scope == _scope && scope == _currentScope,
    );
    if (!lease.hasAuthenticatedIdentity) return null;
    final recent = _recent.remove(courseId);
    if (recent != null && DateTime.now().difference(recent.$2) < _reuseFor) {
      _recent[courseId] = recent;
      return recent.$1;
    }
    final pending = _pending[courseId];
    if (pending != null) return pending;

    late final Future<CourseProgressX?> request;
    request = () async {
      await _takeSlot();
      try {
        if (!lease.isCurrent) return null;
        if (_pending[courseId] != request) return _recent[courseId]?.$1;
        final course = await DatabaseX.getCourse(courseId: courseId);
        if (!lease.isCurrent) return null;
        // An owned detail refresh can replace this older catalog request.
        if (_pending[courseId] != request) return _recent[courseId]?.$1;
        if (course.id != courseId) return null;
        _save(courseId, course.progress);
        return course.progress;
      } catch (_) {
        // The card remains usable and a later catalog load can try again.
        if (!lease.isCurrent) return null;
        return _recent[courseId]?.$1;
      } finally {
        if (_pending[courseId] == request) _pending.remove(courseId);
        if (_waiting.isEmpty) {
          _active--;
        } else {
          _waiting.removeFirst().complete();
        }
      }
    }();
    _pending[courseId] = request;
    return request;
  }

  static Future<void> _takeSlot() async {
    if (_active < _maxConcurrent) {
      _active++;
      return;
    }
    final slot = Completer<void>();
    _waiting.addLast(slot);
    await slot.future;
  }

  /// Called only after the course screen validates its own response and lease.
  static void record(CourseX course) {
    _prepareScope();
    _pending.remove(course.id);
    _save(course.id, course.progress);
  }

  static void _save(String id, CourseProgressX progress) {
    _recent.remove(id);
    _recent[id] = (progress, DateTime.now());
    if (_recent.length > _maxEntries) _recent.remove(_recent.keys.first);
  }
}
