/// Application-level failure. Infrastructure errors are mapped to one of
/// these in repositories so the UI never sees raw exceptions.
sealed class Failure {
  const Failure(this.message);

  /// Human-readable message that is safe to show in the UI.
  final String message;

  @override
  String toString() => '$runtimeType($message)';
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Something went wrong.']);
}
