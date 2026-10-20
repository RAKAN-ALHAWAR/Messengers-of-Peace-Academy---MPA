import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:messengersofpeace/Core/Error/error.dart';

void main() {
  test('Flutter reporting never exposes arbitrary nested response payloads', () {
    FlutterErrorDetails? report;
    final previous = FlutterError.onError;
    FlutterError.onError = (details) => report = details;
    addTearDown(() => FlutterError.onError = previous);
    ErrorX(
      message: 'synthetic-sensitive',
      originalError:
          'https://user:synthetic-sensitive@host/path?unknown=synthetic-sensitive',
      details: {
        'response': [
          {'unknown': 'synthetic-sensitive'},
        ],
      },
    ).log();
    expect(report, isNotNull);
    expect(
      report!.exception.toString(),
      isNot(contains('synthetic-sensitive')),
    );
    expect(report!.informationCollector, isNull);
  });
  test('unknown exceptions and URL stack frames are metadata only', () {
    expect(
      ErrorX.diagnosticSummary(Exception('synthetic-sensitive')),
      isNot(contains('synthetic-sensitive')),
    );
    final stack = ErrorX.diagnosticStack(
      'frame https://user:synthetic-sensitive@host/path?unknown=synthetic-sensitive\npackage:app/a.dart:10',
    );
    expect(stack, isNot(contains('synthetic-sensitive')));
    expect(stack, contains('package:app/a.dart:10'));
  });
}
