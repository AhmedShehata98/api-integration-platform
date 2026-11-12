import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:test_point/app/shell/sidebar/sidebar_actions.dart';
import 'package:test_point/app/shell/sidebar/sidebar_filter.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/ui/theme/app_spacing.dart';
import 'package:test_point/core/ui/widgets/context_menu.dart';
import 'package:test_point/core/ui/widgets/method_pill.dart';
import 'package:test_point/modules/collections/collections.dart';
import 'package:test_point/modules/import/import.dart';
import 'package:test_point/modules/requests/requests.dart';

/// 280 px sidebar: header with count and "+ New", filter, collection tree
/// and a request count footer.
class ShellSidebar extends ConsumerStatefulWidget {
  const ShellSidebar({required this.filterFocus, super.key});

  static const double width = 280;

  /// Focused by `Ctrl+K`.
  final FocusNode filterFocus;

  @override
  ConsumerState<ShellSidebar> createState() => _ShellSidebarState();
}

class _ShellSidebarState extends ConsumerState<ShellSidebar> {
  final _filter = TextEditingController();
  final _expanded = <String>{};

  @override
  void dispose() {
    _filter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final collections = ref.watch(collectionsProvider);
    final requests = ref.watch(savedRequestsProvider).value ?? const [];

    return Container(
      width: ShellSidebar.width,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        border: Border(right: BorderSide(color: scheme.outline)),
      ),
      child: Column(
        children: [
          _Header(count: collections.value?.length ?? 0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: TextField(
              controller: _filter,
              focusNode: widget.filterFocus,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Filter requests',
                isDense: true,
                prefixIcon: const Icon(Icons.search, size: 18),
                // suffixText only shows while focused; the hint should always show.
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: Center(
                    widthFactor: 1,
                    child: Text(
                      'Ctrl+K',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 11,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: collections.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _LoadError(
                message: error is Failure
                    ? error.message
                    : const UnexpectedFailure().message,
                onRetry: () => ref.invalidate(collectionsProvider),
              ),
              data: (list) => _Tree(
                groups: filterSidebar(list, requests, _filter.text),
                filtering: _filter.text.trim().isNotEmpty,
                hasCollections: list.isNotEmpty,
                expanded: _expanded,
                onToggle: (id) => setState(
                  () => _expanded.contains(id)
                      ? _expanded.remove(id)
                      : _expanded.add(id),
                ),
              ),
            ),
          ),
          Container(
            height: 32,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: scheme.outline)),
            ),
            child: Text(
              '${requests.length} ${requests.length == 1 ? 'request' : 'requests'}',
              maxLines: 1,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.count});

  final int count;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final actions = CollectionActions(context, ref);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Title and count share the space left of "Import".
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        'COLLECTIONS',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          letterSpacing: 0.8,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Tooltip(
                message: 'Import',
                child: TextButton.icon(
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () => showImportDialog(context),
                  icon: const Icon(Icons.file_download_outlined, size: 16),
                  label: const Text('Import', maxLines: 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          MenuAnchor(
            menuChildren: [
              MenuItemButton(
                leadingIcon: const Icon(Icons.bolt_outlined, size: 18),
                onPressed: () {
                  ref.read(requestTabsProvider.notifier).openNew();
                  context.go(requestPath);
                },
                child: const Text('New request'),
              ),
              MenuItemButton(
                leadingIcon: const Icon(
                  Icons.create_new_folder_outlined,
                  size: 18,
                ),
                onPressed: actions.create,
                child: const Text('New collection'),
              ),
            ],
            builder: (context, controller, _) => SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: const ButtonStyle(visualDensity: VisualDensity.compact),
                onPressed: () =>
                    controller.isOpen ? controller.close() : controller.open(),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New'),
                iconAlignment: IconAlignment.start,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tree extends ConsumerWidget {
  const _Tree({
    required this.groups,
    required this.filtering,
    required this.hasCollections,
    required this.expanded,
    required this.onToggle,
  });

  final List<SidebarGroup> groups;
  final bool filtering;
  final bool hasCollections;
  final Set<String> expanded;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!hasCollections) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No collections yet'),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: CollectionActions(context, ref).create,
              child: const Text('Create collection'),
            ),
          ],
        ),
      );
    }
    if (groups.isEmpty) {
      return const Center(child: Text('No matches'));
    }

    final activeSavedId = ref.watch(
      requestTabsProvider.select((s) => s.active?.savedRequestId),
    );
    return ListView(
      children: [
        for (final group in groups)
          _CollectionNode(
            group: group,
            expanded: filtering || expanded.contains(group.collection.id),
            activeSavedId: activeSavedId,
            onToggle: () => onToggle(group.collection.id),
          ),
      ],
    );
  }
}

