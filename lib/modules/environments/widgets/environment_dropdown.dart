import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_point/core/ui/theme/app_spacing.dart';
import 'package:test_point/modules/environments/providers/environment_providers.dart';

/// Top-bar menu that picks the active environment.
class EnvironmentDropdown extends ConsumerWidget {
  const EnvironmentDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final environments = ref.watch(environmentsProvider).value ?? const [];
    final active = ref.watch(activeEnvironmentProvider);
    final notifier = ref.read(activeEnvironmentIdProvider.notifier);

    return MenuAnchor(
      menuChildren: [
        MenuItemButton(
          onPressed: () => notifier.select(null),
          child: const Text('No environment'),
        ),
        for (final environment in environments)
          MenuItemButton(
            onPressed: () => notifier.select(environment.id),
            child: Text(
              environment.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
      ],
      builder: (context, controller, _) => TextButton.icon(
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
        icon: const Icon(Icons.layers_outlined, size: 18),
        label: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 160),
          child: Text(
            active?.name ?? 'No environment',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        iconAlignment: IconAlignment.start,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        ),
      ),
    );
  }
}
