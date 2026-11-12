import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_point/core/ui/theme/app_spacing.dart';
import 'package:test_point/modules/environments/environments.dart';
import 'package:test_point/modules/requests/models/send_state.dart';
import 'package:test_point/modules/requests/providers/request_providers.dart';
import 'package:test_point/modules/requests/widgets/method_menu.dart';
import 'package:test_point/modules/requests/widgets/save_request_flow.dart';
import 'package:test_point/modules/requests/widgets/url_field.dart';
import 'package:test_point/modules/requests/widgets/variable_highlight_controller.dart';

/// Method menu, URL field and the Send / Cancel button. `{{variables}}` in
/// the URL are colored in place; undefined ones are amber.
class RequestBar extends ConsumerStatefulWidget {
  const RequestBar({super.key});

  @override
  ConsumerState<RequestBar> createState() => _RequestBarState();
}

class _RequestBarState extends ConsumerState<RequestBar> {
  late final _url = VariableHighlightController(
    text: ref.read(requestDraftProvider).url,
  );
  final _focus = FocusNode();

  @override
  void dispose() {
    _url.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // The Params table can rewrite the URL; mirror it into the field.
    ref.listen(requestDraftProvider.select((draft) => draft.url), (_, url) {
      if (_url.text != url) _url.text = url;
    });

    final method = ref.watch(requestDraftProvider.select((d) => d.method));
    final sending = ref.watch(sendStateProvider) is SendLoading;
    final values = ref.watch(variableResolverProvider).values;
    final draft = ref.read(requestDraftProvider.notifier);
    final sender = ref.read(sendStateProvider.notifier);
    _url.resolvedNames = values.keys.toSet();

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MethodMenu(method: method, onChanged: draft.setMethod),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: UrlField(
                  controller: _url,
                  focusNode: _focus,
                  variableNames: values.keys,
                  onChanged: draft.setUrl,
                  onSubmitted: sender.send,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (sending)
                OutlinedButton(
                  onPressed: sender.cancel,
                  child: const Text('Cancel'),
                )
              else
                FilledButton(
                  onPressed: sender.send,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Send', maxLines: 1),
                      const SizedBox(width: AppSpacing.sm),
                      // Keyboard hint, always `Ctrl` (shell standard).
                      Text(
                        'Ctrl+Enter',
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'JetBrainsMono',
                          color: Theme.of(context).colorScheme.onPrimary
                              .withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              IconButton(
                tooltip: 'Save (Ctrl+S)',
                onPressed: () => saveActiveRequest(context, ref),
                icon: const Icon(Icons.save_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
