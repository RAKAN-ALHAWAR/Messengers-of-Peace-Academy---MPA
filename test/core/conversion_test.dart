import 'package:flutter_test/flutter_test.dart';
import 'package:messengersofpeace/Core/Extension/convert/convert.dart';

void main() {
  test(
    'numeric strings preserve counts, fractions and truncation semantics',
    () {
      const Object integer = '11';
      const Object fraction = '75.5';
      const Object spaced = '  -12.8  ';
      expect(integer.toIntDefaultX(1), 11);
      expect(fraction.toDoubleDefaultX(0), 75.5);
      expect(fraction.toIntDefaultX(9), 75);
      expect(spaced.toIntDefaultX(9), -12);
      expect(spaced.toDoubleDefaultX(9), -12.8);
    },
  );

  test('typed numbers and integer bool conversions retain their meaning', () {
    for (final Object value in [11, 11.0]) {
      expect(value.toIntDefaultX(99), 11);
      expect(value.toDoubleDefaultX(99), 11.0);
    }
    const Object fraction = 75.5;
    const Object yes = true;
    const Object no = false;
    expect(fraction.toIntDefaultX(0), 75);
    expect(fraction.toDoubleDefaultX(0), 75.5);
    expect(yes.toIntDefaultX(7), 1);
    expect(no.toIntDefaultX(7), 0);
    expect(yes.toDoubleDefaultX(7), 7);
  });

  test('missing, invalid and unsupported values retain explicit defaults', () {
    for (final Object? value in [null, '', '  ', 'eleven', Object(), <int>[]]) {
      expect(value.toIntDefaultX(-27), -27);
      expect(value.toDoubleDefaultX(-27.5), -27.5);
    }
  });

  test('nonfinite input cannot escape a default conversion', () {
    for (final Object value in [
      double.nan,
      double.infinity,
      double.negativeInfinity,
      'NaN',
      'Infinity',
      '-Infinity',
    ]) {
      expect(value.toIntDefaultX(17), 17);
      expect(value.toDoubleDefaultX(17.5), 17.5);
    }
  });

  test(
    'strict and nullable conversions do not invent missing critical values',
    () {
      const Object? missing = null;
      const Object invalid = 'not-an-id';
      const Object valid = '11';
      expect(() => missing.toIntX, throwsException);
      expect(() => invalid.toIntX, throwsException);
      expect(missing.toIntNullableX, isNull);
      expect(invalid.toIntNullableX, isNull);
      expect(valid.toIntX, 11);
      expect(valid.toIntNullableX, 11);
      expect(() => missing.toDoubleX, throwsException);
      expect(() => invalid.toDoubleX, throwsException);
      expect(missing.toDoubleNullableX, isNull);
      expect(invalid.toDoubleNullableX, isNull);
    },
  );
}
