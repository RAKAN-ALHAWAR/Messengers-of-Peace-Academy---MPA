part of '../../core.dart';

class AppControllerX extends GetxController {
  //============================================================================
  // Variables

  late Rx<UserX> user;
  final RxBool isLogin =
      (LocalDataX.userid.isNotEmpty && LocalDataX.token.isNotEmpty).obs;
  StreamSubscription<SessionLeaseX>? _expirySubscription;
  int _initRequest = 0;

  //============================================================================
  // Functions

  /// Startup never requests a protected profile under the bundled public key.
  Future<SessionLeaseX?> init() async {
    final request = ++_initRequest;
    final lease = _startupLease(request);
    if (!lease.hasAuthenticatedIdentity) {
      // Already signed out: removing absent credentials would restart init forever.
      if (LocalDataX.userid.isEmpty && LocalDataX.token.isEmpty) {
        isLogin.value = false;
        if (LocalDataX.route != RouteNameX.login) {
          await LocalDataX.put(LocalKeyX.route, RouteNameX.login);
        }
        return lease.isCurrent ? lease : null;
      }
      final clearing = clearLocalSession(lease, navigate: false);
      final cleared = _startupLease(request);
      await clearing;
      return cleared.isCurrent ? cleared : null;
    }
    final id = LocalDataX.userid;
    late UserX profile;
    try {
      profile = await DatabaseX.getUser(userId: id);
    } catch (e) {
      if (!lease.isCurrent) return null;
      // The server refuses an incomplete account's profile (a backend gap), but
      // the account still opens the app: keep the session, show what is known.
      if (e.toErrorX.details[NameX.errorcode] == 'usernotfullysetup') {
        await LocalDataX.put(LocalKeyX.route, RouteNameX.root);
        if (!lease.isCurrent) return null;
        user = unfinishedUser(id).obs;
        isLogin.value = true;
        update();
        return lease;
      }
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

  /// What is known of an account whose profile the server refuses: its id and login name.
  static UserX unfinishedUser(String id, {String username = ''}) => UserX(
    id: id,
    username: username,
    firstname: '',
    lastname: '',
    email: username,
    lang: 'en',
    customfields: [],
    city: '',
    image: '',
    points: 0,
  );

  /// Credentials go before the first await, so a second expiry cannot reuse them.
  Future<void> clearLocalSession(
    SessionLeaseX lease, {
    bool navigate = true,
  }) async {
    if (!lease.isCurrent || !ControllerLeaseX.owns(this)) return;
    isLogin.value = false;
    final writes = [
      LocalDataX.remove(LocalKeyX.userid),
      LocalDataX.remove(LocalKeyX.token),
      LocalDataX.put(LocalKeyX.route, RouteNameX.login),
    ];
    final cleared = ControllerLeaseX.capture(this, registered: true);
    await Future.wait(writes);
    if (!cleared.isCurrent) return;
    if (navigate && Get.currentRoute != RouteNameX.login) {
      Get.offAllNamed(RouteNameX.login);
    }
  }

  Future<void> logOut() async {
    final token = LocalDataX.token;
    final lease = ControllerLeaseX.capture(this, registered: true);
    final cleared = clearLocalSession(lease);
    // Explicit logout remains best-effort server revocation. Expiry never calls it.
    if (token.isNotEmpty) {
      unawaited(
        DatabaseX.logout(token: token).then<void>((_) {}, onError: (_) {}),
      );
    }
    await cleared;
  }

  /// One startup request's work; a newer request retires it.
  SessionLeaseX _startupLease(int request) => ControllerLeaseX.capture(
    this,
    registered: true,
    also: () => request == _initRequest,
  );

  //============================================================================
  // Lifecycle

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
