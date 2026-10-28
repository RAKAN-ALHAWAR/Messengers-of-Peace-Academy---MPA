import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../../Ui/Widget/widget.dart';

class DownloadFileFormUrl {
  /// Returns true only when the file was really saved on the device.
  /// Existing callers may ignore the result.
  ///
  /// [dio] and [getDirectory] exist so tests can run without a network and
  /// without the platform plugins, the app always uses the defaults.
  static Future<bool> download(
    String url,
    String fileName, {
    Dio? dio,
    Future<(Directory, bool)> Function()? getDirectory,
  }) async {
    try {
      // Validate download URL
      if (url.isEmpty || Uri.tryParse(url)?.isAbsolute != true) {
        ToastX.error(title: "Error", message: "Invalid download URL");
        return false;
      }

      // Show loading message
      ToastX.info(message: "Downloading file...");

      // Get download directory, it never needs a permission because the app
      // specific directory is always writable, the public Downloads folder is
      // only used when it happens to be writable as well
      final (Directory downloadDir, bool isPublicDownloads) =
          await (getDirectory ?? _getDownloadDirectory)();

      // Create filename: keep the letters (Arabic included), drop only what a
      // file name cannot contain. Long Arabic names are cut, a file name is
      // limited to 255 bytes and every Arabic letter takes two.
      fileName = fileName
          .replaceAll(' ', '_')
          .replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), '');
      if (fileName.runes.length > 80) {
        fileName = String.fromCharCodes(fileName.runes.take(80));
      }
      if (fileName.isEmpty) fileName = 'file';

      // The extension is only known from the response headers, so download to
      // a temporary name first and rename once we know what the file is
      final tempPath = '${downloadDir.path}/$fileName.part';
      final response = await (dio ?? Dio()).download(url, tempPath);

      // An HTML login page or a JSON error answers 200 as well, never save it
      if (!_isFile(response.headers)) {
        await File(tempPath).delete();
        ToastX.error(title: "Error", message: "Download failed".tr);
        return false;
      }

      final extension = _getExtension(response.headers, url);
      final filePath =
          extension.isEmpty
              ? '${downloadDir.path}/$fileName'
              : '${downloadDir.path}/$fileName.$extension';
      await File(tempPath).rename(filePath);

      // Show success message telling where the file actually landed
      String locationMessage =
          Platform.isIOS
              ? "File saved to Documents".tr
              : isPublicDownloads
              ? "File saved to Downloads".tr
              : "File saved to the app folder".tr;
      ToastX.success(
        title: "Success",
        message: "${"File downloaded successfully".tr}\n$locationMessage",
      );

