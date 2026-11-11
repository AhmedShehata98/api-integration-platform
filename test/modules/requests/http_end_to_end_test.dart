import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/network/dio_provider.dart';
import 'package:test_point/modules/requests/requests.dart';
import 'package:test_point/modules/requests/services/send_request_service.dart';

/// Real Dio + real loopback HTTP server, no mocks.
void main() {
  late HttpServer server;
  late SendRequestService service;
  final slowRequestSeen = Completer<void>();

  setUp(() async {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      switch (request.uri.path) {
        case '/echo':
          final body = await utf8.decoder.bind(request).join();
          request.response
            ..statusCode = 201
            ..headers.contentType = ContentType.json
            ..write(
              jsonEncode({
                'method': request.method,
                'query': request.uri.queryParameters,
                'auth': request.headers.value('authorization'),
                'contentType': request.headers.contentType?.mimeType,
                'body': body,
              }),
            );
        case '/big':
          const item = '{"id":1,"name":"item","tags":["a","b","c"]}';
          request.response.headers.contentType = ContentType.json;
          request.response.write('[');
          for (var i = 0; i < 5 * 1024 * 1024 ~/ (item.length + 1); i++) {
            if (i > 0) request.response.write(',');
            request.response.write(item);
          }
          request.response.write(']');
        case '/slow':
          if (!slowRequestSeen.isCompleted) slowRequestSeen.complete();
          await Future<void>.delayed(const Duration(seconds: 30));
        default:
          request.response.statusCode = 404;
      }
      try {
        await request.response.close();
      } on Object {
        // The client may have gone away (cancelled request).
      }
    });
    final container = ProviderContainer.test();
    service = SendRequestService(container.read(httpRequestRepositoryProvider));
    // Make sure the shared client config is the one under test.
    expect(container.read(dioProvider).options.validateStatus(404), isTrue);
  });

  tearDown(() => server.close(force: true));

  String url(String path) => 'http://127.0.0.1:${server.port}$path';

  test(
    'sends method, query, auth and JSON body, and reads the reply',
    () async {
      final draft = HttpRequestDraft(
        method: HttpMethod.post,
        url: url('/echo?a=1'),
        auth: const RequestAuth.bearer(token: 'tok'),
        body: const RequestBody(type: BodyType.json, text: '{"k":"v"}'),
      );

      final result = await service(draft, CancelSignal());

      final response = result.valueOrNull!;
      expect(response.statusCode, 201);
      expect(
        response.headers['content-type']!.first,
        contains('application/json'),
      );
      final echoed = jsonDecode(response.body) as Map<String, dynamic>;
      expect(echoed['method'], 'POST');
      expect(echoed['query'], {'a': '1'});
      expect(echoed['auth'], 'Bearer tok');
      expect(echoed['contentType'], 'application/json');
      expect(echoed['body'], '{"k":"v"}');
      expect(response.prettyBody, isNotNull);
    },
  );

  test('a 404 is a normal response', () async {
    final result = await service(
      HttpRequestDraft(url: url('/missing')),
      CancelSignal(),
    );

    expect(result.valueOrNull!.statusCode, 404);
  });

  test('reads and formats a 5 MB JSON response', () async {
    final stopwatch = Stopwatch()..start();

    final result = await service(
      HttpRequestDraft(url: url('/big')),
      CancelSignal(),
    );

    final response = result.valueOrNull!;
    expect(response.sizeBytes, greaterThan(5 * 1000 * 1000));
    expect(response.prettyBody!.length, greaterThan(response.body.length));
    // Generous bound: guards against pathological slowness, not a benchmark.
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 20)));
  });

  test('cancelling stops a slow request quickly', () async {
    final signal = CancelSignal();

    final pending = service(HttpRequestDraft(url: url('/slow')), signal);
    await slowRequestSeen.future;
    final stopwatch = Stopwatch()..start();
    signal.cancel();
    final result = await pending;

    expect(result.failureOrNull!.message, 'Request cancelled.');
    expect(stopwatch.elapsed, lessThan(const Duration(seconds: 2)));
  });

  test('a refused connection is a NetworkFailure', () async {
    final port = server.port;
    await server.close(force: true);

    final result = await service(
      HttpRequestDraft(url: 'http://127.0.0.1:$port/'),
      CancelSignal(),
    );

    expect(result.failureOrNull, isA<NetworkFailure>());
  });
}
