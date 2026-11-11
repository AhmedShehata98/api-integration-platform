import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:re_highlight/languages/json.dart';
import 'package:re_highlight/styles/atom-one-dark.dart';
import 'package:re_highlight/styles/atom-one-light.dart';
import 'package:test_point/core/ui/theme/app_fonts.dart';
import 'package:test_point/core/ui/theme/app_spacing.dart';

/// Code editor / viewer with optional JSON highlighting and a `Ctrl+F` find bar.
class CodeView extends StatelessWidget {
  const CodeView({
    required this.controller,
    this.readOnly = false,
    this.highlightJson = false,
    this.hint,
    super.key,
  });

  final CodeLineEditingController controller;
  final bool readOnly;
  final bool highlightJson;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: CodeEditor(
        controller: controller,
        readOnly: readOnly,
        autofocus: false,
        wordWrap: false,
        hint: hint,
        style: CodeEditorStyle(
          fontFamily: AppFonts.mono,
          fontSize: 13,
          backgroundColor: theme.colorScheme.surfaceContainerLow,
          textColor: theme.colorScheme.onSurface,
          codeTheme: highlightJson
              ? CodeHighlightTheme(
                  languages: {'json': CodeHighlightThemeMode(mode: langJson)},
                  theme: dark ? atomOneDarkTheme : atomOneLightTheme,
                )
              : null,
        ),
        findBuilder: (context, findController, readOnly) =>
            _FindBar(controller: findController),
      ),
    );
  }
}

class _FindBar extends StatelessWidget implements PreferredSizeWidget {
  const _FindBar({required this.controller});

  static const double _height = 40;

  final CodeFindController controller;

  @override
  Size get preferredSize =>
      Size(double.infinity, controller.value == null ? 0 : _height);

  @override
  Widget build(BuildContext context) {
    final value = controller.value;
    if (value == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final result = value.result;
    final status = result == null || result.matches.isEmpty
        ? 'No results'
        : '${result.index + 1} / ${result.matches.length}';

    return Align(
      alignment: Alignment.topRight,
      child: Container(
        height: _height,
        width: 360,
        margin: const EdgeInsets.all(AppSpacing.xs),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadius.tag),
          border: Border.all(color: scheme.outline),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller.findInputController,
                focusNode: controller.findInputFocusNode,
                autofocus: true,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Find',
                  border: InputBorder.none,
                  isDense: true,
                ),
                onSubmitted: (_) => controller.nextMatch(),
              ),
            ),
            Text(
              status,
              maxLines: 1,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
            IconButton(
              tooltip: 'Previous',
              iconSize: 18,
              visualDensity: VisualDensity.compact,
              onPressed: controller.previousMatch,
              icon: const Icon(Icons.keyboard_arrow_up),
            ),
            IconButton(
              tooltip: 'Next',
              iconSize: 18,
              visualDensity: VisualDensity.compact,
              onPressed: controller.nextMatch,
              icon: const Icon(Icons.keyboard_arrow_down),
            ),
            IconButton(
              tooltip: 'Close',
              iconSize: 18,
              visualDensity: VisualDensity.compact,
              onPressed: controller.close,
              icon: const Icon(Icons.close),
            ),
          ],
        ),
      ),
    );
  }
}
