import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_point/core/ui/theme/app_spacing.dart';

/// Two panels separated by a draggable handle.
///
/// The panels are only laid out here; their own state and behavior are not
/// touched. The split is kept as a fraction of the available space, so both
/// panels follow when the parent is resized, and neither can shrink below its
/// minimum size or leave the container. Double-tapping the handle restores
/// [initialRatio].
class ResizableSplitPane extends StatefulWidget {
  const ResizableSplitPane({
    required this.first,
    required this.second,
    this.axis = Axis.vertical,
    this.initialRatio = 0.55,
    this.minFirstSize = 0,
    this.minSecondSize = 0,
    super.key,
  }) : assert(initialRatio > 0 && initialRatio < 1);

  /// Top panel (vertical) or left panel (horizontal).
  final Widget first;

  /// Bottom panel (vertical) or right panel (horizontal).
  final Widget second;

  /// [Axis.vertical] stacks the panels top and bottom.
  final Axis axis;

  /// Share of the space the first panel starts with.
  final double initialRatio;

  /// Smallest size, in logical pixels, of each panel along [axis].
  final double minFirstSize;
  final double minSecondSize;

  /// Thickness of the handle, which is also its interaction area.
  static const double handleThickness = 12;

  @override
  State<ResizableSplitPane> createState() => _ResizableSplitPaneState();
}

class _ResizableSplitPaneState extends State<ResizableSplitPane> {
  late double _ratio = widget.initialRatio;

  /// Sizes the first panel may have for [available] pixels of content.
  (double, double) _limits(double available) {
    final min = widget.minFirstSize;
    final max = available - widget.minSecondSize;
    if (max >= min) return (min, max);
    // Too small for both minimums: share the space in their proportion.
    final fixed =
        min * available / (widget.minFirstSize + widget.minSecondSize);
    return (fixed, fixed);
  }

  @override
  Widget build(BuildContext context) {
    final vertical = widget.axis == Axis.vertical;
    return LayoutBuilder(
      builder: (context, constraints) {
        final extent = vertical ? constraints.maxHeight : constraints.maxWidth;
        final available = (extent - ResizableSplitPane.handleThickness).clamp(
          0.0,
          double.infinity,
        );
        final (min, max) = _limits(available);
        final firstSize = (_ratio * available).clamp(min, max);

        void dragBy(double delta) {
          if (available <= 0) return;
          // Start from the current ratio, not from this build's size: several
          // pointer events can arrive within one frame.
          setState(() {
            final current = (_ratio * available).clamp(min, max);
            _ratio = (current + delta).clamp(min, max) / available;
          });
        }

        return Flex(
          direction: widget.axis,
          // Panels always fill the pane across the split direction.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: vertical ? null : firstSize,
              height: vertical ? firstSize : null,
              child: widget.first,
            ),
            _Handle(
              axis: widget.axis,
              onDrag: dragBy,
              onReset: () => setState(() => _ratio = widget.initialRatio),
            ),
            Expanded(child: widget.second),
          ],
        );
      },
    );
  }
}

/// The draggable divider: a thin line with a grip, highlighted on hover,
/// while dragging and when focused. With focus, the arrow keys along the split
/// direction move it (16 px, 64 px with Shift) and Enter or Home resets it.
class _Handle extends StatefulWidget {
  const _Handle({
    required this.axis,
    required this.onDrag,
    required this.onReset,
  });

  final Axis axis;
  final ValueChanged<double> onDrag;
  final VoidCallback onReset;

  @override
  State<_Handle> createState() => _HandleState();
}

class _HandleState extends State<_Handle> {
  static const _step = 16.0;
  static const _bigStep = 64.0;

  bool _hovered = false;
  bool _dragging = false;
  bool _focused = false;

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyUpEvent) return KeyEventResult.ignored;
    final vertical = widget.axis == Axis.vertical;
    final key = event.logicalKey;
    final step = HardwareKeyboard.instance.isShiftPressed ? _bigStep : _step;
    if (key ==
        (vertical
            ? LogicalKeyboardKey.arrowUp
            : LogicalKeyboardKey.arrowLeft)) {
      widget.onDrag(-step);
    } else if (key ==
        (vertical
            ? LogicalKeyboardKey.arrowDown
            : LogicalKeyboardKey.arrowRight)) {
      widget.onDrag(step);
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.home) {
      widget.onReset();
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final vertical = widget.axis == Axis.vertical;
    final active = _hovered || _dragging || _focused;
    final lineColor = _dragging
        ? scheme.primary
        : _hovered
        ? scheme.primary.withValues(alpha: 0.6)
        : scheme.outline;
    final gripColor = active ? scheme.primary : scheme.onSurfaceVariant;

    return Focus(
      onKeyEvent: _onKey,
      onFocusChange: (focused) => setState(() => _focused = focused),
      child: MouseRegion(
        cursor: vertical
            ? SystemMouseCursors.resizeRow
            : SystemMouseCursors.resizeColumn,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onDoubleTap: widget.onReset,
          onVerticalDragStart: vertical ? (_) => _setDragging(true) : null,
          onVerticalDragUpdate: vertical
              ? (d) => widget.onDrag(d.delta.dy)
              : null,
          onVerticalDragEnd: vertical ? (_) => _setDragging(false) : null,
          onVerticalDragCancel: vertical ? () => _setDragging(false) : null,
          onHorizontalDragStart: vertical ? null : (_) => _setDragging(true),
          onHorizontalDragUpdate: vertical
              ? null
              : (d) => widget.onDrag(d.delta.dx),
          onHorizontalDragEnd: vertical ? null : (_) => _setDragging(false),
          onHorizontalDragCancel: vertical ? null : () => _setDragging(false),
          child: Semantics(
            label: 'Resize panels',
            child: SizedBox(
              width: vertical ? null : ResizableSplitPane.handleThickness,
              height: vertical ? ResizableSplitPane.handleThickness : null,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // The line.
                  Container(
                    width: vertical ? double.infinity : (active ? 2 : 1),
                    height: vertical ? (active ? 2 : 1) : double.infinity,
                    color: lineColor,
                  ),
                  // The grip: two short bars.
                  Container(
                    width: vertical ? 36 : 8,
                    height: vertical ? 8 : 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(AppRadius.tag),
                    ),
                    child: Flex(
                      direction: vertical ? Axis.vertical : Axis.horizontal,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < 2; i++) ...[
                          if (i > 0) const SizedBox.square(dimension: 2),
                          Container(
                            width: vertical ? 20 : 2,
                            height: vertical ? 2 : 20,
                            color: gripColor,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _setDragging(bool value) => setState(() => _dragging = value);
}
