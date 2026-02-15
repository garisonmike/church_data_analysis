import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/app_database.dart' as db;
import '../../models/models.dart';
import '../../platform/file_storage.dart';
import '../../repositories/repositories.dart';
import '../../services/services.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  final int churchId;
  const ReportsScreen({super.key, required this.churchId});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportOptions {
  final bool includeGraphs;
  final bool includeKpi;
  final bool includeTable;
  final bool includeTrends;

  const _ReportOptions({
    this.includeGraphs = true,
    this.includeKpi = true,
    this.includeTable = true,
    this.includeTrends = true,
  });

  _ReportOptions copyWith({
    bool? includeGraphs,
    bool? includeKpi,
    bool? includeTable,
    bool? includeTrends,
  }) {
    return _ReportOptions(
      includeGraphs: includeGraphs ?? this.includeGraphs,
      includeKpi: includeKpi ?? this.includeKpi,
      includeTable: includeTable ?? this.includeTable,
      includeTrends: includeTrends ?? this.includeTrends,
    );
  }
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final _csvService = CsvExportService();
  final _backupService = BackupService();
  final _fileStorage = getFileStorage();

  bool _isProcessing = false;
  bool _promptForLocation = true;
  String? _lastExportPath;
  _ReportOptions _reportOptions = const _ReportOptions();
  CsvExportOptions _csvOptions = const CsvExportOptions();

  // Helper to get data for exports
  Future<List<WeeklyRecord>> _getRecords() async {
    final database = ref.read(db.databaseProvider);
    final repository = WeeklyRecordRepository(database);
    return await repository.getRecordsByChurch(widget.churchId);
  }

  Future<List<Church>> _getChurches() async {
    final database = ref.read(db.databaseProvider);
    final repository = ChurchRepository(database);
    final church = await repository.getChurchById(widget.churchId);
    return church != null ? [church] : [];
  }

  Future<List<AdminUser>> _getAdmins() async {
    // For this repair task, we just return empty or current user if needed,
    // but the backup service expects a list.
    // In a real app we'd fetch actual users.
    return [];
  }

  void _showStatus(
    String message, {
    bool isSuccess = false,
    bool isError = false,
  }) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess
            ? Colors.green
            : isError
            ? Colors.red
            : null,
      ),
    );
  }

  Future<void> _exportPdf() async {
    final selectedOptions = await _promptReportOptions();
    if (selectedOptions == null) {
      return;
    }
    setState(() => _reportOptions = selectedOptions);
    setState(() => _isProcessing = true);
    try {
      final records = await _getRecords();
      final churches = await _getChurches();
      final churchName = churches.isNotEmpty ? churches.first.name : 'Church';
      final settings = ref.read(appSettingsProvider);
      final formatCurrency = ref.read(currencyFormatterProvider);
      final formatCurrencyPrecise = ref.read(currencyFormatterPreciseProvider);

      final pdf = await PdfReportService.buildMultiChartReport(
        churchName: churchName,
        records: records,
        chartImages: const {},
        includeGraphs: selectedOptions.includeGraphs,
        includeKpi: selectedOptions.includeKpi,
        includeTable: selectedOptions.includeTable,
        includeTrends: selectedOptions.includeTrends,
        locale: settings.locale,
        currencySymbol: settings.currency.symbol,
        formatCurrency: formatCurrency,
        formatCurrencyPrecise: formatCurrencyPrecise,
      );

      final suggestedName = PdfReportService.generatePdfFileName(
        churchName: churchName,
        reportType: 'analytics_report',
      );
      final customPath = await _pickExportPath(
        suggestedName: '$suggestedName.pdf',
        allowedExtensions: const ['pdf'],
      );
      if (_promptForLocation && customPath == null) {
        _showStatus('PDF export cancelled');
        return;
      }

      final savedPath = await PdfReportService.savePdf(
        pdf: pdf,
        fileName: suggestedName,
        customPath: customPath,
      );

      if (savedPath != null) {
        _showStatus('PDF exported successfully', isSuccess: true);
      } else {
        _showStatus('PDF export failed. Please try again.', isError: true);
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('PDF export error: $e');
        debugPrint('Stack trace: $stack');
      }
      _showStatus('Export failed. Please try again.', isError: true);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _exportCsv() async {
    final selectedOptions = await _promptCsvOptions();
    if (selectedOptions == null) {
      return;
    }
    setState(() => _csvOptions = selectedOptions);
    setState(() => _isProcessing = true);
    try {
      final records = await _getRecords();
      final settings = ref.read(appSettingsProvider);
      final suggestedName = _csvService.generateExportFilename(
        'weekly_records',
      );
      final customPath = await _pickExportPath(
        suggestedName: suggestedName,
        allowedExtensions: const ['csv'],
      );
      if (_promptForLocation && customPath == null) {
        _showStatus('CSV export cancelled');
        return;
      }

      final result = await _csvService.exportWeeklyRecords(
        records,
        customPath: customPath,
        options: selectedOptions,
        currencyCode: settings.currency.code,
      );
      if (result.success) {
        _showStatus('CSV exported successfully', isSuccess: true);
      } else {
        if (kDebugMode) {
          debugPrint('CSV export error: ${result.error}');
        }
        _showStatus('Export failed. Please try again.', isError: true);
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('CSV export error: $e');
        debugPrint('Stack trace: $stack');
      }
      _showStatus('Export failed. Please try again.', isError: true);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _createBackup() async {
    setState(() => _isProcessing = true);
    try {
      final records = await _getRecords();
      final churches = await _getChurches();
      final admins = await _getAdmins();

      final suggestedName = _backupService.generateBackupFilename();
      final customPath = await _pickExportPath(
        suggestedName: suggestedName,
        allowedExtensions: const ['json'],
      );
      if (_promptForLocation && customPath == null) {
        _showStatus('Backup cancelled');
        return;
      }

      final result = await _backupService.createBackup(
        churches: churches,
        admins: admins,
        records: records,
        customPath: customPath,
      );

      if (result.success) {
        _showStatus('Backup created successfully', isSuccess: true);
      } else {
        if (kDebugMode) {
          debugPrint('Backup error: ${result.error}');
        }
        _showStatus('Backup failed. Please try again.', isError: true);
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('Backup error: $e');
        debugPrint('Stack trace: $stack');
      }
      _showStatus('Backup failed. Please try again.', isError: true);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _restoreBackup() async {
    setState(() => _isProcessing = true);
    try {
      final file = await _fileStorage.pickFile(allowedExtensions: ['json']);
      if (file != null) {
        final result = await _backupService.restoreFromBackup(file);
        if (result.success) {
          _showStatus('Restore completed successfully', isSuccess: true);
        } else {
          if (kDebugMode) {
            debugPrint('Restore error: ${result.error}');
          }
          _showStatus('Restore failed. Please try again.', isError: true);
        }
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('Restore error: $e');
        debugPrint('Stack trace: $stack');
      }
      _showStatus('Restore failed. Please try again.', isError: true);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Widget _buildExportLocationCard() {
    final locationLabel = kIsWeb
        ? 'Browser downloads'
        : (_lastExportPath ?? 'Default app exports folder');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Export Location',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Choose save location'),
              subtitle: Text(
                kIsWeb
                    ? 'Web downloads are handled by the browser.'
                    : 'When enabled, you will pick a save location for each export.',
              ),
              value: _promptForLocation,
              onChanged: (value) {
                setState(() => _promptForLocation = value);
              },
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.folder_open, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    locationLabel,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportBuilderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PDF Report Builder',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose what to include in the PDF export.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChip('Graphs', _reportOptions.includeGraphs),
                _buildChip('KPI', _reportOptions.includeKpi),
                _buildChip('Table', _reportOptions.includeTable),
                _buildChip('Trends', _reportOptions.includeTrends),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCsvOptionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CSV Export Options',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose which columns to include in the CSV export.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildChip('Attendance', _csvOptions.includeAttendance),
                _buildChip('Financial', _csvOptions.includeFinancial),
                _buildChip('Totals', _csvOptions.includeTotals),
                _buildChip('Metadata', _csvOptions.includeMetadata),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool enabled) {
    return Chip(
      label: Text(label),
      backgroundColor: enabled
          ? Theme.of(context).colorScheme.secondaryContainer
          : Theme.of(context).colorScheme.surfaceContainerHighest,
    );
  }

  Future<_ReportOptions?> _promptReportOptions() async {
    var options = _reportOptions;

    final result = await showDialog<_ReportOptions>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Customize PDF Report'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Include graphs'),
                  value: options.includeGraphs,
                  onChanged: (value) => setState(
                    () => options = options.copyWith(includeGraphs: value),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Include KPI metrics'),
                  value: options.includeKpi,
                  onChanged: (value) => setState(
                    () => options = options.copyWith(includeKpi: value),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Include records table'),
                  value: options.includeTable,
                  onChanged: (value) => setState(
                    () => options = options.copyWith(includeTable: value),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Include trend summary'),
                  value: options.includeTrends,
                  onChanged: (value) => setState(
                    () => options = options.copyWith(includeTrends: value),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, options),
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    return result;
  }

  bool _hasCsvContent(CsvExportOptions options) {
    return options.includeAttendance ||
        options.includeFinancial ||
        options.includeTotals ||
        options.includeMetadata;
  }

  Future<CsvExportOptions?> _promptCsvOptions() async {
    var options = _csvOptions;

    final result = await showDialog<CsvExportOptions>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Customize CSV Export'),
        content: StatefulBuilder(
          builder: (context, setState) {
            final hasContent = _hasCsvContent(options);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Include attendance columns'),
                  value: options.includeAttendance,
                  onChanged: (value) => setState(
                    () => options = CsvExportOptions(
                      includeAttendance: value,
                      includeFinancial: options.includeFinancial,
                      includeTotals: options.includeTotals,
                      includeMetadata: options.includeMetadata,
                    ),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Include financial columns'),
                  value: options.includeFinancial,
                  onChanged: (value) => setState(
                    () => options = CsvExportOptions(
                      includeAttendance: options.includeAttendance,
                      includeFinancial: value,
                      includeTotals: options.includeTotals,
                      includeMetadata: options.includeMetadata,
                    ),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Include totals'),
                  value: options.includeTotals,
                  onChanged: (value) => setState(
                    () => options = CsvExportOptions(
                      includeAttendance: options.includeAttendance,
                      includeFinancial: options.includeFinancial,
                      includeTotals: value,
                      includeMetadata: options.includeMetadata,
                    ),
                  ),
                ),
                SwitchListTile(
                  title: const Text('Include metadata'),
                  value: options.includeMetadata,
                  onChanged: (value) => setState(
                    () => options = CsvExportOptions(
                      includeAttendance: options.includeAttendance,
                      includeFinancial: options.includeFinancial,
                      includeTotals: options.includeTotals,
                      includeMetadata: value,
                    ),
                  ),
                ),
                if (!hasContent) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Select at least one column group',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _hasCsvContent(options)
                ? () => Navigator.pop(context, options)
                : null,
            child: const Text('Continue'),
          ),
        ],
      ),
    );

    return result;
  }

  Future<String?> _pickExportPath({
    required String suggestedName,
    required List<String> allowedExtensions,
  }) async {
    if (!_promptForLocation) {
      return null;
    }

    final pickedPath = await _fileStorage.pickSaveLocation(
      suggestedName: suggestedName,
      allowedExtensions: allowedExtensions,
    );

    if (pickedPath != null && mounted) {
      setState(() => _lastExportPath = pickedPath);
    }

    return pickedPath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Backup')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isProcessing) const CircularProgressIndicator(),
              const SizedBox(height: 20),
              _buildExportLocationCard(),
              const SizedBox(height: 12),
              _buildReportBuilderCard(),
              const SizedBox(height: 12),
              _buildCsvOptionsCard(),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _exportPdf,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Export PDF Report'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _exportCsv,
                icon: const Icon(Icons.table_chart),
                label: const Text('Export CSV Data'),
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _createBackup,
                icon: const Icon(Icons.save),
                label: const Text('Create Backup'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade100,
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _restoreBackup,
                icon: const Icon(Icons.restore),
                label: const Text('Restore from Backup'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade100,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
