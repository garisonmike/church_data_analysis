import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/dashboard_config.dart';
import 'settings_service.dart';

const String _dashboardConfigKey = 'dashboard_config';

class DashboardConfigService {
  final SharedPreferences _prefs;

  DashboardConfigService(this._prefs);

  DashboardConfig loadConfig() {
    final configJson = _prefs.getString(_dashboardConfigKey);
    if (configJson != null) {
      try {
        final Map<String, dynamic> jsonMap = json.decode(configJson);
        return DashboardConfig.fromJson(jsonMap);
      } catch (e) {
        return DashboardConfig.defaults();
      }
    }
    return DashboardConfig.defaults();
  }

  Future<void> saveConfig(DashboardConfig config) async {
    final configJson = json.encode(config.toJson());
    await _prefs.setString(_dashboardConfigKey, configJson);
  }

  Future<void> resetConfig() async {
    await _prefs.remove(_dashboardConfigKey);
  }
}

final dashboardConfigServiceProvider = Provider<DashboardConfigService>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return DashboardConfigService(prefs);
});

class DashboardConfigNotifier extends StateNotifier<DashboardConfig> {
  final DashboardConfigService _service;

  DashboardConfigNotifier(this._service) : super(_service.loadConfig());

  Future<void> setSectionVisibility(
    DashboardSection section,
    bool isVisible,
  ) async {
    final updatedVisibility = {...state.visibility, section: isVisible};
    final updated = state.copyWith(visibility: updatedVisibility);
    await _service.saveConfig(updated);
    state = updated;
  }

  Future<void> setSectionOrder(List<DashboardSection> order) async {
    final updated = state.copyWith(order: order);
    await _service.saveConfig(updated);
    state = updated;
  }

  Future<void> resetToDefaults() async {
    await _service.resetConfig();
    state = DashboardConfig.defaults();
  }
}

final dashboardConfigProvider =
    StateNotifierProvider<DashboardConfigNotifier, DashboardConfig>((ref) {
      final service = ref.read(dashboardConfigServiceProvider);
      return DashboardConfigNotifier(service);
    });
