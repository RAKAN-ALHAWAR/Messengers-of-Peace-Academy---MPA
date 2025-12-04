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
        loading: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              /// Background
              Image.asset(
                context.isDarkMode ? ImageX.splashDark : ImageX.splash,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),

              /// Loading indicator
              Padding(
                padding: EdgeInsets.only(top: 300),
                child: const CircularProgressIndicator(),
              ),
            ],
          ),
        ),

        /// On success state
        child: (_) => const SizedBox(),
      ),
    );
  }
}
