import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_point/core/ui/theme/app_spacing.dart';
import 'package:test_point/modules/collections/collections.dart';

/// What the user picked in [SaveRequestDialog]. Exactly one of
/// [collectionId] / [newCollectionName] is set.
class SaveRequestChoice {
  const SaveRequestChoice({
    required this.name,
    this.collectionId,
    this.newCollectionName,
  });

  final String name;
  final String? collectionId;
  final String? newCollectionName;
}

const _newCollection = '__new_collection__';

/// Asks for a request name and the collection to save it in
/// (an existing one, or a new one).
class SaveRequestDialog extends ConsumerStatefulWidget {
  const SaveRequestDialog({
    required this.initialName,
    this.initialCollectionId,
    super.key,
  });

  final String initialName;
  final String? initialCollectionId;

  @override
  ConsumerState<SaveRequestDialog> createState() => _SaveRequestDialogState();
}

class _SaveRequestDialogState extends ConsumerState<SaveRequestDialog> {
  late final _name = TextEditingController(text: widget.initialName)
    ..selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.initialName.length,
    );
  final _newCollectionName = TextEditingController();
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialCollectionId;
  }

  @override
  void dispose() {
    _name.dispose();
    _newCollectionName.dispose();
    super.dispose();
  }

  void _submit(String selected) {
    final isNew = selected == _newCollection;
    Navigator.pop(
      context,
      SaveRequestChoice(
        name: _name.text,
        collectionId: isNew ? null : selected,
        newCollectionName: isNew ? _newCollectionName.text : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final collections = ref.watch(collectionsProvider).value ?? const [];
    final ids = {for (final c in collections) c.id};
    // Default to the first collection; with none yet, the only option is a new
    // one. A stale choice falls back the same way.
    final selected = ids.contains(_selected)
        ? _selected!
        : collections.isEmpty
        ? _newCollection
        : collections.first.id;

    return AlertDialog(
      title: const Text('Save request'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Request name'),
              onSubmitted: (_) => _submit(selected),
            ),
            const SizedBox(height: AppSpacing.lg),
            DropdownButtonFormField<String>(
              initialValue: selected,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Collection'),
              items: [
                for (final c in collections)
                  DropdownMenuItem(
                    value: c.id,
                    child: Text(
                      c.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const DropdownMenuItem(
                  value: _newCollection,
                  child: Text('New collection…'),
                ),
              ],
              onChanged: (value) => setState(() => _selected = value),
            ),
            if (selected == _newCollection) ...[
              const SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _newCollectionName,
                decoration: const InputDecoration(labelText: 'Collection name'),
                onSubmitted: (_) => _submit(selected),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => _submit(selected),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
