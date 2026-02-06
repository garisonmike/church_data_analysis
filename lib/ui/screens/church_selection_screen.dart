import 'package:church_analytics/database/app_database.dart' as db;
import 'package:church_analytics/models/church.dart';
import 'package:church_analytics/repositories/repositories.dart';
import 'package:church_analytics/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChurchSelectionScreen extends ConsumerStatefulWidget {
  const ChurchSelectionScreen({super.key});

  @override
  ConsumerState<ChurchSelectionScreen> createState() =>
      _ChurchSelectionScreenState();
}

class _ChurchSelectionScreenState extends ConsumerState<ChurchSelectionScreen> {
  bool _loading = true;
  Object? _error;
  List<Church> _churches = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final database = ref.read(db.databaseProvider);
      final repo = ChurchRepository(database);
      final churches = await repo.getAllChurches();
      if (mounted) {
        setState(() {
          _churches = churches;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _selectChurch(Church church) async {
    if (church.id == null) return;

    final navigator = Navigator.of(context);

    final prefs = await SharedPreferences.getInstance();
    final database = ref.read(db.databaseProvider);
    final churchService = ChurchService(ChurchRepository(database), prefs);
    final ok = await churchService.setCurrentChurchId(church.id!);
    if (!ok) {
      throw StateError('Failed to select church');
    }

    if (!mounted) return;
    navigator.pushReplacementNamed('/');
  }

  Future<void> createChurch() async {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final currencyController = TextEditingController(text: 'USD');

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final shouldCreate = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Church'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Church Name *',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Contact Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Contact Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: currencyController,
                decoration: const InputDecoration(
                  labelText: 'Currency',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (shouldCreate != true) return;

    final now = DateTime.now();
    final church = Church(
      name: nameController.text.trim(),
      address: addressController.text.trim().isEmpty
          ? null
          : addressController.text.trim(),
      contactEmail: emailController.text.trim().isEmpty
          ? null
          : emailController.text.trim(),
      contactPhone: phoneController.text.trim().isEmpty
          ? null
          : phoneController.text.trim(),
      currency: currencyController.text.trim().isEmpty
          ? 'USD'
          : currencyController.text.trim(),
      createdAt: now,
      updatedAt: now,
    );

    final validationError = church.validate();
    if (validationError != null) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(validationError), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final database = ref.read(db.databaseProvider);
      final churchService = ChurchService(ChurchRepository(database), prefs);
      final newId = await churchService.createChurch(church);
      await churchService.setCurrentChurchId(newId);

      if (!mounted) return;
      await _load();
      if (!mounted) return;
      navigator.pushReplacementNamed('/');
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Error creating church: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Church'),
        actions: [
          IconButton(
            tooltip: 'Create church',
            onPressed: createChurch,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : _churches.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'No churches found. Create one to continue.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: createChurch,
                      icon: const Icon(Icons.add),
                      label: const Text('Create Church'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              itemCount: _churches.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final church = _churches[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      church.name.isNotEmpty
                          ? church.name[0].toUpperCase()
                          : '?',
                    ),
                  ),
                  title: Text(church.name),
                  subtitle: church.address == null
                      ? null
                      : Text(church.address!),
                  onTap: () => _selectChurch(church),
                );
              },
            ),
    );
  }
}
