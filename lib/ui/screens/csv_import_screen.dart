import 'package:church_analytics/database/app_database.dart';
import 'package:church_analytics/platform/file_storage_interface.dart';
import 'package:church_analytics/repositories/repositories.dart';
import 'package:church_analytics/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CsvImportScreen extends ConsumerStatefulWidget {
  final int churchId;

  const CsvImportScreen({super.key, required this.churchId});

  @override
  ConsumerState<CsvImportScreen> createState() => _CsvImportScreenState();
}

class _CsvImportScreenState extends ConsumerState<CsvImportScreen> {
  final _csvService = CsvImportService();

  PlatformFileResult? _selectedFile;
  List<String>? _headers;
  List<List<dynamic>>? _rows;
  Map<String, int> _columnMapping = {};
  List<WeeklyRecordImportResult>? _validationResults;
  bool _isLoading = false;
  String? _errorMessage;
  int _currentStep = 0;

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
      final file = await _csvService.pickCsvFile();

      if (file == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final result = await _csvService.parseCsvFile(file);

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
        _columnMapping = _csvService.suggestColumnMapping(result.headers!);
        _isLoading = false;
        _currentStep = 1; // Move to column mapping step
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
        .where((field) => !_columnMapping.containsKey(field))
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
    final database = AppDatabase();
    final adminRepo = AdminUserRepository(database);
    final profileService = AdminProfileService(adminRepo, prefs);
    final currentAdminId = profileService.getCurrentProfileId();
    await database.close();

    for (var i = 0; i < _rows!.length; i++) {
      final result = _csvService.validateAndConvertRow(
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
      _currentStep = 2; // Move to preview/validation step
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

    AppDatabase? database;
    try {
      database = AppDatabase();
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
    } finally {
      await database?.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import CSV'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                    _currentStep = 0;
                    _selectedFile = null;
                    _headers = null;
                    _rows = null;
                    _columnMapping = {};
                    _validationResults = null;
                  });
                },
                child: const Text('Start Over'),
              ),
            ],
          ),
        ),
      );
    }

    return Stepper(
      currentStep: _currentStep,
      onStepContinue: _onStepContinue,
      onStepCancel: _onStepCancel,
      controlsBuilder: (context, details) {
        return Row(
          children: [
            if (details.stepIndex < 2)
              ElevatedButton(
                onPressed: details.onStepContinue,
                child: Text(details.stepIndex == 1 ? 'Validate' : 'Continue'),
              ),
            if (details.stepIndex == 2)
              ElevatedButton(
                onPressed: _importData,
                child: const Text('Import'),
              ),
            const SizedBox(width: 8),
            if (details.stepIndex > 0)
              TextButton(
                onPressed: details.onStepCancel,
                child: const Text('Back'),
              ),
          ],
        );
      },
      steps: [
        Step(
          title: const Text('Select File'),
          content: _buildFilePickerStep(),
          isActive: _currentStep >= 0,
          state: _currentStep > 0 ? StepState.complete : StepState.indexed,
        ),
        Step(
          title: const Text('Map Columns'),
          content: _buildColumnMappingStep(),
          isActive: _currentStep >= 1,
          state: _currentStep > 1 ? StepState.complete : StepState.indexed,
        ),
        Step(
          title: const Text('Preview & Import'),
          content: _buildPreviewStep(),
          isActive: _currentStep >= 2,
        ),
      ],
    );
  }

  void _onStepContinue() {
    if (_currentStep == 0) {
      _pickFile();
    } else if (_currentStep == 1) {
      _validateData();
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Widget _buildFilePickerStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select a CSV file to import weekly records.'),
        const SizedBox(height: 16),
        if (_selectedFile != null) ...[
          Card(
            child: ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: Text(_selectedFile!.name),
              subtitle: Text('${_rows?.length ?? 0} rows'),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _selectedFile = null;
                    _headers = null;
                    _rows = null;
                    _currentStep = 0;
                  });
                },
              ),
            ),
          ),
        ] else ...[
          ElevatedButton.icon(
            onPressed: _pickFile,
            icon: const Icon(Icons.folder_open),
            label: const Text('Choose CSV File'),
          ),
        ],
        const SizedBox(height: 16),
        const Text(
          'CSV Format Requirements:\n'
          '• First row must contain column headers\n'
          '• Date format: YYYY-MM-DD\n'
          '• Numbers should not have commas',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildColumnMappingStep() {
    if (_headers == null || _rows == null) {
      return const Text('No file selected');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Map CSV columns to fields:'),
        const SizedBox(height: 16),
        Text('Required fields', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        ..._requiredFields.map(
          (field) => _buildMappingDropdown(field, isOptional: false),
        ),
        const SizedBox(height: 16),
        Text('Optional fields', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        ..._optionalFields.map(
          (field) => _buildMappingDropdown(field, isOptional: true),
        ),
        const SizedBox(height: 16),
        Text(
          'Preview: ${_rows!.take(3).length} of ${_rows!.length} rows',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: _headers!.map((h) => DataColumn(label: Text(h))).toList(),
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
    );
  }

  Widget _buildMappingDropdown(String field, {required bool isOptional}) {
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
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
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
      return const Text('No validation results');
    }

    final validCount = _validationResults!.where((r) => r.success).length;
    final errorCount = _validationResults!.where((r) => !r.success).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Validation Summary',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text('✓ Valid records: $validCount'),
                Text('✗ Invalid records: $errorCount'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (errorCount > 0) ...[
          Text('Errors Found:', style: Theme.of(context).textTheme.titleMedium),
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
                        color: Colors.red.shade50,
                        child: ListTile(
                          leading: const Icon(Icons.error, color: Colors.red),
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
      ],
    );
  }
}
