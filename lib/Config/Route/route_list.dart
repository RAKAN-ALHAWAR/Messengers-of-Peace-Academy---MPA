import 'package:get/get.dart';
import '../../Ui/Screen/Auth/Login/controller/controller.dart';
import '../../Ui/Screen/Auth/Login/view/view.dart';
import '../../Ui/Screen/Auth/OTP/controller/controller.dart';
import '../../Ui/Screen/Auth/OTP/view/view.dart';
import '../../Ui/Screen/Blog/ArticleDetails/controller/controller.dart';
import '../../Ui/Screen/Blog/ArticleDetails/view/view.dart';
import '../../Ui/Screen/Blog/Blog/controller/controller.dart';
import '../../Ui/Screen/Blog/Blog/view/view.dart';
import '../../Ui/Screen/Course/AllCourses/controller/controller.dart';
import '../../Ui/Screen/Auth/CompleteAccountInfo/controller/controller.dart';
import '../../Ui/Screen/Auth/CompleteAccountInfo/view/view.dart';
import '../../Ui/Screen/Auth/ForgotPassword/controller/controller.dart';
import '../../Ui/Screen/Auth/ForgotPassword/view/view.dart';
import '../../Ui/Screen/Auth/ForgotPasswordReset/controller/controller.dart';
import '../../Ui/Screen/Auth/ForgotPasswordReset/view/view.dart';
import '../../Ui/Screen/Auth/SignUp/controller/controller.dart';
import '../../Ui/Screen/Auth/SignUp/view/view.dart';
import '../../Ui/Screen/Events/AddEvent/controller/controller.dart';
import '../../Ui/Screen/Events/AddEvent/view/view.dart';
import '../../Ui/Screen/Events/CalendarEvents/controller/controller.dart';
import '../../Ui/Screen/Course/CourseDetails/controller/controller.dart';
import '../../Ui/Screen/Course/CourseDetails/view/view.dart';
import '../../Ui/Screen/Course/VideoPlayer /controller/controller.dart';
import '../../Ui/Screen/Course/VideoPlayer /view/view.dart';
import '../../Ui/Screen/Events/EditEvent/controller/controller.dart';
import '../../Ui/Screen/Events/EditEvent/view/view.dart';
import '../../Ui/Screen/Events/EventDetails/controller/controller.dart';
import '../../Ui/Screen/Events/EventDetails/view/view.dart';
import '../../Ui/Screen/Home/controller/controller.dart';
import '../../Ui/Screen/Leaderboard/controller/controller.dart';
import '../../Ui/Screen/Leaderboard/view/view.dart';
import '../../Ui/Screen/Loading/controller/controller.dart';
import '../../Ui/Screen/Loading/view/view.dart';
import '../../Ui/Screen/Meeting/AllMeetings/controller/controller.dart';
import '../../Ui/Screen/Meeting/AllMeetings/view/view.dart';
import '../../Ui/Screen/Meeting/MeetingDetails/controller/controller.dart';
import '../../Ui/Screen/Meeting/MeetingDetails/view/view.dart';
import '../../Ui/Screen/My/MyAchievements/controller/controller.dart';
import '../../Ui/Screen/My/MyAchievements/view/view.dart';
import '../../Ui/Screen/My/MyCertificates/controller/controller.dart';
import '../../Ui/Screen/My/MyCertificates/view/view.dart';
import '../../Ui/Screen/My/MyCourses/controller/controller.dart';
import '../../Ui/Screen/My/MyCourses/view/view.dart';
import '../../Ui/Screen/Badges/view/view.dart';
import '../../Ui/Screen/Badges/controller/controller.dart';
import '../../Ui/Screen/ActivityPionts/view/view.dart';
import '../../Ui/Screen/ActivityPionts/controller/controller.dart';
import '../../Ui/Screen/Notifications/controller/controller.dart';
import '../../Ui/Screen/Notifications/view/view.dart';
import '../../Ui/Screen/Profile/ChangePassword/controller/controller.dart';
import '../../Ui/Screen/Profile/ChangePassword/view/view.dart';
import '../../Ui/Screen/Profile/EditProfile/controller/controller.dart';
import '../../Ui/Screen/Profile/EditProfile/view/view.dart';
import '../../Ui/Screen/Profile/ProfileDetails/controller/controller.dart';
import '../../Ui/Screen/Root/controller/controller.dart';
import '../../Ui/Screen/Root/view/view.dart';
import '../../Ui/Screen/Test/TestInfo/controller/controller.dart';
import '../../Ui/Screen/Test/TestInfo/view/view.dart';
import '../../Ui/Screen/Test/TestQuestions/controller/controller.dart';
import '../../Ui/Screen/Test/TestQuestions/view/view.dart';
import '../../Ui/Screen/Test/TestResults/controller/controller.dart';
import '../../Ui/Screen/Test/TestResults/view/view.dart';
import '../config.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this section }}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// Link pages to their controller via the page name
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class RouteListX {
  /// List Routes
  static final List<GetPage<dynamic>> routes = [
    /// Root
    GetPage(
      name: RouteNameX.root,
      page: () => const RootView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => RootController(), fenix: true);
        Get.lazyPut(() => HomeController());
        Get.lazyPut(() => AllCoursesController());
        Get.lazyPut(() => CalendarController());
        Get.lazyPut(() => ProfileDetailsController());
      }),
    ),
    //========================================================
    /// Loading
    GetPage(
      name: RouteNameX.loading,
      page: () => const LoadingView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => LoadingController());
      }),
    ),
    //========================================================
    ///Auth
    GetPage(
      name: RouteNameX.signUp,
      page: () => const SignUpView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => SignUpController());
      }),
    ),
    GetPage(
      name: RouteNameX.login,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => LoginController());
      }),
    ),
    GetPage(
      name: RouteNameX.forgotPassword,
      page: () => const ForgotPasswordView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ForgotPasswordController());
      }),
    ),
    GetPage(
      name: RouteNameX.forgotPasswordReset,
      page: () => const ForgotPasswordResetView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ForgotPasswordResetController());
      }),
    ),
    GetPage(
      name: RouteNameX.otp,
      page: () => const OTPView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => OTPController());
      }),
    ),
    GetPage(
      name: RouteNameX.completeAccountInfo,
      page: () => const CompleteAccountInfoView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => CompleteAccountInfoController());
      }),
    ),
    //========================================================
    /// Profile
    GetPage(
      name: RouteNameX.editProfile,
      page: () => const EditProfileView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => EditProfileController());
      }),
    ),
    GetPage(
      name: RouteNameX.changePassword,
      page: () => const ChangePasswordView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ChangePasswordController());
      }),
    ),
    //========================================================
    /// Notifications
    GetPage(
      name: RouteNameX.notifications,
      page: () => const NotificationsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => NotificationsController());
      }),
    ),
    //========================================================
    /// Meeting
    GetPage(
      name: RouteNameX.allMeetings,
      page: () => const AllMeetingsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AllMeetingsController());
      }),
    ),
    GetPage(
      name: RouteNameX.meetingDetails,
      page: () => const MeetingDetailsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MeetingDetailsController());
      }),
    ),
    //========================================================
    /// Course
    GetPage(
      name: RouteNameX.courseDetails,
      page: () => const CourseDetailsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => CourseDetailsController());
      }),
    ),
    GetPage(
      name: RouteNameX.videoPlayer,
      page: () => const VideoPlayerView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => VideoPlayerController());
      }),
    ),

    //========================================================
    /// Test
    GetPage(
      name: RouteNameX.testInfo,
      page: () => const TestInfoView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => TestInfoController());
      }),
    ),
    GetPage(
      name: RouteNameX.testQuestions,
      page: () => const TestQuestionsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => TestQuestionsController());
      }),
    ),
    GetPage(
      name: RouteNameX.testResults,
      page: () => const TestResultsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => TestResultsController());
      }),
    ),
    //========================================================
    /// Event
    GetPage(
      name: RouteNameX.eventDetails,
      page: () => const EventDetailsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => EventDetailsController());
      }),
    ),
    GetPage(
      name: RouteNameX.addEvent,
      page: () => const AddEventView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => AddEventController());
      }),
    ),
    GetPage(
      name: RouteNameX.editEvent,
      page: () => const EditEventView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => EditEventController());
      }),
    ),
    //========================================================
    /// Blog
    GetPage(
      name: RouteNameX.blog,
      page: () => const BlogView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => BlogController());
      }),
    ),
    GetPage(
      name: RouteNameX.articleDetails,
      page: () => const ArticleDetailsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ArticleDetailsController());
      }),
    ),
    //========================================================
    /// My
    GetPage(
      name: RouteNameX.myCourses,
      page: () => const MyCoursesView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MyCoursesController());
      }),
    ),
    GetPage(
      name: RouteNameX.myCertificates,
      page: () => const MyCertificatesView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MyCertificatesController());
      }),
    ),
    GetPage(
      name: RouteNameX.myAchievements,
      page: () => const MyAchievementsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => MyAchievementsController());
      }),
    ),
    GetPage(
      name: RouteNameX.badges,
      page: () => const BadgesView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => BadgesController());
      }),
    ),
    //========================================================
    /// Activity Points
    GetPage(
      name: RouteNameX.activityPoints,
      page: () => const ActivityPiontsView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => ActivityPiontsController());
      }),
    ),
    //========================================================
    /// Leaderboard
    GetPage(
      name: RouteNameX.leaderboard,
      page: () => const LeaderboardView(),
      binding: BindingsBuilder(() {
        Get.lazyPut(() => LeaderboardController());
      }),
    ),
    //========================================================
    /// Template
    // GetPage(
    //    name: RouteNameX.,
    //    page: () => const View(),
    //    binding: BindingsBuilder(() {
    //      Get.lazyPut(
    //              () => Controller());
    //    })),
  ];
}
