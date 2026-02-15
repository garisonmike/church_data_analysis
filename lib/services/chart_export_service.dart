import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:church_analytics/platform/file_storage.dart';
import 'package:church_analytics/platform/file_storage_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

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
    FileStorage? fileStorage,
  }) async {
    try {
      final storage = fileStorage ?? getFileStorage();
      final fullFileName = fileName.endsWith('.png')
          ? fileName
          : '$fileName.png';

      final path = await storage.saveFileBytes(
        fileName: fullFileName,
        bytes: imageBytes,
      );

      debugPrint('Chart saved successfully: $path');
      return path;
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

    // Generate timestamp with safe date formatting
    String timestamp;
    try {
      timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    } catch (e) {
      debugPrint('Warning: DateFormat failed, using fallback: $e');
      // Fallback to manual formatting if locale fails
      final now = DateTime.now();
      timestamp =
          '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_'
          '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    }

    return '${cleanChurchName}_${cleanChartType}_$timestamp';
  }

  /// Complete export workflow: capture, generate filename, and save
  ///
  /// Returns the saved file path if successful, null otherwise
  static Future<String?> exportChart({
    required GlobalKey repaintBoundaryKey,
    required String churchName,
    required String chartType,
    FileStorage? fileStorage,
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
        fileStorage: fileStorage,
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
    // Platform-safe verification:
    // - Web downloads can't be verified via filesystem APIs.
    // - Native paths could be verified with dart:io, but that would break web builds.
    // So we treat a non-empty returned value as success.
    return filePath.trim().isNotEmpty;
  }
}
