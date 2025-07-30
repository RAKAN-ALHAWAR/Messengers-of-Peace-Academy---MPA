/// Contains links to database connection points
class DBEndPointX {
  //============================================================================
  // Main API links

  static final String mainAPI =
      'https://mopacademy.org/webservice/rest/server.php?wstoken=64e4b5e059e2cf7a3ae6f20eb42f783d&moodlewsrestformat=json&wsfunction=';
  //============================================================================
  // Auth

  static final String postSignUp =
      '${mainAPI}local_otp_registration_create_user';
  static final String postLogin = '${mainAPI}local_otp_registration_login_user';
  static final String postLoginByGoogle =
      '${mainAPI}local_otp_registration_login_with_google_token';
  static final String postLogout =
      '${mainAPI}local_otp_registration_logout_user';

  //============================================================================
  // Forget Password
  static final String postForgetPassword =
      '${mainAPI}local_otp_registration_send_otp_for_password_reset';

  static final String postResetForgetPassword =
      '${mainAPI}local_otp_registration_reset_password_with_otp';

  //============================================================================
  // OTP
  static final String postVerifyOtpSignUp =
      '${mainAPI}local_otp_registration_verify_user';
  static final String postResendOtpSignUp =
      '${mainAPI}local_otp_registration_resend_otp';
  static final String postVerifyOtpForgetPassword =
      '${mainAPI}local_otp_registration_verify_otp_for_password_reset';

  //============================================================================
  // Get User
  static final String postGetUser =
      '${mainAPI}local_otp_registration_get_user_full_profile';

  static final String postUpdateUser =
      '${mainAPI}local_otp_registration_update_user_profile';

  static final String postUpdateUserImage =
      '${mainAPI}local_otp_registration_update_user_profile_picture';

  static final String postGetUserStatistics =
      '${mainAPI}local_otp_registration_get_user_statistics';

  //============================================================================
  // Info
  static final String postCountriesList =
      '${mainAPI}local_otp_registration_get_country_list';
  static final String postPhoneCodeCountriesList =
      '${mainAPI}local_otp_registration_get_country_calling_codes';
  static final String postNativeLanguages =
      '${mainAPI}local_otp_registration_get_all_supported_languages';

  //============================================================================
  // Complaint or Suggestion
  static final String postSubmitComplaintOrSuggestion =
      '${mainAPI}local_otp_registration_send_complaint';

  //============================================================================
  // Change Password
  static final String postUpdatePassword =
      '${mainAPI}local_otp_registration_update_user_password';

  //============================================================================
  // Courses
  static final String postGetLevelsWithCourses =
      '${mainAPI}local_otp_registration_get_user_categories_summary';

  static final String postMyCourses =
      '${mainAPI}local_otp_registration_get_user_courses';

  static final String postGetCourse =
      '${mainAPI}local_otp_registration_get_course_details';

  static final String postGetCurrentLevel =
      '${mainAPI}local_otp_registration_get_user_current_level_courses';

  static final String postCompleteVideoOfCourse =
      '${mainAPI}local_otp_registration_mark_page_completed';

  //============================================================================
  // Certificates
  static final String postGetMyCertificates =
      '${mainAPI}local_otp_registration_get_user_certificates';

  //============================================================================
  // Blog
  static final String postGetBlogs = '${mainAPI}core_blog_get_entries';

  //============================================================================
  // Notifications
  static final String postGetNotifications =
      '${mainAPI}local_otp_registration_get_user_notifications';
  static final String postReadNotifications =
      '${mainAPI}local_otp_registration_mark_notifications_read';

  //============================================================================
  // Events
  static final String postGetEvents =
      '${mainAPI}local_otp_registration_get_user_calendar_events';
  static final String postGetEventDetails =
      '${mainAPI}local_otp_registration_get_event_details';
  static final String postEditEvent =
      '${mainAPI}local_otp_registration_update_calendar_event';
  static final String postDeleteEvent =
      '${mainAPI}local_otp_registration_delete_calendar_event';
  static final String postAddEvent =
      '${mainAPI}local_otp_registration_add_calendar_event';

  //============================================================================
  // Meetings
  static final String postGetMeetings =
      '${mainAPI}local_otp_registration_get_language_meetings';

  //============================================================================
  // Other
  static final String postGetBadges =
      '${mainAPI}local_otp_registration_get_badges_list';

  static final String postGetLeaderboard =
      '${mainAPI}local_otp_registration_get_leaderboard_list';

  static final String postGetActivityPoints =
      '${mainAPI}local_otp_registration_get_points_guidelines';
  //============================================================================
  // Activity Points
  static final String postGetMyActivityPoints =
      '${mainAPI}local_otp_registration_get_user_activities_points';

  //============================================================================
  // Quiz
  static final String postGetQuizDetails =
      '${mainAPI}local_otp_registration_get_quiz_info';
  static final String postGetQuizStartAttempt =
      '${mainAPI}local_otp_registration_start_or_get_quiz_attempt';
  static final String postQuizSubmitQuestionAnswer =
      '${mainAPI}local_otp_registration_submit_quiz_question_answer';
  static final String postSubmitQuiz =
      '${mainAPI}local_otp_registration_submit_quiz_attempt';
  static final String postGetQuizResult =
      '${mainAPI}local_otp_registration_get_quiz_result';
}
