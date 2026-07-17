import 'package:church_analytics/database/app_database.dart';
import 'package:church_analytics/models/models.dart';
import 'package:church_analytics/repositories/repositories.dart';
import 'package:church_analytics/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// AppBar chip showing the current church. Tapping it opens the church
/// selector screen (`/select-church`) — the single real switching mechanism.
///
/// This widget used to carry its own switch dialog and a duplicated
/// create-church dialog. The switch dialog only updated the persisted
/// current-church id and reloaded the dashboard in place, while every query
/// and pushed screen kept using the churchId frozen into the dashboard at
/// construction — so "switching" changed the label but not the data
/// (live-verified: prefs pointed at the new church while all screens served
/// the old one). The create dialog had also missed the ISO-currency-picker
/// rework and still shipped a free-text USD default. Both flows now route
/// to ChurchSelectionScreen, which owns switching, creation, and deletion,
/// and re-enters through the startup gate so every screen gets the new
/// church.
class ChurchSelectorWidget extends ConsumerStatefulWidget {
  const ChurchSelectorWidget({super.key});

  @override
  ConsumerState<ChurchSelectorWidget> createState() =>
      _ChurchSelectorWidgetState();
}

class _ChurchSelectorWidgetState extends ConsumerState<ChurchSelectorWidget> {
  Church? _currentChurch;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentChurch();
  }

  Future<void> _loadCurrentChurch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final db = ref.read(databaseProvider);
      final service = ChurchService(ChurchRepository(db), prefs);
      final church = await service.getCurrentChurch();
      if (!mounted) return;
      setState(() {
        _currentChurch = church;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    final name = _currentChurch?.name ?? 'Select Church';

    return Tooltip(
      message: 'Switch or manage churches',
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.of(context).pushNamed('/select-church'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blue,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 140),
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}
