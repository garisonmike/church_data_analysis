import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'file_storage_interface.dart';

class FileStorageImpl implements FileStorage {
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
  Future<String?> saveFile({
    required String fileName,
    required String content,
  }) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${appDir.path}/exports');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }
      final file = File('${exportDir.path}/$fileName');
      await file.writeAsString(content);
      return file.path;
    } catch (e) {
      debugPrint('Error saving file: $e');
      return null;
    }
  }

  @override
  Future<String?> saveFileBytes({
    required String fileName,
    required Uint8List bytes,
  }) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final exportDir = Directory('${appDir.path}/exports');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }
      final file = File('${exportDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      return file.path;
    } catch (e) {
      debugPrint('Error saving file: $e');
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
}
