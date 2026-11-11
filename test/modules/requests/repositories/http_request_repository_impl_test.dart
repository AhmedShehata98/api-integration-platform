import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/network/dio_provider.dart';
import 'package:test_point/modules/requests/models/prepared_request.dart';
import 'package:test_point/modules/requests/repositories/http_request_repository.dart';
import 'package:test_point/modules/requests/repositories/http_request_repository_impl.dart';

typedef _Handler = Future<ResponseBody> Function(
  RequestOptions options,
  List<int> sentBody,
  Future<void>? cancelFuture,
);

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this.handler);

  final _Handler handler;
  RequestOptions? lastOptions;
  String? lastBody;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastOptions = options;
    final sent = <int>[];
    if (requestStream != null) {
      await for (final chunk in requestStream) {
        sent.addAll(chunk);
      }
    }
    lastBody = utf8.decode(sent);
    return handler(options, sent, cancelFuture);
  }

  @override
  void close({bool force = false}) {}
}

HttpRequestRepositoryImpl _repository(_FakeAdapter adapter) {
  // The app's real shared client, with the network replaced by the fake.
  final dio = ProviderContainer.test().read(dioProvider)
    ..httpClientAdapter = adapter;
  return HttpRequestRepositoryImpl(dio);
}

final _get = PreparedRequest(method: 'GET', url: Uri.parse('http://a.test/x'));

void main() {
  test('maps status, reason, headers, body and size', () async {
    final adapter = _FakeAdapter(
      (_, _, _) async => ResponseBody.fromString(
        'héllo',
        200,
        statusMessage: 'OK',
        headers: {
          'content-type': ['text/plain'],
        },
      ),
    );

    final result = await _repository(adapter).send(_get, CancelSignal());

    final response = result.valueOrNull!;
    expect(response.statusCode, 200);
    expect(response.reason, 'OK');
    expect(response.body, 'héllo');
    expect(response.sizeBytes, utf8.encode('héllo').length);
    expect(response.headers['content-type'], ['text/plain']);
    expect(response.duration, isNot(Duration.zero));
  });

  test('4xx and 5xx are responses, not failures', () async {
    final adapter = _FakeAdapter(
      (_, _, _) async => ResponseBody.fromString('nope', 404),
    );

    final result = await _repository(adapter).send(_get, CancelSignal());

    expect(result.valueOrNull!.statusCode, 404);
  });

  test('sends method, headers and string body as given', () async {
    final adapter = _FakeAdapter(
      (_, _, _) async => ResponseBody.fromString('', 204),
    );
    final request = PreparedRequest(
      method: 'POST',
      url: Uri.parse('http://a.test/x?a=1'),
      headers: const {'Content-Type': 'application/json', 'X-A': '1'},
      body: '{"k":"v"}',
    );

    await _repository(adapter).send(request, CancelSignal());

    expect(adapter.lastOptions!.method, 'POST');
    expect(adapter.lastOptions!.uri.toString(), 'http://a.test/x?a=1');
    expect(adapter.lastOptions!.headers['X-A'], '1');
    expect(adapter.lastBody, '{"k":"v"}');
  });

  test('sends multipart fields as form-data', () async {
    final adapter = _FakeAdapter(
      (_, _, _) async => ResponseBody.fromString('', 200),
    );
    final request = PreparedRequest(
      method: 'POST',
      url: Uri.parse('http://a.test/upload'),
      multipartFields: const {'name': 'value'},
    );

    await _repository(adapter).send(request, CancelSignal());

    expect(
      adapter.lastOptions!.headers['content-type'].toString(),
      startsWith('multipart/form-data; boundary='),
    );
    expect(adapter.lastBody, contains('name="name"'));
    expect(adapter.lastBody, contains('value'));
  });

  test('timeouts become a NetworkFailure', () async {
    final adapter = _FakeAdapter(
      (options, _, _) async => throw DioException.connectionTimeout(
        timeout: const Duration(seconds: 1),
        requestOptions: options,
      ),
    );

    final result = await _repository(adapter).send(_get, CancelSignal());

    expect(result.failureOrNull, isA<NetworkFailure>());
    expect(result.failureOrNull!.message, 'The request timed out.');
  });

  test('cancelling the signal cancels the in-flight request', () async {
    final adapter = _FakeAdapter((options, _, cancelFuture) async {
      await cancelFuture;
      throw DioException.requestCancelled(
        requestOptions: options,
        reason: 'cancelled',
      );
    });
    final signal = CancelSignal();

    final pending = _repository(adapter).send(_get, signal);
    await Future<void>.delayed(Duration.zero);
    signal.cancel();
    final result = await pending;

    expect(result.failureOrNull, isA<NetworkFailure>());
    expect(result.failureOrNull!.message, 'Request cancelled.');
  });

  test('unexpected errors never escape as exceptions', () async {
    final adapter = _FakeAdapter((_, _, _) async => throw StateError('boom'));

    final result = await _repository(adapter).send(_get, CancelSignal());

    expect(result.failureOrNull, isA<UnexpectedFailure>());
  });
}
