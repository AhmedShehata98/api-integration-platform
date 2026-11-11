import 'dart:io';

import 'package:dio/dio.dart';
import 'package:test_point/core/error/failure.dart';

/// Maps a [DioException] to a [Failure] with a message safe to show in the UI.
Failure mapDioError(DioException error) {
  return switch (error.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.transformTimeout ||
    DioExceptionType.receiveTimeout => const NetworkFailure(
      'The request timed out.',
    ),
    DioExceptionType.connectionError => NetworkFailure(
      _isDnsFailure(error.error)
          ? 'Could not resolve the host. Check the URL and your connection.'
          : 'Could not connect to the server.',
    ),
    DioExceptionType.badCertificate => const NetworkFailure(
      'The server certificate is not valid.',
    ),
    DioExceptionType.cancel => const NetworkFailure('Request cancelled.'),
    DioExceptionType.badResponse ||
    DioExceptionType.unknown => const UnexpectedFailure(),
  };
}

bool _isDnsFailure(Object? error) {
  if (error is! SocketException) return false;
  final text = '${error.message} ${error.osError?.message}'.toLowerCase();
  return text.contains('host') ||
      text.contains('lookup') ||
      text.contains('name or service') ||
      text.contains('nodename');
}
