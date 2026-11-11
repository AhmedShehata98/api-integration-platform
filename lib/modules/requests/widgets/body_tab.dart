import 'package:flutter/material.dart';
import 'package:re_editor/re_editor.dart';
import 'package:test_point/core/ui/theme/app_spacing.dart';
import 'package:test_point/core/ui/widgets/code_view.dart';
import 'package:test_point/modules/requests/models/request_body.dart';
import 'package:test_point/modules/requests/widgets/key_value_table.dart';

/// Body tab: none, JSON, form-data, x-www-form-urlencoded or raw.
class BodyTab extends StatefulWidget {
  const BodyTab({required this.body, required this.onChanged, super.key});

  final RequestBody body;
  final ValueChanged<RequestBody> onChanged;

  @override
  State<BodyTab> createState() => _BodyTabState();
}

class _BodyTabState extends State<BodyTab> {
  // JSON and raw share one editor so the text survives switching between them.
  late final _editor = CodeLineEditingController.fromText(widget.body.text);

  @override
  void initState() {
    super.initState();
    _editor.addListener(_onEditorChanged);
  }

  void _onEditorChanged() {
    final text = _editor.text;
    if (text != widget.body.text) {
      widget.onChanged(widget.body.copyWith(text: text));
    }
  }

  @override
  void dispose() {
    _editor
      ..removeListener(_onEditorChanged)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = widget.body;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              for (final type in BodyType.values)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(
                    label: Text(type.label, maxLines: 1),
                    selected: body.type == type,
                    onSelected: (_) =>
                        widget.onChanged(body.copyWith(type: type)),
                  ),
                ),
            ],
          ),
        ),
        Expanded(child: _content(body)),
      ],
    );
  }

  Widget _content(RequestBody body) {
    switch (body.type) {
      case BodyType.none:
        return const Center(child: Text('This request has no body.'));
      case BodyType.json:
      case BodyType.raw:
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            0,
            AppSpacing.sm,
            AppSpacing.sm,
          ),
          child: CodeView(
            controller: _editor,
            highlightJson: body.type == BodyType.json,
            hint: body.type == BodyType.json ? '{ }' : 'Raw text',
          ),
        );
      case BodyType.formData:
      case BodyType.urlEncoded:
        return KeyValueTable(
          items: body.fields,
          onChanged: (fields) =>
              widget.onChanged(body.copyWith(fields: fields)),
        );
    }
  }
}
