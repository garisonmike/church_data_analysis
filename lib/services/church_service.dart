import 'package:church_analytics/models/models.dart';
import 'package:church_analytics/repositories/repositories.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing church selection and operations
/// Handles current church state and provides church management functionality
class ChurchService {
  final ChurchRepository _churchRepository;
  final SharedPreferences _prefs;

  static const String _currentChurchIdKey = 'current_church_id';

  ChurchService(this._churchRepository, this._prefs);

  /// Get the ID of the currently selected church
  int? getCurrentChurchId() {
    return _prefs.getInt(_currentChurchIdKey);
  }

  /// Set the current church by ID
  /// Returns true if successful, false if church doesn't exist
  Future<bool> setCurrentChurchId(int churchId) async {
    // Verify the church exists before setting
    final church = await _churchRepository.getChurchById(churchId);
    if (church == null) {
      return false;
    }

    return await _prefs.setInt(_currentChurchIdKey, churchId);
  }

  /// Clear the current church selection
  Future<bool> clearCurrentChurch() async {
    return await _prefs.remove(_currentChurchIdKey);
  }

  /// Switch to a different church
  /// Validates the church exists before switching
  Future<void> switchChurch(int churchId) async {
    final church = await _churchRepository.getChurchById(churchId);
    if (church == null) {
      throw StateError('Church with ID $churchId not found');
    }

    final success = await setCurrentChurchId(churchId);
    if (!success) {
      throw StateError('Failed to switch to church');
    }
  }

  /// Get the currently selected church
  Future<Church?> getCurrentChurch() async {
    final churchId = getCurrentChurchId();
    if (churchId == null) return null;

    return await _churchRepository.getChurchById(churchId);
  }

  /// Get all available churches
  Future<List<Church>> getAllChurches() async {
    return await _churchRepository.getAllChurches();
  }

  /// Create a new church
  /// Returns the ID of the newly created church
  Future<int> createChurch(Church church) async {
    // Validate church before creating
    final validationError = church.validate();
    if (validationError != null) {
      throw ArgumentError(validationError);
    }

    return await _churchRepository.createChurch(church);
  }

  /// Update an existing church
  Future<bool> updateChurch(Church church) async {
    if (church.id == null) {
      throw ArgumentError('Church ID cannot be null for updates');
    }

    // Validate church before updating
    final validationError = church.validate();
    if (validationError != null) {
      throw ArgumentError(validationError);
    }

    return await _churchRepository.updateChurch(church);
  }

  /// Delete a church by ID
  /// Note: This may fail if there are related records (admins, weekly records, etc.)
  Future<int> deleteChurch(int churchId) async {
    // Check if this is the currently selected church
    if (getCurrentChurchId() == churchId) {
      await clearCurrentChurch();
    }

    return await _churchRepository.deleteChurch(churchId);
  }

  /// Search for churches by name
  Future<List<Church>> searchChurchesByName(String query) async {
    return await _churchRepository.searchChurchesByName(query);
  }

  /// Initialize the service
  /// If no church is selected, selects the first available church
  /// If no churches exist, returns false
  Future<bool> initialize() async {
    if (getCurrentChurchId() != null) {
      return true; // Already initialized
    }

    final churches = await getAllChurches();
    if (churches.isEmpty) {
      return false; // No churches available
    }

    // Select the first church by default
    await setCurrentChurchId(churches.first.id!);
    return true;
  }
}
