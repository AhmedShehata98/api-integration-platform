import 'package:flutter/material.dart';
import 'package:test_point/core/ui/theme/app_spacing.dart';
import 'package:test_point/modules/environments/environments.dart';
import 'package:test_point/modules/requests/requests.dart';

/// 44 px top bar with the open request tabs and the environment dropdown.
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
        ],
      ),
    );
  }
}
