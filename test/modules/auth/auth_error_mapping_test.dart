import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/modules/auth/auth.dart';
import 'package:test_point/modules/auth/repositories/auth_repository_impl.dart';

void main() {
  group('mapAuthError', () {
    test('an already-registered GitHub account is recognised', () {
      // What a failed redirect produces (see gotrue getSessionFromUrl).
      for (final error in [
        const AuthException(
          'Identity is already linked to another user',
          statusCode: 'identity_already_exists',
          code: 'server_error',
        ),
        const AuthException('Identity is already linked', statusCode: '422'),
        const AuthException(
          'A user with this email address has already been registered',
          statusCode: 'email_exists',
        ),
        const AuthException('x', code: 'user_already_exists'),
      ]) {
        expect(mapAuthError(error), isA<GitHubAccountExistsFailure>());
      }
    });

    test('other redirect errors get clear messages', () {
      expect(
        mapAuthError(const AuthException('denied', code: 'access_denied'))
            .message,
        'GitHub sign-in was cancelled.',
      );
      expect(
        mapAuthError(
          const AuthException('Unsupported provider: provider is not enabled'),
        ).message,
        'GitHub sign-in is not available right now.',
      );
      expect(
        mapAuthError(
          const AuthException('x', statusCode: 'over_request_rate_limit'),
        ),
        isA<AuthFailure>(),
      );
    });

    test('unknown errors fall back to the shared mapper', () {
      expect(mapAuthError(StateError('boom')), isA<Failure>());
      expect(
        mapAuthError(StateError('boom')),
        isNot(isA<GitHubAccountExistsFailure>()),
      );
    });
  });
}
