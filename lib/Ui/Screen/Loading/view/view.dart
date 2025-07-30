import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../Config/config.dart';
import '../../../Widget/Basic/Utils/future_builder.dart';
import '../controller/controller.dart';

class LoadingView extends GetView<LoadingController> {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    /// Build loading view
    return Scaffold(
      body: FutureBuilderX(
        /// Initialize the controller
        future: controller.init,

        /// On success
        onSuccess: controller.finish,

        /// Loading state
        loading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Logo
            Center(
              child: Column(
                children: [
                  Image.asset(ImageX.sponsorLogo, height: 80),
                  const SizedBox(height: 25),
                  Image.asset(
                    context.isDarkMode ? ImageX.logoWhite : ImageX.logo,
                    height: 40,
                  ),
                ],
              ),
            ),

            /// Spacer
            const SizedBox(height: 70, width: double.maxFinite),

            /// Loading indicator
            const CircularProgressIndicator(),
          ],
        ),

        /// On success state
        child: (_) => const SizedBox(),
      ),
    );
  }
}
