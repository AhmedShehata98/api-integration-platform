import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_point/core/ui/theme/app_spacing.dart';
import 'package:test_point/core/ui/widgets/failure_snackbar.dart';
import 'package:test_point/modules/auth/models/auth_user.dart';
import 'package:test_point/modules/auth/providers/auth_providers.dart';

/// Shown for a signed-in user: their email and a Sign out button.
class SignedInDialog extends ConsumerStatefulWidget {
  const SignedInDialog({required this.user, super.key});

  final AuthUser user;

  @override
  ConsumerState<SignedInDialog> createState() => _SignedInDialogState();
}

class _SignedInDialogState extends ConsumerState<SignedInDialog> {
  bool _busy = false;

  Future<void> _signOut() async {
    setState(() => _busy = true);
    final result = await ref.read(sessionProvider.notifier).signOut();
    if (!mounted) return;
    final failure = result.failureOrNull;
    if (failure == null) {
      Navigator.pop(context);
      return;
    }
    setState(() => _busy = false);
    showFailureSnackBar(context, failure);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Account'),
      content: SizedBox(
        width: 360,
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: scheme.primaryContainer,
              child: Text(
                widget.user.initial,
                style: TextStyle(color: scheme.onPrimaryContainer),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.label ?? 'Signed in',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Text(
                    'Your workspace is saved to this account.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        FilledButton(
          onPressed: _busy ? null : _signOut,
          child: const Text('Sign out'),
        ),
      ],
    );
  }
}
