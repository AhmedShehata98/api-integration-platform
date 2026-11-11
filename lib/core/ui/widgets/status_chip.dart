import 'package:flutter/material.dart';
import 'package:test_point/core/ui/theme/app_spacing.dart';
import 'package:test_point/core/ui/theme/http_colors.dart';

/// Response status such as `200 OK`, colored by status class.
class StatusChip extends StatelessWidget {
  const StatusChip({required this.statusCode, this.reason, super.key});

  final int statusCode;
  final String? reason;

  @override
  Widget build(BuildContext context) {
    final color = context.httpColors.statusColor(statusCode);
    final label = reason == null || reason!.isEmpty
        ? '$statusCode'
        : '$statusCode $reason';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadius.tag),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
