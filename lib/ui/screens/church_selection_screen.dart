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
  // The church currently in use, if any. Deletion of the active church is
  // blocked from here — the user must switch away first — to avoid tearing
  // the ground out from under the running session.
  int? _currentChurchId;

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
      final prefs = await SharedPreferences.getInstance();
      final database = ref.read(db.databaseProvider);
      final repo = ChurchRepository(database);
      final churchService = ChurchService(repo, prefs);
      final churches = await repo.getAllChurches();
      final currentId = churchService.getCurrentChurchId();
      if (mounted) {
        setState(() {
          _churches = churches;
          _currentChurchId = currentId;
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
    // Clear the whole stack, not just this screen: when reached mid-session
    // (Dashboard → Church Settings → Switch Church) a pushReplacement would
    // leave the previous church's screens underneath the new dashboard, so
    // pressing back walked into stale data. On first launch the stack is just
    // this selector, so clearing it loses nothing.
    navigator.pushNamedAndRemoveUntil('/', (route) => false);
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
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        content: LayoutBuilder(
          builder: (context, constraints) => ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: constraints.maxHeight * 0.8,
              maxWidth: 560,
            ),
            child: SingleChildScrollView(
              child: FocusTraversalGroup(
                policy: OrderedTraversalPolicy(),
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
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        labelText: 'Address',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Contact Phone',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: currencyController,
                      decoration: const InputDecoration(
                        labelText: 'Currency',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => Navigator.of(context).pop(true),
                    ),
                  ],
                ),
              ),
            ),
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
      // Same stack reset as _selectChurch — see comment there.
      navigator.pushNamedAndRemoveUntil('/', (route) => false);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Error creating church: $e')),
      );
    }
  }

  Future<void> _deleteChurch(Church church) async {
    if (church.id == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final database = ref.read(db.databaseProvider);

    // Show the user exactly what will be removed before they commit — a
    // church delete cascades to its admins, weekly records, and events.
    final recordCount =
        (await WeeklyRecordRepository(database).getRecordsByChurch(church.id!))
            .length;
    final adminCount =
        (await AdminUserRepository(database).getUsersByChurch(church.id!))
            .length;
    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${church.name}"?'),
        content: Text(
          'This permanently deletes the church and everything under it:\n\n'
          '• $recordCount weekly record(s)\n'
          '• $adminCount admin account(s)\n'
          '• all board meetings, holy communion, business meeting, and home '
          'church data\n\n'
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final churchService = ChurchService(ChurchRepository(database), prefs);
      await churchService.deleteChurch(church.id!);
      if (!mounted) return;
      await _load();
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Deleted "${church.name}"')),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Could not delete church: $e')),
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
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      key: const ValueKey('import_backup_button'),
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/restore-backup'),
                      icon: const Icon(Icons.restore_page_outlined),
                      label: const Text('Import Backup'),
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
                final isCurrent = church.id == _currentChurchId;
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
                      ? (isCurrent ? const Text('Currently in use') : null)
                      : Text(
                          isCurrent
                              ? '${church.address!} • Currently in use'
                              : church.address!,
                        ),
                  trailing: PopupMenuButton<String>(
                    tooltip: 'Church actions',
                    onSelected: (value) {
                      if (value == 'delete') _deleteChurch(church);
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'delete',
                        // The active church can't be deleted from here; switch
                        // to another church first.
                        enabled: !isCurrent,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.delete_outline,
                            color: isCurrent
                                ? Theme.of(context).disabledColor
                                : Theme.of(context).colorScheme.error,
                          ),
                          title: Text(
                            isCurrent ? 'Delete (in use)' : 'Delete church',
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () => _selectChurch(church),
                );
              },
            ),
    );
  }
}
