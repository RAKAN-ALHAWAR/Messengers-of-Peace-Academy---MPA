class UpdateUserForm {
  final String? username;
  final String? firstname;
  final String? lastname;
  final String? language;
  final String? gender;
  final String? whatsappNumber;
  final String? countryPhoneCode;
  final DateTime? birthOfDate;
  final String? age;
  final String? hearAboutUs;
  final String? telegramId;
  final String? telegramName;
  final bool? isSaudiUniversityStudent;
  final String? saudiUniversityName;
  final String? country;
  final String? city;
  final String? howToFindUsOthers;
  final String? email;

  UpdateUserForm({
    required this.username,
    required this.firstname,
    required this.lastname,
    required this.language,
    required this.gender,
    required this.whatsappNumber,
    required this.countryPhoneCode,
    this.birthOfDate,
    this.age,
    required this.hearAboutUs,
    required this.telegramId,
    required this.telegramName,
    required this.isSaudiUniversityStudent,
    required this.saudiUniversityName,
    required this.country,
    required this.city,
    required this.howToFindUsOthers,
    required this.email,
  });

  String? get getAge {
    if (age != null && age!.isNotEmpty) {
      return age;
    }
    int? year =
        (birthOfDate != null ? DateTime.now().year - birthOfDate!.year : null);
    List<String> listAge = ["18-25 Yrs", "26-40 Yrs", "41-65 Yrs", "+65 Yrs"];
    if (year != null) {
      if (year <= 25) {
        return listAge[0];
      } else if (year >= 26 && year <= 40) {
        return listAge[1];
      } else if (year >= 41 && year <= 65) {
        return listAge[2];
      } else {
        return listAge[3];
      }
    }
    return null;
  }

  Map<String, String> toMap() {
    return {
      // if (username != null && username!.isNotEmpty) "username": username!,
      // if (email != null && email!.isNotEmpty) "email": email!,
      if (firstname != null && firstname!.isNotEmpty)
        "profile[firstname]": firstname!,
      if (lastname != null && lastname!.isNotEmpty)
        "profile[lastname]": lastname!,
      if (city != null && city!.isNotEmpty) "profile[city]": city!,
      if (language != null && language!.isNotEmpty)
        "customfields[0][name]": "ulang",
      if (language != null && language!.isNotEmpty)
        "customfields[0][value]": language!,
      if (gender != null && gender!.isNotEmpty)
        "customfields[1][name]": "gender",
      if (gender != null && gender!.isNotEmpty)
        "customfields[1][value]": gender!,
      if (whatsappNumber != null && whatsappNumber!.isNotEmpty)
        "customfields[2][name]": "WhatsAppNumber",
      if (whatsappNumber != null && whatsappNumber!.isNotEmpty)
        "customfields[2][value]": whatsappNumber!,
      if (getAge != null && getAge!.isNotEmpty) "customfields[3][name]": "Age",
      if (getAge != null && getAge!.isNotEmpty)
        "customfields[3][value]": getAge!,
      if (hearAboutUs != null && hearAboutUs!.isNotEmpty)
        "customfields[4][name]": "HearboutUs",
      if (hearAboutUs != null && hearAboutUs!.isNotEmpty)
        "customfields[4][value]": hearAboutUs!,
      if (telegramId != null && telegramId!.isNotEmpty)
        "customfields[5][name]": "telegramid",
      if (telegramId != null && telegramId!.isNotEmpty)
        "customfields[5][value]": telegramId!,
      if (telegramName != null && telegramName!.isNotEmpty)
        "customfields[6][name]": "telegramname",
      if (telegramName != null && telegramName!.isNotEmpty)
        "customfields[6][value]": telegramName!,
      if (isSaudiUniversityStudent != null)
        "customfields[7][name]": "ksaunistudy",
      if (isSaudiUniversityStudent != null)
        "customfields[7][value]": isSaudiUniversityStudent! ? "Yes" : "No",
      if (saudiUniversityName != null && saudiUniversityName!.isNotEmpty)
        "customfields[8][name]": "ifyesksastudy",
      if (saudiUniversityName != null && saudiUniversityName!.isNotEmpty)
        "customfields[8][value]": saudiUniversityName!,
      if (country != null && country!.isNotEmpty)
        "customfields[9][name]": "nationality",
      if (country != null && country!.isNotEmpty)
        "customfields[9][value]": country!,
      if (howToFindUsOthers != null && howToFindUsOthers!.isNotEmpty)
        "customfields[10][name]": "others_HearboutUs",
      if (howToFindUsOthers != null && howToFindUsOthers!.isNotEmpty)
        "customfields[10][value]": howToFindUsOthers!,
      if (howToFindUsOthers != null && countryPhoneCode!.isNotEmpty)
        "customfields[11][name]": "countrycode",
      if (howToFindUsOthers != null && countryPhoneCode!.isNotEmpty)
        "customfields[11][value]": countryPhoneCode!,
    };
  }
}
