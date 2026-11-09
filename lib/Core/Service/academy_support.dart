import 'package:url_launcher/url_launcher.dart';

Future<bool> openAcademySupport() async {
  try {
    return await launchUrl(
      Uri.https('mopacademy.org', '/mod/page/view.php', {'id': '80'}),
      mode: LaunchMode.externalApplication,
    );
  } catch (_) {
    return false;
  }
}
