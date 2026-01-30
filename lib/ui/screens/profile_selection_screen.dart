import 'package:church_analytics/database/app_database.dart' as db;
import 'package:church_analytics/models/admin_user.dart';
import 'package:church_analytics/repositories/repositories.dart';
import 'package:church_analytics/services/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSelectionScreen extends StatefulWidget {
  final int churchId;

  const ProfileSelectionScreen({super.key, required this.churchId});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  bool _loading = true;
  Object? _error;
  List<AdminUser> _profiles = const [];

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
      final database = db.AppDatabase();
      try {
        final repo = AdminUserRepository(database);
        final profiles = await repo.getActiveUsersByChurch(widget.churchId);
        if (mounted) {
          setState(() {
            _profiles = profiles;
          });
        }
      } finally {
        await database.close();
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

  Future<void> _selectProfile(AdminUser profile) async {
    if (profile.id == null) return;

    final navigator = Navigator.of(context);

    final prefs = await SharedPreferences.getInstance();
    final database = db.AppDatabase();
    try {
      final service = AdminProfileService(AdminUserRepository(database), prefs);
      final ok = await service.switchProfile(profile.id!);
      if (!ok) {
        throw StateError('Failed to switch profile');
      }

      if (!mounted) return;
      navigator.pushReplacementNamed('/');
    } finally {
      await database.close();
    }
  }

  Future<void> _createProfile() async {
    final usernameController = TextEditingController();
    final fullNameController = TextEditingController();
    final emailController = TextEditingController();

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final shouldCreate = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Admin Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username *',
                  hintText: '3-50 characters',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
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

    try {
      final prefs = await SharedPreferences.getInstance();
      final database = db.AppDatabase();
      try {
        final service = AdminProfileService(
          AdminUserRepository(database),
          prefs,
        );
        await service.createProfile(
          username: usernameController.text.trim(),
          fullName: fullNameController.text.trim(),
          email: emailController.text.trim().isEmpty
              ? null
              : emailController.text.trim(),
          churchId: widget.churchId,
          setAsActive: true,
        );
      } finally {
        await database.close();
      }

      if (!mounted) return;
      await _load();
      if (!mounted) return;
      navigator.pushReplacementNamed('/');
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Error creating profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Profile'),
        actions: [
          IconButton(
            tooltip: 'Create profile',
            onPressed: _createProfile,
            icon: const Icon(Icons.person_add),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : _profiles.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'No admin profiles found. Create one to continue.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: _createProfile,
                      icon: const Icon(Icons.person_add),
                      label: const Text('Create Profile'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              itemCount: _profiles.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final profile = _profiles[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      profile.username.isNotEmpty
                          ? profile.username[0].toUpperCase()
                          : '?',
                    ),
                  ),
                  title: Text(profile.username),
                  subtitle: profile.fullName.isEmpty
                      ? null
                      : Text(profile.fullName),
                  onTap: () => _selectProfile(profile),
                );
              },
            ),
    );
  }
}
