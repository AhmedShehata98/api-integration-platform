import 'package:flutter/material.dart';
import 'package:test_point/core/ui/theme/app_fonts.dart';
import 'package:test_point/core/ui/theme/app_spacing.dart';
import 'package:test_point/modules/requests/models/key_value.dart';
import 'package:test_point/modules/requests/services/bulk_edit.dart';

/// Key / value / enabled table used by Params, Headers and form bodies.
/// "Bulk Edit" swaps the rows for one `key: value` line per row.
class KeyValueTable extends StatefulWidget {
  const KeyValueTable({
    required this.items,
    required this.onChanged,
    super.key,
  });

  final List<KeyValue> items;
  final ValueChanged<List<KeyValue>> onChanged;

  @override
  State<KeyValueTable> createState() => _KeyValueTableState();
}

class _KeyValueTableState extends State<KeyValueTable> {
  final _bulk = TextEditingController();
  bool _bulkMode = false;

  List<KeyValue> get _items => widget.items;

  @override
  void dispose() {
    _bulk.dispose();
    super.dispose();
  }

  void _toggleBulk() {
    // The text is loaded once when entering; typing then owns it, so the
    // cursor does not jump when the parsed rows come back as `items`.
    if (!_bulkMode) _bulk.text = formatBulk(_items);
    setState(() => _bulkMode = !_bulkMode);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: TextButton(
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
              onPressed: _toggleBulk,
              child: Text(_bulkMode ? 'Key-Value Edit' : 'Bulk Edit'),
            ),
          ),
        ),
        Expanded(child: _bulkMode ? _bulkField() : _table()),
      ],
    );
  }

  Widget _bulkField() => Padding(
    padding: const EdgeInsets.all(AppSpacing.sm),
    child: TextField(
      controller: _bulk,
      expands: true,
      maxLines: null,
      minLines: null,
      textAlignVertical: TextAlignVertical.top,
      onChanged: (text) => widget.onChanged(parseBulk(text)),
      style: const TextStyle(fontFamily: AppFonts.mono, fontSize: 13),
      decoration: const InputDecoration(
        hintText: 'key: value, one per line (start with # to disable)',
      ),
    ),
  );

  Widget _table() => ListView(
    padding: const EdgeInsets.all(AppSpacing.sm),
    children: [
      for (var i = 0; i < _items.length; i++)
        _Row(
          key: ValueKey(i),
          item: _items[i],
          onChanged: (item) => widget.onChanged([..._items]..[i] = item),
          onDelete: () => widget.onChanged([..._items]..removeAt(i)),
        ),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => widget.onChanged([..._items, const KeyValue()]),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add'),
        ),
      ),
    ],
  );
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
