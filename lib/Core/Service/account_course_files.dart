import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

import 'download_file_form_url.dart';

/// New private course files are separated by account so only the deleted
/// account's files are purged. Legacy shared exports have no reliable owner.
class AccountCourseFilesX {
  static final _active = <String, Map<CancelToken, Future<bool>>>{};

  static Future<Directory> _directory(String accountId) async {
    if (accountId.isEmpty) throw ArgumentError('Missing download owner');
    final root = await getApplicationSupportDirectory();
    final folder = base64Url.encode(utf8.encode(accountId));
    return Directory('${root.path}/course-downloads/$folder');
  }

  static Future<(Directory, bool)> _downloadDirectory(String accountId) async {
    final directory = await _directory(accountId);
    await directory.create(recursive: true);
    return (directory, false);
  }

  static Future<bool> download(
    String accountId,
    String url,
    String fileName, {
    void Function(int received, int total)? onProgress,
  }) async {
    final cancel = CancelToken();
    final task = DownloadFileFormUrl.download(
      url,
      fileName,
      onProgress: onProgress,
      getDirectory: () => _downloadDirectory(accountId),
      cancelToken: cancel,
    );
    final active = _active.putIfAbsent(accountId, () => {});
    active[cancel] = task;
    try {
      return await task;
    } finally {
      active.remove(cancel);
      if (active.isEmpty) _active.remove(accountId);
    }
  }

  static Future<bool> open(String accountId, String fileName) async {
    if (await DownloadFileFormUrl.openSaved(
      fileName,
      getDirectory: () async => (await _directory(accountId), false),
    )) {
      return true;
    }
    return DownloadFileFormUrl.openSaved(fileName);
  }

  static Future<void> purge(String accountId) async {
    final active = _active[accountId];
    if (active != null) {
      final pending = active.values.toList();
      for (final cancel in active.keys.toList()) {
        cancel.cancel();
      }
      await Future.wait(pending);
    }
    final directory = await _directory(accountId);
    if (await FileSystemEntity.type(directory.path, followLinks: false) ==
        FileSystemEntityType.directory) {
      await directory.delete(recursive: true);
    }
  }
}
