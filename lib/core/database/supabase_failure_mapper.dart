import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test_point/core/error/failure.dart';

/// Maps an exception thrown by the Supabase client to a [Failure].
/// Used by repository implementations so infrastructure errors never reach the UI.
Failure mapSupabaseError(Object error) {
  return switch (error) {
    AuthRetryableFetchException() => const NetworkFailure(_offlineMessage),
    AuthException(:final message) => AuthFailure(message),
    PostgrestException(:final message) => StorageFailure(message),
    SocketException() ||
    TimeoutException() ||
    HttpException() => const NetworkFailure(_offlineMessage),
    _ => const UnexpectedFailure(),
  };
}

const _offlineMessage = 'Cannot reach the server. Check your connection.';
