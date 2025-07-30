part of '../core.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this Util }}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// Entry field validations
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class ValidatorX {
  /// Verify names
  static String? name(String? value) {
    String pattern = r'^[\u0621-\u064A\u0660\ a-zA-Z]+$';
    if (value!.trim().isEmpty) {
      return 'Name Required'.tr;
    } else if (value.trim().length < 2) {
      return 'It must be at least two characters'.tr;
    } else if (value.trim().length > 20) {
      return 'It must be no more than 20 characters'.tr;
    } else if (!RegExp(pattern).hasMatch(value.trim())) {
      return 'The name must consist of letters only'.tr;
    }
    return null;
  }

  static String? username(String? value) {
    if (value!.trim().isEmpty) {
      return 'Username Required'.tr;
    } else if (value.trim().length < 3) {
      return 'It must be at least 3 characters'.tr;
    }
    return null;
  }

  static String? message(String? value) {
    if (value!.trim().isEmpty) {
      return 'Message Required'.tr;
    } else if (value.trim().length < 10) {
      return 'It must be at least 10 characters'.tr;
    }
    return null;
  }

  static String? required(String? value) {
    if (value!.trim().isEmpty) {
      return 'Required'.tr;
    }
    return null;
  }

  static String? repeatCount(String? value) {
    value = value?.trim();
    if (value!.isEmpty) {
      return 'Repeat count required'.tr;
    } else if (int.tryParse(value) == null) {
      return 'It must be a number'.tr;
    } else if (int.parse(value) > 10) {
      return 'It must be no more than 10'.tr;
    }
    return null;
  }

  static String? eventTitle(String? value) {
    if (value!.trim().isEmpty) {
      return 'Event title required'.tr;
    } else if (value.trim().length < 3) {
      return 'It must be at least 3 characters'.tr;
    } else if (value.trim().length > 50) {
      return 'It must be no more than 50 characters'.tr;
    }
    return null;
  }

  static String? location(String? value) {
    if (value!.trim().isEmpty) {
      return 'Location Required'.tr;
    } else if (value.trim().length < 3) {
      return 'It must be at least 3 characters'.tr;
    } else if (value.trim().length > 100) {
      return 'It must be no more than 100 characters'.tr;
    }
    return null;
  }

  static String? city(String? value) {
    if (value!.trim().isEmpty) {
      return 'City Required'.tr;
    } else if (value.trim().length < 3) {
      return 'It must be at least 3 characters'.tr;
    } else if (value.trim().length > 100) {
      return 'It must be no more than 100 characters'.tr;
    }
    return null;
  }

  /// Verify long titles
  static String? title(String? value) {
    String pattern = r'^[\u0621-\u064A\u0660\ a-zA-Z0-9 -.]+$';
    if (value!.trim().isEmpty) {
      return 'Title Required'.tr;
    } else if (value.trim().length < 5) {
      return 'It must be at least 5 characters'.tr;
    } else if (value.trim().length > 100) {
      return 'It must be no more than 100 characters'.tr;
    } else if (!RegExp(pattern).hasMatch(value.trim())) {
      return 'It must consist of letters and numbers only'.tr;
    }
    return null;
  }

  /// Excused Comments
  static String? excusedComments(String? value) {
    if (value!.trim().isEmpty) {
      return 'Reason for non-attendance required'.tr;
    } else if (value.trim().length < 10) {
      return 'It must be at least 10 characters'.tr;
    }
    return null;
  }

  /// Verify long titles
  static String? description(String? value) {
    if (value!.trim().isEmpty) {
      return 'Description Required'.tr;
    } else if (value.trim().length < 10) {
      return 'It must be at least 10 characters'.tr;
    }
    return null;
  }

  /// Verify dates
  static String? date(String? value) {
    if (value!.trim().isEmpty) {
      return 'Date Required'.tr;
    }
    return null;
  }

  /// Verify the phone number
  static String? phone(String? value) {
    String pattern = r'(^(?:[+0]9|00)?[0-9]{8,12}$)';
    if (value!.trim().isEmpty) {
      return 'Phone Required'.tr;
    } else if (!RegExp(pattern).hasMatch(value.trim().arabicToEnglishNumbers)) {
      return 'Enter a valid phone number'.tr;
    }
    return null;
  }

  static String? password(String? value) {
    if (value!.trim().isEmpty) {
      return 'Password Required'.tr;
    } else if (value.trim().length < 8) {
      return 'Password must be at least 8 characters long'.tr;
    }
    return null;
  }

  static String? changePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password Required'.tr;
    } else if (value.trim().length < 8) {
      return 'Password must be at least 8 characters long'.tr;
    } else if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter'.tr;
    } else if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must include at least one special character'.tr;
    }
    return null;
  }

  static String? rePassword(String? value, String password) {
    if (value!.trim().isEmpty) {
      return 'Confirm password Required'.tr;
    } else if (value.trim() != password.trim()) {
      return 'Password do not match'.tr;
    }
    return null;
  }

  static String? idNumber(String? value) {
    if (value!.trim().isEmpty) {
      return 'ID Number Required'.tr;
    } else if (value.trim().length < 3) {
      return 'ID Number must be at least 3 characters long'.tr;
    }
    return null;
  }

  /// Verify Email
  static String? email(String? value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    if (value!.trim().isEmpty) {
      return 'Email Required'.tr;
    } else if (!RegExp(pattern).hasMatch(value.trim())) {
      return 'Enter Valid Email'.tr;
    }
    return null;
  }
}
