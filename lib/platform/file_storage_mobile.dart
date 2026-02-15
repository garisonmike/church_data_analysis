import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'file_storage_interface.dart';

class FileStorageImpl implements FileStorage {
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
      final file = fullPath != null
          ? File(fullPath)
          : File('${(await _getExportDirectory()).path}/$fileName');
      await file.parent.create(recursive: true);
      await file.writeAsString(content);
      if (kDebugMode) {
        debugPrint('File saved to: ${file.path}');
      }
      return file.path;
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
      final file = fullPath != null
          ? File(fullPath)
          : File('${(await _getExportDirectory()).path}/$fileName');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes);
      if (kDebugMode) {
        debugPrint('File saved to: ${file.path}');
      }
      return file.path;
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
