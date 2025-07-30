import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../Config/config.dart';
import '../../../Ui/Widget/widget.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this screen }}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// A general element for dealing with cases of unexpected and unaddressed errors
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class SystemCrashView extends StatelessWidget {
  const SystemCrashView({required this.error, super.key});
  final FlutterErrorDetails error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextX(
          kDebugMode ? error.summary.toString() : 'Oups! Something went wrong!',
          textAlign: TextAlign.center,
          color: kDebugMode ? ColorX.danger : null,
          style: TextStyleX.titleLarge,
        ),
      ),
    );
  }
}
