import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/modules/collections/collections.dart';
import 'package:test_point/modules/requests/requests.dart';

import '../../../support/fake_backend.dart';

const _users = Collection(id: 'c1', workspaceId: 'ws-1', name: 'Users');
const _draft = HttpRequestDraft(
  method: HttpMethod.post,
  url: 'http://a.test/users',
);

SavedRequest _saved(String id, String name, {int position = 0}) => SavedRequest(
  id: id,
  collectionId: 'c1',
  name: name,
  position: position,
  draft: _draft,
);

ProviderContainer _container(FakeStore store) {
  final container = ProviderContainer.test(
    overrides: fakeBackend(store: store),
  );
  // Tabs listen to saved requests; keep both alive like the real app does.
  container.listen(requestTabsProvider, (_, _) {});
  return container;
}

/// Opens a tab holding [draft] and returns its id.
String _openTab(ProviderContainer container, {String? collectionId}) {
  final tabs = container.read(requestTabsProvider.notifier);
  final id = tabs.openNew(collectionId: collectionId);
  tabs.editActive((_) => _draft);
  return id;
}

Future<List<String>> _names(ProviderContainer container) async => [
  for (final r in await container.read(savedRequestsProvider.future)) r.name,
];

void main() {
  test('no collections means no requests (and no query)', () async {
    final container = _container(FakeStore());

    expect(await container.read(savedRequestsProvider.future), isEmpty);
  });

  test('loads the requests of all collections', () async {
    final container = _container(
      FakeStore(
        collections: [_users],
        requests: [_saved('r1', 'List'), _saved('r2', 'Create')],
      ),
    );

    expect(await _names(container), ['List', 'Create']);
  });

  test('a load failure becomes the provider error', () async {
    final store = FakeStore(collections: [_users]);
    final container = _container(store);
    await container.read(collectionsProvider.future);
    store.failure = const NetworkFailure('offline');
    container.invalidate(savedRequestsProvider);

    await expectLater(
      container.read(savedRequestsProvider.future),
      throwsA(isA<NetworkFailure>()),
    );
  });

  group('saveTab', () {
    test(
      'creates the request in the chosen collection and links the tab',
      () async {
        final store = FakeStore(collections: [_users]);
        final container = _container(store);
        await container.read(savedRequestsProvider.future);
        final tabId = _openTab(container);

        final result = await container
            .read(savedRequestsProvider.notifier)
            .saveTab(tabId, collectionId: 'c1', name: ' Create user ');

        final saved = result.valueOrNull!;
        expect(saved.name, 'Create user');
        expect(saved.draft, _draft);
        expect(store.requests, [saved]);
        final tab = container.read(requestTabsProvider).tabs.single;
        expect(tab.savedRequestId, saved.id);
        expect(tab.name, 'Create user');
        expect(tab.isDirty, isFalse);
        expect(await _names(container), ['Create user']);
      },
    );

    test('a saved tab is updated in place', () async {
      final store = FakeStore(collections: [_users]);
      final container = _container(store);
      await container.read(savedRequestsProvider.future);
      final tabId = _openTab(container);
      final notifier = container.read(savedRequestsProvider.notifier);
      await notifier.saveTab(tabId, collectionId: 'c1', name: 'Create user');

      container
          .read(requestTabsProvider.notifier)
          .editActive((d) => d.copyWith(url: 'http://a.test/v2'));
      expect(container.read(requestTabsProvider).tabs.single.isDirty, isTrue);
      final result = await notifier.saveTab(tabId);

      expect(result.isSuccess, isTrue);
      expect(store.requests, hasLength(1));
      expect(store.requests.single.draft.url, 'http://a.test/v2');
      expect(container.read(requestTabsProvider).tabs.single.isDirty, isFalse);
    });

    test('a new tab needs a collection', () async {
      final container = _container(FakeStore(collections: [_users]));
      final tabId = _openTab(container);

      final result = await container
          .read(savedRequestsProvider.notifier)
          .saveTab(tabId, name: 'x');

      expect(result.failureOrNull, isA<ValidationFailure>());
    });

    test('a blank name is rejected and nothing is stored', () async {
      final store = FakeStore(collections: [_users]);
      final container = _container(store);
      final tabId = _openTab(container);

      final result = await container
          .read(savedRequestsProvider.notifier)
          .saveTab(tabId, collectionId: 'c1', name: '  ');

      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(store.requests, isEmpty);
      expect(container.read(requestTabsProvider).tabs.single.isSaved, isFalse);
    });

    test('a failed save leaves the tab unsaved', () async {
      final store = FakeStore(collections: [_users]);
      final container = _container(store);
      await container.read(savedRequestsProvider.future);
      final tabId = _openTab(container);
      store.failure = const NetworkFailure('offline');

      final result = await container
          .read(savedRequestsProvider.notifier)
          .saveTab(tabId, collectionId: 'c1', name: 'x');

      expect(result.failureOrNull, isA<NetworkFailure>());
      final tab = container.read(requestTabsProvider).tabs.single;
      expect(tab.isSaved, isFalse);
      expect(tab.isDirty, isTrue);
    });

    test('closed tabs cannot be saved', () async {
      final container = _container(FakeStore(collections: [_users]));

      final result = await container
          .read(savedRequestsProvider.notifier)
          .saveTab('gone', collectionId: 'c1', name: 'x');

      expect(result.failureOrNull, isA<ValidationFailure>());
    });
  });

  test('saveTabInNewCollection creates the collection first', () async {
    final store = FakeStore();
    final container = _container(store);
    await container.read(savedRequestsProvider.future);
    final tabId = _openTab(container);

    final result = await container
        .read(savedRequestsProvider.notifier)
        .saveTabInNewCollection(
          tabId,
          collectionName: 'Fresh',
          name: 'First request',
        );

    expect(result.isSuccess, isTrue);
    expect(store.collections.single.name, 'Fresh');
    expect(store.requests.single.collectionId, store.collections.single.id);
  });

  test(
    'saveTabInNewCollection stops if the collection name is invalid',
    () async {
      final store = FakeStore();
      final container = _container(store);
      final tabId = _openTab(container);

      final result = await container
          .read(savedRequestsProvider.notifier)
          .saveTabInNewCollection(tabId, collectionName: ' ', name: 'x');

      expect(result.failureOrNull!.message, 'Collection name is required.');
      expect(store.requests, isEmpty);
    },
  );

  test('rename, duplicate and delete update the list', () async {
    final store = FakeStore(
      collections: [_users],
      requests: [_saved('r1', 'List'), _saved('r2', 'Create', position: 1)],
    );
    final container = _container(store);
    final notifier = container.read(savedRequestsProvider.notifier);
    await container.read(savedRequestsProvider.future);

    await notifier.rename('r1', 'List all');
    await notifier.duplicate(store.requests.first);
    await notifier.delete('r2');

    expect(await _names(container), ['List all', 'List all copy']);
  });
}
