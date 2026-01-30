import 'dart:typed_data';

/// Result wrapper for platform-agnostic file handling
class PlatformFileResult {
  final String name;
  final String? path;
  final Uint8List? bytes;

  PlatformFileResult({required this.name, this.path, this.bytes});
}

/// Interface for platform-specific file operations
abstract class FileStorage {
  /// Pick a file with allowed extensions
  Future<PlatformFileResult?> pickFile({
    required List<String> allowedExtensions,
  });

  /// Save content to a file (Download on Web, Save to Documents on Mobile)
  Future<String?> saveFile({required String fileName, required String content});

  /// Save binary content to a file
  Future<String?> saveFileBytes({
    required String fileName,
    required Uint8List bytes,
  });

  /// Read content from a picked file
  Future<String> readFileAsString(PlatformFileResult file);
}
