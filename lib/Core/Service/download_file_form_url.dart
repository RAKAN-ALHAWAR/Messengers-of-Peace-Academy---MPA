import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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

      // Request storage permission
      bool hasPermission = await _requestStoragePermission();
      if (!hasPermission) {
        ToastX.error(
          title: "Storage permission required",
          message: "Please grant storage permission to download",
        );
        return;
      }

      // Get download directory
      Directory? downloadDir = await _getDownloadDirectory();
      if (downloadDir == null) {
        ToastX.error(title: "Error", message: "Download failed");
        return;
      }

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

      // Show success message
      String locationMessage =
          Platform.isIOS
              ? "File saved to Documents".tr
              : "File saved to Downloads".tr;
      ToastX.success(
        title: "Success",
        message: "${"File downloaded successfully".tr}\n$locationMessage",
      );
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

  static Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+), we need different permissions
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      // Request storage permission
      var status = await Permission.storage.request();
      if (status.isGranted) {
        return true;
      }

      // For Android 11+ (API 30+), try manage external storage
      if (await Permission.manageExternalStorage.request().isGranted) {
        return true;
      }

      return false;
    } else if (Platform.isIOS) {
      // iOS doesn't require explicit permission for app documents directory
      return true;
    }
    return false;
  }

  static Future<Directory?> _getDownloadDirectory() async {
    try {
      if (Platform.isAndroid) {
        // Try to get the Downloads directory
        Directory? downloadsDir = Directory('/storage/emulated/0/Download');
        if (await downloadsDir.exists()) {
          return downloadsDir;
        }

        // Fallback to external storage directory
        Directory? externalDir = await getExternalStorageDirectory();
        if (externalDir != null) {
          return Directory('${externalDir.path}/Download');
        }

        // Final fallback to app documents directory
        return await getApplicationDocumentsDirectory();
      } else if (Platform.isIOS) {
        // For iOS, use the app documents directory
        return await getApplicationDocumentsDirectory();
      }
    } catch (_) {}
    return null;
  }
}
