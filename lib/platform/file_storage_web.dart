import 'dart:convert';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

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
      withData: true, // Important for web
    );

    if (result != null) {
      final file = result.files.single;
      return PlatformFileResult(name: file.name, path: null, bytes: file.bytes);
    }
    return null;
  }

  @override
  Future<String?> saveFile({
    required String fileName,
    required String content,
  }) async {
    final bytes = utf8.encode(content);
    return saveFileBytes(fileName: fileName, bytes: Uint8List.fromList(bytes));
  }

  @override
  Future<String?> saveFileBytes({
    required String fileName,
    required Uint8List bytes,
  }) async {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute("download", fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
    return "Download started";
  }

  @override
  Future<String> readFileAsString(PlatformFileResult file) async {
    if (file.bytes == null) {
      throw Exception('File bytes are null on web');
    }
    return utf8.decode(file.bytes!);
  }
}
