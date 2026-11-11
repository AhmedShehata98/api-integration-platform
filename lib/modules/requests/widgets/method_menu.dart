import 'package:flutter/material.dart';
import 'package:test_point/core/ui/theme/app_spacing.dart';
import 'package:test_point/core/ui/widgets/method_pill.dart';
import 'package:test_point/modules/requests/models/http_method.dart';

/// HTTP method picker shown as a pill; opens a `MenuAnchor` list.
class MethodMenu extends StatelessWidget {
  const MethodMenu({required this.method, required this.onChanged, super.key});

  final HttpMethod method;
  final ValueChanged<HttpMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: [
        for (final item in HttpMethod.values)
          MenuItemButton(
            onPressed: () => onChanged(item),
            child: MethodPill(method: item.label),
          ),
      ],
      builder: (context, controller, _) => InkWell(
        borderRadius: BorderRadius.circular(AppRadius.tag),
        onTap: () => controller.isOpen ? controller.close() : controller.open(),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MethodPill(method: method.label),
              const Icon(Icons.arrow_drop_down, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
