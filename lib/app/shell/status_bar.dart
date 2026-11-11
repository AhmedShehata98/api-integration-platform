import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_point/core/ui/theme/app_spacing.dart';
import 'package:test_point/modules/environments/environments.dart';
import 'package:test_point/modules/settings/settings.dart';

/// 28 px status bar: state on the left, active environment and proxy state
/// on the right.
class ShellStatusBar extends ConsumerWidget {
  const ShellStatusBar({super.key});

  static const double height = 28;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final style = TextStyle(fontSize: 12, color: scheme.onSurfaceVariant);
    final environment = ref.watch(activeEnvironmentProvider);
    final baseUrl = ref.watch(activeBaseUrlProvider);
    final environmentText = environment == null
        ? 'No environment'
        : baseUrl == null
        ? environment.name
        : '${environment.name} · $baseUrl';

    final proxy = ref.watch(settingsProvider.select((s) => s.proxyUrl));
    final proxyHost = proxy == null ? null : Uri.tryParse(proxy.trim())?.host;
    final proxyText = proxy == null
        ? 'Proxy: Off'
        : 'Proxy: ${proxyHost == null || proxyHost.isEmpty ? 'On' : proxyHost}';

    return Container(
      height: height,
      color: scheme.surfaceContainer,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        children: [
          Text('Ready', style: style, maxLines: 1),
          const Spacer(),
          Flexible(
            child: Text(
              environmentText,
              style: style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Text(proxyText, style: style, maxLines: 1),
        ],
      ),
    );
  }
}
