import 'package:messengersofpeace/Core/Extension/convert/convert.dart';

import '../../../Core/Helper/model/model.dart';
import '../../data.dart';
import 'custom_field.dart';

class UserX {
  UserX({
    required this.id,
    required this.username,
    required this.firstname,
    required this.lastname,
    required this.email,
    required this.lang,
    required this.customfields,
    required this.city,
    required this.image,
    required this.points,
  });

  String id;
  String username;
  String firstname;
  String lastname;
  String email;
  String lang;
  String city;
  String image;
  List<CustomField> customfields;
  int points;

  // دوال مساعدة للوصول للحقول المخصصة الشائعة
  String get whatsapp {
    final whatsappField = customfields.firstWhere(
      (field) => field.name == NameX.whatsappNumber,
      orElse: () => CustomField(name: NameX.whatsappNumber, value: ''),
    );
    return whatsappField.value;
  }

  String get phone {
    final whatsappField = whatsapp;
    if (whatsappField.isNotEmpty) {
      return whatsappField.substring(phoneCodeCountry.length);
    }
    return "";
  }

  String get phoneCodeCountry {
    final phoneCodeCountry = customfields.firstWhere(
      (field) => field.name == NameX.countrycode,
      orElse: () => CustomField(name: NameX.countrycode, value: '+966'),
    );
    return phoneCodeCountry.value;
  }

  String get gender {
    final genderField = customfields.firstWhere(
      (field) => field.name == NameX.gender,
      orElse: () => CustomField(name: NameX.gender, value: 'male'),
    );
    return genderField.value.toLowerCase().contains("female")
        ? "female"
        : "male";
  }

  String get age {
    final ageField = customfields.firstWhere(
      (field) => field.name == NameX.age,
      orElse: () => CustomField(name: NameX.age, value: ''),
    );
    if (ageField.value.isNotEmpty && ageField.value.contains("{mlang}")) {
      if (ageField.value.contains("{mlang en}")) {
        final startIndex =
            ageField.value.indexOf("{mlang en}") + "{mlang en}".length;
        final endIndex = ageField.value.indexOf("{mlang}", startIndex);
        if (endIndex != -1) {
          ageField.value = ageField.value.substring(startIndex, endIndex);
        }
      }
    }
    return ageField.value;
  }

  String get accountType {
    final accountTypeField = customfields.firstWhere(
      (field) => field.name == NameX.accountType,
      orElse: () => CustomField(name: NameX.accountType, value: ''),
    );
    return accountTypeField.value;
  }

  String get role {
    final roleField = customfields.firstWhere(
      (field) => field.name == NameX.role,
      orElse: () => CustomField(name: NameX.role, value: ''),
    );
    return roleField.value;
  }

  String get country {
    final nationalityField = customfields.firstWhere(
      (field) => field.name == NameX.nationality,
      orElse: () => CustomField(name: NameX.nationality, value: ''),
    );
    return nationalityField.value;
  }

  String get telegramId {
    final telegramField = customfields.firstWhere(
      (field) => field.name == NameX.telegramId,
      orElse: () => CustomField(name: NameX.telegramId, value: ''),
    );
    return telegramField.value;
  }

  String get telegramName {
    final telegramNameField = customfields.firstWhere(
      (field) => field.name == NameX.telegramName,
      orElse: () => CustomField(name: NameX.telegramName, value: ''),
    );
    return telegramNameField.value;
  }

  String get howToFindUs {
    final hearboutUsField = customfields.firstWhere(
      (field) => field.name == NameX.hearboutUs,
      orElse: () => CustomField(name: NameX.hearboutUs, value: ''),
    );
    if (hearboutUsField.value.isNotEmpty &&
        hearboutUsField.value.contains("{mlang}")) {
      if (hearboutUsField.value.contains("{mlang en}")) {
        final startIndex =
            hearboutUsField.value.indexOf("{mlang en}") + "{mlang en}".length;
        final endIndex = hearboutUsField.value.indexOf("{mlang}", startIndex);
        if (endIndex != -1) {
          hearboutUsField.value = hearboutUsField.value.substring(
            startIndex,
            endIndex,
          );
        }
      }
    }
    return hearboutUsField.value;
  }

