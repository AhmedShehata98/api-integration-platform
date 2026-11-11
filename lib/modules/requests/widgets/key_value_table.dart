import 'package:flutter/material.dart';
import 'package:test_point/core/ui/theme/app_fonts.dart';
import 'package:test_point/core/ui/theme/app_spacing.dart';
import 'package:test_point/modules/requests/models/key_value.dart';

/// Key / value / enabled table used by Params, Headers and form bodies.
class KeyValueTable extends StatelessWidget {
  const KeyValueTable({
    required this.items,
    required this.onChanged,
    super.key,
  });

  final List<KeyValue> items;
  final ValueChanged<List<KeyValue>> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.sm),
      children: [
        for (var i = 0; i < items.length; i++)
          _Row(
            key: ValueKey(i),
            item: items[i],
            onChanged: (item) => onChanged([...items]..[i] = item),
            onDelete: () => onChanged([...items]..removeAt(i)),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => onChanged([...items, const KeyValue()]),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add'),
          ),
        ),
      ],
    );
  }
}

class _Row extends StatefulWidget {
  const _Row({
    required this.item,
    required this.onChanged,
    required this.onDelete,
    super.key,
  });

  final KeyValue item;
  final ValueChanged<KeyValue> onChanged;
  final VoidCallback onDelete;

  @override
  State<_Row> createState() => _RowState();
}

class _RowState extends State<_Row> {
  late final _key = TextEditingController(text: widget.item.key);
  late final _value = TextEditingController(text: widget.item.value);

  @override
  void didUpdateWidget(_Row oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The URL field can change params from outside; keep the text in sync.
    if (_key.text != widget.item.key) _key.text = widget.item.key;
    if (_value.text != widget.item.value) _value.text = widget.item.value;
  }

  @override
  void dispose() {
    _key.dispose();
    _value.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          Checkbox(
            value: item.enabled,
            onChanged: (v) =>
                widget.onChanged(item.copyWith(enabled: v ?? true)),
          ),
          Expanded(
            child: _Cell(
              controller: _key,
              hint: 'Key',
              onChanged: (v) => widget.onChanged(item.copyWith(key: v)),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _Cell(
              controller: _value,
              hint: 'Value',
              onChanged: (v) => widget.onChanged(item.copyWith(value: v)),
            ),
          ),
          IconButton(
            tooltip: 'Delete',
            iconSize: 18,
            onPressed: widget.onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(fontFamily: AppFonts.mono, fontSize: 13),
      decoration: InputDecoration(hintText: hint, isDense: true),
    );
  }
}
