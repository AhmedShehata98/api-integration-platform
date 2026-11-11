import 'package:flutter_test/flutter_test.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/error/result.dart';

void main() {
  group('Result', () {
    test('success exposes value and no failure', () {
      const result = Result<int>.success(1);

      expect(result.isSuccess, isTrue);
      expect(result.valueOrNull, 1);
      expect(result.failureOrNull, isNull);
    });

    test('failure exposes failure and no value', () {
      const result = Result<int>.failure(ValidationFailure('Name is required'));

      expect(result.isSuccess, isFalse);
      expect(result.valueOrNull, isNull);
      expect(result.failureOrNull, isA<ValidationFailure>());
    });

    test('when picks the matching branch', () {
      const ok = Result<int>.success(2);
      const bad = Result<int>.failure(NetworkFailure('offline'));

      expect(ok.when(success: (v) => 'v$v', failure: (f) => f.message), 'v2');
      expect(
        bad.when(success: (v) => 'v$v', failure: (f) => f.message),
        'offline',
      );
    });
  });
}
