import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_point/core/ui/theme/app_spacing.dart';
import 'package:test_point/modules/auth/models/github_account_exists_failure.dart';
import 'package:test_point/modules/auth/providers/auth_providers.dart';
import 'package:test_point/modules/auth/widgets/guest_data_warning_dialog.dart';
import 'package:test_point/modules/auth/widgets/signed_in_dialog.dart';

/// Opens the Account dialog over the workspace: Continue with GitHub for a
/// guest, the account and Sign out for a signed-in user.
Future<void> showAccountDialog(BuildContext context, WidgetRef ref) {
  final user = ref.read(sessionProvider).value;
  return showDialog<void>(
    context: context,
    builder: (_) => user == null || user.isAnonymous
        ? const _GuestDialog()
        : SignedInDialog(user: user),
  );
}

class _GuestDialog extends ConsumerStatefulWidget {
  const _GuestDialog();

  @override
  ConsumerState<_GuestDialog> createState() => _GuestDialogState();
}

class _GuestDialogState extends ConsumerState<_GuestDialog> {
  late final SessionNotifier _session;

  bool _waiting = false;
  bool _cancelled = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _session = ref.read(sessionProvider.notifier);
  }

  @override
  void dispose() {
    if (_waiting) _session.cancelGitHub();
    super.dispose();
  }

  /// First time with GitHub: link it to the guest, keeping their data. If the
  /// GitHub account turns out to be registered already, sign in to it instead.
  Future<void> _continueWithGitHub() async {
    _begin();
    final result = await _session.linkGitHub();
    if (!mounted) return;

    if (result.failureOrNull is GitHubAccountExistsFailure && !_cancelled) {
      await _signInToExisting();
      return;
    }
    _finish(result.isSuccess, result.failureOrNull?.message);
  }

  /// Sign in to the account GitHub already belongs to. Supabase may show its
  /// "already linked" error in the browser instead of redirecting back, so this
  /// is also offered directly ("Already have an account?").
  Future<void> _signInToExisting() async {
    if (ref.read(guestHasDataProvider)) {
      setState(() => _waiting = false); // nothing is pending while asking
      final confirmed = await showGuestDataWarningDialog(context);
      if (!mounted || !confirmed) return;
    }
    _begin();
    final result = await _session.signInWithGitHub();
    if (!mounted) return;
    _finish(result.isSuccess, result.failureOrNull?.message);
  }

  void _begin() => setState(() {
    _waiting = true;
    _cancelled = false;
    _error = null;
  });

  void _finish(bool success, String? error) {
    if (success) {
      _waiting = false; // nothing left to cancel on dispose
      Navigator.pop(context);
      return;
    }
    setState(() {
      _waiting = false;
      _error = _cancelled ? null : error;
    });
  }

  /// Back to the first state; the dialog stays open.
  void _cancelWaiting() {
    _cancelled = true;
    _session.cancelGitHub();
    setState(() => _waiting = false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: Text(
              _waiting ? 'Waiting for GitHub' : 'Account',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: _waiting ? _waitingBody(context) : _startBody(context),
      ),
      actions: [
        TextButton(
          onPressed: _waiting ? _cancelWaiting : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _startBody(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = TextStyle(fontSize: 12, color: scheme.onSurfaceVariant);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'You are using Test Point as a guest.',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: _continueWithGitHub,
            icon: Image.asset(
              'assets/images/github.png',
              width: 20,
              height: 20,
              filterQuality: FilterQuality.medium,
              excludeFromSemantics: true,
            ),
            label: const Text(
              'Continue with GitHub',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: scheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                'Signing in with GitHub keeps your guest workspace.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: _signInToExisting,
          child: const Text(
            'Already have an account? Sign in with GitHub',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.md),
          Text(_error!, style: TextStyle(color: scheme.error)),
        ],
      ],
    );
  }

  Widget _waitingBody(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(strokeWidth: 3),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Finish signing in in your browser.',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'We will bring you back here when you are done.',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
