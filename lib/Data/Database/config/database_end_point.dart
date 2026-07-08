import 'dart:developer';

import '../../data.dart';

/// Contains links to database connection points
class DBEndPointX {
  //============================================================================
  // Main API links

  /// Base url of the Moodle web service
  static const String _baseUrl =
      'https://mopacademy.org/webservice/rest/server.php';

  /// Shared service token.
  ///
  /// Used **only** for the public endpoints that are called before the user
  /// is authenticated (sign up, login, otp, forgot password, static lists).
  static const String _serviceToken = '8a09f10d7521ab7803484a7cd647f515';

  /// Builds a web service url with the given [wstoken].
  static String _api(String wstoken) =>
      '$_baseUrl?wstoken=$wstoken&moodlewsrestformat=json&wsfunction=';

  /// Api for the endpoints that require an authenticated user.
  ///
  /// Uses the token returned by the backend on login / sign up.
  /// Falls back to the service token when there is no stored user token
  /// (e.g. the user is not logged in yet).
  static String get mainAPI {
    final userToken = LocalDataX.token;
    if (userToken.isNotEmpty) return _api(userToken);

    /// A logged in user without a token means the backend did not return one.
    /// The request will run with the shared service token and Moodle will
    /// reject any call that checks `userid == $USER->id` (quiz endpoints).
    if (LocalDataX.userid.isNotEmpty) {
      log(
        'No user wstoken stored for userid ${LocalDataX.userid}, '
        'falling back to the shared service token',
        name: 'DBEndPointX',
      );
    }
    return _api(_serviceToken);
  }

  /// Api for the public endpoints (before login).
  static String get publicAPI => _api(_serviceToken);

  //============================================================================
  // Auth

  static String get postSignUp =>
      '${publicAPI}local_otp_registration_create_user';
  static String get postLogin =>
      '${publicAPI}local_otp_registration_login_user';
  static String get postLoginByGoogle =>
      '${publicAPI}local_otp_registration_login_with_google_token';
  static String get postLogout =>
      '${publicAPI}local_otp_registration_logout_user';

  //============================================================================
  // Forget Password
  static String get postForgetPassword =>
      '${publicAPI}local_otp_registration_send_otp_for_password_reset';

  static String get postResetForgetPassword =>
      '${publicAPI}local_otp_registration_reset_password_with_otp';

  //============================================================================
  // OTP
  static String get postVerifyOtpSignUp =>
      '${publicAPI}local_otp_registration_verify_user';
  static String get postResendOtpSignUp =>
      '${publicAPI}local_otp_registration_resend_otp';
  static String get postVerifyOtpForgetPassword =>
      '${publicAPI}local_otp_registration_verify_otp_for_password_reset';

  //============================================================================
  // Info (public static lists, used inside the sign up flow)
  static String get postCountriesList =>
      '${publicAPI}local_otp_registration_get_country_list';
  static String get postPhoneCodeCountriesList =>
      '${publicAPI}local_otp_registration_get_country_calling_codes';
  static String get postNativeLanguages =>
      '${publicAPI}local_otp_registration_get_all_supported_languages';

  //============================================================================
  // Get User
  static String get postGetUser =>
      '${mainAPI}local_otp_registration_get_user_full_profile';

  static String get postUpdateUser =>
      '${mainAPI}local_otp_registration_update_user_profile';

  static String get postUpdateUserImage =>
      '${mainAPI}local_otp_registration_update_user_profile_picture';

  static String get postGetUserStatistics =>
      '${mainAPI}local_otp_registration_get_user_statistics';

  //============================================================================
  // Complaint or Suggestion
  static String get postSubmitComplaintOrSuggestion =>
      '${mainAPI}local_otp_registration_send_complaint';

  //============================================================================
  // Change Password
  static String get postUpdatePassword =>
      '${mainAPI}local_otp_registration_update_user_password';

  //============================================================================
  // Courses
  static String get postGetLevelsWithCourses =>
      '${mainAPI}local_otp_registration_get_user_categories_summary';

  static String get postMyCourses =>
      '${mainAPI}local_otp_registration_get_user_courses';

  static String get postGetCourse =>
      '${mainAPI}local_otp_registration_get_course_details';

  static String get postGetCurrentLevel =>
      '${mainAPI}local_otp_registration_get_user_current_level_courses';

  static String get postCompleteVideoOfCourse =>
      '${mainAPI}local_otp_registration_mark_page_completed';

  //============================================================================
  // Certificates
  static String get postGetMyCertificates =>
      '${mainAPI}local_otp_registration_get_user_certificates';

  //============================================================================
  // Blog
  static String get postGetBlogs => '${mainAPI}core_blog_get_entries';

  //============================================================================
  // Notifications
  static String get postGetNotifications =>
      '${mainAPI}local_otp_registration_get_user_notifications';
  static String get postReadNotifications =>
      '${mainAPI}local_otp_registration_mark_notifications_read';

  //============================================================================
  // Events
  static String get postGetEvents =>
      '${mainAPI}local_otp_registration_get_user_calendar_events';
  static String get postGetEventDetails =>
      '${mainAPI}local_otp_registration_get_event_details';
  static String get postEditEvent =>
      '${mainAPI}local_otp_registration_update_calendar_event';
  static String get postDeleteEvent =>
      '${mainAPI}local_otp_registration_delete_calendar_event';
  static String get postAddEvent =>
      '${mainAPI}local_otp_registration_add_calendar_event';

  //============================================================================
  // Meetings
  static String get postGetMeetings =>
      '${mainAPI}local_otp_registration_get_language_meetings';

  //============================================================================
  // Other
  static String get postGetBadges =>
      '${mainAPI}local_otp_registration_get_badges_list';

  static String get postGetLeaderboard =>
      '${mainAPI}local_otp_registration_get_leaderboard_list';

  static String get postGetActivityPoints =>
      '${mainAPI}local_otp_registration_get_points_guidelines';
  //============================================================================
  // Activity Points
  static String get postGetMyActivityPoints =>
      '${mainAPI}local_otp_registration_get_user_activities_points';

  //============================================================================
  // Quiz
  static String get postGetQuizDetails =>
      '${mainAPI}local_otp_registration_get_quiz_info';
  static String get postGetQuizStartAttempt =>
      '${mainAPI}local_otp_registration_start_or_get_quiz_attempt';
  static String get postQuizSubmitQuestionAnswer =>
      '${mainAPI}local_otp_registration_submit_quiz_question_answer';
  static String get postSubmitQuiz =>
      '${mainAPI}local_otp_registration_submit_quiz_attempt';
  static String get postGetQuizResult =>
      '${mainAPI}local_otp_registration_get_quiz_result';

  /// Core Moodle function, used to read the real `timestart` of the running
  /// attempt so a resumed attempt keeps its original deadline
  static String get postGetQuizUserAttempts =>
      '${mainAPI}mod_quiz_get_user_attempts';
}
