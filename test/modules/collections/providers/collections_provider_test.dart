import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/modules/collections/collections.dart';
import 'package:test_point/modules/requests/requests.dart';

import '../../../support/fake_backend.dart';

Collection _col(String id, String name, [int position = 0]) =>
    Collection(id: id, workspaceId: 'ws-1', name: name, position: position);

ProviderContainer _container(FakeStore store) =>
    ProviderContainer.test(overrides: fakeBackend(store: store));

Future<List<String>> _names(ProviderContainer container) async => [
  for (final c in await container.read(collectionsProvider.future)) c.name,
];

void main() {
  test('loads the collections of the current workspace', () async {
    final container = _container(
      FakeStore(collections: [_col('c1', 'Users'), _col('c2', 'Billing')]),
    );

    expect(await _names(container), ['Users', 'Billing']);
  });

  test('a load failure becomes the provider error', () async {
    final container = _container(
      FakeStore()..failure = const NetworkFailure('offline'),
    );

    await expectLater(
      container.read(collectionsProvider.future),
      throwsA(isA<NetworkFailure>()),
    );
  });

  test('create adds the collection after the existing ones', () async {
    final container = _container(FakeStore(collections: [_col('c1', 'A', 4)]));
    await container.read(collectionsProvider.future);

    final result = await container
        .read(collectionsProvider.notifier)
        .create('  B ');

    expect(result.valueOrNull!.position, 5);
    expect(await _names(container), ['A', 'B']);
  });

  test('create with a blank name fails and changes nothing', () async {
    final container = _container(FakeStore(collections: [_col('c1', 'A')]));
    await container.read(collectionsProvider.future);

    final result = await container
        .read(collectionsProvider.notifier)
        .create('   ');

    expect(result.failureOrNull, isA<ValidationFailure>());
    expect(await _names(container), ['A']);
  });

  test('rename updates the collection in place', () async {
    final container = _container(
      FakeStore(collections: [_col('c1', 'A'), _col('c2', 'B')]),
    );
    await container.read(collectionsProvider.future);

    await container.read(collectionsProvider.notifier).rename('c2', 'Bee');

    expect(await _names(container), ['A', 'Bee']);
  });

  test('delete removes the collection', () async {
    final container = _container(
      FakeStore(collections: [_col('c1', 'A'), _col('c2', 'B')]),
    );
    await container.read(collectionsProvider.future);

    await container.read(collectionsProvider.notifier).delete('c1');

    expect(await _names(container), ['B']);
  });

  test('a failed server call leaves the list as it was', () async {
    final store = FakeStore(collections: [_col('c1', 'A')]);
    final container = _container(store);
    await container.read(collectionsProvider.future);
    store.failure = const NetworkFailure('offline');

    final result = await container
        .read(collectionsProvider.notifier)
        .delete('c1');

    expect(result.failureOrNull, isA<NetworkFailure>());
    expect(await _names(container), ['A']);
  });

  test('duplicate adds "X copy", with its requests, once reloaded', () async {
    final store = FakeStore(
      collections: [_col('c1', 'Users')],
      requests: [
        const SavedRequest(
          id: 'r1',
          collectionId: 'c1',
          name: 'List',
          draft: HttpRequestDraft(url: 'http://a.test'),
        ),
      ],
    );
    final container = _container(store);
    final collections = await container.read(collectionsProvider.future);
    // Keep the saved-requests provider alive so it reacts to the change.
    container.listen(savedRequestsProvider, (_, _) {});
    expect((await container.read(savedRequestsProvider.future)).length, 1);

    await container
        .read(collectionsProvider.notifier)
        .duplicate(collections.single);

    expect(await _names(container), ['Users', 'Users copy']);
    final requests = await container.read(savedRequestsProvider.future);
    expect(requests.map((r) => r.name), ['List', 'List']);
    expect(requests.map((r) => r.collectionId).toSet(), hasLength(2));
  });
}
