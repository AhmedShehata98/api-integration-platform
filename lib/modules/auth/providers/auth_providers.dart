import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_point/core/database/supabase_client_provider.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/auth/models/auth_user.dart';
import 'package:test_point/modules/auth/repositories/auth_repository.dart';
import 'package:test_point/modules/auth/repositories/auth_repository_impl.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.watch(supabaseClientProvider)),
);

/// Whether the guest has work that signing in to another account would
/// discard (collections or environments). `auth` cannot see those modules, so
/// the app wires this in `app/di/`; the default is "no data".
final guestHasDataProvider = Provider<bool>((ref) => false);

/// Failures from a GitHub redirect nobody was waiting for.
final authCallbackErrorProvider = StreamProvider<Failure>(
  (ref) => ref.watch(authRepositoryProvider).callbackErrors,
);

/// The current session user. Starts a guest session when none is stored.
/// Errors carry a `Failure` as the error object.
final sessionProvider = AsyncNotifierProvider<SessionNotifier, AuthUser?>(
  SessionNotifier.new,
  retry: (_, _) => null, // the shell offers a manual Retry instead
);

class SessionNotifier extends AsyncNotifier<AuthUser?> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);

  @override
  Future<AuthUser?> build() async {
    final repository = ref.watch(authRepositoryProvider);

    final subscription = repository.userChanges.listen((user) {
      if (user != null) state = AsyncData(user);
    });
    ref.onDispose(subscription.cancel);

    final existing = repository.currentUser;
    if (existing != null) return existing;

    final result = await repository.signInAnonymously();
    return result.when(
      // A GitHub redirect that was being exchanged while the guest session
      // started may have signed in a real account meanwhile; keep that one.
      success: (guest) => repository.currentUser ?? guest,
      failure: (failure) => throw failure,
    );
  }

  /// Connects GitHub to the guest, keeping all of their data. Fails with
  /// `GitHubAccountExistsFailure` if that GitHub account is already registered.
  Future<Result<AuthUser>> linkGitHub() => _adopt(_repository.linkGitHub());

  /// Signs in to the account that owns the GitHub identity. The workspace,
  /// collections and environments reload for the new user.
  Future<Result<AuthUser>> signInWithGitHub() =>
      _adopt(_repository.signInWithGitHub());

  /// Stops waiting for the browser (the Cancel button).
  void cancelGitHub() => _repository.cancelPendingGitHub();

  /// Signs out and starts a fresh guest session.
  Future<Result<void>> signOut() async {
    final result = await _repository.signOut();
    if (!result.isSuccess) return result;

    state = const AsyncLoading();
    final guest = await _repository.signInAnonymously();
    state = guest.when(
      success: AsyncData.new,
      failure: (failure) => AsyncError(failure, StackTrace.current),
    );
    return guest;
  }

  Future<Result<AuthUser>> _adopt(Future<Result<AuthUser>> pending) async {
    final result = await pending;
    if (result case Success(:final value)) state = AsyncData(value);
    return result;
  }
}
