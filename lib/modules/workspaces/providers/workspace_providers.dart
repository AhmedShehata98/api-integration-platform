import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_point/core/database/supabase_client_provider.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/modules/auth/auth.dart';
import 'package:test_point/modules/workspaces/models/workspace.dart';
import 'package:test_point/modules/workspaces/repositories/workspace_repository.dart';
import 'package:test_point/modules/workspaces/repositories/workspace_repository_impl.dart';

final workspaceRepositoryProvider = Provider<WorkspaceRepository>(
  (ref) => WorkspaceRepositoryImpl(ref.watch(supabaseClientProvider)),
);

/// The current workspace. Reloads when the session user changes.
/// Errors carry a `Failure` as the error object.
final currentWorkspaceProvider = FutureProvider<Workspace>(
  (ref) async {
    final user = await ref.watch(sessionProvider.future);
    if (user == null) {
      throw const AuthFailure('No active session.');
    }

    final result = await ref.watch(workspaceRepositoryProvider).loadDefault();
    return result.when(
      success: (workspace) => workspace,
      failure: (failure) => throw failure,
    );
  },
  retry: (_, _) => null, // the shell offers a manual Retry instead
);
