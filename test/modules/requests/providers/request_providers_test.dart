import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/requests/models/prepared_request.dart';
import 'package:test_point/modules/requests/models/send_state.dart';
import 'package:test_point/modules/requests/requests.dart';

import '../../../support/fake_backend.dart';

class MockHttpRequestRepository extends Mock implements HttpRequestRepository {}

const _ok = HttpResponseResult(
  statusCode: 200,
  headers: {},
  body: 'ok',
  duration: Duration(milliseconds: 1),
  sizeBytes: 2,
);

/// A container with one open (empty) request tab, like after "New request".
ProviderContainer _container(HttpRequestRepository repository) {
  final container = ProviderContainer.test(
    overrides: [
      httpRequestRepositoryProvider.overrideWithValue(repository),
      ...fakeBackend(),
    ],
  );
  container.read(requestTabsProvider.notifier).openNew();
  return container;
}

void main() {
  late MockHttpRequestRepository repository;

  setUpAll(() {
    registerFallbackValue(PreparedRequest(method: 'GET', url: Uri()));
    registerFallbackValue(CancelSignal());
  });

  setUp(() => repository = MockHttpRequestRepository());

  group('draft', () {
    test('editing the URL rebuilds the params table', () {
      final container = _container(repository);
      final notifier = container.read(requestDraftProvider.notifier);

      notifier.setUrl('http://a.test?x=1&y=2');

      expect(container.read(requestDraftProvider).params, const [
        KeyValue(key: 'x', value: '1'),
        KeyValue(key: 'y', value: '2'),
      ]);
    });

    test('editing params rewrites the URL and keeps disabled ones', () {
      final container = _container(repository);
      final notifier = container.read(requestDraftProvider.notifier)
        ..setUrl('http://a.test/p');

      notifier.setParams(const [
        KeyValue(key: 'a', value: '1'),
        KeyValue(key: 'off', value: '2', enabled: false),
      ]);

      final draft = container.read(requestDraftProvider);
      expect(draft.url, 'http://a.test/p?a=1');
      expect(draft.params, hasLength(2));
    });
  });

  group('send', () {
    test('success stores the response', () async {
      when(() => repository.send(any(), any()))
          .thenAnswer((_) async => const Result.success(_ok));
      final container = _container(repository);
      container.read(requestDraftProvider.notifier).setUrl('http://a.test');

      await container.read(sendStateProvider.notifier).send();

      final state = container.read(sendStateProvider);
      expect(state, isA<SendSuccess>());
      expect((state as SendSuccess).response, _ok);
    });

    test('an invalid URL ends in a failed state', () async {
      final container = _container(repository);

      await container.read(sendStateProvider.notifier).send();

      final state = container.read(sendStateProvider);
      expect(state, isA<SendFailed>());
      expect((state as SendFailed).failure, isA<ValidationFailure>());
    });

    test('cancel returns to idle and ignores the late result', () async {
      final pending = Completer<Result<HttpResponseResult>>();
      when(() => repository.send(any(), any()))
          .thenAnswer((_) => pending.future);
      final container = _container(repository);
      container.read(requestDraftProvider.notifier).setUrl('http://a.test');
      final notifier = container.read(sendStateProvider.notifier);

      final sending = notifier.send();
      expect(container.read(sendStateProvider), isA<SendLoading>());

      notifier.cancel();
      expect(container.read(sendStateProvider), isA<SendIdle>());

      pending.complete(const Result.success(_ok));
      await sending;
      expect(container.read(sendStateProvider), isA<SendIdle>());
    });

    test('the cancel signal reaches the repository', () async {
      CancelSignal? received;
      when(() => repository.send(any(), any())).thenAnswer((invocation) {
        received = invocation.positionalArguments[1] as CancelSignal;
        return Completer<Result<HttpResponseResult>>().future;
      });
      final container = _container(repository);
      container.read(requestDraftProvider.notifier).setUrl('http://a.test');
      final notifier = container.read(sendStateProvider.notifier);

      unawaited(notifier.send());
      await Future<void>.delayed(Duration.zero);
      notifier.cancel();

      expect(received!.isCancelled, isTrue);
    });

    test('a second send while loading is ignored', () async {
      final pending = Completer<Result<HttpResponseResult>>();
      when(() => repository.send(any(), any()))
          .thenAnswer((_) => pending.future);
      final container = _container(repository);
      container.read(requestDraftProvider.notifier).setUrl('http://a.test');
      final notifier = container.read(sendStateProvider.notifier);

      final first = notifier.send();
      await notifier.send();
      pending.complete(const Result.success(_ok));
      await first;

      verify(() => repository.send(any(), any())).called(1);
    });
  });
}
