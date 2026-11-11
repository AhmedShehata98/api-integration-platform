import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test_point/core/database/supabase_failure_mapper.dart';
import 'package:test_point/core/error/failure.dart';

void main() {
  test('maps AuthException to AuthFailure with its message', () {
    final failure = mapSupabaseError(const AuthException('Invalid login'));

    expect(failure, isA<AuthFailure>());
    expect(failure.message, 'Invalid login');
  });

  test('maps PostgrestException to StorageFailure', () {
    final failure = mapSupabaseError(const PostgrestException(message: 'boom'));

    expect(failure, isA<StorageFailure>());
    expect(failure.message, 'boom');
  });

  test('maps retryable auth fetch errors to NetworkFailure', () {
    final failure = mapSupabaseError(AuthRetryableFetchException());

    expect(failure, isA<NetworkFailure>());
  });

  test('maps socket and timeout errors to NetworkFailure', () {
    expect(
      mapSupabaseError(const SocketException('down')),
      isA<NetworkFailure>(),
    );
    expect(mapSupabaseError(TimeoutException('slow')), isA<NetworkFailure>());
  });

  test('maps anything else to UnexpectedFailure', () {
    expect(mapSupabaseError(StateError('x')), isA<UnexpectedFailure>());
  });
}
