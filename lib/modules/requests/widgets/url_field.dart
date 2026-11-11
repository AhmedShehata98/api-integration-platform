import 'package:flutter/material.dart';
import 'package:test_point/core/ui/theme/app_fonts.dart';

/// A suggestion for the `{{variable}}` being typed: the whole text after
/// accepting it, and where the cursor goes.
class VariableCompletion {
  const VariableCompletion({
    required this.name,
    required this.text,
    required this.cursor,
  });

  final String name;
  final String text;
  final int cursor;
}

/// Suggestions for the unfinished `{{partial` that ends at the cursor.
/// Empty when the cursor is not inside an open `{{`.
List<VariableCompletion> variableCompletions(
  TextEditingValue value,
  Iterable<String> names,
) {
  final cursor = value.selection.baseOffset;
  if (!value.selection.isCollapsed || cursor < 0) return const [];
  final before = value.text.substring(0, cursor);
  final open = before.lastIndexOf('{{');
  if (open < 0 || before.indexOf('}}', open) >= 0) return const [];

  final partial = before.substring(open + 2).trim().toLowerCase();
  final after = value.text.substring(cursor);
  // Do not add a second "}}" when the closing braces are already there.
  final suffix = after.startsWith('}}') ? '' : '}}';
  return [
    for (final name in names)
      if (name.toLowerCase().startsWith(partial))
        VariableCompletion(
          name: name,
          text: '${value.text.substring(0, open + 2)}$name$suffix$after',
          cursor: open + 2 + name.length + 2,
        ),
  ];
}

/// URL text field that suggests variables after `{{`.
class UrlField extends StatelessWidget {
  const UrlField({
    required this.controller,
    required this.focusNode,
    required this.variableNames,
    required this.onChanged,
    required this.onSubmitted,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final Iterable<String> variableNames;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<VariableCompletion>(
      textEditingController: controller,
      focusNode: focusNode,
      displayStringForOption: (option) => option.text,
      optionsBuilder: (value) => variableCompletions(value, variableNames),
      onSelected: (option) {
        controller.selection = TextSelection.collapsed(offset: option.cursor);
        onChanged(option.text);
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) =>
          TextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: onChanged,
            onSubmitted: (_) => onSubmitted(),
            style: const TextStyle(fontFamily: AppFonts.mono, fontSize: 14),
            decoration: const InputDecoration(
              hintText: 'Enter request URL',
              isDense: true,
            ),
          ),
      optionsViewBuilder: (context, onSelected, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320, maxHeight: 200),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                for (final option in options)
                  ListTile(
                    dense: true,
                    title: Text(
                      '{{${option.name}}}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppFonts.mono,
                        fontSize: 13,
                      ),
                    ),
                    onTap: () => onSelected(option),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
