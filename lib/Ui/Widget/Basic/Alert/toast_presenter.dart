import 'dart:async';

import 'package:flutter/material.dart';

/// Owns one notification independently of navigation and Get's snackbar queue.
/// New messages replace the old one rather than accumulating pending work.
class ToastPresenterX {
  OverlayEntry? _entry;
  Timer? _timer;

  void show({
    required OverlayState? overlay,
    required Duration duration,
    required Widget Function(VoidCallback dismiss) builder,
  }) {
    dismiss();
    if (overlay == null || !overlay.mounted) return;
    late final OverlayEntry entry;
    void dismissThis() {
      if (identical(_entry, entry)) dismiss();
    }

    entry = OverlayEntry(builder: (_) => builder(dismissThis));
    _entry = entry;
    overlay.insert(entry);
    _timer = Timer(duration, dismissThis);
  }

  /// Idempotent; releases resources even after the host overlay unmounts.
  void dismiss() {
    _timer?.cancel();
    _timer = null;
    final entry = _entry;
    _entry = null;
    if (entry != null) {
      entry.remove();
      entry.dispose();
    }
  }
}
