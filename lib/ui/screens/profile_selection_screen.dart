import 'package:church_analytics/database/app_database.dart' as db;
import 'package:church_analytics/models/admin_user.dart';
import 'package:church_analytics/repositories/repositories.dart';
import 'package:church_analytics/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileSelectionScreen extends ConsumerStatefulWidget {
  final int churchId;

  const ProfileSelectionScreen({super.key, required this.churchId});

  @override
  ConsumerState<ProfileSelectionScreen> createState() =>
      _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState
    extends ConsumerState<ProfileSelectionScreen> {
  bool _loading = true;
  Object? _error;
  List<AdminUser> _profiles = const [];
  // The profile currently in use, if any. Like the church switcher, the
  // active profile can't be deleted from here — switch away first.
  int? _currentProfileId;

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
      final repo = AdminUserRepository(database);
      final service = AdminProfileService(repo, prefs);
      final profiles = await repo.getActiveUsersByChurch(widget.churchId);
      final currentId = service.getCurrentProfileId();
      if (mounted) {
        setState(() {
          _profiles = profiles;
          _currentProfileId = currentId;
        });
      }
    } catch (e, stack) {
      LogService.error(
        'ProfileSelectionScreen',
        'Failed to load profiles',
        error: e,
        stackTrace: stack,
      );
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

    // Capture context-dependent objects before any awaits
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // If this profile has a PIN, prompt for it
    if (profile.pinHash != null) {
      final enteredPin = await _showPinDialog(context, profile.username);
      if (enteredPin == null) return; // User cancelled

      final database = ref.read(db.databaseProvider);
      final repo = AdminUserRepository(database);
      final prefs = await SharedPreferences.getInstance();
      final service = AdminProfileService(repo, prefs);

      final valid = await service.verifyPin(profile.id!, enteredPin);
      if (!valid) {
        if (mounted) {
          messenger.showSnackBar(
            const SnackBar(content: Text('Incorrect PIN. Try again.')),
          );
        }
        return;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final database = ref.read(db.databaseProvider);
    final service = AdminProfileService(AdminUserRepository(database), prefs);
    final ok = await service.switchProfile(profile.id!);
    if (!ok) {
      // Surface the failure to the user instead of throwing an uncaught
      // async error (U1 — no raw exceptions to the user).
      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Could not switch to that profile. Try again.'),
          ),
        );
      }
      return;
    }

    if (!mounted) return;
    // Clear the whole stack: this screen is reachable both from the startup
    // gate (stack of one) and mid-session from the dashboard's profile chip;
    // in the latter case a pushReplacement would leave the previous
    // profile's dashboard underneath the new one.
    navigator.pushNamedAndRemoveUntil('/', (route) => false);
  }

  /// Shows a PIN entry dialog. Returns the entered PIN string or null on cancel.
  Future<String?> _showPinDialog(BuildContext context, String username) async {
    final pinController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Enter PIN for $username'),
        content: TextField(
          controller: pinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          maxLength: 4,
          decoration: const InputDecoration(
            labelText: 'PIN',
            hintText: '••••',
            border: OutlineInputBorder(),
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(pinController.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        // NOTE: no LayoutBuilder here — AlertDialog measures its content via
        // IntrinsicWidth, and LayoutBuilder cannot report intrinsics (debug
        // builds assert and the dialog renders as a dimmed empty barrier).
        // AlertDialog already height-limits its content; the scroll view
        // handles overflow.
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            child: FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
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
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => Navigator.of(context).pop(true),
                  ),
                ],
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

    try {
      final prefs = await SharedPreferences.getInstance();
      final database = ref.read(db.databaseProvider);
      final service = AdminProfileService(AdminUserRepository(database), prefs);
      await service.createProfile(
        username: usernameController.text.trim(),
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim().isEmpty
            ? null
            : emailController.text.trim(),
        churchId: widget.churchId,
        setAsActive: true,
      );

      if (!mounted) return;
      await _load();
      if (!mounted) return;
      // Same stack reset as _selectProfile — see comment there.
      navigator.pushNamedAndRemoveUntil('/', (route) => false);
    } on DuplicateUsernameException {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('That username is already taken — choose another.'),
        ),
      );
    } on ProfileValidationException catch (e) {
      // Validation messages are already phrased for end users.
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e, stack) {
      // Plain-language message for the user; full detail goes to App Logs
      // (U1 — no raw exceptions in user-facing error surfaces).
      LogService.error(
        'ProfileSelectionScreen',
        'Profile creation failed',
        error: e,
        stackTrace: stack,
      );
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not create the profile. Please try again.'),
        ),
      );
    }
  }

  Future<void> _editProfile(AdminUser profile) async {
    final usernameController = TextEditingController(text: profile.username);
    final fullNameController = TextEditingController(text: profile.fullName);
    final emailController = TextEditingController(text: profile.email ?? '');

    final messenger = ScaffoldMessenger.of(context);

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        // See note on the create dialog: LayoutBuilder breaks AlertDialog's
        // intrinsic measurement.
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            child: FocusTraversalGroup(
              policy: OrderedTraversalPolicy(),
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
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: fullNameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name *',
                      border: OutlineInputBorder(),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => Navigator.of(context).pop(true),
                  ),
                ],
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
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (shouldSave != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final database = ref.read(db.databaseProvider);
      final service = AdminProfileService(AdminUserRepository(database), prefs);
      // Built directly rather than via copyWith so a cleared email actually
      // becomes null instead of silently keeping the old value.
      final email = emailController.text.trim();
      await service.updateProfile(
        AdminUser(
          id: profile.id,
          username: usernameController.text.trim(),
          fullName: fullNameController.text.trim(),
          email: email.isEmpty ? null : email,
          churchId: profile.churchId,
          isActive: profile.isActive,
          createdAt: profile.createdAt,
          lastLoginAt: profile.lastLoginAt,
          pinHash: profile.pinHash,
        ),
      );

      if (!mounted) return;
      await _load();
      if (!mounted) return;
      messenger.showSnackBar(const SnackBar(content: Text('Profile updated')));
    } on DuplicateUsernameException {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('That username is already taken — choose another.'),
        ),
      );
    } on ProfileValidationException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e, stack) {
      LogService.error(
        'ProfileSelectionScreen',
        'Profile update failed',
        error: e,
        stackTrace: stack,
      );
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not update the profile. Please try again.'),
        ),
      );
    }
  }

  Future<void> _deactivateProfile(AdminUser profile) async {
    if (profile.id == null) return;

    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Deactivate "${profile.username}"?'),
        content: const Text(
          'A deactivated admin can no longer log in or be selected as a '
          'profile, but everything they entered is preserved — records keep '
          'showing who created them.\n\n'
          'Use this to retire admins who have entered records (deletion is '
          'blocked for them to protect that history).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final database = ref.read(db.databaseProvider);
      final service = AdminProfileService(AdminUserRepository(database), prefs);
      await service.deactivateProfile(profile.id!);
      if (!mounted) return;
      await _load();
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Deactivated "${profile.username}"')),
      );
    } catch (e, stack) {
      LogService.error(
        'ProfileSelectionScreen',
        'Profile deactivation failed',
        error: e,
        stackTrace: stack,
      );
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not deactivate the profile. Please try again.'),
        ),
      );
    }
  }

  Future<void> _deleteProfile(AdminUser profile) async {
    if (profile.id == null) return;

    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete "${profile.username}"?'),
        content: const Text(
          'This permanently deletes the profile.\n\n'
          'Profiles that have entered weekly records or events cannot be '
          'deleted — the record of who entered the data is kept for '
          'accountability. Use Deactivate for those instead.\n\n'
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
      final database = ref.read(db.databaseProvider);
      final service = AdminProfileService(AdminUserRepository(database), prefs);
      await service.deleteProfile(profile.id!);
      if (!mounted) return;
      await _load();
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Deleted "${profile.username}"')),
      );
    } on ProfileHasRecordsException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'This admin has entered ${e.recordCount} record(s) and can\'t be '
            'deleted. Deactivate them instead from the profile menu.',
          ),
        ),
      );
    } catch (e, stack) {
      LogService.error(
        'ProfileSelectionScreen',
        'Profile deletion failed',
        error: e,
        stackTrace: stack,
      );
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not delete the profile. Please try again.'),
        ),
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
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Could not load profiles.'),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            )
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
                final isCurrent = profile.id == _currentProfileId;
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
                      ? (isCurrent ? const Text('Currently in use') : null)
                      : Text(
                          isCurrent
                              ? '${profile.fullName} • Currently in use'
                              : profile.fullName,
                        ),
                  trailing: PopupMenuButton<String>(
                    tooltip: 'Profile actions',
                    onSelected: (value) {
                      if (value == 'edit') _editProfile(profile);
                      if (value == 'deactivate') _deactivateProfile(profile);
                      if (value == 'delete') _deleteProfile(profile);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Edit profile'),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'deactivate',
                        // The active profile can't be deactivated from here;
                        // switch to another profile first — same guardrail
                        // as delete.
                        enabled: !isCurrent,
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            Icons.person_off_outlined,
                            color: isCurrent
                                ? Theme.of(context).disabledColor
                                : null,
                          ),
                          title: Text(
                            isCurrent ? 'Deactivate (in use)' : 'Deactivate',
                          ),
                        ),
                      ),
                      PopupMenuItem<String>(
                        value: 'delete',
                        // The active profile can't be deleted from here;
                        // switch to another profile first.
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
                            isCurrent ? 'Delete (in use)' : 'Delete profile',
                          ),
                        ),
                      ),
                    ],
                  ),
                  onTap: () => _selectProfile(profile),
                );
              },
            ),
    );
  }
}
