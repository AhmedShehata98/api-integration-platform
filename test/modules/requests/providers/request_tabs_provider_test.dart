import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/collections/collections.dart';
import 'package:test_point/modules/requests/models/prepared_request.dart';
import 'package:test_point/modules/requests/models/send_state.dart';
import 'package:test_point/modules/requests/requests.dart';

import '../../../support/fake_backend.dart';

class MockHttpRequestRepository extends Mock implements HttpRequestRepository {}

const _users = Collection(id: 'c1', workspaceId: 'ws-1', name: 'Users');
const _ok = HttpResponseResult(
  statusCode: 200,
  headers: {},
  body: 'ok',
  duration: Duration(milliseconds: 1),
  sizeBytes: 2,
);

SavedRequest _saved(String id, String name, {String url = 'http://a.test'}) =>
    SavedRequest(
      id: id,
      collectionId: 'c1',
      name: name,
      draft: HttpRequestDraft(url: url),
    );

ProviderContainer _container({FakeStore? store, HttpRequestRepository? http}) {
  final container = ProviderContainer.test(
    overrides: [
      ...fakeBackend(store: store),
      if (http != null) httpRequestRepositoryProvider.overrideWithValue(http),
    ],
  );
  container.listen(requestTabsProvider, (_, _) {});
  // The sidebar keeps saved requests loaded (and tabs reconciled) in the app.
  container.listen(savedRequestsProvider, (_, _) {});
  return container;
}

RequestTabsNotifier _tabs(ProviderContainer c) =>
    c.read(requestTabsProvider.notifier);

RequestTabsState _state(ProviderContainer c) => c.read(requestTabsProvider);

