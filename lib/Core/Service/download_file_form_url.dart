import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

import '../../Ui/Widget/widget.dart';

class DownloadFileFormUrl {
  static download(String url, String fileName) async {
    try {
      // Validate download URL
      if (url.isEmpty || !Uri.tryParse(url)!.isAbsolute) {
        ToastX.error(title: "Error", message: "Invalid download URL");
        return;
      }

      // Show loading message
      ToastX.info(message: "Downloading file...");

      // Get download directory, it never needs a permission because the app
      // specific directory is always writable, the public Downloads folder is
      // only used when it happens to be writable as well
      final (Directory downloadDir, bool isPublicDownloads) =
          await _getDownloadDirectory();

      // Get extension from url
      String extension = _getExtensionFromUrl(url);

      // Create filename
      fileName = fileName
          .replaceAll(' ', '_')
          .replaceAll(RegExp(r'[^\w\s-.]'), '');
      String filePath = '${downloadDir.path}/$fileName.$extension';

      // Download file
      Dio dio = Dio();
      await dio.download(url, filePath);

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
      try {
        final result = await OpenFile.open(filePath);
        if (result.type != ResultType.done) {
          await SharePlus.instance.share(
            ShareParams(files: [XFile(filePath)], text: fileName),
          );
        }
      } catch (_) {
        await SharePlus.instance.share(
          ShareParams(files: [XFile(filePath)], text: fileName),
        );
      }
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
    }
  }

  static String _getExtensionFromUrl(String url) {
    final uri = Uri.parse(url);
    final path = uri.path;
    final extension = path.split('.').last;
    if (extension.length <= 5 && !extension.contains('/')) {
      return extension;
    }
    return 'png'; // fallback
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
