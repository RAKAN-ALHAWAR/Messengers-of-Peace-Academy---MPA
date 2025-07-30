import 'package:get/get.dart';
import 'package:messengersofpeace/Data/Model/meeting.dart';
import 'package:url_launcher/url_launcher.dart';

class MeetingDetailsController extends GetxController {
  //============================================================================
  // Variables
  final MeetingX meeting = Get.arguments;

  //============================================================================
  // Functions

  /// Open the meeting url
  void onOpenMeetingUrl() {
    try {
      launchUrl(Uri.parse(meeting.url));
    } catch (_) {}
  }
}
