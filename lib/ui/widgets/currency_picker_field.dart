import 'package:flutter/material.dart';

import '../../models/iso_currencies.dart';

/// A form field that replaces free-text currency entry with a searchable
/// picker of ISO 4217 codes (U2/U3).
///
/// Displays the currently selected code and name; tapping opens a search
/// dialog. [value] is the stored ISO code (e.g. 'KES'); [onChanged] fires with
/// the newly picked code. An unknown or empty [value] renders as a prompt.
class CurrencyPickerField extends StatelessWidget {
  final String? value;
  final ValueChanged<String> onChanged;
  final String labelText;

  const CurrencyPickerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.labelText = 'Currency',
  });

  @override
  Widget build(BuildContext context) {
    final selected = isoCurrencyByCode(value);

    return InkWell(
      key: const ValueKey('currency_picker_field'),
      onTap: () async {
        final picked = await showDialog<IsoCurrency>(
          context: context,
          builder: (_) => _CurrencyPickerDialog(selectedCode: selected?.code),
        );
        if (picked != null) onChanged(picked.code);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.payments_outlined),
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          selected != null
              ? '${selected.code} — ${selected.name}'
              : (value != null && value!.isNotEmpty
                    ? value! // an unknown code from an imported backup
                    : 'Select currency'),
          style: selected == null && (value == null || value!.isEmpty)
              ? TextStyle(color: Theme.of(context).hintColor)
              : null,
        ),
      ),
    );
  }
}

/// Searchable modal list of [kIsoCurrencies], filtered by code or name.
class _CurrencyPickerDialog extends StatefulWidget {
  final String? selectedCode;

  const _CurrencyPickerDialog({this.selectedCode});

  @override
  State<_CurrencyPickerDialog> createState() => _CurrencyPickerDialogState();
}

class _CurrencyPickerDialogState extends State<_CurrencyPickerDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final matches = q.isEmpty
        ? kIsoCurrencies
        : kIsoCurrencies
              .where(
                (c) =>
                    c.code.toLowerCase().contains(q) ||
                    c.name.toLowerCase().contains(q),
              )
              .toList();

    return AlertDialog(
      title: const Text('Select Currency'),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      content: SizedBox(
        width: 420,
        height: 460,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search code or name…',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: matches.isEmpty
                  ? const Center(child: Text('No matching currencies'))
                  : ListView.builder(
                      itemCount: matches.length,
                      itemBuilder: (context, index) {
                        final c = matches[index];
                        final isSelected = c.code == widget.selectedCode;
                        return ListTile(
                          dense: true,
                          selected: isSelected,
                          leading: SizedBox(
                            width: 44,
                            child: Text(
                              c.code,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(c.name),
                          trailing: isSelected
                              ? const Icon(Icons.check, size: 18)
                              : null,
                          onTap: () => Navigator.of(context).pop(c),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
