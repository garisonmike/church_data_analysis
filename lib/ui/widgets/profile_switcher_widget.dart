import 'package:church_analytics/models/admin_user.dart';
import 'package:church_analytics/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// AppBar chip showing the current admin profile. Tapping it opens the
/// profile selection screen (`/select-profile`) — the single real profile
/// management surface, with switch, create, edit, deactivate, and delete.
///
/// This widget used to carry its own "Switch Profile" and "Create New
/// Profile" dialogs. Since the selection screen was otherwise only reachable
/// through the startup gate, those dialogs were the only profile UI most
/// users ever saw — which made the screen's Edit/Deactivate/Delete features
/// effectively invisible (reported as "missing" in device testing despite
/// being implemented).
class ProfileSwitcherWidget extends ConsumerWidget {
  final int churchId;
  final AdminProfileService profileService;

  const ProfileSwitcherWidget({
    super.key,
    required this.churchId,
    required this.profileService,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

        final displayName = snapshot.data?.username ?? 'No Profile';

        return Tooltip(
          message: 'Switch or manage profiles',
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => Navigator.of(context)
                .pushNamed('/select-profile', arguments: churchId),
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
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 120),
                    child: Text(
                      displayName,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
