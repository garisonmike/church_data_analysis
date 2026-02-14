import 'package:church_analytics/database/app_database.dart';
import 'package:church_analytics/platform/file_storage_interface.dart';
import 'package:church_analytics/repositories/repositories.dart';
import 'package:church_analytics/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ImportScreen extends ConsumerStatefulWidget {
  final int churchId;

  const ImportScreen({super.key, required this.churchId});

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  final _importService = ImportService();

  PlatformFileResult? _selectedFile;
  List<String>? _headers;
  List<List<dynamic>>? _rows;
  Map<String, int> _columnMapping = {};
  List<WeeklyRecordImportResult>? _validationResults;
  bool _isLoading = false;
  String? _errorMessage;

  // Field names that need to be mapped
  final List<String> _requiredFields = [
    'weekStartDate',
    'men',
    'women',
    'youth',
    'children',
    'sundayHomeChurch',
    'tithe',
    'offerings',
  ];

  final List<String> _optionalFields = [
    'emergencyCollection',
    'plannedCollection',
  ];

  final Map<String, String> _fieldLabels = {
    'weekStartDate': 'Week Start Date',
    'men': 'Men Attendance',
    'women': 'Women Attendance',
    'youth': 'Youth Attendance',
    'children': 'Children Attendance',
    'sundayHomeChurch': 'Sunday Home Church',
    'tithe': 'Tithe',
    'offerings': 'Offerings',
    'emergencyCollection': 'Emergency Collection',
    'plannedCollection': 'Planned Collection',
  };

  Future<void> _pickFile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final file = await _importService.pickFile();

      if (file == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final result = await _importService.parseFile(file);

      if (!result.success) {
        setState(() {
          _errorMessage = result.error;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _selectedFile = file;
        _headers = result.headers;
        _rows = result.rows;
        _columnMapping = _importService.suggestColumnMapping(result.headers!);
        _isLoading = false;
        _validationResults = null; // Reset validation
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking file: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _validateData() async {
    if (_rows == null || _headers == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Check that all required fields are mapped
    final unmappedFields = _requiredFields
        .where(
          (field) =>
              !_columnMapping.containsKey(field) ||
              _columnMapping[field] == null,
        )
        .toList();

    if (unmappedFields.isNotEmpty) {
      setState(() {
        _errorMessage =
            'Please map all required fields: ${unmappedFields.map((f) => _fieldLabels[f]).join(', ')}';
        _isLoading = false;
      });
      return;
    }

    // Validate each row
    final results = <WeeklyRecordImportResult>[];

    // Get current admin ID
    final prefs = await SharedPreferences.getInstance();
    final database = ref.read(databaseProvider);
    final adminRepo = AdminUserRepository(database);
    final profileService = AdminProfileService(adminRepo, prefs);
    final currentAdminId = profileService.getCurrentProfileId();

    for (var i = 0; i < _rows!.length; i++) {
      final result = _importService.validateAndConvertRow(
        _rows![i],
        _columnMapping,
        widget.churchId,
        i + 2, // +2 because row 1 is headers and display is 1-indexed
        currentAdminId,
        _optionalFields.toSet(),
      );
      results.add(result);
    }

    setState(() {
      _validationResults = results;
      _isLoading = false;
    });
  }

  Future<void> _importData() async {
    if (_validationResults == null) return;

    final validRecords = _validationResults!
        .where((r) => r.success)
        .map((r) => r.record!)
        .toList();

    if (validRecords.isEmpty) {
      setState(() {
        _errorMessage = 'No valid records to import';
      });
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Import'),
        content: Text(
          'Import ${validRecords.length} record(s)?\n\n'
          '${_validationResults!.where((r) => !r.success).length} record(s) will be skipped due to errors.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Import'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final database = ref.read(databaseProvider);
      final repository = WeeklyRecordRepository(database);

      int successCount = 0;
      int skipCount = 0;
      final errors = <String>[];

      for (final record in validRecords) {
        try {
          // Check for duplicates
          final exists = await repository.weekExists(
            record.churchId,
            record.weekStartDate,
          );

          if (exists) {
            skipCount++;
            errors.add(
              'Row skipped: duplicate week ${record.weekStartDate.toString().split(' ')[0]}',
            );
          } else {
            await repository.createRecord(record);
            successCount++;
          }
        } catch (e) {
          errors.add('Failed to import record: ${e.toString()}');
        }
      }

      if (mounted) {
        // Show results
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Import Complete'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('✓ Successfully imported: $successCount'),
                  if (skipCount > 0) Text('⚠ Skipped (duplicates): $skipCount'),
                  if (errors.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Errors:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...errors.map(
                      (e) => Text('• $e', style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(true); // Return to previous screen
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Import failed: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _reset() {
    setState(() {
      _selectedFile = null;
      _headers = null;
      _rows = null;
      _columnMapping = {};
      _validationResults = null;
      _isLoading = false;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Data'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _reset,
            tooltip: 'Start Over',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh),
                label: const Text('Start Over'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildFilePickerStep(),
        if (_headers != null && _rows != null) ...[
          const SizedBox(height: 24),
          _buildColumnMappingStep(),
          const SizedBox(height: 24),
          _buildActionsStep(),
        ],
        if (_validationResults != null) ...[
          const SizedBox(height: 24),
          _buildPreviewStep(),
        ],
      ],
    );
  }

  Widget _buildFilePickerStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                child: Text('1', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              title: Text(
                'Select File',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16),
            if (_selectedFile != null) ...[
              Text(
                'Selected: ${_selectedFile!.name} (${_rows?.length ?? 0} rows)',
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.replay),
                  label: const Text('Choose a different file'),
                ),
              ),
            ] else ...[
              const Text('Select a CSV or XLSX file to import weekly records.'),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Choose File'),
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Format Requirements:\n'
              '• First row must contain column headers\n'
              '• Date format: YYYY-MM-DD\n'
              '• Numbers should not have commas',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColumnMappingStep() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                child: Text('2', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              title: Text(
                'Map Columns',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              subtitle: const Text('Match file columns to database fields.'),
            ),
            const SizedBox(height: 16),
            Text(
              'Required fields',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ..._requiredFields.map(
              (field) => _buildMappingDropdown(field, isOptional: false),
            ),
            const SizedBox(height: 16),
            Text(
              'Optional fields',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ..._optionalFields.map(
              (field) => _buildMappingDropdown(field, isOptional: true),
            ),
            const SizedBox(height: 16),
            Text(
              'Preview: First ${_rows!.take(3).length} of ${_rows!.length} data rows',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: _headers!
                    .map((h) => DataColumn(label: Text(h)))
                    .toList(),
                rows: _rows!.take(3).map((row) {
                  return DataRow(
                    cells: row
                        .map((cell) => DataCell(Text(cell.toString())))
                        .toList(),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: ElevatedButton.icon(
          onPressed: _validateData,
          icon: const Icon(Icons.check_circle_outline),
          label: const Text('Validate Data'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            textStyle: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }

  Widget _buildMappingDropdown(String field, {required bool isOptional}) {
    final mappedIndices = _columnMapping.values.toList();
    final currentValue = _columnMapping[field];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(child: Text(_fieldLabels[field]!)),
                if (isOptional)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Optional',
                      style: TextStyle(
                        fontSize: 11,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<int>(
              initialValue: _columnMapping[field],
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              hint: const Text('Select column'),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('-- Not mapped --'),
                ),
                ..._headers!.asMap().entries.map((entry) {
                  final isMapped =
                      mappedIndices.contains(entry.key) &&
                      entry.key != currentValue;
                  return DropdownMenuItem(
                    value: entry.key,
                    enabled: !isMapped,
                    child: Text(
                      isMapped ? '${entry.value} (mapped)' : entry.value,
                      style: TextStyle(color: isMapped ? Colors.grey : null),
                    ),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  if (value == null) {
                    _columnMapping.remove(field);
                  } else {
                    _columnMapping[field] = value;
                  }
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewStep() {
    if (_validationResults == null) {
      return const SizedBox.shrink();
    }

    final validCount = _validationResults!.where((r) => r.success).length;
    final errorCount = _validationResults!.where((r) => !r.success).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                child: Text('3', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              title: Text(
                'Validation Results',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Theme.of(
                context,
              ).colorScheme.secondaryContainer.withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '✓',
                          style: TextStyle(color: Colors.green, fontSize: 24),
                        ),
                        Text('$validCount Valid'),
                      ],
                    ),
                    Column(
                      children: [
                        Text(
                          '✗',
                          style: TextStyle(color: Colors.red, fontSize: 24),
                        ),
                        Text('$errorCount Invalid'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (errorCount > 0) ...[
              const SizedBox(height: 16),
              Text(
                'Errors Found:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _validationResults!
                        .where((r) => !r.success)
                        .map(
                          (r) => Card(
                            elevation: 1,
                            color: Colors.red.shade50,
                            child: ListTile(
                              leading: const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                              ),
                              title: Text('Row ${r.rowNumber}'),
                              subtitle: Text(r.errors!.join('\n')),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: validCount > 0 ? _importData : null,
                icon: const Icon(Icons.file_upload),
                label: Text('Import $validCount Records'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  textStyle: Theme.of(context).textTheme.titleMedium,
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
