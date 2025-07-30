class OtpX {
  OtpX({
    this.email,
    this.phone,
    this.countryCode,
    this.userid,
    required this.isSignUp,
    required this.isPhone,
    this.isEdit = false,
  });

  OtpX.empty();

  late String? email;
  late int? phone;
  late int? countryCode;
  late String? userid;
  late bool isSignUp;
  late bool isPhone;
  late bool isEdit;
}
