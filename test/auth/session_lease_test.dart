import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:messengersofpeace/Core/Service/session_lease.dart';
import 'package:messengersofpeace/Data/data.dart';

void main() {
  late Directory directory;
  setUpAll(() async {
    directory = await Directory.systemTemp.createTemp('mopa_lease_test');
    Hive.init(directory.path);
    HiveX.box = await Hive.openBox('app');
  });
  setUp(() async {
    await HiveX.box.clear();
    LocalDataX.put(LocalKeyX.userid, 'synthetic-A');
    LocalDataX.put(LocalKeyX.token, 'synthetic-token');
  });
  tearDownAll(() async {
    await Hive.close();
    await directory.delete(recursive: true);
  });

  test('unrelated preferences keep a lease valid', () {
    final lease = SessionLeaseX.capture();
    LocalDataX.put(LocalKeyX.language, 'ar');
    expect(lease.isCurrent, isTrue);
  });
  test('same-value login write invalidates older work', () {
    final lease = SessionLeaseX.capture();
    LocalDataX.put(LocalKeyX.token, 'synthetic-token');
    expect(lease.isCurrent, isFalse);
  });
  test('A to B to A cannot revive abandoned work', () {
    final lease = SessionLeaseX.capture();
    LocalDataX.put(LocalKeyX.userid, 'synthetic-B');
    LocalDataX.put(LocalKeyX.userid, 'synthetic-A');
    expect(lease.isCurrent, isFalse);
  });
  test('controller ownership and logout invalidate work', () {
    var active = true;
    final lease = SessionLeaseX.capture(isActive: () => active);
    active = false;
    expect(lease.isCurrent, isFalse);
    final next = SessionLeaseX.capture();
    LocalDataX.remove(LocalKeyX.token);
    expect(next.isCurrent, isFalse);
  });
  test(
    'low-level clear and restore cannot revive the previous session',
    () async {
      final lease = SessionLeaseX.capture();
      await HiveX.removeAll();
      await HiveX.put(key: LocalKeyX.userid, data: 'synthetic-A');
      await HiveX.put(key: LocalKeyX.token, data: 'synthetic-token');
      expect(lease.isCurrent, isFalse);
    },
  );
  test('expiry-driven credential removal invalidates a lease', () async {
    await LocalDataX.put(
      LocalKeyX.token,
      'synthetic-token',
      maxAge: const Duration(seconds: 1),
    );
    final lease = SessionLeaseX.capture();
    final revision = LocalDataX.sessionRevision;
    await HiveX.box.put(LocalKeyX.token, {
      'value': 'synthetic-token',
      'expiry': DateTime(2000).toIso8601String(),
    });
    expect(lease.isCurrent, isFalse);
    expect(LocalDataX.sessionRevision, greaterThan(revision));
  });
  test('expiry only reports current explicit user credentials', () {
    var events = 0;
    final subscription = SessionExpiryX.events.listen((_) => events++);
    addTearDown(subscription.cancel);
    final lease = SessionLeaseX.capture();
    expect(
      lease.authenticates('https://synthetic.invalid/?wstoken=synthetic-token'),
      isTrue,
    );
    expect(
      lease.authenticates('https://synthetic.invalid/?wstoken=public'),
      isFalse,
    );
    SessionExpiryX.report(lease);
    expect(events, 1);
    LocalDataX.remove(LocalKeyX.userid);
    SessionExpiryX.report(lease);
    SessionExpiryX.report(SessionLeaseX.capture());
    expect(events, 1);
  });
}
