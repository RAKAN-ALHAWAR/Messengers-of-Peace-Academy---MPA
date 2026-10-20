import 'package:flutter_test/flutter_test.dart';
import 'package:messengersofpeace/Data/Form/update_user_form.dart';
import 'package:messengersofpeace/Data/Model/user/custom_field.dart';
import 'package:messengersofpeace/Data/Model/user/user.dart';

UserX userWithPhone(String phone, String prefix) => UserX(
  id: 'synthetic-user',
  username: 'synthetic',
  firstname: 'Test',
  lastname: 'User',
  email: 'test@example.invalid',
  lang: 'en',
  city: 'Damascus',
  image: '',
  points: 0,
  customfields: [
    CustomField(name: 'WhatsAppNumber', value: phone),
    CustomField(name: 'countrycode', value: prefix),
  ],
);

UpdateUserForm birthForm(DateTime? birth, {String? age}) => UpdateUserForm(
  username: null,
  firstname: null,
  lastname: null,
  language: null,
  gender: null,
  whatsappNumber: null,
  countryPhoneCode: null,
  birthOfDate: birth,
  age: age,
  hearAboutUs: null,
  telegramId: null,
  telegramName: null,
  isSaudiUniversityStudent: null,
  saudiUniversityName: null,
  country: null,
  city: null,
  howToFindUsOthers: null,
  email: null,
);

void main() {
  test('short legacy phone is preserved without RangeError', () {
    expect(userWithPhone('12', '+963').phone, '12');
  });
  test('mismatched prefix preserves the entire legacy phone', () {
    expect(userWithPhone('+441234567890', '+963').phone, '+441234567890');
  });
  test(
    'matching prefix strips only that prefix and empty values stay empty',
    () {
      expect(userWithPhone('+963944123456', '+963').phone, '944123456');
      expect(userWithPhone('', '+963').phone, '');
      expect(userWithPhone('944123456', '').phone, '944123456');
    },
  );
  for (final (years, previous, current) in [
    (26, '18-25 Yrs', '26-40 Yrs'),
    (41, '26-40 Yrs', '41-65 Yrs'),
    (66, '41-65 Yrs', '+65 Yrs'),
  ]) {
    for (final day in [19, 20, 21]) {
      test('age bucket before/on/after $years birthday: day $day', () {
        final birth = DateTime(2026 - years, 10, 20);
        expect(
          birthForm(birth).ageBucketAt(DateTime(2026, 10, day)),
          day < 20 ? previous : current,
        );
      });
    }
  }
  test(
    'explicit backend age code wins and no new DOB or clearing fields appear',
    () {
      expect(birthForm(DateTime(1990), age: '+65 Yrs').getAge, '+65 Yrs');
      expect(birthForm(null).toMap(), isEmpty);
      final fields = birthForm(DateTime(1990)).toMap();
      expect(fields.keys.toSet(), {
        'customfields[3][name]',
        'customfields[3][value]',
      });
    },
  );
}
