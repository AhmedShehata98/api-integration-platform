import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/network/dio_failure_mapper.dart';

final _options = RequestOptions(path: 'http://a.test');

DioException _error(DioExceptionType type, [Object? error]) =>
    DioException(requestOptions: _options, type: type, error: error);

void main() {
  test('timeouts map to a timeout message', () {
    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
    ]) {
      final failure = mapDioError(_error(type));

      expect(failure, isA<NetworkFailure>());
      expect(failure.message, 'The request timed out.');
    }
  });

  test('DNS lookup failure is called out', () {
    final failure = mapDioError(
      _error(
        DioExceptionType.connectionError,
        const SocketException(
          'Failed host lookup: nope.invalid',
          osError: OSError('No such host is known', 11001),
        ),
      ),
    );

    expect(failure.message, contains('resolve the host'));
  });

  test('other connection errors are generic', () {
    final failure = mapDioError(
      _error(
        DioExceptionType.connectionError,
        const SocketException(
          'Connection refused',
          osError: OSError('refused', 10061),
        ),
      ),
    );

    expect(failure, isA<NetworkFailure>());
    expect(failure.message, 'Could not connect to the server.');
  });

  test('cancel and certificate errors', () {
    expect(
      mapDioError(_error(DioExceptionType.cancel)).message,
      'Request cancelled.',
    );
    expect(
      mapDioError(_error(DioExceptionType.badCertificate)).message,
      contains('certificate'),
    );
  });

  test('unknown errors map to UnexpectedFailure', () {
    expect(
      mapDioError(_error(DioExceptionType.unknown)),
      isA<UnexpectedFailure>(),
    );
  });
}
