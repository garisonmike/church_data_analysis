import 'package:church_analytics/database/app_database.dart';
import 'package:church_analytics/models/models.dart';
import 'package:church_analytics/repositories/repositories.dart';
import 'package:church_analytics/services/services.dart';
import 'package:flutter/material.dart';
import 'package:church_analytics/ui/screens/home_church_screen.dart';
import 'package:church_analytics/ui/widgets/currency_picker_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Screen for viewing and editing church settings
class ChurchSettingsScreen extends ConsumerStatefulWidget {
  final int churchId;

  const ChurchSettingsScreen({super.key, required this.churchId});

  @override
  ConsumerState<ChurchSettingsScreen> createState() =>
      _ChurchSettingsScreenState();
}

class _ChurchSettingsScreenState extends ConsumerState<ChurchSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  ChurchService? _churchService;
  Church? _church;
  bool _isLoading = true;
  bool _isSaving = false;

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  // Currency is a picked ISO 4217 code, not free text (U2/U3).
  String? _selectedCurrency;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _initializeService();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _initializeService() async {
    final prefs = await SharedPreferences.getInstance();
    final db = ref.read(databaseProvider);
    final churchRepo = ChurchRepository(db);

    setState(() {
      _churchService = ChurchService(churchRepo, prefs);
    });

    await _loadChurch();
  }

  Future<void> _loadChurch() async {
    if (_churchService == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final church = await _churchService!.getAllChurches().then(
        (churches) => churches.firstWhere((c) => c.id == widget.churchId),
      );

      setState(() {
        _church = church;
        _nameController.text = church.name;
        _addressController.text = church.address ?? '';
        _emailController.text = church.contactEmail ?? '';
        _phoneController.text = church.contactPhone ?? '';
        _selectedCurrency = church.currency;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading church: $e')));
      }
    }
  }

  Future<void> _saveChurch() async {
    if (!_formKey.currentState!.validate() ||
        _churchService == null ||
        _church == null) {
      return;
    }

    if (_selectedCurrency == null || _selectedCurrency!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a currency.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedChurch = _church!.copyWith(
        name: _nameController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        contactEmail: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        contactPhone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        currency: _selectedCurrency!,
        updatedAt: DateTime.now(),
      );

      await _churchService!.updateChurch(updatedChurch);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Church settings saved successfully')),
        );
        Navigator.of(
          context,
        ).pop(true); // Return true to indicate changes were saved
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving church: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Church Settings'),
        actions: [
          if (!_isLoading && !_isSaving)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveChurch,
              tooltip: 'Save Changes',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Church Name
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Church Name *',
                        hintText: 'Enter church name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.church),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Church name is required';
                        }
                        if (value.trim().length > 200) {
                          return 'Church name cannot exceed 200 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Address
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        hintText: 'Enter church address',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // Contact Email
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Email',
                        hintText: 'Enter contact email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          final emailRegex = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );
                          if (!emailRegex.hasMatch(value.trim())) {
                            return 'Invalid email format';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Contact Phone
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Phone',
                        hintText: 'Enter contact phone',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    // Currency
                    CurrencyPickerField(
                      value: _selectedCurrency,
                      onChanged: (code) =>
                          setState(() => _selectedCurrency = code),
                    ),
                    const SizedBox(height: 24),

                    // Metadata
                    if (_church != null) ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Church Information',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                'Church ID',
                                _church!.id.toString(),
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                'Created',
                                _formatDateTime(_church!.createdAt),
                              ),
                              const SizedBox(height: 8),
                              _buildInfoRow(
                                'Last Updated',
                                _formatDateTime(_church!.updatedAt),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Home Churches management link
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.home_work_outlined),
                        title: const Text('Home Churches'),
                        subtitle: const Text('Manage sub-congregations and ministry groups'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeChurchScreen()),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Switch Church — reaches the church selector, which is
                    // otherwise only pushed automatically at first launch.
                    Card(
                      child: ListTile(
                        key: const ValueKey('switch_church_tile'),
                        leading: const Icon(Icons.swap_horiz),
                        title: const Text('Switch Church'),
                        subtitle: const Text(
                          'Select a different church or create a new one',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            Navigator.of(context).pushNamed('/select-church'),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Save Button (large)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveChurch,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(flex: 3, child: Text(value)),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
