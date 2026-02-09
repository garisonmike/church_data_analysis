// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
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
  Future<String?> pickSaveLocation({
    required String suggestedName,
    required List<String> allowedExtensions,
  }) async {
    return suggestedName;
  }

  @override
  Future<String?> saveFile({
    required String fileName,
    required String content,
    String? fullPath,
  }) async {
    final bytes = utf8.encode(content);
    return saveFileBytes(
      fileName: fileName,
      bytes: Uint8List.fromList(bytes),
      fullPath: fullPath,
    );
  }

  @override
  Future<String?> saveFileBytes({
    required String fileName,
    required Uint8List bytes,
    String? fullPath,
  }) async {
    final rawName = fullPath ?? fileName;
    final normalized = rawName.replaceAll('\\', '/');
    final effectiveName = normalized.contains('/')
        ? normalized.split('/').last
        : normalized;
    final lower = fileName.toLowerCase();
    final String? mimeType = lower.endsWith('.png')
        ? 'image/png'
        : lower.endsWith('.pdf')
        ? 'application/pdf'
        : lower.endsWith('.csv')
        ? 'text/csv'
        : lower.endsWith('.json')
        ? 'application/json'
        : null;

    final blob = mimeType == null
        ? html.Blob([bytes])
        : html.Blob([bytes], mimeType);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute("download", effectiveName)
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

  @override
  Future<Uint8List> readFileAsBytes(PlatformFileResult file) async {
    throw UnsupportedError(
      'Binary file reads are not supported on web. '
      'Use readFileAsString or handle in-memory bytes instead.',
    );
  }
}