void main() {
  setUpAll(() {
    registerFallbackValue(PreparedRequest(method: 'GET', url: Uri()));
    registerFallbackValue(CancelSignal());
  });

  group('opening and closing', () {
    test('starts with no tabs', () {
      final container = _container();

      expect(_state(container).tabs, isEmpty);
      expect(_state(container).active, isNull);
    });

    test('openNew adds and activates an empty tab', () {
      final container = _container();

      final id = _tabs(container).openNew(collectionId: 'c1');

      final tab = _state(container).active!;
      expect(tab.id, id);
      expect(tab.name, untitledRequestName);
      expect(tab.collectionId, 'c1');
      expect(tab.isDirty, isFalse);
      expect(tab.isSaved, isFalse);
    });

    test('openSaved opens a clean tab, and reuses it the second time', () {
      final container = _container();
      final request = _saved('r1', 'List');

      _tabs(container).openSaved(request);
      final first = _state(container).active!;
      _tabs(container).openNew();
      _tabs(container).openSaved(request);

      expect(first.name, 'List');
      expect(first.isDirty, isFalse);
      expect(_state(container).tabs, hasLength(2));
      expect(_state(container).activeId, first.id);
    });

    test('closing the active tab activates its left neighbour', () {
      final container = _container();
      final a = _tabs(container).openNew();
      final b = _tabs(container).openNew();
      final c = _tabs(container).openNew();
      _tabs(container).activate(b);

      _tabs(container).close(b);
      expect(_state(container).activeId, a);

      _tabs(container).activate(c);
      _tabs(container).close(c);
      expect(_state(container).activeId, a);
    });

    test('closing the first active tab activates the next one', () {
      final container = _container();
      final a = _tabs(container).openNew();
      final b = _tabs(container).openNew();
      _tabs(container).activate(a);

      _tabs(container).close(a);

      expect(_state(container).activeId, b);
    });

    test('closing a background tab keeps the active one', () {
      final container = _container();
      final a = _tabs(container).openNew();
      final b = _tabs(container).openNew();

      _tabs(container).close(a);

      expect(_state(container).activeId, b);
    });

    test('closing the last tab leaves none active', () {
      final container = _container();
      final id = _tabs(container).openNew();

      _tabs(container).close(id);

      expect(_state(container).tabs, isEmpty);
      expect(_state(container).activeId, isNull);
    });
  });

  group('editing', () {
    test('edits apply to the active tab only', () {
      final container = _container();
      final first = _tabs(container).openNew();
      _tabs(container).openNew();

      container.read(requestDraftProvider.notifier).setUrl('http://b.test');

      expect(_state(container).active!.draft.url, 'http://b.test');
      _tabs(container).activate(first);
      expect(container.read(requestDraftProvider).url, '');
    });

    test('a new tab is dirty once edited, and clean again after a save', () {
      final container = _container();
      _tabs(container).openNew();
      expect(_state(container).active!.isDirty, isFalse);

      container.read(requestDraftProvider.notifier).setUrl('http://a.test');

      expect(_state(container).active!.isDirty, isTrue);
    });

    test('a saved tab is dirty only while it differs from what was saved', () {
      final container = _container();
      _tabs(container).openSaved(_saved('r1', 'List'));
      final draft = container.read(requestDraftProvider.notifier);

      draft.setUrl('http://changed.test');
      expect(_state(container).active!.isDirty, isTrue);

      draft.setUrl('http://a.test');
      expect(_state(container).active!.isDirty, isFalse);
    });
  });

  group('following saved requests', () {
    test('a rename shows up on the open tab', () async {
      final store = FakeStore(
        collections: [_users],
        requests: [_saved('r1', 'List')],
      );
      final container = _container(store: store);
      final saved = await container.read(savedRequestsProvider.future);
      _tabs(container).openSaved(saved.single);

      await container
          .read(savedRequestsProvider.notifier)
          .rename('r1', 'List all');

      expect(_state(container).active!.name, 'List all');
    });

    test('a deleted request leaves its tab open as unsaved work', () async {
      final store = FakeStore(
        collections: [_users],
        requests: [_saved('r1', 'List', url: 'http://keep.me')],
      );
      final container = _container(store: store);
      final saved = await container.read(savedRequestsProvider.future);
      _tabs(container).openSaved(saved.single);

      await container.read(savedRequestsProvider.notifier).delete('r1');

      final tab = _state(container).active!;
      expect(tab.isSaved, isFalse);
      expect(tab.draft.url, 'http://keep.me');
      expect(tab.isDirty, isTrue);
    });

    test('deleting the collection detaches tabs of its requests', () async {
      final store = FakeStore(
        collections: [_users],
        requests: [_saved('r1', 'List')],
      );
      final container = _container(store: store);
      final saved = await container.read(savedRequestsProvider.future);
      _tabs(container).openSaved(saved.single);

      await container.read(collectionsProvider.notifier).delete('c1');
      await container.pump();
      await container.read(savedRequestsProvider.future);

      expect(_state(container).tabs, hasLength(1));
      expect(_state(container).active!.isSaved, isFalse);
    });
  });

  group('responses are per tab', () {
    test(
      'a response lands on the tab that sent it, not the active one',
      () async {
        final http = MockHttpRequestRepository();
        final pending = Completer<Result<HttpResponseResult>>();
        when(() => http.send(any(), any())).thenAnswer((_) => pending.future);
        final container = _container(http: http);
        final a = _tabs(container).openNew();
        container.read(requestDraftProvider.notifier).setUrl('http://a.test');
        final sending = container.read(sendStateProvider.notifier).send();
        final b = _tabs(container).openNew();

        expect(container.read(sendStateProvider), isA<SendIdle>());
        pending.complete(const Result.success(_ok));
        await sending;

        final byId = {for (final t in _state(container).tabs) t.id: t};
        expect(byId[a]!.sendState, isA<SendSuccess>());
        expect(byId[b]!.sendState, isA<SendIdle>());
        expect(container.read(sendStateProvider), isA<SendIdle>());
        _tabs(container).activate(a);
        expect(container.read(sendStateProvider), isA<SendSuccess>());
      },
    );

    test('closing a tab cancels its in-flight request', () async {
      final http = MockHttpRequestRepository();
      CancelSignal? signal;
      when(() => http.send(any(), any())).thenAnswer((invocation) {
        signal = invocation.positionalArguments[1] as CancelSignal;
        return Completer<Result<HttpResponseResult>>().future;
      });
      final container = _container(http: http);
      final id = _tabs(container).openNew();
      container.read(requestDraftProvider.notifier).setUrl('http://a.test');
      unawaited(container.read(sendStateProvider.notifier).send());
      await Future<void>.delayed(Duration.zero);
      expect(signal!.isCancelled, isFalse);

      _tabs(container).close(id);
      await container.pump();

      expect(signal!.isCancelled, isTrue);
    });

    test('sending with no open tab does nothing', () async {
      final http = MockHttpRequestRepository();
      final container = _container(http: http);

      await container.read(sendStateProvider.notifier).send();

      verifyNever(() => http.send(any(), any()));
    });
  });
}
