import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/core/ui/theme/app_spacing.dart';
import 'package:test_point/core/ui/widgets/confirm_dialog.dart';
import 'package:test_point/core/ui/widgets/failure_snackbar.dart';
import 'package:test_point/core/ui/widgets/name_dialog.dart';
import 'package:test_point/modules/environments/models/environment.dart';
import 'package:test_point/modules/environments/models/environment_variable.dart';
import 'package:test_point/modules/environments/providers/environment_providers.dart';
import 'package:test_point/modules/environments/widgets/variable_table.dart';

/// Lists the workspace's environments and edits the selected one's variables.
class EnvironmentsScreen extends ConsumerStatefulWidget {
  const EnvironmentsScreen({super.key});

  @override
  ConsumerState<EnvironmentsScreen> createState() => _EnvironmentsScreenState();
}

class _EnvironmentsScreenState extends ConsumerState<EnvironmentsScreen> {
  String? _selectedId;

  /// Unsaved edits of the selected environment's variables.
  List<EnvironmentVariable>? _edits;

  void _select(Environment environment) => setState(() {
    _selectedId = environment.id;
    _edits = null;
  });

  void _fail(Failure failure) {
    if (mounted) showFailureSnackBar(context, failure);
  }

  Future<void> _create() async {
    final name = await showNameDialog(
      context,
      title: 'New environment',
      confirmLabel: 'Create',
      label: 'Environment name',
    );
    if (name == null) return;
    final result = await ref.read(environmentsProvider.notifier).create(name);
    switch (result) {
      case Success(:final value):
        _select(value);
      case Err(:final failure):
        _fail(failure);
    }
  }

  Future<void> _rename(Environment environment) async {
    final name = await showNameDialog(
      context,
      title: 'Rename environment',
      confirmLabel: 'Rename',
      label: 'Environment name',
      initialValue: environment.name,
    );
    if (name == null) return;
    final result = await ref
        .read(environmentsProvider.notifier)
        .rename(environment.id, name);
    if (result case Err(:final failure)) _fail(failure);
  }

  Future<void> _delete(Environment environment) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete environment',
      message: 'Delete "${environment.name}" and its variables?',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed) return;
    final result = await ref
        .read(environmentsProvider.notifier)
        .delete(environment.id);
    switch (result) {
      case Success():
        if (_selectedId == environment.id) {
          setState(() {
            _selectedId = null;
            _edits = null;
          });
        }
      case Err(:final failure):
        _fail(failure);
    }
  }

  Future<void> _save(Environment environment) async {
    final edits = _edits;
    if (edits == null) return;
    final result = await ref
        .read(environmentsProvider.notifier)
        .saveVariables(environment.id, edits);
    switch (result) {
      case Success():
        if (mounted) setState(() => _edits = null);
      case Err(:final failure):
        _fail(failure);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(environmentsProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(error is Failure ? error.message : 'Could not load.'),
      ),
      data: (environments) {
        final selected = environments
            .where((e) => e.id == _selectedId)
            .firstOrNull;
        return Row(
          children: [
            SizedBox(
              width: 260,
              child: _EnvironmentList(
                environments: environments,
                selectedId: selected?.id,
                onSelect: _select,
                onCreate: _create,
                onRename: _rename,
                onDelete: _delete,
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: selected == null
                  ? const Center(child: Text('Select or create an environment'))
                  : _Editor(
                      environment: selected,
                      variables: _edits ?? selected.variables,
                      dirty: _edits != null,
                      onChanged: (v) => setState(() => _edits = v),
                      onSave: () => _save(selected),
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _EnvironmentList extends StatelessWidget {
  const _EnvironmentList({
    required this.environments,
    required this.selectedId,
    required this.onSelect,
    required this.onCreate,
    required this.onRename,
    required this.onDelete,
  });

  final List<Environment> environments;
  final String? selectedId;
  final ValueChanged<Environment> onSelect;
  final VoidCallback onCreate;
  final ValueChanged<Environment> onRename;
  final ValueChanged<Environment> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Environments',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                tooltip: 'New environment',
                onPressed: onCreate,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            children: [
              for (final environment in environments)
                ListTile(
                  dense: true,
                  selected: environment.id == selectedId,
                  title: Text(
                    environment.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => onSelect(environment),
                  trailing: MenuAnchor(
                    menuChildren: [
                      MenuItemButton(
                        onPressed: () => onRename(environment),
                        child: const Text('Rename'),
                      ),
                      MenuItemButton(
                        onPressed: () => onDelete(environment),
                        child: const Text('Delete'),
                      ),
                    ],
                    builder: (context, controller, _) => IconButton(
                      tooltip: 'More',
                      iconSize: 18,
                      onPressed: () => controller.isOpen
                          ? controller.close()
                          : controller.open(),
                      icon: const Icon(Icons.more_vert),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Editor extends StatelessWidget {
  const _Editor({
    required this.environment,
    required this.variables,
    required this.dirty,
    required this.onChanged,
    required this.onSave,
  });

  final Environment environment;
  final List<EnvironmentVariable> variables;
  final bool dirty;
  final ValueChanged<List<EnvironmentVariable>> onChanged;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  environment.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              FilledButton(
                onPressed: dirty ? onSave : null,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
        Expanded(
          // Keyed by environment so row controllers reset when switching.
          child: VariableTable(
            key: ValueKey(environment.id),
            variables: variables,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
