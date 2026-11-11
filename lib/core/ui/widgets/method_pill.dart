import 'package:flutter/material.dart';
import 'package:test_point/core/ui/theme/app_fonts.dart';
import 'package:test_point/core/ui/theme/app_spacing.dart';
import 'package:test_point/core/ui/theme/http_colors.dart';

/// Fixed-width pill showing an HTTP method, colored by method.
class MethodPill extends StatelessWidget {
  const MethodPill({required this.method, super.key});

  static const double width = 52;

  final String method;

  @override
  Widget build(BuildContext context) {
    final color = context.httpColors.methodColor(method);
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 2),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadius.tag),
      ),
      child: Text(
        method.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontFamily: AppFonts.mono,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
