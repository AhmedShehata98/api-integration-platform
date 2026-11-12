import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:test_point/app/shell/layout_toggle_button.dart';
import 'package:test_point/core/ui/theme/app_spacing.dart';
import 'package:test_point/modules/environments/environments.dart';
import 'package:test_point/modules/import/import.dart';
import 'package:test_point/modules/requests/requests.dart';
import 'package:test_point/modules/settings/settings.dart';

/// 44 px top bar with the open request tabs, the environment dropdown, the
/// layout toggle and the overflow menu.
class ShellTopBar extends StatelessWidget {
  const ShellTopBar({super.key});

  static const double height = 44;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: height,
      padding: const EdgeInsets.only(left: AppSpacing.xs, right: AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        border: Border(bottom: BorderSide(color: scheme.outline)),
      ),
      child: const Row(
        children: [
          Expanded(child: RequestTabBar()),
          EnvironmentDropdown(),
          SizedBox(width: AppSpacing.xs),
          LayoutToggleButton(),
          _OverflowMenu(),
        ],
      ),
    );
  }
}

class _OverflowMenu extends ConsumerWidget {
  const _OverflowMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasTabs = ref.watch(
      requestTabsProvider.select((s) => s.tabs.isNotEmpty),
    );
    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          leadingIcon: const Icon(Icons.file_download_outlined, size: 18),
          onPressed: () => showImportDialog(context),
          child: const Text('Import…'),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.tab_unselected, size: 18),
          onPressed: hasTabs
              ? ref.read(requestTabsProvider.notifier).closeAll
              : null,
          child: const Text('Close all tabs'),
        ),
        MenuItemButton(
          leadingIcon: const Icon(Icons.settings_outlined, size: 18),
          onPressed: () => context.go(settingsPath),
          child: const Text('Settings'),
        ),
      ],
      builder: (context, controller, _) => IconButton(
        tooltip: 'More options',
        iconSize: 20,
        visualDensity: VisualDensity.compact,
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        icon: const Icon(Icons.more_vert),
      ),
    );
  }
}
