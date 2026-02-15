import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'file_storage_interface.dart';

class FileStorageImpl implements FileStorage {
  Future<Directory> _getExportDirectory() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${appDir.path}/exports');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }
      return exportDir;
    } catch (e) {
      // Unit tests (and some desktop contexts) may not have path_provider
      // plugin channels registered. Fall back to a safe temp directory.
      final exportDir = Directory('${Directory.systemTemp.path}/exports');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
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
      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error picking save location: $e');
      }
      return null;
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
      await file.writeAsString(content);
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
      await file.writeAsBytes(bytes);
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
