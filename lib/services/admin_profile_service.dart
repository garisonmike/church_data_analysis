import 'package:church_analytics/models/models.dart';
import 'package:church_analytics/repositories/repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing admin profile state and operations
class AdminProfileService {
  static const String _currentProfileIdKey = 'current_admin_profile_id';
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';

  final AdminUserRepository _repository;
  final SharedPreferences _prefs;

  AdminProfileService(this._repository, this._prefs);

  /// Gets the currently active admin profile ID
  int? getCurrentProfileId() {
    return _prefs.getInt(_currentProfileIdKey);
  }

  /// Sets the currently active admin profile ID
  Future<bool> setCurrentProfileId(int profileId) async {
    return await _prefs.setInt(_currentProfileIdKey, profileId);
  }

  /// Clears the currently active admin profile
  Future<bool> clearCurrentProfile() async {
    return await _prefs.remove(_currentProfileIdKey);
  }

  /// Gets the currently active admin profile
  Future<AdminUser?> getCurrentProfile() async {
    final profileId = getCurrentProfileId();
    if (profileId == null) return null;

    return await _repository.getUserById(profileId);
  }

  /// Switches to a different admin profile
  Future<bool> switchProfile(int profileId) async {
    final profile = await _repository.getUserById(profileId);
    if (profile == null || !profile.isActive) {
      return false;
    }

    // Update last login time
    await _repository.updateLastLogin(profileId);

    // Set as current profile
    return await setCurrentProfileId(profileId);
  }

  /// Creates a new admin profile and optionally sets it as active
  Future<int?> createProfile({
    required String username,
    required String fullName,
    String? email,
    required int churchId,
    bool setAsActive = true,
  }) async {
    // Validate that username doesn't already exist
    final existing = await _repository.getUserByUsername(username);
    if (existing != null) {
      throw Exception('Username already exists');
    }

    final now = DateTime.now();
    final newProfile = AdminUser(
      username: username,
      fullName: fullName,
      email: email,
      churchId: churchId,
      isActive: true,
      createdAt: now,
      lastLoginAt: now,
    );

    // Validate the profile
    final validationError = newProfile.validate();
    if (validationError != null) {
      throw Exception(validationError);
    }

    // Create the profile
    final profileId = await _repository.createUser(newProfile);

    // Set as active if requested
    if (setAsActive) {
      await setCurrentProfileId(profileId);
    }

    return profileId;
  }

  /// Gets all admin profiles for a church
  Future<List<AdminUser>> getProfilesByChurch(int churchId) async {
    return await _repository.getUsersByChurch(churchId);
  }

  /// Gets all active admin profiles for a church
  Future<List<AdminUser>> getActiveProfilesByChurch(int churchId) async {
    return await _repository.getActiveUsersByChurch(churchId);
  }

  /// Updates an admin profile
  Future<bool> updateProfile(AdminUser profile) async {
    final validationError = profile.validate();
    if (validationError != null) {
      throw Exception(validationError);
    }

    return await _repository.updateUser(profile);
  }

  /// Deactivates an admin profile
  Future<bool> deactivateProfile(int profileId) async {
    // Don't allow deactivating the current profile if it's the last active one
    final currentId = getCurrentProfileId();
    if (currentId == profileId) {
      final profile = await _repository.getUserById(profileId);
      if (profile != null) {
        final activeProfiles = await _repository.getActiveUsersByChurch(
          profile.churchId,
        );
        if (activeProfiles.length <= 1) {
          throw Exception(
            'Cannot deactivate the last active profile for this church',
          );
        }

        // Clear current profile if deactivating it
        await clearCurrentProfile();
      }
    }

    return await _repository.deactivateUser(profileId);
  }

  /// Activates an admin profile
  Future<bool> activateProfile(int profileId) async {
    return await _repository.activateUser(profileId);
  }

  /// Deletes an admin profile (hard delete)
  Future<bool> deleteProfile(int profileId) async {
    // Don't allow deleting the current profile if it's the last one
    final currentId = getCurrentProfileId();
    if (currentId == profileId) {
      final profile = await _repository.getUserById(profileId);
      if (profile != null) {
        final allProfiles = await _repository.getUsersByChurch(
          profile.churchId,
        );
        if (allProfiles.length <= 1) {
          throw Exception('Cannot delete the last profile for this church');
        }

        // Clear current profile if deleting it
        await clearCurrentProfile();
      }
    }

    final result = await _repository.deleteUser(profileId);
    return result > 0;
  }

  /// Checks if user has seen the onboarding
  bool hasSeenOnboarding() {
    return _prefs.getBool(_hasSeenOnboardingKey) ?? false;
  }

  /// Marks onboarding as seen
  Future<bool> markOnboardingAsSeen() async {
    return await _prefs.setBool(_hasSeenOnboardingKey, true);
  }

  /// Checks if any profiles exist for a church
  Future<bool> hasProfiles(int churchId) async {
    final profiles = await _repository.getUsersByChurch(churchId);
    return profiles.isNotEmpty;
  }

  /// Gets the default church ID (from current profile or first available)
  Future<int?> getDefaultChurchId() async {
    final profile = await getCurrentProfile();
    if (profile != null) {
      return profile.churchId;
    }

    // If no current profile, try to get any profile
    // This would require a church repository to get first church
    return null;
  }

  /// Initialize: Ensures at least one profile exists
  Future<void> initialize(int churchId) async {
    final profiles = await _repository.getUsersByChurch(churchId);

    if (profiles.isEmpty) {
      // Create a default profile
      await createProfile(
        username: 'admin',
        fullName: 'Default Admin',
        churchId: churchId,
        setAsActive: true,
      );
    } else if (getCurrentProfileId() == null) {
      // Set first active profile as current
      final activeProfile = profiles.firstWhere(
        (p) => p.isActive,
        orElse: () => profiles.first,
      );
      await setCurrentProfileId(activeProfile.id!);
    }
  }
}
