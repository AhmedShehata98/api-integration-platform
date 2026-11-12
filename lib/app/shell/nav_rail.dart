import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:test_point/core/ui/theme/app_spacing.dart';
import 'package:test_point/core/ui/widgets/app_logo.dart';
import 'package:test_point/core/ui/widgets/failure_snackbar.dart';
import 'package:test_point/modules/auth/auth.dart';
import 'package:test_point/modules/settings/settings.dart';

class NavDestination {
  const NavDestination(this.label, this.icon, this.path);

  final String label;
  final IconData icon;
  final String path;
}

const navDestinations = [
  NavDestination('Collections', Icons.folder_outlined, '/collections'),
  NavDestination('Environments', Icons.layers_outlined, '/environments'),
  NavDestination('Settings', Icons.settings_outlined, '/settings'),
];

/// 72 px navigation rail: logo, section items, guest avatar at the bottom.
class ShellNavRail extends ConsumerWidget {
  const ShellNavRail({required this.location, super.key});

  static const double width = 72;

  final String location;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      color: scheme.surfaceContainer,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Column(
        children: [
          const AppLogo(),
          const SizedBox(height: AppSpacing.lg),
          for (final item in navDestinations)
            _NavItem(item: item, selected: location.startsWith(item.path)),
          const Spacer(),
          IconButton(
            tooltip: dark ? 'Switch to light theme' : 'Switch to dark theme',
            onPressed: () async {
              final result = await ref
                  .read(settingsProvider.notifier)
                  .toggleTheme();
              final failure = result.failureOrNull;
              if (failure != null && context.mounted) {
                showFailureSnackBar(context, failure);
              }
            },
            icon: Icon(dark ? Icons.dark_mode_outlined : Icons.light_mode),
          ),
          const SizedBox(height: AppSpacing.sm),
          const UserAvatar(),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.item, required this.selected});

  final NavDestination item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = selected ? scheme.primary : scheme.onSurfaceVariant;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.card),
      onTap: () => context.go(item.path),
      child: SizedBox(
        width: ShellNavRail.width,
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? scheme.primary.withValues(alpha: 0.16)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.dialog),
              ),
              child: Icon(item.icon, size: 22, color: color),
            ),
            const SizedBox(height: 2),
            // Scales down instead of cutting "Environments" short.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.label,
                  maxLines: 1,
                  style: TextStyle(fontSize: 11, color: color),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
