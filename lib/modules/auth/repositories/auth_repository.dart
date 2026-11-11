import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/auth/models/auth_user.dart';

abstract interface class AuthRepository {
  /// The user of the stored session, or `null` if there is none.
  AuthUser? get currentUser;

  /// Emits whenever the session user changes (sign in, sign out, link).
  Stream<AuthUser?> get userChanges;

  /// Starts a guest session.
  Future<Result<AuthUser>> signInAnonymously();

  /// Opens GitHub in the browser and links it to the current guest (same user
  /// id, so all data is kept). Completes when the browser returns to the app.
  /// Fails with `GitHubAccountExistsFailure` if the GitHub account is already
  /// registered.
  Future<Result<AuthUser>> linkGitHub();

  /// Opens GitHub in the browser and signs in to the account it belongs to,
  /// replacing the current session. Completes when the browser returns.
  Future<Result<AuthUser>> signInWithGitHub();

  /// Stops waiting for the browser; the pending call completes with a failure.
  void cancelPendingGitHub();

  Future<Result<void>> signOut();
}
