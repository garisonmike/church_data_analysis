import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_settings.dart';
import '../../services/settings_service.dart';

/// Screen for managing application settings like currency, locale etc.
class AppSettingsScreen extends ConsumerWidget {
  const AppSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final settingsNotifier = ref.read(appSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () => _showResetDialog(context, settingsNotifier),
            icon: const Icon(Icons.restore),
            tooltip: 'Reset to defaults',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Currency Settings Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Currency Settings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Currency>(
                    initialValue: settings.currency,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                      border: OutlineInputBorder(),
                      helperText:
                          'Choose your preferred currency for financial data',
                    ),
                    items: Currency.values.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Row(
                          children: [
                            Text(
                              currency.symbol,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(currency.name),
                                Text(
                                  currency.code,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (Currency? newCurrency) {
                      if (newCurrency != null) {
                        settingsNotifier.updateCurrency(newCurrency);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Currency preview
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Preview:',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          settingsNotifier.formatCurrency(1250.75),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Precise: ${settingsNotifier.formatCurrencyPrecise(1250.75)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Theme Settings Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme Settings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<AppThemeMode>(
                    initialValue: settings.themeMode,
                    decoration: const InputDecoration(
                      labelText: 'Theme Mode',
                      border: OutlineInputBorder(),
                      helperText: 'Choose your preferred theme',
                    ),
                    items: AppThemeMode.values.map((mode) {
                      return DropdownMenuItem(
                        value: mode,
                        child: Row(
                          children: [
                            Icon(
                              _getThemeIcon(mode),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(mode.displayName),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (AppThemeMode? newMode) {
                      if (newMode != null) {
                        settingsNotifier.updateThemeMode(newMode);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Theme preview
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current theme:',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                Theme.of(context).brightness == Brightness.dark 
                                    ? 'Dark Mode' 
                                    : 'Light Mode',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Theme.of(context).brightness == Brightness.dark
                                ? Icons.dark_mode
                                : Icons.light_mode,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Regional Settings Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Regional Settings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: settings.locale,
                    decoration: const InputDecoration(
                      labelText: 'Locale',
                      border: OutlineInputBorder(),
                      helperText: 'Language and country code (e.g., en_KE)',
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        settingsNotifier.updateLocale(value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: settings.timezone,
                    decoration: const InputDecoration(
                      labelText: 'Timezone',
                      border: OutlineInputBorder(),
                      helperText: 'Timezone identifier (e.g., Africa/Nairobi)',
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        settingsNotifier.updateTimezone(value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Quick Presets Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Presets',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      _PresetChip(
                        label: 'Kenya (KES)',
                        onTap: () => _applyKenyanPreset(settingsNotifier),
                        isActive: _isKenyanPreset(settings),
                      ),
                      _PresetChip(
                        label: 'Uganda (UGX)',
                        onTap: () => _applyUgandanPreset(settingsNotifier),
                        isActive: _isUgandanPreset(settings),
                      ),
                      _PresetChip(
                        label: 'Tanzania (TZS)',
                        onTap: () => _applyTanzanianPreset(settingsNotifier),
                        isActive: _isTanzanianPreset(settings),
                      ),
                      _PresetChip(
                        label: 'US/International (USD)',
                        onTap: () => _applyUSPreset(settingsNotifier),
                        isActive: _isUSPreset(settings),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, SettingsNotifier notifier) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Settings'),
          content: const Text(
            'Are you sure you want to reset all settings to default values? This will set the currency to Kenyan Shilling and locale to Kenya.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                notifier.resetToDefaults();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings reset to defaults')),
                );
              },
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  IconData _getThemeIcon(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.light:
        return Icons.light_mode;
      case AppThemeMode.dark:
        return Icons.dark_mode;
      case AppThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  void _applyKenyanPreset(SettingsNotifier notifier) {
    notifier.updateCurrency(Currency.kes);
    notifier.updateLocale('en_KE');
    notifier.updateTimezone('Africa/Nairobi');
  }

  void _applyUgandanPreset(SettingsNotifier notifier) {
    notifier.updateCurrency(Currency.ugx);
    notifier.updateLocale('en_UG');
    notifier.updateTimezone('Africa/Kampala');
  }

  void _applyTanzanianPreset(SettingsNotifier notifier) {
    notifier.updateCurrency(Currency.tzs);
    notifier.updateLocale('en_TZ');
    notifier.updateTimezone('Africa/Dar_es_Salaam');
  }

  void _applyUSPreset(SettingsNotifier notifier) {
    notifier.updateCurrency(Currency.usd);
    notifier.updateLocale('en_US');
    notifier.updateTimezone('America/New_York');
  }

  bool _isKenyanPreset(AppSettings settings) {
    return settings.currency == Currency.kes &&
        settings.locale == 'en_KE' &&
        settings.timezone == 'Africa/Nairobi';
  }

  bool _isUgandanPreset(AppSettings settings) {
    return settings.currency == Currency.ugx &&
        settings.locale == 'en_UG' &&
        settings.timezone == 'Africa/Kampala';
  }

  bool _isTanzanianPreset(AppSettings settings) {
    return settings.currency == Currency.tzs &&
        settings.locale == 'en_TZ' &&
        settings.timezone == 'Africa/Dar_es_Salaam';
  }

  bool _isUSPreset(AppSettings settings) {
    return settings.currency == Currency.usd &&
        settings.locale == 'en_US' &&
        settings.timezone == 'America/New_York';
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _PresetChip({
    required this.label,
    required this.onTap,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isActive,
      onSelected: (_) => onTap(),
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      showCheckmark: true,
    );
  }
}
