import 'dart:async';
import 'dart:io';
import 'dart:ui' show PlatformDispatcher, Rect, Size;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show debugPrint;
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
  /// [onProgress] gets the bytes received and the total size, the total is
  /// -1 (or 0) when the server did not say how big the file is.
  ///
  /// [dio] and [getDirectory] exist so tests can run without a network and
  /// without the platform plugins, the app always uses the defaults.
  static Future<bool> download(
    String url,
    String fileName, {
    Dio? dio,
    Future<(Directory, bool)> Function()? getDirectory,
    void Function(int received, int total)? onProgress,
  }) async {
    String? tempPath;
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

      fileName = _safeName(fileName);

      // The extension is only known from the response headers, so download to
      // a temporary name first and rename once we know what the file is
      final partPath = tempPath = '${downloadDir.path}/$fileName.part';
      final response = await (dio ?? _newDio()).download(
        url,
        partPath,
        onReceiveProgress: onProgress,
      );

      // An HTML login page or a JSON error answers 200 as well, never save it
      if (!_isFile(response.headers)) {
        await File(partPath).delete();
        ToastX.error(title: "Error", message: "Download failed".tr);
        return false;
      }

      final extension = _getExtension(response.headers, url);
      final filePath =
          extension.isEmpty
              ? '${downloadDir.path}/$fileName'
              : '${downloadDir.path}/$fileName.$extension';
      await File(partPath).rename(filePath);

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

      // The file is saved, the caller shows it as done at once. Opening it (or
      // the share sheet) can stay on screen for as long as the user likes, so
      // it never holds the result back.
      unawaited(_openOrShare(filePath));
      return true;
    } catch (e) {
      await _deleteQuietly(tempPath);
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

  /// A file name the file system accepts: keep the letters (Arabic included),
  /// drop only what a file name cannot contain. Dots become underscores, so
  /// the only dot in a saved file is the one before its extension. Long Arabic
  /// names are cut, a file name is limited to 255 bytes and every Arabic letter
  /// takes two. The caller puts what identifies the file (the activity cmId)
  /// first, so the cut never removes it.
  static String _safeName(String fileName) {
    var name = fileName
        .replaceAll(' ', '_')
        .replaceAll('.', '_')
        .replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), '');
    if (name.runes.length > 80) {
      name = String.fromCharCodes(name.runes.take(80));
    }
    return name.isEmpty ? 'file' : name;
  }

  /// The saved copy of [fileName] (any extension), null when there is none.
  /// A half written `.part` file is never a saved copy, and only the exact
  /// name matches: `name` or `name.<extension>`.
  static Future<String?> findSaved(
    String fileName, {
    Future<(Directory, bool)> Function()? getDirectory,
  }) async {
    try {
      final (Directory dir, _) = await (getDirectory ?? _getDownloadDirectory)();
      final name = _safeName(fileName);
      await for (final entity in dir.list(followLinks: false)) {
        if (entity is! File) continue;
        final base = entity.uri.pathSegments.last;
        if (base.endsWith('.part')) continue;
        // A saved name has no dot of its own, so what follows the name must
        // be one extension and nothing else
        if (base == name ||
            (base.startsWith('$name.') &&
                !base.substring(name.length + 1).contains('.'))) {
          return entity.path;
        }
      }
    } catch (_) {
      // No readable folder means no saved copy, the caller downloads again
    }
    return null;
  }

  /// Opens the saved copy of [fileName] again (share sheet when no app can
  /// open it). False when the copy is gone, so the caller downloads it again.
  /// Returns as soon as the file is handed over, never waits for the viewer.
  static Future<bool> openSaved(
    String fileName, {
    Future<(Directory, bool)> Function()? getDirectory,
  }) async {
    final path = await findSaved(fileName, getDirectory: getDirectory);
    if (path == null) return false;
    unawaited(_openOrShare(path));
    return true;
  }

  /// Shows the saved file: opened directly on Android, through the share
  /// sheet on iOS. The file is already saved, so a failure here only ends
  /// this attempt, it never turns the download into a failed one.
  ///
  /// iOS must not use `OpenFile.open`: open_file_ios finds its view controller
  /// through `UIApplication.delegate.window`, which is nil in an app that uses
  /// UIScene (this one), so the preview never appears and the call never
  /// returns (seen on the iOS simulator). The share sheet works there and
  /// offers Save to Files and Open in.
  ///
  /// حاول فتح الملف مباشرة، وإن تعذر شارك الملف
  static Future<void> _openOrShare(String filePath) async {
    if (!Platform.isIOS) {
      try {
        final result = await OpenFile.open(filePath);
        if (result.type == ResultType.done) return;
      } catch (_) {
        // No app opens it: the share sheet below is the way to show the file
      }
    }
    try {
      final view = PlatformDispatcher.instance.implicitView;
      final size =
          view == null ? const Size(1, 1) : view.physicalSize / view.devicePixelRatio;
      await SharePlus.instance.share(shareParamsFor(filePath, size));
    } catch (e) {
      // Nothing more to try, the file stays saved where the toast said
      debugPrint('Sharing the saved file failed: $e');
    }
  }

  /// The share sheet request for [filePath]. The iPad shows the sheet as a
  /// popover and refuses it without an anchor rect, so the rect is a small one
  /// in the center of the screen ([screen] in logical pixels). The phones
  /// ignore it.
  static ShareParams shareParamsFor(String filePath, Size screen) {
    final center = Rect.fromLTWH(screen.width / 2, screen.height / 2, 0, 0);
    return ShareParams(
      files: [XFile(filePath)],
      sharePositionOrigin: center.inflate(5),
    );
  }

  /// A Dio whose transfer cannot hang for ever: the server of the course
  /// files is slow (tens of seconds for a few MB) but never silent that long.
  static Dio _newDio() => Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
    ),
  );

  /// Removes the half written file after a failure, best effort cleanup: the
  /// failure itself is already reported to the user.
  static Future<void> _deleteQuietly(String? path) async {
    if (path == null) return;
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {}
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
      final ext = _plainExtension(_percentDecoded(name));
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

  /// Decodes `%XX` escapes when the name has valid ones. Dart reads header
  /// bytes as Latin-1, so a raw UTF-8 Arabic name arrives as non-ASCII
  /// mojibake and `Uri.decodeFull` throws on it, the name is used as it is then.
  static String _percentDecoded(String name) {
    try {
      return Uri.decodeFull(name);
    } on ArgumentError {
      return name;
    }
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