  String get language {
    final ulangField = customfields.firstWhere(
      (field) => field.name == NameX.ulang,
      orElse: () => CustomField(name: NameX.ulang, value: ''),
    );
    return ulangField.value;
  }

  String get howToFindUsOthers {
    final othersField = customfields.firstWhere(
      (field) => field.name == NameX.othersHearboutUs,
      orElse: () => CustomField(name: NameX.othersHearboutUs, value: ''),
    );
    return othersField.value;
  }

  String get university {
    final ksaunistudyField = customfields.firstWhere(
      (field) => field.name == NameX.ifyesksastudy,
      orElse: () => CustomField(name: NameX.ifyesksastudy, value: ''),
    );
    if (ksaunistudyField.value.isNotEmpty &&
        ksaunistudyField.value.contains("{mlang}")) {
      if (ksaunistudyField.value.contains("{mlang en}")) {
        final startIndex =
            ksaunistudyField.value.indexOf("{mlang en}") + "{mlang en}".length;
        final endIndex = ksaunistudyField.value.indexOf("{mlang}", startIndex);
        if (endIndex != -1) {
          ksaunistudyField.value = ksaunistudyField.value.substring(
            startIndex,
            endIndex,
          );
        }
      }
    }
    return ksaunistudyField.value;
  }

  bool get isSaudiUniversity {
    final ifyesksastudyField = customfields.firstWhere(
      (field) => field.name == NameX.ksaunistudy,
      orElse: () => CustomField(name: NameX.ksaunistudy, value: 'no'),
    );
    return ifyesksastudyField.value.toLowerCase().contains("yes");
  }

  // دالة للحصول على أي حقل مخصص بالاسم
  String getCustomField(String fieldName) {
    final field = customfields.firstWhere(
      (field) => field.name == fieldName,
      orElse: () => CustomField(name: fieldName, value: ''),
    );
    return field.value;
  }

  factory UserX.fromJson(Map<String, dynamic> json) {
    return ModelUtilX.checkFromJson(json, (json) {
      List<Map<String, dynamic>> customfieldsJson = [];
      if (json[NameX.customfields] != null &&
          json[NameX.customfields] is List) {
        customfieldsJson = List<Map<String, dynamic>>.from(
          json[NameX.customfields] as List,
        );
      }

      return UserX(
        id: json[NameX.id].toStrX,
        username: json[NameX.username].toStrX,
        firstname: json[NameX.firstname].toStrDefaultX(''),
        lastname: json[NameX.lastname].toStrDefaultX(''),
        email: json[NameX.email].toStrX,
        lang: json[NameX.lang].toStrDefaultX('en'),
        customfields: ModelUtilX.generateItems(
          customfieldsJson,
          CustomField.fromJson,
        ),
        city: json[NameX.city].toStrDefaultX(''),
        image: json[NameX.profileImageUrl].toStrDefaultX(''),
        points: json[NameX.points].toIntDefaultX(0),
      );
    }, requiredDataKeys: [NameX.id, NameX.username, NameX.email]);
  }

  Map<String, dynamic> toJson() {
    return {
      NameX.id: id,
      NameX.username: username,
      NameX.firstname: firstname,
      NameX.lastname: lastname,
      NameX.email: email,
      NameX.lang: lang,
      NameX.city: city,
      NameX.profileImageUrl: image,
      NameX.points: points,
      NameX.customfields: customfields.map((field) => field.toJson()).toList(),
    };
  }

  // دالة للحصول على الاسم الكامل
  String get fullName => '$firstname $lastname'.trim();

  // دالة للحصول على الاسم للعرض (إما الاسم الكامل أو اسم المستخدم)
  String get displayName {
    if (firstname.isNotEmpty || lastname.isNotEmpty) {
      return fullName;
    }
    return username;
  }
}
