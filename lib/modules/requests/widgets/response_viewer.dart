import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:re_editor/re_editor.dart';
import 'package:test_point/core/ui/theme/app_fonts.dart';
import 'package:test_point/core/ui/theme/app_spacing.dart';
import 'package:test_point/core/ui/widgets/code_view.dart';
import 'package:test_point/core/ui/widgets/status_chip.dart';
import 'package:test_point/modules/requests/models/http_response_result.dart';
import 'package:test_point/modules/requests/models/send_state.dart';
import 'package:test_point/modules/requests/providers/request_providers.dart';

/// Response pane: idle, loading, error and the Body / Headers result views.
class ResponseViewer extends ConsumerWidget {
  const ResponseViewer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(sendStateProvider)) {
      SendIdle() => const _Message(
        icon: Icons.send_outlined,
        text: 'Send a request to see the response.',
      ),
      SendLoading() => const _Loading(),
      SendFailed(:final failure) => _Message(
        icon: Icons.error_outline,
        text: failure.message,
        isError: true,
      ),
      SendSuccess(:final response) => _ResponseResult(response: response),
    };
  }
}

class _Message extends ConsumerWidget {
  const _Message({
    required this.icon,
    required this.text,
    this.isError = false,
  });

  final IconData icon;
  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final color = isError ? scheme.error : scheme.primary;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.cardLarge),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Icon(icon, size: 28, color: color),
          ),
          const SizedBox(height: AppSpacing.md),
          if (isError) ...[
            Text(
              'Request failed',
              maxLines: 1,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          Text(text, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: AppSpacing.sm),
          if (isError)
            TextButton(
              onPressed: ref.read(sendStateProvider.notifier).send,
              child: const Text('Retry'),
            )
          else
            Text(
              'Press Ctrl+Enter to send',
              maxLines: 1,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}

class _Loading extends ConsumerWidget {
  const _Loading();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.md),
          const Text('Sending…'),
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: ref.read(sendStateProvider.notifier).cancel,
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

class _ResponseResult extends StatefulWidget {
  const _ResponseResult({required this.response});

  final HttpResponseResult response;

  @override
  State<_ResponseResult> createState() => _ResponseResultState();
}

class _ResponseResultState extends State<_ResponseResult> {
  final _editor = CodeLineEditingController();
  int _loadId = 0;
  bool _pretty = true;

  HttpResponseResult get _response => widget.response;

  bool get _hasPretty => _response.prettyBody != null;

  String get _shownText =>
      _pretty && _hasPretty ? _response.prettyBody! : _response.body;

  @override
  void initState() {
    super.initState();
    _showText();
  }

  @override
  void didUpdateWidget(_ResponseResult oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.response != widget.response) {
      _pretty = true;
      _showText();
    }
  }

  @override
  void dispose() {
    _editor.dispose();
    super.dispose();
  }

  void _setPretty(bool pretty) {
    setState(() => _pretty = pretty);
    _showText();
  }

  /// Splits the text into lines off the main isolate, so a multi-megabyte body
  /// does not freeze the UI. A newer request wins over an older one.
  Future<void> _showText() async {
    final id = ++_loadId;
    final lines = await _shownText.codeLinesAsync;
    if (!mounted || id != _loadId) return;
    _editor.codeLines = lines;
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _shownText));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Body copied'),
          duration: Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = TextStyle(fontSize: 12, color: scheme.onSurfaceVariant);

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                StatusChip(
                  statusCode: _response.statusCode,
                  reason: _response.reason,
                ),
                const SizedBox(width: AppSpacing.md),
                Text(_formatDuration(_response.duration), style: muted),
                const SizedBox(width: AppSpacing.md),
                Text(_formatSize(_response.sizeBytes), style: muted),
                const Spacer(),
                if (_hasPretty)
                  SegmentedButton<bool>(
                    showSelectedIcon: false,
                    style: const ButtonStyle(
                      visualDensity: VisualDensity.compact,
                    ),
                    segments: const [
                      ButtonSegment(value: true, label: Text('Pretty')),
                      ButtonSegment(value: false, label: Text('Raw')),
                    ],
                    selected: {_pretty},
                    onSelectionChanged: (s) => _setPretty(s.first),
                  ),
                IconButton(
                  tooltip: 'Copy body',
                  onPressed: _copy,
                  icon: const Icon(Icons.copy_outlined, size: 18),
                ),
              ],
            ),
          ),
          const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Body'),
              Tab(text: 'Headers'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: CodeView(
                    controller: _editor,
                    readOnly: true,
                    highlightJson: _pretty && _hasPretty,
                    hint: 'Empty response body',
                  ),
                ),
                _HeadersList(headers: _response.headers),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HeadersList extends StatelessWidget {
  const _HeadersList({required this.headers});

  final Map<String, List<String>> headers;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final entries = headers.entries.toList();
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: entries.length,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
        child: SelectableText.rich(
          TextSpan(
            style: const TextStyle(fontFamily: AppFonts.mono, fontSize: 13),
            children: [
              TextSpan(
                text: '${entries[i].key}: ',
                style: TextStyle(color: scheme.primary),
              ),
              TextSpan(text: entries[i].value.join(', ')),
            ],
          ),
        ),
      ),
    );
  }
}

String _formatDuration(Duration d) => d.inMilliseconds >= 1000
    ? '${(d.inMilliseconds / 1000).toStringAsFixed(2)} s'
    : '${d.inMilliseconds} ms';

String _formatSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}
