import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_point/modules/auth/providers/auth_providers.dart';

/// Shows a snackbar when a GitHub redirect fails while no dialog is waiting
/// for it (for example when the browser started the app fresh).
class AuthCallbackErrorListener extends ConsumerWidget {
  const AuthCallbackErrorListener({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authCallbackErrorProvider, (_, next) {
      final failure = next.value;
      if (failure == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            failure.message,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    });
    return child;
  }
}
