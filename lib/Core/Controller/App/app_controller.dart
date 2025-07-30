part of '../../core.dart';

class AppControllerX extends GetxController {
  //============================================================================
  // Variables

  late Rx<UserX> user;

  RxBool isLogin = LocalDataX.userid.isNotEmpty.obs;

  //============================================================================
  // Functions

  init() async {
    /// Profile
    if (isLogin.value) {
      user = (await DatabaseX.getUser()).obs;
    }
    update();
  }

  logOut() async {
    try {
      isLogin.value = false;
      LocalDataX.remove(LocalKeyX.userid);
      LocalDataX.remove(LocalKeyX.token);
      LocalDataX.put(LocalKeyX.route, RouteNameX.login);
      if (Get.currentRoute != RouteNameX.login) {
        await Future.wait([
          DatabaseX.logout(token: LocalDataX.token),
          Future.microtask(() => Get.offAllNamed(RouteNameX.login)),
        ]);
      } else {
        await DatabaseX.logout(token: LocalDataX.token);
      }
    } catch (_) {}
  }
}
