import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:test_point/core/ui/theme/app_fonts.dart';
import 'package:test_point/core/ui/theme/app_spacing.dart';
import 'package:test_point/modules/import/models/import_result.dart';
import 'package:test_point/modules/import/providers/import_providers.dart';
import 'package:test_point/modules/requests/requests.dart';

/// Opens the Import dialog: paste a cURL command or choose a Postman file.
Future<void> showImportDialog(BuildContext context) =>
    showDialog<void>(context: context, builder: (_) => const _ImportDialog());

class _ImportDialog extends ConsumerStatefulWidget {
  const _ImportDialog();

  @override
  ConsumerState<_ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends ConsumerState<_ImportDialog>
    with SingleTickerProviderStateMixin {
  late final _tabs = TabController(length: 2, vsync: this);
  final _command = TextEditingController();

  bool _busy = false;
  String? _error;
  ImportSummary? _summary;

  @override
  void dispose() {
    _tabs.dispose();
    _command.dispose();
    super.dispose();
  }

  void _importCurl() {
    final result = ref.read(importActionsProvider).importCurl(_command.text);
    final summary = result.valueOrNull;
    if (summary == null) {
      setState(() => _error = result.failureOrNull!.message);
      return;
    }
    // The request is open in a new tab: show it. A clean import closes the
    // dialog; one with skipped parts stays open to list them.
    context.go(requestPath);
    if (summary.skipped.isEmpty) {
      Navigator.pop(context);
    } else {
      setState(() => _summary = summary);
    }
  }

  Future<void> _importPostman() async {
    final source = await ref.read(pickImportFileProvider)();
    if (source == null || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final result = await ref.read(importActionsProvider).importPostman(source);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _summary = result.valueOrNull;
      _error = result.failureOrNull?.message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final summary = _summary;
    return AlertDialog(
      title: const Text('Import'),
      content: SizedBox(
        width: 520,
        child: summary != null
            ? _SummaryView(summary: summary)
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TabBar(
                    controller: _tabs,
                    tabs: const [
                      Tab(text: 'cURL'),
                      Tab(text: 'Postman'),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    height: 180,
                    child: TabBarView(
                      controller: _tabs,
                      children: [
                        TextField(
                          controller: _command,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: const TextStyle(
                            fontFamily: AppFonts.mono,
                            fontSize: 13,
                          ),
                          decoration: const InputDecoration(
                            hintText: "curl -X POST 'https://api.test/users' …",
                          ),
                        ),
                        _PostmanPane(busy: _busy, onChoose: _importPostman),
                      ],
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(summary == null ? 'Cancel' : 'Done'),
        ),
        if (summary == null)
          ListenableBuilder(
            listenable: _tabs,
            builder: (context, _) => _tabs.index == 0
                ? FilledButton(
                    onPressed: _importCurl,
                    child: const Text('Import'),
                  )
                : const SizedBox.shrink(),
          ),
      ],
    );
  }
}

class _PostmanPane extends StatelessWidget {
  const _PostmanPane({required this.busy, required this.onChoose});

  final bool busy;
  final VoidCallback onChoose;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: busy
          ? const CircularProgressIndicator()
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Choose a Postman Collection v2.1 (.json) file.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton.icon(
                  onPressed: onChoose,
                  icon: const Icon(Icons.upload_file_outlined, size: 18),
                  label: const Text('Choose file'),
                ),
              ],
            ),
    );
  }
}

class _SummaryView extends StatelessWidget {
  const _SummaryView({required this.summary});

  final ImportSummary summary;

  @override
  Widget build(BuildContext context) {
    final count = summary.importedCount;
    final name = summary.collectionName;
    final headline = name == null
        ? 'Imported $count ${count == 1 ? 'request' : 'requests'}.'
        : 'Imported $count ${count == 1 ? 'request' : 'requests'} '
              'into "$name".';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(headline),
        if (summary.skipped.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Text(
            'Skipped (${summary.skipped.length})',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200),
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final note in summary.skipped)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                    child: Text(
                      '• $note',
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
