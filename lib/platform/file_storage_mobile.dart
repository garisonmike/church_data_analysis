import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'file_storage_interface.dart';

class FileStorageImpl implements FileStorage {
  File _sanitizeFileName(File file) {
    final normalized = file.path.replaceAll('\\', '/');
    final safeName = normalized.contains('/')
        ? normalized.split('/').last
        : normalized;
    return File('${file.parent.path}/$safeName');
  }

  Future<File> _ensureUniqueFile(File file) async {
    if (!await file.exists()) return file;

    final originalPath = file.path;
    final dotIndex = originalPath.lastIndexOf('.');
    final base = dotIndex == -1
        ? originalPath
        : originalPath.substring(0, dotIndex);
    final ext = dotIndex == -1 ? '' : originalPath.substring(dotIndex);

    var counter = 1;
    while (true) {
      final candidate = File('${base}_$counter$ext');
      if (!await candidate.exists()) return candidate;
      counter++;
    }
  }

  Future<Directory> _getExportDirectory() async {
    try {
      Directory baseDir;
      if (Platform.isAndroid) {
        final downloadDirs = await getExternalStorageDirectories(
          type: StorageDirectory.downloads,
        );
        baseDir = (downloadDirs != null && downloadDirs.isNotEmpty)
            ? downloadDirs.first
            : await getApplicationDocumentsDirectory();
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        baseDir = await getDownloadsDirectory() ??
            await getApplicationDocumentsDirectory();
      } else {
        baseDir = await getApplicationDocumentsDirectory();
      }

      final exportDir = Directory('${baseDir.path}/ChurchAnalytics');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }
      if (kDebugMode) {
        debugPrint('Export directory: ${exportDir.path}');
      }
      return exportDir;
    } catch (e) {
      // Unit tests (and some desktop contexts) may not have path_provider
      // plugin channels registered. Fall back to a safe temp directory.
      final exportDir = Directory('${Directory.systemTemp.path}/exports');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }
      if (kDebugMode) {
        debugPrint('Export directory fallback: ${exportDir.path}');
      }
      return exportDir;
    }
  }

  @override
  Future<PlatformFileResult?> pickFile({
    required List<String> allowedExtensions,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      return PlatformFileResult(
        name: result.files.single.name,
        path: result.files.single.path,
        bytes:
            null, // bytes usually null on mobile unless withReadStream or withData is used
      );
    }
    return null;
  }

  @override
  Future<String?> pickSaveLocation({
    required String suggestedName,
    required List<String> allowedExtensions,
  }) async {
    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Select export location',
        fileName: suggestedName,
        allowedExtensions: allowedExtensions,
        type: FileType.custom,
      );
      if (result == null || result.trim().isEmpty) {
        if (kDebugMode) {
          debugPrint('Save location dialog cancelled');
        }
        return null;
      }
      if (kDebugMode) {
        debugPrint('Selected save location: $result');
      }
      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error picking save location: $e');
      }
      rethrow;
    }
  }

  @override
  Future<String?> saveFile({
    required String fileName,
    required String content,
    String? fullPath,
  }) async {
    try {
      final safeName = fileName.replaceAll('\\', '/');
      final file = fullPath != null
          ? File(fullPath)
          : File('${(await _getExportDirectory()).path}/$safeName');
      final sanitized = _sanitizeFileName(file);
      await sanitized.parent.create(recursive: true);
      final target = await _ensureUniqueFile(sanitized);
      await target.writeAsString(content);
      if (kDebugMode) {
        debugPrint('File saved to: ${target.path}');
      }
      return target.path;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving file: $e');
      }
      return null;
    }
  }

  @override
  Future<String?> saveFileBytes({
    required String fileName,
    required Uint8List bytes,
    String? fullPath,
  }) async {
    try {
      final safeName = fileName.replaceAll('\\', '/');
      final file = fullPath != null
          ? File(fullPath)
          : File('${(await _getExportDirectory()).path}/$safeName');
      final sanitized = _sanitizeFileName(file);
      await sanitized.parent.create(recursive: true);
      final target = await _ensureUniqueFile(sanitized);
      await target.writeAsBytes(bytes);
      if (kDebugMode) {
        debugPrint('File saved to: ${target.path}');
      }
      return target.path;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving file: $e');
      }
      return null;
    }
  }

  @override
  Future<String> readFileAsString(PlatformFileResult file) async {
    if (file.path == null) {
      throw Exception('File path is null on mobile');
    }
    return File(file.path!).readAsString();
  }

  @override
  Future<Uint8List> readFileAsBytes(PlatformFileResult file) async {
    if (file.path == null) {
      throw Exception('File path is null on mobile');
    }
    return File(file.path!).readAsBytes();
  }
}