class _CollectionNode extends ConsumerWidget {
  const _CollectionNode({
    required this.group,
    required this.expanded,
    required this.activeSavedId,
    required this.onToggle,
  });

  final SidebarGroup group;
  final bool expanded;
  final String? activeSavedId;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final actions = CollectionActions(context, ref);
    final collection = group.collection;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ContextMenu(
          items: [
            ContextMenuItem(
              label: 'New request',
              icon: Icons.add,
              onPressed: () => actions.newRequestIn(collection),
            ),
            ContextMenuItem(
              label: 'Rename',
              icon: Icons.edit_outlined,
              onPressed: () => actions.rename(collection),
            ),
            ContextMenuItem(
              label: 'Duplicate',
              icon: Icons.copy_outlined,
              onPressed: () => actions.duplicate(collection),
            ),
            ContextMenuItem(
              label: 'Delete',
              icon: Icons.delete_outline,
              destructive: true,
              onPressed: () => actions.delete(
                collection,
                requestCount: group.requests.length,
              ),
            ),
          ],
          builder: (context, menu) => InkWell(
            onTap: () {
              if (!expanded) onToggle();
              context.go('/collections/${collection.id}');
            },
            child: SizedBox(
              height: 36,
              child: Row(
                children: [
                  IconButton(
                    tooltip: expanded ? 'Collapse' : 'Expand',
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    onPressed: onToggle,
                    icon: Icon(
                      expanded ? Icons.expand_more : Icons.chevron_right,
                    ),
                  ),
                  Icon(Icons.folder_outlined, size: 18, color: scheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      collection.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    tooltip: 'More',
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                    onPressed: menu.open,
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (expanded)
          for (final request in group.requests)
            _RequestNode(
              request: request,
              selected: request.id == activeSavedId,
            ),
      ],
    );
  }
}

class _RequestNode extends ConsumerWidget {
  const _RequestNode({required this.request, required this.selected});

  final SavedRequest request;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final actions = SavedRequestActions(context, ref);

    return ContextMenu(
      items: [
        ContextMenuItem(
          label: 'Rename',
          icon: Icons.edit_outlined,
          onPressed: () => actions.rename(request),
        ),
        ContextMenuItem(
          label: 'Duplicate',
          icon: Icons.copy_outlined,
          onPressed: () => actions.duplicate(request),
        ),
        ContextMenuItem(
          label: 'Delete',
          icon: Icons.delete_outline,
          destructive: true,
          onPressed: () => actions.delete(request),
        ),
      ],
      builder: (context, menu) => InkWell(
        onTap: () => actions.open(request),
        child: Container(
          height: 34,
          color: selected ? scheme.primary.withValues(alpha: 0.12) : null,
          padding: const EdgeInsets.only(left: 44, right: AppSpacing.xs),
          child: Row(
            children: [
              MethodPill(method: request.draft.method.label),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  request.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13),
                ),
              ),
              IconButton(
                tooltip: 'More',
                iconSize: 16,
                visualDensity: VisualDensity.compact,
                onPressed: menu.open,
                icon: const Icon(Icons.more_vert),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: AppSpacing.sm),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
