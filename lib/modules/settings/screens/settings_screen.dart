import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/core/ui/theme/app_fonts.dart';
import 'package:test_point/core/ui/theme/app_spacing.dart';
import 'package:test_point/core/ui/widgets/failure_snackbar.dart';
import 'package:test_point/modules/settings/providers/settings_providers.dart';
import 'package:test_point/modules/settings/services/settings_service.dart';

/// Theme, request defaults and proxy. Every change is stored and applied at
/// once; text fields apply when submitted (Enter) or when they lose focus.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _timeout;
  late final TextEditingController _proxy;
  late bool _proxyOn;

  @override
  void initState() {
    super.initState();
    // Built here, not lazily: dispose() must not need `ref`.
    final settings = ref.read(settingsProvider);
    _timeout = TextEditingController(text: '${settings.timeoutSeconds}');
    _proxy = TextEditingController(text: settings.proxyUrl ?? '');
    _proxyOn = settings.proxyUrl != null;
  }

  @override
  void dispose() {
    _timeout.dispose();
    _proxy.dispose();
    super.dispose();
  }

  /// Shows the failure, and puts the field back to the stored value.
  void _report(Result<void> result, VoidCallback restore) {
    final failure = result.failureOrNull;
    if (failure == null || !mounted) return;
    showFailureSnackBar(context, failure);
    restore();
  }

  Future<void> _applyTimeout() async {
    final seconds = int.tryParse(_timeout.text.trim());
    final notifier = ref.read(settingsProvider.notifier);
    void restore() =>
        _timeout.text = '${ref.read(settingsProvider).timeoutSeconds}';
    if (seconds == null) {
      _report(
        const Result.failure(
          ValidationFailure('Timeout must be a whole number of seconds.'),
        ),
        restore,
      );
      return;
    }
    _report(await notifier.setTimeoutSeconds(seconds), restore);
  }

  Future<void> _applyProxy() async {
    final result = await ref
        .read(settingsProvider.notifier)
        .setProxyUrl(_proxyOn ? _proxy.text : null);
    _report(
      result,
      () => _proxy.text = ref.read(settingsProvider).proxyUrl ?? '',
    );
  }

  Future<void> _setProxyOn(bool on) async {
    setState(() => _proxyOn = on);
    // Turning it off applies at once; turning it on waits for a URL.
    if (!on) await _applyProxy();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final titleStyle = Theme.of(context).textTheme.titleSmall;

    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            Text('Theme', style: titleStyle),
            const SizedBox(height: AppSpacing.sm),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (modes) async {
                final result = await notifier.setThemeMode(modes.first);
                _report(result, () {});
              },
            ),
            const SizedBox(height: AppSpacing.xl),
            Text('Request defaults', style: titleStyle),
            const SizedBox(height: AppSpacing.sm),
            Focus(
              onFocusChange: (hasFocus) {
                if (!hasFocus) _applyTimeout();
              },
              child: TextField(
                controller: _timeout,
                keyboardType: TextInputType.number,
                onSubmitted: (_) => _applyTimeout(),
                decoration: const InputDecoration(
                  labelText: 'Timeout (seconds)',
                  helperText:
                      'Between $minTimeoutSeconds and $maxTimeoutSeconds.',
                  isDense: true,
                ),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Follow redirects'),
              value: settings.followRedirects,
              onChanged: (value) async {
                final result = await notifier.setFollowRedirects(value);
                _report(result, () {});
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text('Proxy', style: titleStyle),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Use a proxy'),
              value: _proxyOn,
              onChanged: _setProxyOn,
            ),
            if (_proxyOn)
              Focus(
                onFocusChange: (hasFocus) {
                  if (!hasFocus) _applyProxy();
                },
                child: TextField(
                  controller: _proxy,
                  onSubmitted: (_) => _applyProxy(),
                  style: const TextStyle(
                    fontFamily: AppFonts.mono,
                    fontSize: 14,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Proxy URL',
                    hintText: 'http://127.0.0.1:8888',
                    isDense: true,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