      // حاول فتح الملف مباشرة، وإن تعذر شارك الملف
      // try to open the file directly, share it when that is not possible
      // The file is already saved, so a failure here never turns the result
      // into a failed download
      try {
        final result = await OpenFile.open(filePath);
        if (result.type != ResultType.done) {
          await SharePlus.instance.share(
            ShareParams(files: [XFile(filePath)], text: fileName),
          );
        }
      } catch (_) {
        try {
          await SharePlus.instance.share(
            ShareParams(files: [XFile(filePath)], text: fileName),
          );
        } catch (_) {}
      }
      return true;
    } catch (e) {
      String errorMessage = "Download failed".tr;

      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.receiveTimeout:
          case DioExceptionType.sendTimeout:
            errorMessage = "Network error".tr;
            break;
          case DioExceptionType.badResponse:
            errorMessage = "Invalid download URL".tr;
            break;
          default:
            errorMessage = "Download failed".tr;
        }
      }

      ToastX.error(title: "Error", message: errorMessage);
      return false;
    }
  }

  /// The file name Content-Disposition suggests, for example
  /// `attachment; filename="a.pdf"` or `filename*=UTF-8''%D8%AF.pdf`.
  /// Null when the header is missing.
  static String? _dispositionName(Headers headers) {
    final value = headers.value('content-disposition');
    if (value == null) return null;
    final match = RegExp(
      r'''filename\*?=(?:UTF-8'')?"?([^";]+)"?''',
      caseSensitive: false,
    ).firstMatch(value);
    return match?.group(1);
  }

  /// A response is a real file when the server says it is an attachment, or
  /// when it is not a web page or a JSON message (login page, Moodle error).
  static bool _isFile(Headers headers) {
    if (_dispositionName(headers) != null) return true;
    final type = (headers.value('content-type') ?? '').toLowerCase();
    return !(type.startsWith('text/html') ||
        type.startsWith('application/xhtml') ||
        type.startsWith('application/json'));
  }

  static const _typeExtensions = {
    'application/pdf': 'pdf',
    'image/png': 'png',
    'image/jpeg': 'jpg',
    'image/gif': 'gif',
    'image/webp': 'webp',
    'application/zip': 'zip',
    'application/msword': 'doc',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
        'docx',
    'application/vnd.ms-excel': 'xls',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet': 'xlsx',
    'application/vnd.ms-powerpoint': 'ppt',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation':
        'pptx',
    'text/plain': 'txt',
    'video/mp4': 'mp4',
    'audio/mpeg': 'mp3',
  };

  /// Extension from Content-Disposition, then Content-Type, then the url.
  /// Empty when none of them tells, we never guess an extension.
  static String _getExtension(Headers headers, String url) {
    final name = _dispositionName(headers);
    if (name != null) {
      final ext = _plainExtension(Uri.decodeFull(name));
      if (ext != null) return ext;
    }

    final type = (headers.value('content-type') ?? '').split(';').first;
    final byType = _typeExtensions[type.trim().toLowerCase()];
    if (byType != null) return byType;

    // A url ending in .php is the script that serves the file, not its type
    const scripts = {'php', 'asp', 'aspx', 'jsp'};
    final byUrl = _plainExtension(Uri.parse(url).path);
    return byUrl == null || scripts.contains(byUrl) ? '' : byUrl;
  }

  /// The extension of the last path segment, or null when it does not look
  /// like a file extension.
  static String? _plainExtension(String path) {
    final segment = path.split('/').last;
    if (!segment.contains('.')) return null;
    final extension = segment.split('.').last.toLowerCase();
    return RegExp(r'^[a-z0-9]{1,5}$').hasMatch(extension) ? extension : null;
  }

  /// Whether the legacy storage permission is actually granted.
  ///
  /// `WRITE_EXTERNAL_STORAGE` is declared with `maxSdkVersion=28`, and starting
  /// from Android 10 scoped storage makes it meaningless, so this only ever
  /// returns true on Android 9 and older. It is a best effort check, a denial
  /// must never block the download because the app specific directory needs no
  /// permission at all.
  static Future<bool> _hasLegacyStorageAccess() async {
    try {
      return (await Permission.storage.request()).isGranted;
    } catch (_) {
      return false;
    }
  }

  /// Returns the directory to download into, and whether it is the public
  /// Downloads folder (used only to tell the user where the file landed).
  static Future<(Directory, bool)> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      // The public Downloads folder is only usable on old Android versions,
      // verify with a real write instead of trusting the permission result
      if (await _hasLegacyStorageAccess()) {
        final publicDownloads = Directory('/storage/emulated/0/Download');
        if (await publicDownloads.exists() &&
            await _isWritable(publicDownloads)) {
          return (publicDownloads, true);
        }
      }

      // App specific external directory, writable on every Android version
      // without any permission
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) {
        await externalDir.create(recursive: true);
        return (externalDir, false);
      }
    }

    // iOS, and the Android fallback
    return (await getApplicationDocumentsDirectory(), false);
  }

  /// Probe the directory with a real file, permissions alone are not enough
  static Future<bool> _isWritable(Directory dir) async {
    try {
      final probe = File('${dir.path}/.write_probe');
      await probe.writeAsString('');
      await probe.delete();
      return true;
    } catch (_) {
      return false;
    }
  }
}
