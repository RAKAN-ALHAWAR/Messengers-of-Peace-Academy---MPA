import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../Core/Service/session_lease.dart';
import '../../../../Core/Service/academy_support.dart';
import '../../../../Core/core.dart';
import '../../../../Data/Database/account_deletion.dart';

class AccountDeletionView extends StatefulWidget {
  const AccountDeletionView({
    super.key,
    required this.session,
    required this.app,
    this.now = DateTime.now,
  });

  final SessionLeaseX session;
  final AppControllerX app;
  final DateTime Function() now;

  @override
  State<AccountDeletionView> createState() => _AccountDeletionViewState();
}

class _AccountDeletionViewState extends State<AccountDeletionView> {
  static const _resendDelay = Duration(seconds: 60);
  static final _sixDigits = RegExp(r'^[0-9]{6}$');
  final _api = AccountDeletionApi();
  final _code = TextEditingController();
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
  String? _message;
  String? _codeError;

  int _secondsUntil(DateTime? deadline) {
    final ms = deadline?.difference(widget.now()).inMilliseconds ?? 0;
    return ms > 0 ? (ms + 999) ~/ 1000 : 0;
  }

  bool get _canAct => mounted && !_busy && !_blocked && !_uncertain;

  void _watchDeadlines() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_challenge != null &&
            _secondsUntil(_expiresAt) == 0 &&
            !_confirming) {
          _challenge = null;
          _code.clear();
          _codeError = null;
          _message = 'delete.expired';
        }
      });
      if (_challenge == null && _secondsUntil(_resendAt) == 0) timer.cancel();
    });
  }

  bool _checkSession() {
    if (widget.session.isCurrent && widget.session.hasAuthenticatedIdentity) {
      return true;
    }
    setState(() {
      _blocked = true;
      _challenge = null;
      _code.clear();
      _message = 'delete.changed';
    });
    return false;
  }

  Future<void> _requestCode() async {
    if (!_canAct ||
        !_consent ||
        _secondsUntil(_resendAt) > 0 ||
        !_checkSession()) {
      return;
    }
    final requestedAt = widget.now();
    setState(() {
      _busy = true;
      _message = null;
      _codeError = null;
      _resendAt = widget.now().add(_resendDelay);
    });
    _watchDeadlines();
    try {
      final challenge = await _api.requestCode(widget.session);
      if (!mounted || !_checkSession()) return;
      setState(() {
        _challenge = challenge;
        _expiresAt = requestedAt.add(Duration(seconds: challenge.expiresIn));
        _resendAt = widget.now().add(_resendDelay);
        _wrongCodes = 0;
        _code.clear();
      });
    } on AccountDeletionException catch (error) {
      if (mounted && _checkSession()) await _handleError(error.reason);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmDeletion() async {
    final challenge = _challenge;
    if (!_canAct || !_consent || challenge == null || !_checkSession()) return;
    if (_secondsUntil(_expiresAt) == 0) {
      await _handleError(AccountDeletionError.expiredCode);
      return;
    }
    final code = _code.text;
    if (!_sixDigits.hasMatch(code)) {
      setState(() => _codeError = 'delete.sixDigits');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _confirming = true;
      _message = null;
      _codeError = null;
    });
    try {
      await _api.confirm(widget.session, challenge, code);
      if (!mounted || !_checkSession()) return;
      _challenge = null;
      _code.clear();
      await widget.app.finishAccountDeletion(widget.session);
    } on AccountDeletionException catch (error) {
      if (mounted && _checkSession()) await _handleError(error.reason);
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _confirming = false;
        });
      }
    }
  }

  Future<void> _handleError(AccountDeletionError reason) async {
    if (reason == AccountDeletionError.sessionExpired) {
      setState(() {
        _challenge = null;
        _code.clear();
        _blocked = true;
        _message = 'delete.sessionExpired';
      });
      await widget.app.returnToSignIn(widget.session, 'delete.sessionExpired');
      return;
    }
    setState(() {
      switch (reason) {
        case AccountDeletionError.invalidCode:
          _wrongCodes++;
          if (_wrongCodes < 5) {
            _codeError = 'delete.invalid';
            return;
          }
          _challenge = null;
          _code.clear();
          _codeError = null;
          _message = 'delete.expired';
        case AccountDeletionError.expiredCode:
          _challenge = null;
          _code.clear();
          _codeError = null;
          _message = 'delete.expired';
        case AccountDeletionError.consentRequired:
          _consent = false;
          _challenge = null;
          _code.clear();
          _message = 'delete.consentRequired';
        case AccountDeletionError.rateLimited:
          _resendAt = widget.now().add(_resendDelay);
          _message = 'delete.rateLimited';
          _watchDeadlines();
        case AccountDeletionError.busy:
          _message = 'delete.busy';
        case AccountDeletionError.deliveryFailed:
          _challenge = null;
          _code.clear();
          _message = 'delete.delivery';
        case AccountDeletionError.outcomeUnknown:
          _uncertain = true;
          _challenge = null;
          _code.clear();
          _message = 'delete.unknown';
        case AccountDeletionError.protectedAccount:
        case AccountDeletionError.recoveryBlocked:
          _blocked = true;
          _challenge = null;
          _code.clear();
          _message = 'delete.supportRequired';
        case AccountDeletionError.unavailable:
          _blocked = true;
          _challenge = null;
          _code.clear();
          _message = 'delete.unavailable';
        case AccountDeletionError.requestFailed:
          // A lost resend response could have invalidated the old code.
          _challenge = null;
          _code.clear();
          _message = 'delete.requestFailed';
        case AccountDeletionError.sessionExpired:
          break;
      }
    });
  }

  Future<void> _openSupport() async {
    final opened = await openAcademySupport();
    if (opened || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not open the page, please try again'.tr)),
    );
  }

  static final _digits = TextInputFormatter.withFunction((oldValue, newValue) {
    const easternArabic = '٠١٢٣٤٥٦٧٨٩';
    const persian = '۰۱۲۳۴۵۶۷۸۹';
    final text = newValue.text.replaceAllMapped(RegExp(r'[٠-٩۰-۹]'), (match) {
      final digit = match[0]!;
      final index = easternArabic.indexOf(digit);
      return (index >= 0 ? index : persian.indexOf(digit)).toString();
    });
    return newValue.copyWith(text: text);
  });

  @override
  Widget build(BuildContext context) {
    final resend = _secondsUntil(_resendAt);
    final expires = _secondsUntil(_expiresAt);
    final theme = Theme.of(context);
    // This screen must follow system accessibility settings even though the
    // surrounding application fixes text scale for older layouts.
    final systemScale = MediaQueryData.fromView(View.of(context)).textScaler;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: systemScale),
      child: PopScope(
        canPop: !_confirming && !_uncertain,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Delete account'.tr),
            automaticallyImplyLeading: !_confirming && !_uncertain,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'delete.explanation'.tr,
                    style: theme.textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  if (!_blocked && !_uncertain && _challenge == null)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text('delete.consent'.tr),
                      value: _consent,
                      onChanged: _busy
                          ? null
                          : (value) => setState(() => _consent = value == true),
                    ),
                  if (_challenge != null) ...[
                    Text('delete.sent'.tr),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _code,
                      enabled: !_busy,
                      keyboardType: TextInputType.number,
                      textDirection: TextDirection.ltr,
                      autocorrect: false,
                      enableSuggestions: false,
                      autofillHints: const [AutofillHints.oneTimeCode],
                      inputFormatters: [
                        _digits,
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      decoration: InputDecoration(
                        labelText: 'delete.code'.tr,
                        errorText: _codeError?.tr,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (_) {
                        if (_codeError != null) {
                          setState(() => _codeError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    Text('delete.expires'.trParams({'seconds': '$expires'})),
                    const SizedBox(height: 16),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                      ),
                      onPressed: _busy ? null : _confirmDeletion,
                      child: Text('delete.confirm'.tr),
                    ),
                  ],
                  if (!_blocked && !_uncertain)
                    OutlinedButton(
                      onPressed: _busy || !_consent || resend > 0
                          ? null
                          : _requestCode,
                      child: Text(
                        resend > 0
                            ? 'delete.resendIn'.trParams({'seconds': '$resend'})
                            : (_resendAt == null
                                      ? 'delete.send'
                                      : 'delete.resend')
                                  .tr,
                      ),
                    ),
                  if (_busy)
                    Semantics(
                      label: 'Loading'.tr,
                      child: const LinearProgressIndicator(),
                    ),
                  if (_message != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Semantics(
                        liveRegion: true,
                        child: Text(
                          _message!.tr,
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    ),
                  if (_uncertain)
                    FilledButton(
                      onPressed: () => widget.app.returnToSignIn(
                        widget.session,
                        'delete.unknown',
                      ),
                      child: Text('delete.returnToSignIn'.tr),
                    ),
                  TextButton(
                    onPressed: _openSupport,
                    child: Text('delete.support'.tr),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _code.dispose();
    super.dispose();
  }
}
