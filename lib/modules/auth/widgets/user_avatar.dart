import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_point/modules/auth/providers/auth_providers.dart';
import 'package:test_point/modules/auth/widgets/account_dialog.dart';

/// Avatar for the nav rail: a person icon for guests, the initial once signed
/// in. Clicking it opens the Account dialog.
class UserAvatar extends ConsumerWidget {
  const UserAvatar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final user = ref.watch(sessionProvider).value;
    final signedIn = user != null && !user.isAnonymous;

    return Tooltip(
      message: signedIn ? user.label ?? 'Account' : 'Guest',
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => showAccountDialog(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: signedIn
                ? scheme.primaryContainer
                : scheme.surfaceContainerHigh,
            child: signedIn
                ? Text(
                    user.initial,
                    style: TextStyle(
                      fontSize: 14,
                      color: scheme.onPrimaryContainer,
                    ),
                  )
                : Icon(
                    Icons.person_outline,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
          ),
        ),
      ),
    );
  }
}
