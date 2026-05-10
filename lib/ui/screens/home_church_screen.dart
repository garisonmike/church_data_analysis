import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/models.dart';
import '../../services/log_service.dart';
import '../../services/weekly_records_provider.dart';
import '../../services/settings_service.dart';

/// Screen for managing the list of home churches under a church.
/// Clerk can add, edit, reorder, and deactivate home churches.
class HomeChurchScreen extends ConsumerStatefulWidget {
  const HomeChurchScreen({super.key});

  @override
  ConsumerState<HomeChurchScreen> createState() => _HomeChurchScreenState();
}

class _HomeChurchScreenState extends ConsumerState<HomeChurchScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final churchId = settings.selectedChurchId;
    if (churchId == null) {
      return const Scaffold(body: Center(child: Text('No church selected.')));
    }
    final hcAsync = ref.watch(homeChurchesProvider(churchId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Churches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Home Church',
            onPressed: () => _showEditDialog(context, churchId, null),
          ),
        ],
      ),
      body: hcAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (homeChurches) {
          if (homeChurches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.home_work_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No home churches yet.'),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () => _showEditDialog(context, churchId, null),
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Home Church'),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: homeChurches.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final hc = homeChurches[i];
              return _HomeChurchTile(
                homeChurch: hc,
                onEdit: () => _showEditDialog(context, churchId, hc),
                onToggleActive: () => _toggleActive(hc),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _toggleActive(HomeChurch hc) async {
    final repo = ref.read(homeChurchRepositoryProvider);
    await repo.update(hc.copyWith(isActive: !hc.isActive));
    final settings = ref.read(appSettingsProvider);
    if (settings.selectedChurchId != null) {
      ref.invalidate(homeChurchesProvider(settings.selectedChurchId!));
    }
    LogService.info('HomeChurchScreen',
        '${hc.isActive ? "Deactivated" : "Activated"} home church: ${hc.name}');
  }

  Future<void> _showEditDialog(
      BuildContext context, int churchId, HomeChurch? existing) async {
    final result = await showDialog<HomeChurch>(
      context: context,
      builder: (_) => _HomeChurchDialog(churchId: churchId, existing: existing),
    );
    if (result != null && context.mounted) {
      final repo = ref.read(homeChurchRepositoryProvider);
      if (existing == null) {
        await repo.create(result);
        LogService.info('HomeChurchScreen', 'Created home church: ${result.name}');
      } else {
        await repo.update(result);
        LogService.info('HomeChurchScreen', 'Updated home church: ${result.name}');
      }
      ref.invalidate(homeChurchesProvider(churchId));
    }
  }
}

class _HomeChurchTile extends StatelessWidget {
  final HomeChurch homeChurch;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;

  const _HomeChurchTile({
    required this.homeChurch,
    required this.onEdit,
    required this.onToggleActive,
  });

  Color _categoryColor(HomeChurchCategory cat) {
    switch (cat) {
      case HomeChurchCategory.geographical: return Colors.blue;
      case HomeChurchCategory.ministry:     return Colors.teal;
      case HomeChurchCategory.special:      return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(homeChurch.category);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(30),
          child: Icon(Icons.home_work, color: color, size: 20),
        ),
        title: Text(
          homeChurch.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: homeChurch.isActive ? null : Colors.grey,
            decoration: homeChurch.isActive ? null : TextDecoration.lineThrough,
          ),
        ),
        subtitle: Text(
          '${homeChurch.category.displayName} · ${homeChurch.expectedMembership} members',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: onEdit),
            IconButton(
              icon: Icon(
                homeChurch.isActive ? Icons.toggle_on : Icons.toggle_off,
                color: homeChurch.isActive ? Colors.green : Colors.grey,
              ),
              onPressed: onToggleActive,
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeChurchDialog extends StatefulWidget {
  final int churchId;
  final HomeChurch? existing;
  const _HomeChurchDialog({required this.churchId, this.existing});

  @override
  State<_HomeChurchDialog> createState() => _HomeChurchDialogState();
}

class _HomeChurchDialogState extends State<_HomeChurchDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _expectedMembership;
  late TextEditingController _expectedAtKcc;
  late HomeChurchCategory _category;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _expectedMembership = TextEditingController(
        text: e?.expectedMembership.toString() ?? '0');
    _expectedAtKcc = TextEditingController(
        text: e?.expectedAtKcc.toString() ?? '0');
    _category = e?.category ?? HomeChurchCategory.geographical;
  }

  @override
  void dispose() {
    _name.dispose(); _expectedMembership.dispose(); _expectedAtKcc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    return AlertDialog(
      title: Text(isEdit ? 'Edit Home Church' : 'Add Home Church'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Name *', border: OutlineInputBorder()),
              textCapitalization: TextCapitalization.characters,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Name is required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<HomeChurchCategory>(
              value: _category,
              decoration: const InputDecoration(
                  labelText: 'Category', border: OutlineInputBorder()),
              items: HomeChurchCategory.values
                  .map((c) => DropdownMenuItem(
                      value: c, child: Text(c.displayName)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _expectedMembership,
              decoration: const InputDecoration(
                  labelText: 'Expected Membership',
                  border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n < 0) return 'Enter a valid number';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _expectedAtKcc,
              decoration: const InputDecoration(
                  labelText: 'Expected at KCC',
                  helperText: 'How many attend main church events',
                  border: OutlineInputBorder()),
              keyboardType: TextInputType.number,
              validator: (v) {
                final n = int.tryParse(v ?? '');
                if (n == null || n < 0) return 'Enter a valid number';
                return null;
              },
            ),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            final now = DateTime.now();
            final hc = HomeChurch(
              id: widget.existing?.id,
              churchId: widget.churchId,
              name: _name.text.trim().toUpperCase(),
              category: _category,
              expectedMembership: int.parse(_expectedMembership.text),
              expectedAtKcc: int.parse(_expectedAtKcc.text),
              isActive: widget.existing?.isActive ?? true,
              sortOrder: widget.existing?.sortOrder ?? 0,
              createdAt: widget.existing?.createdAt ?? now,
              updatedAt: now,
            );
            final error = hc.validate();
            if (error != null) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(error)));
              return;
            }
            Navigator.pop(context, hc);
          },
          child: Text(isEdit ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
