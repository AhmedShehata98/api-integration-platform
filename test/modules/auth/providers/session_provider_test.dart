import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/auth/auth.dart';

import '../../../support/fake_backend.dart';

ProviderContainer _container(AuthRepository repository) =>
    ProviderContainer.test(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );

void main() {
  test('reuses the stored session without signing in again', () async {
    const stored = AuthUser(id: 'u1', isAnonymous: false, email: 'a@b.co');
    final repository = stubAuth(user: stored);

    final user = await _container(repository).read(sessionProvider.future);

    expect(user, stored);
    verifyNever(() => repository.signInAnonymously());
  });

  test('starts a guest session when none is stored', () async {
    final repository = stubAuth(user: null);

    final user = await _container(repository).read(sessionProvider.future);

    expect(user, guestUser);
    verify(() => repository.signInAnonymously()).called(1);
  });

  test('exposes the failure when guest sign-in fails', () async {
    final repository = stubAuth(user: null);
    when(
      () => repository.signInAnonymously(),
    ).thenAnswer((_) async => const Result.failure(NetworkFailure('offline')));
    final container = _container(repository);

    await expectLater(
      container.read(sessionProvider.future),
      throwsA(isA<NetworkFailure>()),
    );
  });

  test('AuthUser.initial uses the email, or ? without one', () {
    expect(
      const AuthUser(id: '1', isAnonymous: false, email: 'zed@x.co').initial,
      'Z',
    );
    expect(guestUser.initial, '?');
  });
}
