import 'dart:async';

import '../../Data/data.dart';

/// An operation belongs to the identity and login generation that started it.
/// Credential contents stay private and must never enter diagnostics.
class SessionLeaseX {
  SessionLeaseX._(this._userId, this._token, this._revision, this._isActive);

  factory SessionLeaseX.capture({bool Function()? isActive}) => SessionLeaseX._(
    LocalDataX.userid,
    LocalDataX.token,
    LocalDataX.sessionRevision,
    isActive,
  );

  final String _userId;
  final String _token;
  final int _revision;
  final bool Function()? _isActive;

  bool get isCurrent =>
      (_isActive?.call() ?? true) &&
      LocalDataX.userid == _userId &&
      LocalDataX.token == _token &&
      LocalDataX.sessionRevision == _revision;

  bool get hasAuthenticatedIdentity => _userId.isNotEmpty && _token.isNotEmpty;

  /// Only an explicitly user-authenticated request may expire this session.
  bool authenticates(String url) =>
      hasAuthenticatedIdentity &&
      Uri.tryParse(url)?.queryParameters['wstoken'] == _token;
}

/// Local notification only; never retries a request or calls the server.
class SessionExpiryX {
  static final _events = StreamController<SessionLeaseX>.broadcast(sync: true);
  static Stream<SessionLeaseX> get events => _events.stream;

  static void report(SessionLeaseX lease) {
    if (lease.hasAuthenticatedIdentity && lease.isCurrent) _events.add(lease);
  }
}
