import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_point/core/ui/widgets/failure_snackbar.dart';
import 'package:test_point/modules/settings/settings.dart';

/// Switches the request and response panes between stacked and side by side.
/// Used in the top bar and in the status bar.
class LayoutToggleButton extends ConsumerWidget {
  const LayoutToggleButton({this.size = 20, super.key});

  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stacked = ref.watch(settingsProvider.select((s) => s.stackedLayout));
    return IconButton(
      tooltip: stacked ? 'Show panes side by side' : 'Stack the panes',
      iconSize: size,
      visualDensity: VisualDensity.compact,
      onPressed: () async {
        final result = await ref.read(settingsProvider.notifier).toggleLayout();
        final failure = result.failureOrNull;
        if (failure != null && context.mounted) {
          showFailureSnackBar(context, failure);
        }
      },
      icon: Icon(stacked ? Icons.splitscreen : Icons.vertical_split_outlined),
    );
  }
}
