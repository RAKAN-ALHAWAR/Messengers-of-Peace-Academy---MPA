part of '../data.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this section }}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// Manage all database connections
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class DatabaseX {
  static init() async {
    try {
      /// Here codes are added to configure anything within this section when the application starts
    } catch (e) {
      return Future.error(e);
    }
  }

  //============================================================================
  // Auth

  static Future<String> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String username,
    required String lang,
  }) async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postSignUp,
      body: {
        NameX.email: email,
        NameX.password: password,
        NameX.firstname: firstName,
        NameX.lastname: lastName,
        NameX.username: username,
        NameX.lang: lang,
      },
    );
    if (data.$1[NameX.userId] != null) {
      return data.$1[NameX.userId].toString();
    } else {
      throw ErrorX(details: data.$1);
    }
  }

  static Future<(String userid, String token)> login({
    required String email,
    required String password,
  }) async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postLogin,
      body: {NameX.username: email, NameX.password: password},
    );
    if (data.$1[NameX.userId] != null) {
      return (
        data.$1[NameX.userId].toString(),
        (data.$1[NameX.token] ?? "").toString(),
      );
    } else {
      throw ErrorX(details: data.$1);
    }
  }

  static Future<String> loginByGoogle({required String token}) async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postLoginByGoogle,
      body: {NameX.idtoken: token},
    );
    if (data.$1[NameX.userId] != null) {
      return data.$1[NameX.userId].toString();
    } else {
      throw ErrorX(details: data.$1);
    }
  }

  //============================================================================
  // Forget Password
  static Future<String?> forgetPassword({required String email}) async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postForgetPassword,
      body: {NameX.username: email},
    );
    return data.$2;
  }

  static Future<String?> resetForgetPassword({
    required String email,
    required String otpCode,
    required String password,
  }) async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postResetForgetPassword,
      body: {
        NameX.username: email,
        NameX.otp: otpCode,
        NameX.newpassword: password,
      },
    );
    return data.$2;
  }

  //============================================================================
  // OTP
  static Future<String?> verifyOtpForgetPassword({
    required String email,
    required String otpCode,
  }) async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postVerifyOtpForgetPassword,
      body: {NameX.username: email, NameX.otp: otpCode},
    );
    return data.$2;
  }

  static Future<String?> resendOtpSignUp({required String email}) async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postResendOtpSignUp,
      body: {NameX.username: email},
    );
    return data.$2;
  }

  static Future<String?> verifyOtpSignUp({
    required String userId,
    required String otpCode,
  }) async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postVerifyOtpSignUp,
      body: {NameX.userId: userId, NameX.otp: otpCode},
    );
    return data.$2;
  }

  static Future<String?> logout({required String token}) async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postLogout,
      body: {NameX.token: token},
    );
    return data.$2;
  }

  //============================================================================
  // Change Password
  static Future<String?> updatePassword({
    required String username,
    required String oldPassword,
    required String newPassword,
  }) async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postUpdatePassword,
      body: {
        NameX.username: username,
        NameX.oldPassword: oldPassword,
        NameX.newPassword: newPassword,
        NameX.confirmPassword: newPassword,
      },
    );
    if (data.$1[NameX.status] == "success") {
      return data.$2;
    } else {
      throw ErrorX(message: data.$2);
    }
  }

  //============================================================================
  // User
  static Future<UserX> getUser({String? userId}) async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postGetUser,
      body: {NameX.userId: userId ?? LocalDataX.userid},
    );
    return UserX.fromJson(data.$1);
  }

  static Future<UserStatisticsX> getUserStatistics() async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postGetUserStatistics,
      body: {NameX.userId: LocalDataX.userid},
    );
    return UserStatisticsX.fromJson(data.$1);
  }

  static Future<String?> updateUser({
    required UpdateUserForm form,
    required String username,
  }) async {
    var response = await RemoteDataSourceX.post(
      DBEndPointX.postUpdateUser,
      body: {NameX.username: username, ...form.toMap()},
    );
    return response.$2;
  }

  static Future<String?> updateUserImage({required File image}) async {
    var response = await RemoteDataSourceX.postFiles(
      DBEndPointX.postUpdateUserImage,
      {NameX.file: image},
      body: {NameX.userId: LocalDataX.userid, NameX.filename: 'avatar.png'},
    );
    return response.$2;
  }

  //============================================================================
  // Info
  static Future<List<Country>> getCountriesList() async {
    var data = await RemoteDataSourceX.post(DBEndPointX.postCountriesList);
    if (data.$1 is List) {
      var list = ModelUtilX.generateItems(data.$1, Country.fromJson);
      list.removeWhere((element) => element.name == "");
      return list;
    } else {
      throw ErrorX(details: data.$1);
    }
  }

  static Future<List<PhoneCode>> getPhoneCodeCountriesList() async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postPhoneCodeCountriesList,
    );
    if (data.$1 is List) {
      var list = ModelUtilX.generateItems(data.$1, PhoneCode.fromJson);
      list.removeWhere((element) => element.dialCode == "");
      return list;
    } else {
      throw ErrorX(details: data.$1);
    }
  }

  static Future<List<Language>> getNativeLanguages() async {
    var data = await RemoteDataSourceX.post(DBEndPointX.postNativeLanguages);
    if (data.$1 is List) {
      var list = ModelUtilX.generateItems(data.$1, Language.fromJson);
      list.removeWhere((element) => element.name == "");
      return list;
    } else {
      throw ErrorX(details: data.$1);
    }
  }

  //============================================================================
  // Complaint or Suggestion
  static Future<String?> submitComplaintOrSuggestion({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postSubmitComplaintOrSuggestion,
      body: {
        NameX.name: name,
        NameX.email: email,
        NameX.subject: subject,
        NameX.message: message,
      },
    );
    return data.$2;
  }

  //============================================================================
  // Courses
  static Future<List<LevelX>> getLevelsWithCourses() async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postGetLevelsWithCourses,
      body: {NameX.userId: LocalDataX.userid},
    );
    if (data.$1 is List) {
      return ModelUtilX.generateItems(data.$1, LevelX.fromJson);
    } else {
      throw ErrorX(details: data.$1);
    }
  }

  static Future<List<MyCourse>> getMyCourses() async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postMyCourses,
      body: {NameX.userId: LocalDataX.userid},
    );
    if (data.$1 is List) {
      return ModelUtilX.generateItems(data.$1, MyCourse.fromJson);
    } else {
      throw ErrorX(details: data.$1);
    }
  }

  static Future<CourseX> getCourse({required String courseId}) async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postGetCourse,
      body: {NameX.userId: LocalDataX.userid, NameX.courseId: courseId},
    );
    return CourseX.fromJson(data.$1);
  }

  static Future<LevelX> getCurrentLevel() async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postGetCurrentLevel,
      body: {NameX.userId: LocalDataX.userid},
    );
    return LevelX.fromJson(data.$1);
  }

  static Future<String?> completeVideoOfCourse({required String cmId}) async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postCompleteVideoOfCourse,
      body: {NameX.userId: LocalDataX.userid, NameX.cmId: cmId},
    );
    return data.$2;
  }

  //============================================================================
  // Certificates
  static Future<List<MyCertificate>> getMyCertificates() async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postGetMyCertificates,
      body: {NameX.userId: LocalDataX.userid},
    );
    if (data.$1 is List) {
      return ModelUtilX.generateItems(data.$1, MyCertificate.fromJson);
    } else {
      throw ErrorX(details: data.$1);
    }
  }

  //============================================================================
  // Blog
  static Future<List<BlogX>> getBlogs({
    required String lang,
    int page = 0,
  }) async {
    List<BlogX> blogs = [];
    var tagid =
        lang == "ar"
            ? 1
            : lang == "en"
            ? 2
            : lang == "es"
            ? 3
            : lang == "ph"
            ? 4
            : 2;
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postGetBlogs,
      body: {
        "filters[0][name]": NameX.tagid,
        "filters[0][value]": tagid.toString(),
        NameX.page: page.toString(),
      },
    );
    if (data.$1?[NameX.entries] is List) {
      blogs = ModelUtilX.generateItems(
        data.$1?[NameX.entries] ?? [],
        BlogX.fromJson,
      );
    } else {
      throw ErrorX(details: data.$1);
    }
    if (data.$1?[NameX.totalentries] != null) {
      var totalEntries = data.$1?[NameX.totalentries] as int;
      var totalPages = (totalEntries / 10).ceil();
      if (page < totalPages) {
        blogs.addAll(await getBlogs(lang: lang, page: page + 1));
      }
    }
    return blogs;
  }

  //============================================================================
  // Notifications
  static Future<List<NotificationX>> getNotifications() async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postGetNotifications,
      body: {NameX.userId: LocalDataX.userid, NameX.readStatus: "all"},
    );
    if (data.$1 is List) {
      return ModelUtilX.generateItems(data.$1, NotificationX.fromJson);
    } else {
      throw ErrorX(details: data.$1);
    }
  }

  static Future<String?> readNotifications({
    String notificationId = "0",
  }) async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postReadNotifications,
      body: {
        NameX.userId: LocalDataX.userid,
        NameX.notificationId: notificationId,
      },
    );
    return data.$2;
  }

  //============================================================================
  // Events
  static Future<List<EventX>> getEvents() async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postGetEvents,
      body: {NameX.userId: LocalDataX.userid},
    );
    if (data.$1 is List) {
      return ModelUtilX.generateItems(data.$1, EventX.fromJson);
    } else {
      throw ErrorX(details: data.$1);
    }
  }

  static Future<EventX> getEventDetails({required String eventId}) async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postGetEventDetails,
      body: {
        // NameX.userId: LocalDataX.userid,
        NameX.eventId: eventId,
      },
    );
    return EventX.fromJson(data.$1);
  }

  static Future<String?> addEvent({
    required String title,
    required String description,
    required String location,
    required int startTime,
    required int endTime,
    required bool isRepeated,
    required int repeatCount,
  }) async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postAddEvent,
      body: {
        NameX.userId: LocalDataX.userid,
        NameX.title: title,
        NameX.description: description,
        NameX.location: location,
        NameX.startTime: startTime.toString(),
        NameX.endTime: endTime.toString(),
        if (isRepeated) NameX.repeatCount: repeatCount.toString(),
      },
    );
    return data.$2;
  }

  static Future<String?> editEvent({
    required String eventId,
    required String title,
    required String description,
    required String location,
    required int startTime,
    required int endTime,
    required bool isRepeated,
    required int repeatCount,
    required EventOptionEX editOption,
  }) async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postEditEvent,
      body: {
        // NameX.userId: LocalDataX.userid,
        NameX.eventId: eventId,
        NameX.title: title,
        NameX.description: description,
        NameX.location: location,
        NameX.startTime: startTime.toString(),
        NameX.endTime: endTime.toString(),
        NameX.repeatCount: isRepeated ? repeatCount.toString() : "0",
        NameX.updateOption: editOption.name,
      },
    );
    return data.$2;
  }

  static Future<String?> deleteEvent({
    required String eventId,
    required EventOptionEX deleteOption,
  }) async {
    try {
      var data = await RemoteDataSourceX.post(
        DBEndPointX.postDeleteEvent,
        body: {
          // NameX.userId: LocalDataX.userid,
          NameX.eventId: eventId,
          NameX.deleteOption: deleteOption.name,
        },
      );
      return data.$2;
    } catch (e) {
      var error = e.toErrorX;
      if (error.details[NameX.exception] == "dml_missing_record_exception") {
        return null;
      } else {
        throw error;
      }
    }
  }

  //============================================================================
  // Meetings
  static Future<List<MeetingX>> getMeetings({
    required MeetingOptionEX option,
  }) async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postGetMeetings,
      body: {NameX.status: option.name},
    );
    if (data.$1?[NameX.meetings] is List) {
      return ModelUtilX.generateItems(
        data.$1?[NameX.meetings],
        MeetingX.fromJson,
      );
    } else {
      throw ErrorX(details: data.$1);
    }
  }

  //============================================================================
  // Other
  static Future<List<BadgeX>> getBadges() async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postGetBadges,
      body: {NameX.userId: LocalDataX.userid},
    );
    if (data.$1 is List) {
      return ModelUtilX.generateItems(data.$1, BadgeX.fromJson);
    } else {
      throw ErrorX(details: data.$1);
    }
  }

  static Future<List<LeaderboardX>> getLeaderboard() async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postGetLeaderboard,
      // body: {NameX.userId: LocalDataX.userid},
    );
    if (data.$1 is List) {
      return ModelUtilX.generateItems(data.$1, LeaderboardX.fromJson);
    } else {
      throw ErrorX(details: data.$1);
    }
  }

  static Future<List<ActivityPointX>> getActivityPoints() async {
    var data = await RemoteDataSourceX.post(DBEndPointX.postGetActivityPoints);
    if (data.$1 is List) {
      return ModelUtilX.generateItems(data.$1, ActivityPointX.fromJson);
    } else {
      throw ErrorX(details: data.$1);
    }
  }

  //============================================================================
  // My Activity Points
  static Future<List<MyActivityPointX>> getMyActivityPoints() async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postGetMyActivityPoints,
      body: {NameX.userId: LocalDataX.userid},
    );
    if (data.$1 is List) {
      return ModelUtilX.generateItems(data.$1, MyActivityPointX.fromJson);
    } else {
      throw ErrorX(details: data.$1);
    }
  }

  //============================================================================
  // Quiz
  static Future<QuizX> getQuizDetails({required String quizId}) async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postGetQuizDetails,
      body: {NameX.userId: LocalDataX.userid, NameX.quizId: quizId},
    );
    return QuizX.fromJson(data.$1);
  }

  static Future<QuizStartAttemptX> getQuizStartAttempt({
    required String quizId,
  }) async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postGetQuizStartAttempt,
      body: {NameX.userId: LocalDataX.userid, NameX.quizId: quizId},
      isSkeepStatus: true,
    );
    return QuizStartAttemptX.fromJson(data.$1);
  }

  static Future<String?> submitQuiz({required String attemptId}) async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postSubmitQuiz,
      body: {NameX.userId: LocalDataX.userid, NameX.attemptId: attemptId},
      isSkeepStatus: true,
    );
    return data.$2;
  }

  static Future<String?> submitQuizQuestionAnswer({
    required String quizId,
    required String attemptId,
    required int questionNumber,
    required int answerIndex,
  }) async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postQuizSubmitQuestionAnswer,
      body: {
        NameX.userId: LocalDataX.userid,
        NameX.quizId: quizId,
        NameX.attemptId: attemptId,
        NameX.slot: questionNumber.toString(),
        "answer[0][key]": "answer",
        "answer[0][value]": answerIndex.toString(),
      },
    );
    return data.$2;
  }

  static Future<QuizResultX> getQuizResult({required String quizId}) async {
    var data = await RemoteDataSourceX.post(
      DBEndPointX.postGetQuizResult,
      body: {NameX.userId: LocalDataX.userid, NameX.quizId: quizId},
      isSkeepStatus: true,
    );
    return QuizResultX.fromJson(data.$1);
  }
}
