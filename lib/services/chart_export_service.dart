import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class ChartExportService {
  /// Captures a widget rendered with RepaintBoundary and returns as image bytes
  ///
  /// Returns null if capture fails
  static Future<Uint8List?> captureWidget(GlobalKey key) async {
    try {
      // Get the RenderRepaintBoundary from the key
      final RenderRepaintBoundary? boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        debugPrint('Error: Could not find RenderRepaintBoundary');
        return null;
      }

      // Capture the image at a higher resolution for better quality
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      // Convert to byte data in PNG format
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        debugPrint('Error: Could not convert image to byte data');
        return null;
      }

      return byteData.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing widget: $e');
      return null;
    }
  }

  /// Saves image bytes as a PNG file to the device's downloads directory
  ///
  /// Returns the file path if successful, null otherwise
  static Future<String?> saveAsPng({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    try {
      // Get the appropriate directory for saving files
      Directory? directory;

      if (Platform.isAndroid) {
        // On Android, try to get the Downloads directory
        directory = await getExternalStorageDirectory();
        if (directory != null) {
          // Navigate to Downloads folder: /storage/emulated/0/Download
          final downloadPath = directory.path.split('Android')[0];
          directory = Directory('${downloadPath}Download');

          // Create directory if it doesn't exist
          if (!await directory.exists()) {
            directory = await getApplicationDocumentsDirectory();
          }
        }
      } else if (Platform.isIOS) {
        // On iOS, use the documents directory
        directory = await getApplicationDocumentsDirectory();
      } else {
        // On desktop or other platforms
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        debugPrint('Error: Could not get storage directory');
        return null;
      }

      // Ensure the file name ends with .png
      final fullFileName = fileName.endsWith('.png')
          ? fileName
          : '$fileName.png';

      // Create the full file path
      final filePath = '${directory.path}/$fullFileName';
      final file = File(filePath);

      // Write the bytes to the file
      await file.writeAsBytes(imageBytes);

      debugPrint('Chart saved successfully: $filePath');
      return filePath;
    } catch (e) {
      debugPrint('Error saving PNG: $e');
      return null;
    }
  }

  /// Generates a standardized file name for exported charts
  ///
  /// Format: {churchName}_{chartType}_{timestamp}.png
  /// Example: holy_trinity_attendance_20260129_143052.png
  static String generateFileName({
    required String churchName,
    required String chartType,
  }) {
    // Clean the church name (remove spaces, special chars, convert to lowercase)
    final cleanChurchName = churchName
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();

    // Clean the chart type
    final cleanChartType = chartType
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .trim();

    // Generate timestamp
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());

    return '${cleanChurchName}_${cleanChartType}_$timestamp';
  }

  /// Complete export workflow: capture, generate filename, and save
  ///
  /// Returns the saved file path if successful, null otherwise
  static Future<String?> exportChart({
    required GlobalKey repaintBoundaryKey,
    required String churchName,
    required String chartType,
  }) async {
    try {
      // Step 1: Capture the widget
      final imageBytes = await captureWidget(repaintBoundaryKey);
      if (imageBytes == null) {
        return null;
      }

      // Step 2: Generate file name
      final fileName = generateFileName(
        churchName: churchName,
        chartType: chartType,
      );

      // Step 3: Save as PNG
      final filePath = await saveAsPng(
        imageBytes: imageBytes,
        fileName: fileName,
      );

      return filePath;
    } catch (e) {
      debugPrint('Error in export workflow: $e');
      return null;
    }
  }

  /// Verifies that an exported file exists and is readable
  ///
  /// Returns true if the file can be opened, false otherwise
  static Future<bool> verifyExport(String filePath) async {
    try {
      final file = File(filePath);

      // Check if file exists
      if (!await file.exists()) {
        debugPrint('Export verification failed: File does not exist');
        return false;
      }

      // Check if file is readable
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        debugPrint('Export verification failed: File is empty');
        return false;
      }

      // Check if it's a valid PNG (starts with PNG signature)
      if (bytes.length >= 8) {
        final signature = bytes.sublist(0, 8);
        const pngSignature = [137, 80, 78, 71, 13, 10, 26, 10];

        bool isValidPng = true;
        for (int i = 0; i < 8; i++) {
          if (signature[i] != pngSignature[i]) {
            isValidPng = false;
            break;
          }
        }

        if (!isValidPng) {
          debugPrint('Export verification failed: Invalid PNG format');
          return false;
        }
      }

      debugPrint('Export verification successful: $filePath');
      return true;
    } catch (e) {
      debugPrint('Error verifying export: $e');
      return false;
    }
  }
}
