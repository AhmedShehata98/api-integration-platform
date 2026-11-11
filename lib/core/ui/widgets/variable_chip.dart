import 'package:flutter/material.dart';
import 'package:test_point/core/ui/theme/app_fonts.dart';
import 'package:test_point/core/ui/theme/app_spacing.dart';
import 'package:test_point/core/ui/theme/http_colors.dart';

/// A `{{name}}` variable. Unresolved variables are shown in amber.
class VariableChip extends StatelessWidget {
  const VariableChip({required this.name, this.resolved = true, super.key});

  final String name;
  final bool resolved;

  @override
  Widget build(BuildContext context) {
    final color = resolved
        ? Theme.of(context).colorScheme.primary
        : context.httpColors.status4xx;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadius.tag),
      ),
      child: Text(
        '{{$name}}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontFamily: AppFonts.mono, fontSize: 12, color: color),
      ),
    );
  }
}
