import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../Core/Service/session_lease.dart';
import '../data.dart';
import 'config/database_end_point.dart';

enum AccountDeletionError {
  sessionExpired,
  unavailable,
  protectedAccount,
  consentRequired,
  invalidCode,
  expiredCode,
  rateLimited,
  busy,
  deliveryFailed,
  recoveryBlocked,
  requestFailed,
  outcomeUnknown,
}

class AccountDeletionException implements Exception {
  const AccountDeletionException(this.reason);

  final AccountDeletionError reason;
}

class AccountDeletionChallenge {
  const AccountDeletionChallenge(this.id, this.expiresIn);

  final String id;
  final int expiresIn;
}

class AccountDeletionApi {
  static const _request = 'local_user_anonymizer_request_self_anonymisation';
  static const _confirm = 'local_user_anonymizer_confirm_self_anonymisation';

  Future<AccountDeletionChallenge> requestCode(SessionLeaseX session) async {
    final reply = await _post(session, _request);
    final id = reply['requestid'];
    final expiresIn = reply['expiresin'];
    if (id is! String ||
        !RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(id) ||
        expiresIn is! int ||
        expiresIn <= 0 ||
        expiresIn > const Duration(days: 1).inSeconds) {
      throw const AccountDeletionException(AccountDeletionError.requestFailed);
    }
    return AccountDeletionChallenge(id, expiresIn);
  }

  Future<void> confirm(
    SessionLeaseX session,
    AccountDeletionChallenge challenge,
    String code,
  ) async {
    if (!RegExp(r'^[0-9]{6}$').hasMatch(code)) {
      throw const AccountDeletionException(AccountDeletionError.invalidCode);
    }
    final reply = await _post(session, _confirm, {
      'requestid': challenge.id,
      'code': code,
      'confirm': '1',
    });
    if (reply['status'] != 'anonymised' || reply['logoutrequired'] != true) {
      throw const AccountDeletionException(AccountDeletionError.outcomeUnknown);
    }
  }

  Future<Map<String, dynamic>> _post(
    SessionLeaseX session,
    String function, [
    Map<String, String> fields = const {},
  ]) async {
    if (!session.hasAuthenticatedIdentity || !session.isCurrent) {
      throw const AccountDeletionException(AccountDeletionError.sessionExpired);
    }
    final confirming = function == _confirm;
    final fallback = confirming
        ? AccountDeletionError.outcomeUnknown
        : AccountDeletionError.requestFailed;
    // Dedicated transport: the ordinary Moodle client puts tokens in the URL
    // and may retry or capture responses. These operations must do neither.
    final client = http.Client();
    try {
      final request = http.Request('POST', DBEndPointX.accountDeletionUri)
        ..followRedirects = false
        ..headers['Accept'] = 'application/json'
        ..bodyFields = {
          'wstoken': LocalDataX.token,
          'wsfunction': function,
          'moodlewsrestformat': 'json',
          ...fields,
        };
      final response = await (() async {
        return http.Response.fromStream(await client.send(request));
      })().timeout(const Duration(seconds: 20));
      if (response.statusCode == 401) {
        throw const AccountDeletionException(
          AccountDeletionError.sessionExpired,
        );
      }
      final Object? decoded;
      try {
        decoded = jsonDecode(utf8.decode(response.bodyBytes));
      } on FormatException {
        throw AccountDeletionException(fallback);
      }
      if (decoded is! Map<String, dynamic>) {
        throw AccountDeletionException(fallback);
      }
      if (decoded['exception'] != null ||
          decoded['errorcode'] != null ||
          response.statusCode < 200 ||
          response.statusCode >= 300) {
        final reason = switch (decoded['errorcode']) {
          'invalidtoken' ||
          'invalidwstoken' => AccountDeletionError.sessionExpired,
          'postrequired' ||
          'accessexception' ||
          'webserviceaccessexception' ||
          'servicenotavailable' ||
          'unknownfunction' => AccountDeletionError.unavailable,
          'protecteduser' => AccountDeletionError.protectedAccount,
          'confirmcheck' => AccountDeletionError.consentRequired,
          'confirmationinvalid' => AccountDeletionError.invalidCode,
          'confirmationexpired' => AccountDeletionError.expiredCode,
          'requestlimited' => AccountDeletionError.rateLimited,
          'requestbusy' => AccountDeletionError.busy,
          'confirmationdeliveryfailed' => AccountDeletionError.deliveryFailed,
          'recoverysize' ||
          'recoveryconflict' => AccountDeletionError.recoveryBlocked,
          _ =>
            response.statusCode == 429
                ? AccountDeletionError.rateLimited
                : fallback,
        };
        throw AccountDeletionException(reason);
      }
      return decoded;
    } on AccountDeletionException {
      rethrow;
    } catch (_) {
      // Never propagate a transport exception that might include request data.
      throw AccountDeletionException(fallback);
    } finally {
      client.close();
    }
  }
}
