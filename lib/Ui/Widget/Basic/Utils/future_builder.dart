import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../../Core/Service/session_lease.dart';
import '../../../../Data/data.dart';
import '../../../Section/GeneralState/error.dart';

class FutureBuilderX<T> extends StatefulWidget {
  const FutureBuilderX({
    super.key,
    required this.future,
    this.requestKey,
    this.loading,
    required this.child,
    this.onLoading,
    this.onError,
    this.onSuccess,
    this.onRetry,
    this.isHideIfError = false,
    this.isHideIfEmpty = false,
  });

  final Future<T> Function() future;

  /// Immutable equality key for business inputs such as a course ID or locale.
  /// A new callback object alone does not identify a new request. Session
  /// revisions are included automatically, even when these inputs are unchanged.
  final Object? requestKey;
  final Widget? loading;
  final Widget Function(T data) child;

  final bool isHideIfError;
  final bool isHideIfEmpty;

  final VoidCallback? onLoading;
  final VoidCallback? onError;
  final VoidCallback? onSuccess;
  final VoidCallback? onRetry;

  @override
  State<FutureBuilderX<T>> createState() => FutureBuilderXState<T>();
}

class FutureBuilderXState<T> extends State<FutureBuilderX<T>> {
  late Future<T> _future;
  late SessionLeaseX _lease;
  late int _sessionRevision;
  int _generation = 0;
  late final StreamSubscription<int> _sessionSubscription;

  @override
  void initState() {
    super.initState();
    _startLoad();
    _sessionSubscription = LocalDataX.sessionChanges.listen((_) {
      if (WidgetsBinding.instance.schedulerPhase ==
          SchedulerPhase.persistentCallbacks) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _reloadSession());
      } else {
        _reloadSession();
      }
    });
  }

  void _reloadSession() {
    if (mounted && _sessionRevision != LocalDataX.sessionRevision) {
      setState(_startLoad);
    }
  }

  @override
  void dispose() {
    _sessionSubscription.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FutureBuilderX<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.requestKey != widget.requestKey ||
        _sessionRevision != LocalDataX.sessionRevision) {
      _startLoad();
    }
  }

  void _startLoad() {
    final generation = ++_generation;
    _sessionRevision = LocalDataX.sessionRevision;
    final lease = SessionLeaseX.capture(
      isActive: () => mounted && generation == _generation,
    );
    _lease = lease;
    _notify(lease, () => widget.onLoading);

    // Deferral catches synchronous throws and keeps callers' initial state
    // changes out of the ancestor build that created this widget.
    final request = widget.future;
    _future = Future<T>.microtask(() {
      if (!lease.isCurrent) {
        throw StateError(
          'The request no longer belongs to the current screen.',
        );
      }
      return request();
    });
    _future.then<void>(
      (_) => _notify(lease, () => widget.onSuccess),
      onError: (Object error, StackTrace stackTrace) {
        _notify(lease, () => widget.onError);
      },
    );
  }

  void _notify(SessionLeaseX lease, VoidCallback? Function() callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (lease.isCurrent) callback()?.call();
    });
  }

  /// Fetch the current inputs once, without reporting a user error retry.
  Future<void> refresh() => _reloadFuture(notifyRetry: false);

  /// Existing retry entry point retained for callers and the error action.
  Future<void> onRefresh() => _reloadFuture(notifyRetry: true);

  Future<void> _reloadFuture({required bool notifyRetry}) async {
    if (!mounted) return;
    setState(_startLoad);
    if (notifyRetry) _notify(_lease, () => widget.onRetry);
    try {
      await _future;
    } catch (_) {
      // The retained FutureBuilder renders the failure. An ignored retry
      // callback must not create a second, unhandled asynchronous error.
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: (context, snapshot) {
        // A stale operation may finish before navigation removes this widget.
        // Neither its data nor its success/error callbacks belong to the new
        // account. The session signal starts the new session's load, including
        // when no parent rebuild occurs.
        if (!_lease.isCurrent) return const SizedBox();
        if (snapshot.connectionState != ConnectionState.done) {
          return widget.loading ??
              const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return widget.isHideIfError
              ? const SizedBox()
              : ErrorView(error: snapshot.error, onTapButton: onRefresh);
        }
        if (widget.isHideIfEmpty && snapshot.data == null) {
          return const SizedBox();
        }
        return widget.child(snapshot.data as T);
      },
    );
  }
}
