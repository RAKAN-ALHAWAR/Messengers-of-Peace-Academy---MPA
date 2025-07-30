import 'package:get/get.dart';
import '../../../../../Core/core.dart';
import '../../../../Data/data.dart';

class LoadingController extends GetxController {
  //============================================================================
  // Injection of required controls

  /// App controller
  AppControllerX app = Get.find();

  //============================================================================
  // Functions

  /// Initialize the controller
  Future<void> init() async {
    /// Configure the global controller when it is on the home page when the application opens so that it fetches user data
    await app.init();
  }

  /// Finish the controller
  finish() {
    /// Navigate to the home page or login page
    Get.offAllNamed(LocalDataX.route);
  }
}
