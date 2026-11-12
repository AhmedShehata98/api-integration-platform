import 'package:flutter/foundation.dart' show setEquals;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:test_point/core/ui/theme/http_colors.dart';

final _variable = RegExp(r'\{\{\s*([^{}]+?)\s*\}\}');

/// Text controller that colors `{{variable}}` in the URL field itself:
/// teal when the active environment defines it, amber when it does not.
class VariableHighlightController extends TextEditingController {
  VariableHighlightController({super.text});

  Set<String> _resolved = const {};
  bool _disposed = false;

  /// Names the active environment defines. Changing them repaints the text.
  set resolvedNames(Set<String> names) {
    if (setEquals(_resolved, names)) return;
    _resolved = names;
    // Set while the parent builds, so the repaint waits for the next frame.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!_disposed) notifyListeners();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    // Keep the input method's composing underline when it is active.
    if (withComposing && value.isComposingRangeValid) {
      return super.buildTextSpan(
        context: context,
        style: style,
        withComposing: withComposing,
      );
    }
    final matches = _variable.allMatches(text).toList();
    if (matches.isEmpty) return TextSpan(style: style, text: text);

    final primary = Theme.of(context).colorScheme.primary;
    final amber = context.httpColors.status4xx;
    final spans = <InlineSpan>[];
    var last = 0;
    for (final match in matches) {
      if (match.start > last) {
        spans.add(TextSpan(text: text.substring(last, match.start)));
      }
      final color = _resolved.contains(match.group(1)) ? primary : amber;
      spans.add(
        TextSpan(
          text: match.group(0),
          style: TextStyle(
            color: color,
            backgroundColor: color.withValues(alpha: 0.16),
            fontWeight: FontWeight.w600,
          ),
        ),
      );
      last = match.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
    return TextSpan(style: style, children: spans);
  }
}
