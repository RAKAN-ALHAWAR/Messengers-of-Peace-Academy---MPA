part of '../../core.dart';

class AppControllerX extends GetxController {
  late Rx<UserX> user;
  final RxBool isLogin =
      (LocalDataX.userid.isNotEmpty && LocalDataX.token.isNotEmpty).obs;
  StreamSubscription<SessionLeaseX>? _expirySubscription;
  int _initRequest = 0;
  bool get _ownsApp =>
      !isClosed &&
      Get.isRegistered<AppControllerX>() &&
      identical(Get.find<AppControllerX>(), this);

  /// Startup never requests a protected profile under the bundled public key.
  Future<SessionLeaseX?> init() async {
    final request = ++_initRequest;
    final lease = SessionLeaseX.capture(
      isActive: () => _ownsApp && request == _initRequest,
    );
    if (!lease.hasAuthenticatedIdentity) {
      // A genuinely signed-out startup is already clean. Removing absent
      // credentials would invalidate the loading view and restart init forever.
      if (LocalDataX.userid.isEmpty && LocalDataX.token.isEmpty) {
        isLogin.value = false;
        if (LocalDataX.route != RouteNameX.login) {
          await LocalDataX.put(LocalKeyX.route, RouteNameX.login);
        }
        return lease.isCurrent ? lease : null;
      }
      final clearing = clearLocalSession(lease, navigate: false);
      final cleared = SessionLeaseX.capture(
        isActive: () => _ownsApp && request == _initRequest,
      );
      await clearing;
      return cleared.isCurrent ? cleared : null;
    }
    final id = LocalDataX.userid;
    late UserX profile;
    try {
      profile = await DatabaseX.getUser(userId: id);
    } catch (_) {
      if (!lease.isCurrent) return null;
      rethrow;
    }
    if (!lease.isCurrent) return null;
    if (profile.id != id) {
      await clearLocalSession(lease, navigate: false);
      throw StateError(
        'The returned profile does not match the signed-in account.',
      );
    }
    user = profile.obs;
    isLogin.value = true;
    update();
    return lease;
  }

  /// Credential removals happen synchronously before the first await. A second
  /// expiry event cannot reuse this generation, and a newer login owns its route.
  Future<void> clearLocalSession(
    SessionLeaseX lease, {
    bool navigate = true,
  }) async {
    if (!lease.isCurrent || !_ownsApp) return;
    isLogin.value = false;
    final writes = [
      LocalDataX.remove(LocalKeyX.userid),
      LocalDataX.remove(LocalKeyX.token),
      LocalDataX.put(LocalKeyX.route, RouteNameX.login),
    ];
    final cleared = SessionLeaseX.capture(isActive: () => _ownsApp);
    await Future.wait(writes);
    if (!cleared.isCurrent) return;
    if (navigate && Get.currentRoute != RouteNameX.login) {
      Get.offAllNamed(RouteNameX.login);
    }
  }

  Future<void> logOut() async {
    final token = LocalDataX.token;
    final lease = SessionLeaseX.capture(isActive: () => _ownsApp);
    final cleared = clearLocalSession(lease);
    // Explicit logout remains best-effort server revocation. Expiry never calls it.
    if (token.isNotEmpty) {
      unawaited(
        DatabaseX.logout(token: token).then<void>((_) {}, onError: (_) {}),
      );
    }
    await cleared;
  }

  @override
  void onInit() {
    super.onInit();
    _expirySubscription = SessionExpiryX.events.listen((lease) {
      unawaited(clearLocalSession(lease));
    });
  }

  @override
  void onClose() {
    _expirySubscription?.cancel();
    super.onClose();
  }
}
