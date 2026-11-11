import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:test_point/app/shell/sidebar/sidebar_actions.dart';
import 'package:test_point/core/ui/theme/app_fonts.dart';
import 'package:test_point/core/ui/theme/app_spacing.dart';
import 'package:test_point/core/ui/widgets/method_pill.dart';
import 'package:test_point/modules/collections/collections.dart';
import 'package:test_point/modules/requests/requests.dart';

/// Overview of one collection: its requests and the collection actions.
class CollectionOverviewScreen extends ConsumerWidget {
  const CollectionOverviewScreen({required this.collectionId, super.key});

  final String collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collection = ref
        .watch(collectionsProvider)
        .value
        ?.where((c) => c.id == collectionId)
        .firstOrNull;
    if (collection == null) {
      return const Center(child: Text('Collection not found.'));
    }

    final theme = Theme.of(context);
    final requests = [
      for (final r in ref.watch(savedRequestsProvider).value ?? const [])
        if (r.collectionId == collectionId) r,
    ];
    final actions = CollectionActions(context, ref);
    final requestActions = SavedRequestActions(context, ref);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                collection.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall,
              ),
            ),
            IconButton(
              tooltip: 'Rename',
              onPressed: () => actions.rename(collection),
              icon: const Icon(Icons.edit_outlined),
            ),
            IconButton(
              tooltip: 'Duplicate',
              onPressed: () => actions.duplicate(collection),
              icon: const Icon(Icons.copy_outlined),
            ),
            IconButton(
              tooltip: 'Delete',
              onPressed: () async {
                final deleted = await actions.delete(
                  collection,
                  requestCount: requests.length,
                );
                if (deleted && context.mounted) context.go('/collections');
              },
              icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
            ),
          ],
        ),
        Text(
          '${requests.length} ${requests.length == 1 ? 'request' : 'requests'}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: () => actions.newRequestIn(collection),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New request'),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (requests.isEmpty)
          const Text('This collection has no requests yet.')
        else
          for (final request in requests)
            ListTile(
              leading: MethodPill(method: request.draft.method.label),
              title: Text(
                request.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                request.draft.url,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: AppFonts.mono, fontSize: 12),
              ),
              onTap: () => requestActions.open(request),
            ),
      ],
    );
  }
}
