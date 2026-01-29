import 'package:church_analytics/database/app_database.dart';
import 'package:church_analytics/models/models.dart' as models;
import 'package:church_analytics/repositories/repositories.dart';
import 'package:church_analytics/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeeklyEntryScreen extends ConsumerStatefulWidget {
  final models.WeeklyRecord? existingRecord;

  const WeeklyEntryScreen({super.key, this.existingRecord});

  @override
  ConsumerState<WeeklyEntryScreen> createState() => _WeeklyEntryScreenState();
}

class _WeeklyEntryScreenState extends ConsumerState<WeeklyEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for attendance fields
  final _menController = TextEditingController();
  final _womenController = TextEditingController();
  final _youthController = TextEditingController();
  final _childrenController = TextEditingController();
  final _sundayHomeChurchController = TextEditingController();

  // Controllers for financial fields
  final _titheController = TextEditingController();
  final _offeringsController = TextEditingController();
  final _emergencyCollectionController = TextEditingController();
  final _plannedCollectionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  int? _selectedChurchId; // Will be loaded from ChurchService
  String? _errorMessage;
  bool _isLoading = false;
  ChurchService? _churchService;

  @override
  void initState() {
    super.initState();
    _initializeChurchService();

    // If editing existing record, populate fields
    if (widget.existingRecord != null) {
      final record = widget.existingRecord!;
      _menController.text = record.men.toString();
      _womenController.text = record.women.toString();
      _youthController.text = record.youth.toString();
      _childrenController.text = record.children.toString();
      _sundayHomeChurchController.text = record.sundayHomeChurch.toString();
      _titheController.text = record.tithe.toStringAsFixed(2);
      _offeringsController.text = record.offerings.toStringAsFixed(2);
      _emergencyCollectionController.text = record.emergencyCollection
          .toStringAsFixed(2);
      _plannedCollectionController.text = record.plannedCollection
          .toStringAsFixed(2);
      _selectedDate = record.weekStartDate;
      _selectedChurchId = record.churchId;
    }
  }

  Future<void> _initializeChurchService() async {
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase();
    final churchRepo = ChurchRepository(db);

    setState(() {
      _churchService = ChurchService(churchRepo, prefs);
    });

    // If not editing existing record, get current church
    if (widget.existingRecord == null) {
      final churchId = _churchService!.getCurrentChurchId();
      if (churchId != null) {
        setState(() {
          _selectedChurchId = churchId;
        });
      } else {
        // No church selected, show error
        setState(() {
          _errorMessage = 'Please select a church first';
        });
      }
    }
  }

  @override
  void dispose() {
    _menController.dispose();
    _womenController.dispose();
    _youthController.dispose();
    _childrenController.dispose();
    _sundayHomeChurchController.dispose();
    _titheController.dispose();
    _offeringsController.dispose();
    _emergencyCollectionController.dispose();
    _plannedCollectionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String? _validatePositiveInteger(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    final number = int.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (number < 0) {
      return 'Number must be positive';
    }

    return null;
  }

  String? _validatePositiveDecimal(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }

    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid amount';
    }

    if (number < 0) {
      return 'Amount must be positive';
    }

    return null;
  }

  Future<void> _saveRecord() async {
    // Clear previous error
    setState(() {
      _errorMessage = null;
    });

    // Check if church is selected
    if (_selectedChurchId == null) {
      setState(() {
        _errorMessage = 'Please select a church first';
      });
      return;
    }

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    AppDatabase? database;
    try {
      database = AppDatabase();
      final repository = WeeklyRecordRepository(database);

      // Check for duplicate week (only if creating new or date changed)
      if (widget.existingRecord == null ||
          widget.existingRecord!.weekStartDate != _selectedDate) {
        final isDuplicate = await repository.weekExists(
          _selectedChurchId!,
          _selectedDate,
        );

        if (isDuplicate) {
          setState(() {
            _errorMessage =
                'A record for this week already exists. Please choose a different date.';
            _isLoading = false;
          });
          return;
        }
      }

      // Create WeeklyRecord from form data
      final now = DateTime.now();

      // Get current admin ID
      final prefs = await SharedPreferences.getInstance();
      final adminDb = AppDatabase();
      final adminRepo = AdminUserRepository(adminDb);
      final profileService = AdminProfileService(adminRepo, prefs);
      final currentAdminId = profileService.getCurrentProfileId();
      await adminDb.close();

      final record = models.WeeklyRecord(
        id: widget.existingRecord?.id ?? 0, // 0 for new records
        churchId: _selectedChurchId!,
        createdByAdminId:
            widget.existingRecord?.createdByAdminId ?? currentAdminId,
        weekStartDate: _selectedDate,
        men: int.parse(_menController.text),
        women: int.parse(_womenController.text),
        youth: int.parse(_youthController.text),
        children: int.parse(_childrenController.text),
        sundayHomeChurch: int.parse(_sundayHomeChurchController.text),
        tithe: double.parse(_titheController.text),
        offerings: double.parse(_offeringsController.text),
        emergencyCollection: double.parse(_emergencyCollectionController.text),
        plannedCollection: double.parse(_plannedCollectionController.text),
        createdAt: widget.existingRecord?.createdAt ?? now,
        updatedAt: now,
      );

      // Save to database
      if (widget.existingRecord == null) {
        await repository.createRecord(record);
      } else {
        await repository.updateRecord(record);
      }

      // Show success and navigate back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingRecord == null
                  ? 'Weekly record saved successfully'
                  : 'Weekly record updated successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error saving record: ${e.toString()}';
        _isLoading = false;
      });
    } finally {
      // Always close database
      await database?.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingRecord == null
              ? 'New Weekly Entry'
              : 'Edit Weekly Entry',
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Error message display
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Date picker
                    Card(
                      child: ListTile(
                        title: const Text('Week Start Date'),
                        subtitle: Text(
                          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Attendance Section
                    Text(
                      'Attendance',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    _buildIntegerField(
                      controller: _menController,
                      label: 'Men',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 8),
                    _buildIntegerField(
                      controller: _womenController,
                      label: 'Women',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 8),
                    _buildIntegerField(
                      controller: _youthController,
                      label: 'Youth',
                      icon: Icons.group,
                    ),
                    const SizedBox(height: 8),
                    _buildIntegerField(
                      controller: _childrenController,
                      label: 'Children',
                      icon: Icons.child_care,
                    ),
                    const SizedBox(height: 8),
                    _buildIntegerField(
                      controller: _sundayHomeChurchController,
                      label: 'Sunday Home Church',
                      icon: Icons.home,
                    ),
                    const SizedBox(height: 24),

                    // Financial Section
                    Text(
                      'Financial Data',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    _buildDecimalField(
                      controller: _titheController,
                      label: 'Tithe',
                      icon: Icons.attach_money,
                    ),
                    const SizedBox(height: 8),
                    _buildDecimalField(
                      controller: _offeringsController,
                      label: 'Offerings',
                      icon: Icons.volunteer_activism,
                    ),
                    const SizedBox(height: 8),
                    _buildDecimalField(
                      controller: _emergencyCollectionController,
                      label: 'Emergency Collection',
                      icon: Icons.warning_amber,
                    ),
                    const SizedBox(height: 8),
                    _buildDecimalField(
                      controller: _plannedCollectionController,
                      label: 'Planned Collection',
                      icon: Icons.event_note,
                    ),
                    const SizedBox(height: 32),

                    // Save button
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _saveRecord,
                      icon: const Icon(Icons.save),
                      label: Text(
                        widget.existingRecord == null
                            ? 'Save Record'
                            : 'Update Record',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildIntegerField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      validator: _validatePositiveInteger,
    );
  }

  Widget _buildDecimalField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      validator: _validatePositiveDecimal,
    );
  }
}
