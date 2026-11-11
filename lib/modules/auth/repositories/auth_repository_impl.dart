import 'dart:async';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:test_point/core/database/supabase_failure_mapper.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/auth/models/auth_user.dart';
import 'package:test_point/modules/auth/models/github_account_exists_failure.dart';
import 'package:test_point/modules/auth/repositories/auth_repository.dart';

/// Where GitHub sends the browser back to. Registered as a URL scheme in the
/// desktop runners and listed in Supabase's allowed redirect URLs.
const authRedirectUrl = 'testpoint://auth-callback';

/// How long to wait for the user to finish in the browser.
const _browserTimeout = Duration(minutes: 5);

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._client);

  final supabase.SupabaseClient _client;

  Completer<Result<AuthUser>>? _pending;
  StreamSubscription<supabase.AuthState>? _pendingSubscription;
  Timer? _pendingTimeout;

  @override
  AuthUser? get currentUser => _toAuthUser(_client.auth.currentUser);

  @override
  Stream<AuthUser?> get userChanges => _client.auth.onAuthStateChange
      // Errors from the OAuth redirect arrive on this stream too. The pending
      // GitHub call in `_viaBrowser` reports them; here they are not user
      // changes, so drop them instead of leaving them unhandled.
      .handleError((Object _) {})
      .map((state) => _toAuthUser(state.session?.user))
      .distinct();

  @override
  Future<Result<AuthUser>> signInAnonymously() async {
    try {
      final user = _toAuthUser((await _client.auth.signInAnonymously()).user);
      if (user == null) {
        return const Result.failure(
          AuthFailure('Could not start a guest session.'),
        );
      }
      return Result.success(user);
    } on Object catch (error) {
      return Result.failure(_mapError(error));
    }
  }

  @override
  Future<Result<AuthUser>> linkGitHub() => _viaBrowser(
    () => _client.auth.linkIdentity(
      supabase.OAuthProvider.github,
      redirectTo: authRedirectUrl,
    ),
  );

  @override
  Future<Result<AuthUser>> signInWithGitHub() => _viaBrowser(
    () => _client.auth.signInWithOAuth(
      supabase.OAuthProvider.github,
      redirectTo: authRedirectUrl,
    ),
  );

  @override
  void cancelPendingGitHub() => _finish(
    const Result.failure(AuthFailure('GitHub sign-in was cancelled.')),
  );

  @override
  Future<Result<void>> signOut() async {
    try {
      await _client.auth.signOut();
      return const Result.success(null);
    } on Object catch (error) {
      return Result.failure(_mapError(error));
    }
  }

  /// Opens the browser, then waits for Supabase to report a signed-in account
  /// (or an error from the redirect).
  Future<Result<AuthUser>> _viaBrowser(Future<bool> Function() launch) async {
    cancelPendingGitHub();
    final completer = Completer<Result<AuthUser>>();
    _pending = completer;
    _pendingSubscription = _client.auth.onAuthStateChange.listen((state) {
      final user = _toAuthUser(state.session?.user);
      if (user != null && !user.isAnonymous) _finish(Result.success(user));
    }, onError: (Object error) => _finish(Result.failure(_mapError(error))));
    _pendingTimeout = Timer(
      _browserTimeout,
      () => _finish(
        const Result.failure(
          AuthFailure('GitHub sign-in timed out. Try again.'),
        ),
      ),
    );

    try {
      if (!await launch()) {
        _finish(
          const Result.failure(AuthFailure('Could not open your browser.')),
        );
      }
    } on Object catch (error) {
      _finish(Result.failure(_mapError(error)));
    }
    return completer.future;
  }

  void _finish(Result<AuthUser> result) {
    final completer = _pending;
    _pending = null;
    unawaited(_pendingSubscription?.cancel());
    _pendingSubscription = null;
    _pendingTimeout?.cancel();
    _pendingTimeout = null;
    if (completer != null && !completer.isCompleted) completer.complete(result);
  }

  Failure _mapError(Object error) => mapAuthError(error);

  AuthUser? _toAuthUser(supabase.User? user) {
    if (user == null) return null;
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final name = metadata['user_name'] ?? metadata['full_name'];
    return AuthUser(
      id: user.id,
      isAnonymous: user.isAnonymous,
      email: user.email,
      name: name is String ? name : null,
    );
  }
}

/// Turns a Supabase error into a `Failure` with a clear message. Public only
/// so tests can feed it the exact exceptions `supabase_flutter` produces.
///
/// For a redirect error the `AuthException` carries the description as
/// `message`, the `error_code` as `statusCode` and the `error` as `code`.
@visibleForTesting
Failure mapAuthError(Object error) {
  if (error is supabase.AuthException) {
    final text = '${error.code} ${error.statusCode} ${error.message}'
        .toLowerCase();
    // The GitHub account (or its email) already belongs to a Test Point user.
    if (text.contains('identity_already_exists') ||
        text.contains('already linked') ||
        text.contains('email_exists') ||
        text.contains('user_already_exists') ||
        text.contains('already been registered') ||
        text.contains('already registered') ||
        text.contains('already exists')) {
      return const GitHubAccountExistsFailure();
    }
    if (text.contains('access_denied')) {
      return const AuthFailure('GitHub sign-in was cancelled.');
    }
    if (text.contains('provider_disabled') ||
        text.contains('manual_linking_disabled') ||
        text.contains('not enabled')) {
      return const AuthFailure('GitHub sign-in is not available right now.');
    }
    if (text.contains('rate_limit')) {
      return const AuthFailure('Too many attempts. Try again in a minute.');
    }
  }
  return mapSupabaseError(error);
}
