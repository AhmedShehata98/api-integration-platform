import 'package:flutter/material.dart';

class ContextMenuItem {
  const ContextMenuItem({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.destructive = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool destructive;
}

/// Wraps [builder]'s widget with a menu that opens on right-click. The
/// [MenuController] passed to [builder] opens the same menu from a button.
class ContextMenu extends StatelessWidget {
  const ContextMenu({required this.items, required this.builder, super.key});

  final List<ContextMenuItem> items;
  final Widget Function(BuildContext context, MenuController controller)
  builder;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return MenuAnchor(
      menuChildren: [
        for (final item in items)
          MenuItemButton(
            onPressed: item.onPressed,
            leadingIcon: Icon(
              item.icon,
              size: 18,
              color: item.destructive ? scheme.error : null,
            ),
            child: Text(
              item.label,
              style: item.destructive ? TextStyle(color: scheme.error) : null,
            ),
          ),
      ],
      builder: (context, controller, _) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onSecondaryTapUp: (details) =>
            controller.open(position: details.localPosition),
        child: builder(context, controller),
      ),
    );
  }
}
