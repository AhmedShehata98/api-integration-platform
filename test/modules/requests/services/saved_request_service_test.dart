import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/requests/models/http_method.dart';
import 'package:test_point/modules/requests/models/http_request_draft.dart';
import 'package:test_point/modules/requests/models/saved_request.dart';
import 'package:test_point/modules/requests/repositories/saved_request_repository.dart';
import 'package:test_point/modules/requests/services/saved_request_service.dart';

class MockSavedRequestRepository extends Mock
    implements SavedRequestRepository {}

const _draft = HttpRequestDraft(method: HttpMethod.post, url: 'http://a.test');

SavedRequest _saved(
  String id,
  String name, {
  String collectionId = 'c1',
  int position = 0,
}) => SavedRequest(
  id: id,
  collectionId: collectionId,
  name: name,
  position: position,
  draft: _draft,
);

void main() {
  late MockSavedRequestRepository repository;
  late SavedRequestService service;

  setUpAll(() => registerFallbackValue(_draft));

  setUp(() {
    repository = MockSavedRequestRepository();
    service = SavedRequestService(repository);
    when(
      () => repository.create(
        collectionId: any(named: 'collectionId'),
        name: any(named: 'name'),
        position: any(named: 'position'),
        draft: any(named: 'draft'),
      ),
    ).thenAnswer((_) async => Result.success(_saved('new', 'x')));
  });

  group('create', () {
    test('rejects a blank name', () async {
      final result = await service.create(
        collectionId: 'c1',
        name: ' ',
        draft: _draft,
        existing: const [],
      );

      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(result.failureOrNull!.message, 'Request name is required.');
    });

    test(
      'appends after the highest position in that collection only',
      () async {
        await service.create(
          collectionId: 'c1',
          name: ' Get users ',
          draft: _draft,
          existing: [
            _saved('a', 'A', position: 2),
            _saved('b', 'B', collectionId: 'c2', position: 9),
          ],
        );

        verify(
          () => repository.create(
            collectionId: 'c1',
            name: 'Get users',
            position: 3,
            draft: _draft,
          ),
        );
      },
    );
  });

  test('update validates the name and sends the draft', () async {
    when(
      () => repository.update(
        any(),
        name: any(named: 'name'),
        draft: any(named: 'draft'),
      ),
    ).thenAnswer((_) async => Result.success(_saved('r1', 'Renamed')));

    final bad = await service.update('r1', name: '', draft: _draft);
    expect(bad.failureOrNull, isA<ValidationFailure>());

    await service.update('r1', name: 'Renamed', draft: _draft);
    verify(() => repository.update('r1', name: 'Renamed', draft: _draft));
  });

  test('rename validates the name', () async {
    final result = await service.rename('r1', '  ');

    expect(result.failureOrNull, isA<ValidationFailure>());
    verifyNever(() => repository.rename(any(), any()));
  });

  group('duplicate', () {
    test('copies into the same collection under a unique copy name', () async {
      final source = _saved('a', 'Get users', position: 0);

      await service.duplicate(source, [
        source,
        _saved('b', 'Get users copy', position: 1),
        // Same name in another collection does not count as a clash.
        _saved('c', 'Get users copy 2', collectionId: 'c2'),
      ]);

      verify(
        () => repository.create(
          collectionId: 'c1',
          name: 'Get users copy 2',
          position: 2,
          draft: _draft,
        ),
      );
    });
  });
}
