import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/app_database.dart' as db;
import '../../models/models.dart';
import '../../platform/path_safety_guard.dart';
// 2.6-A: removed repositories.dart (caused unused-import warning)
// 2.6-A: added individual repository imports needed by _getRecords / _getChurches
import '../../repositories/weekly_record_repository.dart';
import '../../repositories/church_repository.dart';
import '../../services/services.dart';
// 2.6-A: removed four dead chart-screen imports (advanced, attendance, correlation, financial)
import '../../services/pdf_graph_catalogue.dart'; // 2.6-B
import '../../services/weekly_records_provider.dart'; // FEAT-010: holyCommunionEventsProvider
import '../widgets/export_result_snack_bar.dart';

/// Normalizes a raw export file-system path by trimming whitespace.
///
/// Returns `null` when [rawPath] is `null` or consists solely of whitespace,
/// so that empty strings never flow into file-system operations.
///
/// Exposed for unit testing via `@visibleForTesting`; callers outside this
/// library should not depend on this function directly.
@visibleForTesting
String? normalizeExportPath(String? rawPath) {
  final trimmed = rawPath?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  assert(
    trimmed == trimmed.trim(),
    'Export path must not contain leading/trailing whitespace',
  );
  return trimmed;
}

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

  bool _isProcessing = false;
  String _processingMessage = ''; // 2.6-C
  Set<PdfGraphId> _selectedGraphs = Set.of(PdfGraphId.values); // 2.6-C: all selected by default
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

  // 2.6-D: _collectChartImages deleted entirely — replaced by native PDF vector charts

  // 2.6-E: replaced _exportPdf — no more _collectChartImages, passes selectedGraphs instead
  Future<void> _exportPdf() async {
    setState(() {
      _isProcessing = true;
      _processingMessage = 'Loading records\u2026';
    });
    try {
      final records = await _getRecords();
      final churches = await _getChurches();
      final churchName = churches.isNotEmpty ? churches.first.name : 'Church';
      final settings = ref.read(appSettingsProvider);
      final formatCurrency = ref.read(currencyFormatterProvider);
      final formatCurrencyPrecise = ref.read(currencyFormatterPreciseProvider);

      // FEAT-010: fetch communion events so Holy Communion graphs render correctly
      final communionEvents =
          await ref.read(holyCommunionEventsProvider(widget.churchId).future);

      setState(() => _processingMessage = 'Building PDF\u2026');

      final pdf = await PdfReportService.buildMultiChartReport(
        churchName: churchName,
        records: records,
        selectedGraphs: _selectedGraphs.toList(),
        communionEvents: communionEvents, // FEAT-010
        includeGraphs: _reportOptions.includeGraphs,
        includeKpi: _reportOptions.includeKpi,
        includeTable: _reportOptions.includeTable,
        includeTrends: _reportOptions.includeTrends,
        locale: settings.locale,
        currencySymbol: settings.currency.symbol,
        formatCurrency: formatCurrency,
        formatCurrencyPrecise: formatCurrencyPrecise,
      );

      setState(() => _processingMessage = 'Saving file\u2026');

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
        fileService: ref.read(fileServiceProvider),
      );

      if (savedPath != null) {
        if (mounted) {
          setState(() => _lastExportPath = savedPath);
          ExportResultSnackBar.show(context, ExportResult.success(savedPath));
        }
      } else {
        if (mounted) {
          ExportResultSnackBar.show(
            context,
            ExportResult.failure('PDF export failed. Please try again.'),
          );
        }
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('PDF export error: $e');
        debugPrint('Stack trace: $stack');
      }
      if (mounted) {
        ExportResultSnackBar.show(
          context,
          ExportResult.failure('Export failed: $e'),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
        _processingMessage = '';
      });
    }
  }

  Future<void> _exportCsv() async {
    if (!_hasCsvContent(_csvOptions)) {
      _showStatus('Select at least one CSV column group first.');
      return;
    }
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
        options: _csvOptions,
        currencyCode: settings.currency.code,
      );
      if (result.success) {
        final savedPath = result.filePath;
        if (savedPath != null && mounted) {
          setState(() => _lastExportPath = savedPath);
          ExportResultSnackBar.show(context, ExportResult.success(savedPath));
        } else if (mounted) {
          ExportResultSnackBar.show(
            context,
            ExportResult.failure('CSV export failed.'),
          );
        }
      } else {
        if (kDebugMode) debugPrint('CSV export error: ${result.error}');
        if (mounted) {
          ExportResultSnackBar.show(
            context,
            ExportResult.failure(result.error ?? 'CSV export failed.'),
          );
        }
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('CSV export error: $e');
        debugPrint('Stack trace: $stack');
      }
      if (mounted) {
        ExportResultSnackBar.show(
          context,
          ExportResult.failure('Export failed: $e'),
        );
      }
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
        final savedPath = result.filePath;
        if (savedPath != null && mounted) {
          setState(() => _lastExportPath = savedPath);
          ExportResultSnackBar.show(context, ExportResult.success(savedPath));
        } else if (mounted) {
          ExportResultSnackBar.show(
            context,
            ExportResult.failure('Backup failed.'),
          );
        }
      } else {
        if (kDebugMode) {
          debugPrint('Backup error: ${result.error}');
        }
        if (mounted) {
          ExportResultSnackBar.show(
            context,
            ExportResult.failure(result.error ?? 'Backup failed.'),
          );
        }
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('Backup error: $e');
        debugPrint('Stack trace: $stack');
      }
      if (mounted) {
        ExportResultSnackBar.show(
          context,
          ExportResult.failure('Backup failed: $e'),
        );
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _restoreBackup() async {
    setState(() => _isProcessing = true);
    try {
      final file = await ref
          .read(fileServiceProvider)
          .pickFile(allowedExtensions: ['json']);
      if (file != null && mounted) {
        final result = await _backupService.restoreFromBackup(file);
        if (result.success) {
          if (mounted) {
            ExportResultSnackBar.showImportSuccess(context, file.name);
          }
        } else {
          if (kDebugMode) {
            debugPrint('Restore error: ${result.error}');
          }
          if (mounted) {
            ExportResultSnackBar.showImportError(
              context,
              errorMessage: result.error ?? 'Restore failed.',
            );
          }
        }
      }
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint('Restore error: $e');
        debugPrint('Stack trace: $stack');
      }
      if (mounted) {
        ExportResultSnackBar.showImportError(
          context,
          errorMessage: 'Restore failed: $e',
        );
      }
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

  // 2.6-G: replaced _buildReportBuilderCard with full graph-selection UI
  Widget _buildReportBuilderCard() {
    // Group the catalogue by category for sectioned display
    final byCategory = <PdfGraphCategory, List<PdfGraphOption>>{};
    for (final opt in kPdfGraphCatalogue) {
      byCategory.putIfAbsent(opt.category, () => []).add(opt);
    }

    final allSelected = _selectedGraphs.length == PdfGraphId.values.length;
    final noneSelected = _selectedGraphs.isEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PDF Report Builder',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              'Choose what to include in the exported PDF.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),

            // ── Section toggles (KPI, Table, Trends) ──────────────────────
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('KPI Summary'),
                  selected: _reportOptions.includeKpi,
                  onSelected: (v) => setState(
                      () => _reportOptions =
                          _reportOptions.copyWith(includeKpi: v)),
                ),
                FilterChip(
                  label: const Text('Data Table'),
                  selected: _reportOptions.includeTable,
                  onSelected: (v) => setState(
                      () => _reportOptions =
                          _reportOptions.copyWith(includeTable: v)),
                ),
                FilterChip(
                  label: const Text('Trends Summary'),
                  selected: _reportOptions.includeTrends,
                  onSelected: (v) => setState(
                      () => _reportOptions =
                          _reportOptions.copyWith(includeTrends: v)),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 4),

            // ── Graphs header + Select All / Deselect All ──────────────────
            Row(
              children: [
                Text('Graphs',
                    style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() {
                    if (allSelected) {
                      _selectedGraphs = {};
                    } else {
                      _selectedGraphs = Set.of(PdfGraphId.values);
                    }
                    _reportOptions = _reportOptions.copyWith(
                      includeGraphs: _selectedGraphs.isNotEmpty,
                    );
                  }),
                  child: Text(allSelected ? 'Deselect All' : 'Select All'),
                ),
              ],
            ),

            // Warning when no graphs are selected
            if (noneSelected)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'No graphs selected \u2014 the graphs section will be omitted from the PDF.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.orange.shade800),
                ),
              ),

            // ── Graph chips grouped by category ────────────────────────────
            ...PdfGraphCategory.values.map((category) {
              final options = byCategory[category] ?? [];
              if (options.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    kPdfGraphCategoryLabels[category]!,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: options.map((opt) {
                      final selected = _selectedGraphs.contains(opt.id);
                      return FilterChip(
                        label: Text(
                          opt.label,
                          style: const TextStyle(fontSize: 12),
                        ),
                        selected: selected,
                        tooltip: opt.description,
                        onSelected: (v) => setState(() {
                          if (v) {
                            _selectedGraphs = {..._selectedGraphs, opt.id};
                          } else {
                            _selectedGraphs = _selectedGraphs
                                .where((id) => id != opt.id)
                                .toSet();
                          }
                          _reportOptions = _reportOptions.copyWith(
                            includeGraphs: _selectedGraphs.isNotEmpty,
                          );
                        }),
                      );
                    }).toList(),
                  ),
                ],
              );
            }),

            const SizedBox(height: 8),
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
                FilterChip(
                  label: const Text('Attendance'),
                  selected: _csvOptions.includeAttendance,
                  onSelected: (v) => setState(
                    () => _csvOptions = CsvExportOptions(
                      includeAttendance: v,
                      includeFinancial: _csvOptions.includeFinancial,
                      includeTotals: _csvOptions.includeTotals,
                      includeMetadata: _csvOptions.includeMetadata,
                    ),
                  ),
                ),
                FilterChip(
                  label: const Text('Financial'),
                  selected: _csvOptions.includeFinancial,
                  onSelected: (v) => setState(
                    () => _csvOptions = CsvExportOptions(
                      includeAttendance: _csvOptions.includeAttendance,
                      includeFinancial: v,
                      includeTotals: _csvOptions.includeTotals,
                      includeMetadata: _csvOptions.includeMetadata,
                    ),
                  ),
                ),
                FilterChip(
                  label: const Text('Totals'),
                  selected: _csvOptions.includeTotals,
                  onSelected: (v) => setState(
                    () => _csvOptions = CsvExportOptions(
                      includeAttendance: _csvOptions.includeAttendance,
                      includeFinancial: _csvOptions.includeFinancial,
                      includeTotals: v,
                      includeMetadata: _csvOptions.includeMetadata,
                    ),
                  ),
                ),
                FilterChip(
                  label: const Text('Metadata'),
                  selected: _csvOptions.includeMetadata,
                  onSelected: (v) => setState(
                    () => _csvOptions = CsvExportOptions(
                      includeAttendance: _csvOptions.includeAttendance,
                      includeFinancial: _csvOptions.includeFinancial,
                      includeTotals: _csvOptions.includeTotals,
                      includeMetadata: v,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _hasCsvContent(CsvExportOptions options) {
    return options.includeAttendance ||
        options.includeFinancial ||
        options.includeTotals ||
        options.includeMetadata;
  }

  Future<String?> _pickExportPath({
    required String suggestedName,
    required List<String> allowedExtensions,
  }) async {
    if (!_promptForLocation) {
      return null;
    }

    final rawPath = await ref
        .read(fileServiceProvider)
        .pickSaveLocation(
          suggestedName: suggestedName,
          allowedExtensions: allowedExtensions,
        );

    final trimmed = normalizeExportPath(rawPath);

    if (trimmed != null) {
      // Reject paths that point to hidden or app-internal directories.
      final guardResult = PathSafetyGuard.guard(trimmed);
      if (guardResult.wasOverridden) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Selected folder is not user-accessible. '
                'Using the default export folder instead.',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        // Return null so the caller falls back to the platform default path.
        return null;
      }

      if (mounted) {
        setState(() => _lastExportPath = trimmed);
        if (kDebugMode) {
          debugPrint('Export location selected: $trimmed');
        }
      }
    }

    // Guard: the returned path must never contain leading/trailing whitespace.
    assert(
      trimmed == null || trimmed == trimmed.trim(),
      'Export path must not contain leading/trailing whitespace',
    );

    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Backup')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final spacing = width < 480 ? 8.0 : (width < 840 ? 12.0 : 16.0);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // 2.6-F: replaced bare CircularProgressIndicator with
                    // LinearProgressIndicator + message label
                    if (_isProcessing) ...[
                      const LinearProgressIndicator(),
                      const SizedBox(height: 8),
                      Text(
                        _processingMessage,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                    ],
                    SizedBox(height: spacing),
                    if (width >= 840) ...[
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: (width - 44) / 2,
                            child: _buildExportLocationCard(),
                          ),
                          SizedBox(
                            width: (width - 44) / 2,
                            child: _buildReportBuilderCard(),
                          ),
                          SizedBox(
                            width: (width - 44) / 2,
                            child: _buildCsvOptionsCard(),
                          ),
                        ],
                      ),
                    ] else ...[
                      _buildExportLocationCard(),
                      SizedBox(height: spacing),
                      _buildReportBuilderCard(),
                      SizedBox(height: spacing),
                      _buildCsvOptionsCard(),
                    ],
                    SizedBox(height: spacing),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _exportPdf,
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Export PDF Report'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _exportCsv,
                          icon: const Icon(Icons.table_chart),
                          label: const Text('Export CSV Data'),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing),
                    const Divider(),
                    SizedBox(height: spacing),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isProcessing ? null : _createBackup,
                          icon: const Icon(Icons.save),
                          label: const Text('Create Backup'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade100,
                          ),
                        ),
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
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
