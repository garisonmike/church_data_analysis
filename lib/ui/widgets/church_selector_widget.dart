import 'package:church_analytics/database/app_database.dart';
import 'package:church_analytics/models/models.dart';
import 'package:church_analytics/repositories/repositories.dart';
import 'package:church_analytics/services/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Widget for selecting and switching between churches
/// Displays the current church and allows switching or creating new churches
class ChurchSelectorWidget extends StatefulWidget {
  final VoidCallback? onChurchChanged;

  const ChurchSelectorWidget({super.key, this.onChurchChanged});

  @override
  State<ChurchSelectorWidget> createState() => _ChurchSelectorWidgetState();
}

class _ChurchSelectorWidgetState extends State<ChurchSelectorWidget> {
  ChurchService? _churchService;
  Church? _currentChurch;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase();
    final churchRepo = ChurchRepository(db);

    setState(() {
      _churchService = ChurchService(churchRepo, prefs);
    });

    await _loadCurrentChurch();
  }

  Future<void> _loadCurrentChurch() async {
    if (_churchService == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final church = await _churchService!.getCurrentChurch();
      setState(() {
        _currentChurch = church;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showChurchSelector() async {
    if (_churchService == null) return;

    final churches = await _churchService!.getAllChurches();

    if (!mounted) return;

    final selectedChurch = await showDialog<Church>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Church'),
        content: SizedBox(
          width: double.maxFinite,
          child: churches.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No churches available. Create one first.'),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: churches.length,
                  itemBuilder: (context, index) {
                    final church = churches[index];
                    final isSelected = church.id == _currentChurch?.id;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isSelected
                            ? Colors.blue
                            : Colors.grey[300],
                        child: Text(
                          church.name[0].toUpperCase(),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                      title: Text(church.name),
                      subtitle: church.address != null
                          ? Text(church.address!)
                          : null,
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Colors.blue)
                          : null,
                      selected: isSelected,
                      onTap: () => Navigator.of(context).pop(church),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedChurch != null && selectedChurch.id != _currentChurch?.id) {
      await _switchChurch(selectedChurch);
    }
  }

  Future<void> _switchChurch(Church church) async {
    if (_churchService == null || church.id == null) return;

    try {
      await _churchService!.switchChurch(church.id!);
      await _loadCurrentChurch();

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Switched to ${church.name}')));
        widget.onChurchChanged?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error switching church: $e')));
      }
    }
  }

  Future<void> _showCreateChurchDialog() async {
    if (_churchService == null) return;

    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final currencyController = TextEditingController(text: 'USD');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Church'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Church Name *',
                  hintText: 'Enter church name',
                ),
                autofocus: true,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  hintText: 'Enter church address',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Contact Email',
                  hintText: 'Enter contact email',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Contact Phone',
                  hintText: 'Enter contact phone',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: currencyController,
                decoration: const InputDecoration(
                  labelText: 'Currency',
                  hintText: 'e.g., USD, EUR, GBP',
                ),
              ),
            ],
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

    if (result == true) {
      final name = nameController.text.trim();
      if (name.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Church name is required')),
          );
        }
        return;
      }

      try {
        final now = DateTime.now();
        final church = Church(
          name: name,
          address: addressController.text.trim().isEmpty
              ? null
              : addressController.text.trim(),
          contactEmail: emailController.text.trim().isEmpty
              ? null
              : emailController.text.trim(),
          contactPhone: phoneController.text.trim().isEmpty
              ? null
              : phoneController.text.trim(),
          currency: currencyController.text.trim().isEmpty
              ? 'USD'
              : currencyController.text.trim(),
          createdAt: now,
          updatedAt: now,
        );

        final churchId = await _churchService!.createChurch(church);

        // Switch to the newly created church
        await _churchService!.setCurrentChurchId(churchId);
        await _loadCurrentChurch();

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Created church: $name')));
          widget.onChurchChanged?.call();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error creating church: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _churchService == null) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'switch') {
          _showChurchSelector();
        } else if (value == 'create') {
          _showCreateChurchDialog();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'switch',
          child: Row(
            children: [
              Icon(Icons.swap_horiz),
              SizedBox(width: 8),
              Text('Switch Church'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'create',
          child: Row(
            children: [
              Icon(Icons.add),
              SizedBox(width: 8),
              Text('Create New Church'),
            ],
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: Text(
                _currentChurch?.name.isNotEmpty == true
                    ? _currentChurch!.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentChurch?.name ?? 'No Church',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 20),
          ],
        ),
      ),
    );
  }
}
