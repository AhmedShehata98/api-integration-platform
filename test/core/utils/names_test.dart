import 'package:flutter_test/flutter_test.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/utils/names.dart';

void main() {
  group('validateName', () {
    test('trims a valid name', () {
      final result = validateName('  Users API ');

      expect(result.name, 'Users API');
      expect(result.failure, isNull);
    });

    test('rejects blank names, naming the field', () {
      final result = validateName('   ', label: 'Collection name');

      expect(result.name, isNull);
      expect(result.failure, isA<ValidationFailure>());
      expect(result.failure!.message, 'Collection name is required.');
    });

    test('rejects names over the column limit', () {
      final result = validateName('x' * (maxNameLength + 1));

      expect(result.failure!.message, contains('$maxNameLength'));
      expect(validateName('x' * maxNameLength).failure, isNull);
    });
  });

  group('nextCopyName', () {
    test('adds " copy"', () {
      expect(nextCopyName('Users', ['Users']), 'Users copy');
    });

    test('numbers further copies', () {
      expect(nextCopyName('Users', ['Users', 'Users copy']), 'Users copy 2');
      expect(
        nextCopyName('Users', ['Users', 'Users copy', 'Users copy 2']),
        'Users copy 3',
      );
    });

    test('duplicating a copy does not stack suffixes', () {
      expect(
        nextCopyName('Users copy', ['Users', 'Users copy']),
        'Users copy 2',
      );
      expect(
        nextCopyName('Users copy 2', ['Users', 'Users copy', 'Users copy 2']),
        'Users copy 3',
      );
    });

    test('ignores case when checking for clashes', () {
      expect(nextCopyName('Users', ['USERS COPY']), 'Users copy 2');
    });
  });
}
