import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:test_point/core/ui/theme/app_spacing.dart';
import 'package:test_point/core/ui/widgets/confirm_dialog.dart';
import 'package:test_point/core/ui/widgets/method_pill.dart';
import 'package:test_point/modules/requests/models/request_tab.dart';
import 'package:test_point/modules/requests/providers/request_tabs_providers.dart';
import 'package:test_point/modules/requests/requests_routes.dart';

/// Open request tabs (method pill, name, unsaved dot, close) and a "+" button.
class RequestTabBar extends ConsumerWidget {
  const RequestTabBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(requestTabsProvider);
    final notifier = ref.read(requestTabsProvider.notifier);

    return Row(
      children: [
        Flexible(
          child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: [
              for (final tab in state.tabs)
                _TabItem(
                  key: ValueKey(tab.id),
                  tab: tab,
                  active: tab.id == state.activeId,
                  onSelect: () {
                    notifier.activate(tab.id);
                    context.go(requestPath);
                  },
                  onClose: () => _close(context, notifier, tab),
                ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'New request',
          iconSize: 20,
          onPressed: () {
            notifier.openNew();
            context.go(requestPath);
          },
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }

  Future<void> _close(
    BuildContext context,
    RequestTabsNotifier notifier,
    RequestTab tab,
  ) async {
    if (tab.isDirty) {
      final discard = await showConfirmDialog(
        context,
        title: 'Close "${tab.name}"?',
        message: 'This request has unsaved changes that will be lost.',
        confirmLabel: 'Discard',
        destructive: true,
      );
      if (!discard) return;
    }
    notifier.close(tab.id);
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.tab,
    required this.active,
    required this.onSelect,
    required this.onClose,
    super.key,
  });

  final RequestTab tab;
  final bool active;
  final VoidCallback onSelect;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onSelect,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 240),
        padding: const EdgeInsets.only(left: AppSpacing.md),
        decoration: BoxDecoration(
          color: active ? scheme.surfaceContainerHigh : null,
          // Teal top edge on the active tab, as in the Stitch shell.
          border: Border(
            top: BorderSide(
              width: 2,
              color: active ? scheme.primary : Colors.transparent,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MethodPill(method: tab.draft.method.label),
            const SizedBox(width: AppSpacing.sm),
            Flexible(
              child: Text(
                tab.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: active ? scheme.onSurface : scheme.onSurfaceVariant,
                ),
              ),
            ),
            if (tab.isDirty)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm),
                child: Tooltip(
                  message: 'Unsaved changes',
                  child: Container(
                    key: const ValueKey('unsaved-dot'),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            IconButton(
              tooltip: 'Close',
              iconSize: 14,
              visualDensity: VisualDensity.compact,
              onPressed: onClose,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}
