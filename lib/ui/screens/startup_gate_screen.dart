import 'package:church_analytics/database/app_database.dart';
import 'package:church_analytics/repositories/repositories.dart';
import 'package:church_analytics/services/services.dart';
import 'package:church_analytics/ui/screens/log_viewer_screen.dart';
import 'package:church_analytics/ui/widgets/onboarding_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Startup gate that enforces required context (church + admin profile)
/// before allowing the user into the dashboard.
class StartupGateScreen extends ConsumerStatefulWidget {
  const StartupGateScreen({super.key});

  @override
  ConsumerState<StartupGateScreen> createState() => _StartupGateScreenState();
}

class _StartupGateScreenState extends ConsumerState<StartupGateScreen> {
  Object? _error;
  bool _navigationInProgress = false;

  @override
  void initState() {
    super.initState();
    _routeFromState();
    // After first frame: check for crash, then show onboarding on first launch.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (_navigationInProgress) return;
      await showCrashRecoveryDialogIfNeeded(context);
      if (!mounted) return;
      if (_navigationInProgress) return;
      final done = await isOnboardingComplete();
      if (!done && mounted && !_navigationInProgress) {
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (_) => const OnboardingOverlay(),
          ),
        );
      }
    });
  }

  Future<void> _routeFromState() async {
    try {
      _navigationInProgress = true;
      final prefs = await SharedPreferences.getInstance();
      final db = ref.read(databaseProvider);
      final churchRepo = ChurchRepository(db);
      final adminRepo = AdminUserRepository(db);

      final churchService = ChurchService(churchRepo, prefs);
      final profileService = AdminProfileService(adminRepo, prefs);

      final churches = await churchRepo.getAllChurches();
      if (churches.isEmpty) {
        await churchService.clearCurrentChurch();
        await profileService.clearCurrentProfile();
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/select-church');
        return;
      }

      final currentChurchId = churchService.getCurrentChurchId();
      if (currentChurchId == null) {
        await churchService.clearCurrentChurch();
        await profileService.clearCurrentProfile();
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/select-church');
        return;
      }

      final currentChurchExists = churches.any((c) => c.id == currentChurchId);
      if (!currentChurchExists) {
        await churchService.clearCurrentChurch();
        await profileService.clearCurrentProfile();
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/select-church');
        return;
      }

      final churchId = currentChurchId;

      // Admin profile must exist, be active, and belong to the selected church.
      final currentProfileId = profileService.getCurrentProfileId();
      if (currentProfileId == null) {
        if (!mounted) return;
        Navigator.of(
          context,
        ).pushReplacementNamed('/select-profile', arguments: churchId);
        return;
      }

      final currentProfile = await adminRepo.getUserById(currentProfileId);
      final validProfile =
          currentProfile != null &&
          currentProfile.isActive &&
          currentProfile.churchId == churchId;

      if (!validProfile) {
        await profileService.clearCurrentProfile();
        if (!mounted) return;
        Navigator.of(
          context,
        ).pushReplacementNamed('/select-profile', arguments: churchId);
        return;
      }

      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacementNamed('/dashboard', arguments: churchId);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Startup')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Unable to start the app.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(_error.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _error = null);
                    _routeFromState();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const Scaffold(
      body: Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 3),
        ),
      ),
    );
  }
}
