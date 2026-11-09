import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../../Core/Service/academy_support.dart';
import '../../../../../Core/Service/controller_lease.dart';
import '../../../../../Core/Service/route_origin.dart';
import '../../../../../Core/Service/session_lease.dart';
import '../../../../../Core/core.dart';
import '../../../../../Data/Database/account_deletion.dart';
import '../../../../Widget/widget.dart';

class AccountDeletionController extends GetxController {
  AccountDeletionController({this.now = DateTime.now});

  static const _resendDelay = Duration(seconds: 60);
  static final _sixDigits = RegExp(r'^[0-9]{6}$');

  final DateTime Function() now;
  final AppControllerX _app = Get.find();
  final SessionLeaseX _session = SessionLeaseX.capture();
  final _api = AccountDeletionApi();

  AccountDeletionChallenge? _challenge;
  DateTime? _expiresAt;
  DateTime? _resendAt;
  Timer? _ticker;
  bool _consent = false;
  bool _busy = false;
  bool _confirming = false;
  bool _blocked = false;
  bool _uncertain = false;
  int _wrongCodes = 0;
  int _otpInputVersion = 0;
  String _code = '';
  String? _message;
  String? _codeError;

  bool get consent => _consent;
  bool get busy => _busy;
  bool get hasChallenge => _challenge != null;
  bool get uncertain => _uncertain;
  bool get canGoBack => !_confirming && !_uncertain;
  bool get showConsent => !_blocked && !_uncertain && !hasChallenge;
  bool get showSend => !_blocked && !_uncertain && _resendAt == null;
  bool get showResend => !_blocked && !_uncertain && _resendAt != null;
  bool get canRequestCode => _canAct && _consent && resendSeconds == 0;
  int get otpInputVersion => _otpInputVersion;
  int get resendSeconds => _secondsUntil(_resendAt);
  int get expirySeconds => _secondsUntil(_expiresAt);
  String? get message => _message;
  String? get codeError => _codeError;

  bool get _canAct => !isClosed && !_busy && !_blocked && !_uncertain;

  int _secondsUntil(DateTime? deadline) {
    final ms = deadline?.difference(now()).inMilliseconds ?? 0;
    return ms > 0 ? (ms + 999) ~/ 1000 : 0;
  }

  void onConsentChanged(bool? value) {
    if (!_canAct || !showConsent) return;
    _consent = value == true;
    update();
  }

  void onCodeChanged(String code) {
    if (!_canAct || !hasChallenge) return;
    _code = code;
    if (_codeError == null) return;
    _codeError = null;
    update();
  }

  void _discardChallenge() {
    _challenge = null;
    _code = '';
    _codeError = null;
  }

  void _expireCode() {
    _discardChallenge();
    _message = 'delete.expired';
  }

  void _watchDeadlines() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (hasChallenge && expirySeconds == 0 && !_confirming) {
        _expireCode();
      }
      if (!hasChallenge && resendSeconds == 0) timer.cancel();
      update();
    });
  }

  bool _checkSession() {
    if (_session.isCurrent &&
        _session.hasAuthenticatedIdentity &&
        _app.isLogin.value &&
        ControllerLeaseX.owns(this, app: _app)) {
      return true;
    }
    _blocked = true;
    _discardChallenge();
    _message = 'delete.changed';
    update();
    return false;
  }

  Future<void> onRequestCode() async {
    if (!canRequestCode || !_checkSession()) return;
    final origin = RouteOriginX.capture();
    final requestedAt = now();
    _busy = true;
    _message = null;
    _codeError = null;
    _resendAt = requestedAt.add(_resendDelay);
    _watchDeadlines();
    update();
    try {
      final challenge = await _api.requestCode(_session);
      if (isClosed || !origin.isActive || !_checkSession()) return;
      _challenge = challenge;
      _expiresAt = requestedAt.add(Duration(seconds: challenge.expiresIn));
      _resendAt = now().add(_resendDelay);
      _wrongCodes = 0;
      _code = '';
      _otpInputVersion++;
    } on AccountDeletionException catch (error) {
      if (!isClosed && origin.isActive && _checkSession()) {
        await _handleError(error.reason);
      }
    } finally {
      if (!isClosed && origin.isActive) {
        _busy = false;
        update();
      }
    }
  }

  Future<void> onConfirmDeletion() async {
    final challenge = _challenge;
    if (!_canAct || !_consent || challenge == null || !_checkSession()) return;
    if (expirySeconds == 0) {
      _expireCode();
      update();
      return;
    }
    final code = _code;
    if (!_sixDigits.hasMatch(code)) {
      _codeError = 'delete.sixDigits';
      update();
      return;
    }

    final origin = RouteOriginX.capture();
    FocusManager.instance.primaryFocus?.unfocus();
    _busy = true;
    _confirming = true;
    _message = null;
    _codeError = null;
    update();
    try {
      await _api.confirm(_session, challenge, code);
      if (isClosed || !origin.isActive || !_checkSession()) return;
      _discardChallenge();
      await _app.finishAccountDeletion(_session);
    } on AccountDeletionException catch (error) {
      if (!isClosed && origin.isActive && _checkSession()) {
        await _handleError(error.reason);
      }
    } finally {
      if (!isClosed && origin.isActive) {
        _busy = false;
        _confirming = false;
        update();
      }
    }
  }

  Future<void> _handleError(AccountDeletionError reason) async {
    switch (reason) {
      case AccountDeletionError.sessionExpired:
        _discardChallenge();
        _blocked = true;
        _message = 'delete.sessionExpired';
        update();
        await _app.returnToSignIn(_session, 'delete.sessionExpired');
      case AccountDeletionError.invalidCode:
        _wrongCodes++;
        if (_wrongCodes < 5) {
          _codeError = 'delete.invalid';
          return;
        }
        _expireCode();
      case AccountDeletionError.expiredCode:
        _expireCode();
      case AccountDeletionError.consentRequired:
        _consent = false;
        _discardChallenge();
        _message = 'delete.consentRequired';
      case AccountDeletionError.rateLimited:
        _resendAt = now().add(_resendDelay);
        _message = 'delete.rateLimited';
        _watchDeadlines();
      case AccountDeletionError.busy:
        _message = 'delete.busy';
      case AccountDeletionError.deliveryFailed:
        _discardChallenge();
        _message = 'delete.delivery';
      case AccountDeletionError.outcomeUnknown:
        _uncertain = true;
        _discardChallenge();
        _message = 'delete.unknown';
      case AccountDeletionError.protectedAccount:
      case AccountDeletionError.recoveryBlocked:
        _blocked = true;
        _discardChallenge();
        _message = 'delete.supportRequired';
      case AccountDeletionError.unavailable:
        _blocked = true;
        _discardChallenge();
        _message = 'delete.unavailable';
      case AccountDeletionError.requestFailed:
        // A lost resend response could have invalidated the old code.
        _discardChallenge();
        _message = 'delete.requestFailed';
    }
  }

  Future<void> onReturnToSignIn() async {
    if (isClosed || !_uncertain || _busy) return;
    await _app.returnToSignIn(_session, 'delete.unknown');
  }

  Future<void> onOpenSupport() async {
    final origin = RouteOriginX.capture();
    final opened = await openAcademySupport();
    if (!opened && !isClosed && origin.isActive) {
      ToastX.error(message: 'Could not open the page, please try again');
    }
  }

  @override
  void onClose() {
    _ticker?.cancel();
    _discardChallenge();
    super.onClose();
  }
}
