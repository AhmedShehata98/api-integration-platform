import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_point/core/ui/theme/app_spacing.dart';
import 'package:test_point/core/ui/widgets/resizable_split_pane.dart';
import 'package:test_point/modules/requests/providers/request_providers.dart';
import 'package:test_point/modules/requests/providers/request_tabs_providers.dart';
import 'package:test_point/modules/requests/widgets/request_editor.dart';
import 'package:test_point/modules/requests/widgets/response_viewer.dart';
import 'package:test_point/modules/requests/widgets/save_request_flow.dart';

class _SendIntent extends Intent {
  const _SendIntent();
}

class _SaveIntent extends Intent {
  const _SaveIntent();
}

/// Request builder and response viewer (stacked or side by side, see
/// [requestPanesStackedProvider]) with a draggable divider.
/// Shows an empty state when no request tab is open.
class RequestScreen extends ConsumerWidget {
  const RequestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeId = ref.watch(requestTabsProvider.select((s) => s.activeId));
    if (activeId == null) return const _NoOpenRequests();
    final stacked = ref.watch(requestPanesStackedProvider);

    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.enter, control: true): _SendIntent(),
        SingleActivator(LogicalKeyboardKey.keyS, control: true): _SaveIntent(),
      },
      child: Actions(
        actions: {
          _SendIntent: CallbackAction<_SendIntent>(
            onInvoke: (_) => ref.read(sendStateProvider.notifier).send(),
          ),
          _SaveIntent: CallbackAction<_SaveIntent>(
            onInvoke: (_) => saveActiveRequest(context, ref),
          ),
        },
        // Keyed by the active tab so every tab gets its own editors and
        // scroll state.
        child: ResizableSplitPane(
          // Re-created on a layout change so the split restarts at its ratio.
          key: ValueKey('split-$stacked'),
          axis: stacked ? Axis.vertical : Axis.horizontal,
          initialRatio: 0.55,
          minFirstSize: 220,
          minSecondSize: 160,
          first: RequestEditor(key: ValueKey('editor-$activeId')),
          second: ResponseViewer(key: ValueKey('response-$activeId')),
        ),
      ),
    );
  }
}

class _NoOpenRequests extends ConsumerWidget {
  const _NoOpenRequests();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('No open requests', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: ref.read(requestTabsProvider.notifier).openNew,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New request'),
          ),
        ],
      ),
    );
  }
}
