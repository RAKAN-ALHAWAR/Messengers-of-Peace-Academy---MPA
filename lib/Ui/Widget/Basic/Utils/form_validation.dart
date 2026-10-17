import 'package:flutter/material.dart';

import '../../../../Config/config.dart';

/// Validate the mounted fields, then reveal the first error after layout.
/// Conditional fields participate only while they belong to this Form.
bool validateAndRevealFirstError(FormState form) {
  final invalid = form.validateGranularly();
  if (invalid.isEmpty) return true;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final mounted =
        invalid.where((field) => field.mounted && field.hasError).toList();
    if (mounted.isEmpty) return;
    mounted.sort((a, b) {
      final first = a.context.findRenderObject();
      final second = b.context.findRenderObject();
      if (first is! RenderBox || second is! RenderBox) return 0;
      return first
          .localToGlobal(Offset.zero)
          .dy
          .compareTo(second.localToGlobal(Offset.zero).dy);
    });
    final first = mounted.first;
    FocusNode? node;
    void findFocus(Element element) {
      final widget = element.widget;
      if (widget is Focus && widget.focusNode?.canRequestFocus == true) {
        node ??= widget.focusNode;
      }
      if (node == null) element.visitChildren(findFocus);
    }

    first.context.visitChildElements(findFocus);
    node?.requestFocus();
    Scrollable.ensureVisible(
      first.context,
      duration: StyleX.formScrollDuration,
      alignment: 0.15,
    );
  });
  return false;
}
