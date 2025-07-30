part of '../core.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this Helper }}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// Phone clipboard management
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class ClipboardX {
  /// Copy to clipboard
  static copy(String val,{String msg="Copied to clipboard",bool showMsg=true}) async {
    await Clipboard.setData(
      ClipboardData(text: val),
    );
    if(showMsg) {
      ToastX.success(message: msg);
    }
  }
}
