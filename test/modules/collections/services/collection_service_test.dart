import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/collections/models/collection.dart';
import 'package:test_point/modules/collections/repositories/collection_repository.dart';
import 'package:test_point/modules/collections/services/collection_service.dart';

class MockCollectionRepository extends Mock implements CollectionRepository {}

Collection _collection(String id, String name, [int position = 0]) =>
    Collection(id: id, workspaceId: 'ws', name: name, position: position);

void main() {
  late MockCollectionRepository repository;
  late CollectionService service;

  setUp(() {
    repository = MockCollectionRepository();
    service = CollectionService(repository);
  });

  group('create', () {
    void stubCreate() => when(
      () => repository.create(
        workspaceId: any(named: 'workspaceId'),
        name: any(named: 'name'),
        position: any(named: 'position'),
      ),
    ).thenAnswer((i) async => Result.success(_collection('new', 'x')));

    test('rejects a blank name without calling the repository', () async {
      final result = await service.create(
        workspaceId: 'ws',
        name: '  ',
        existing: const [],
      );

      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(result.failureOrNull!.message, 'Collection name is required.');
      verifyNever(
        () => repository.create(
          workspaceId: any(named: 'workspaceId'),
          name: any(named: 'name'),
          position: any(named: 'position'),
        ),
      );
    });

    test('trims the name and starts positions at 0', () async {
      stubCreate();

      await service.create(
        workspaceId: 'ws',
        name: ' Users ',
        existing: const [],
      );

      verify(
        () => repository.create(workspaceId: 'ws', name: 'Users', position: 0),
      );
    });

    test('puts the new collection after the highest position', () async {
      stubCreate();

      await service.create(
        workspaceId: 'ws',
        name: 'Users',
        existing: [_collection('a', 'A', 4), _collection('b', 'B', 1)],
      );

      verify(
        () => repository.create(workspaceId: 'ws', name: 'Users', position: 5),
      );
    });
  });

  group('rename', () {
    test('rejects a blank name', () async {
      final result = await service.rename('c1', '');

      expect(result.failureOrNull, isA<ValidationFailure>());
      verifyNever(() => repository.rename(any(), any()));
    });

    test('passes the trimmed name on', () async {
      when(() => repository.rename(any(), any()))
          .thenAnswer((_) async => Result.success(_collection('c1', 'New')));

      await service.rename('c1', ' New ');

      verify(() => repository.rename('c1', 'New'));
    });
  });

  test('duplicate picks a non-clashing copy name', () async {
    when(() => repository.duplicate(any(), any())).thenAnswer(
      (_) async => Result.success(_collection('c2', 'Users copy 2')),
    );
    final users = _collection('c1', 'Users');

    await service.duplicate(users, [users, _collection('c9', 'Users copy')]);

    verify(() => repository.duplicate('c1', 'Users copy 2'));
  });

  test('repository failures are passed through', () async {
    when(
      () => repository.delete(any()),
    ).thenAnswer((_) async => const Result.failure(NetworkFailure('offline')));

    final result = await service.delete('c1');

    expect(result.failureOrNull!.message, 'offline');
  });
}
