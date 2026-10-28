part of '../../data.dart';

// ~~~~~~~~~~~~~~~~~~~~~~~{{ Why this section }}~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
/// Data keys that are stored on the device
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

class LocalKeyX {
  static const String route = 'route';
  static const String userid = 'userid';
  static const String token = 'token';
  static const String language = 'language';
  static const String themeIsDark = 'themeIsDark';

  // TEMP(backend): local progress keys, see the TEMP(backend) notes where used.
  // Per user keys start with the user id so another account on the same device
  // never sees them.

  /// A file (resource) activity was downloaded by this user
  static String fileDone(String cmId) => '${LocalDataX.userid}:fileDone:$cmId';

  /// Seconds this user spent watching lessons
  static String get learnedSeconds => '${LocalDataX.userid}:learnedSeconds';

  /// Real length of a video in seconds. Content metadata, so it is not per
  /// user. Keyed by the video url because the player only knows the url.
  static String videoSeconds(String url) => 'videoSeconds:$url';
}
