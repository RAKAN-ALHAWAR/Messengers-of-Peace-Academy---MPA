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
    /// Keep the token before clearing it, the backend needs it to
    /// invalidate the session
    final token = LocalDataX.token;
    try {
      isLogin.value = false;
      LocalDataX.remove(LocalKeyX.userid);
      LocalDataX.remove(LocalKeyX.token);
      LocalDataX.put(LocalKeyX.route, RouteNameX.login);
      if (Get.currentRoute != RouteNameX.login) {
        await Future.wait([
          DatabaseX.logout(token: token),
          Future.microtask(() => Get.offAllNamed(RouteNameX.login)),
        ]);
      } else {
        await DatabaseX.logout(token: token);
      }
    } catch (_) {
      /// The local session is already cleared, ignore backend failures
    }
  }
}
