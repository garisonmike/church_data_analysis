import 'package:church_analytics/database/app_database.dart' as db;
import 'package:church_analytics/models/admin_user.dart';
import 'package:church_analytics/repositories/repositories.dart';
import 'package:church_analytics/services/services.dart';
import 'package:flutter/material.dart';

/// A widget that displays the current admin profile and allows switching between profiles
class ProfileSwitcherWidget extends StatelessWidget {
  final int churchId;
  final AdminProfileService profileService;
  final VoidCallback? onProfileChanged;

  const ProfileSwitcherWidget({
    super.key,
    required this.churchId,
    required this.profileService,
    this.onProfileChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AdminUser?>(
      future: profileService.getCurrentProfile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final currentProfile = snapshot.data;
        final displayName = currentProfile?.username ?? 'No Profile';

        return PopupMenuButton<String>(
          tooltip: 'Switch Profile',
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    displayName[0].toUpperCase(),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(Icons.arrow_drop_down, size: 20),
              ],
            ),
          ),
          onSelected: (value) async {
            if (value == 'switch') {
              await _showProfileSelectionDialog(context);
            } else if (value == 'create') {
              await _showCreateProfileDialog(context);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'switch',
              child: Row(
                children: [
                  Icon(Icons.switch_account),
                  SizedBox(width: 8),
                  Text('Switch Profile'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'create',
              child: Row(
                children: [
                  Icon(Icons.person_add),
                  SizedBox(width: 8),
                  Text('Create New Profile'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showProfileSelectionDialog(BuildContext context) async {
    final database = db.AppDatabase();
    final repository = AdminUserRepository(database);
    final profiles = await repository.getActiveUsersByChurch(churchId);
    await database.close();

    if (!context.mounted) return;

    final currentProfileId = profileService.getCurrentProfileId();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Switch Profile'),
        content: SizedBox(
          width: double.maxFinite,
          child: profiles.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No profiles available'),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: profiles.length,
                  itemBuilder: (context, index) {
                    final profile = profiles[index];
                    final isCurrentProfile = profile.id == currentProfileId;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isCurrentProfile
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey[300],
                        child: Text(
                          profile.username[0].toUpperCase(),
                          style: TextStyle(
                            color: isCurrentProfile
                                ? Theme.of(context).colorScheme.onPrimary
                                : Colors.grey[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(profile.username),
                      subtitle: profile.fullName.isNotEmpty
                          ? Text(profile.fullName)
                          : null,
                      trailing: isCurrentProfile
                          ? Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () async {
                        if (!isCurrentProfile) {
                          try {
                            await profileService.switchProfile(profile.id!);
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Switched to ${profile.username}',
                                  ),
                                ),
                              );
                              onProfileChanged?.call();
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error switching profile: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        } else {
                          Navigator.pop(context);
                        }
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateProfileDialog(BuildContext context) async {
    final usernameController = TextEditingController();
    final fullNameController = TextEditingController();
    final emailController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'Enter username (3-50 characters)',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter full name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email (optional)',
                  hintText: 'Enter email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final username = usernameController.text.trim();
              final fullName = fullNameController.text.trim();
              final email = emailController.text.trim();

              if (username.isEmpty || fullName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Username and full name are required'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              try {
                await profileService.createProfile(
                  username: username,
                  fullName: fullName,
                  email: email.isEmpty ? null : email,
                  churchId: churchId,
                  setAsActive: true,
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Profile "$username" created')),
                  );
                  onProfileChanged?.call();
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error creating profile: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    usernameController.dispose();
    fullNameController.dispose();
    emailController.dispose();
  }
}
