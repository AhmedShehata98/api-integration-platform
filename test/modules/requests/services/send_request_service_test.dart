import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/requests/models/http_request_draft.dart';
import 'package:test_point/modules/requests/models/http_response_result.dart';
import 'package:test_point/modules/requests/models/prepared_request.dart';
import 'package:test_point/modules/requests/repositories/http_request_repository.dart';
import 'package:test_point/modules/requests/services/send_request_service.dart';

class MockHttpRequestRepository extends Mock implements HttpRequestRepository {}

HttpResponseResult _response(String body, {String? contentType}) =>
    HttpResponseResult(
      statusCode: 200,
      headers: {
        'Content-Type': ?(contentType == null ? null : [contentType]),
      },
      body: body,
      duration: const Duration(milliseconds: 5),
      sizeBytes: body.length,
    );

void main() {
  late MockHttpRequestRepository repository;
  late SendRequestService service;
  const draft = HttpRequestDraft(url: 'http://a.test');

  setUpAll(() {
    registerFallbackValue(PreparedRequest(method: 'GET', url: Uri()));
    registerFallbackValue(CancelSignal());
  });

  setUp(() {
    repository = MockHttpRequestRepository();
    service = SendRequestService(repository);
  });

  void stubSend(HttpResponseResult response) =>
      when(() => repository.send(any(), any()))
          .thenAnswer((_) async => Result.success(response));

  test('an invalid URL fails validation without sending', () async {
    final result = await service(const HttpRequestDraft(), CancelSignal());

    expect(result.failureOrNull, isA<ValidationFailure>());
    verifyNever(() => repository.send(any(), any()));
  });

  test('passes repository failures through', () async {
    when(() => repository.send(any(), any())).thenAnswer(
      (_) async => const Result.failure(NetworkFailure('timed out')),
    );

    final result = await service(draft, CancelSignal());

    expect(result.failureOrNull!.message, 'timed out');
  });

  test('pretty-prints a JSON body', () async {
    stubSend(_response('{"a":[1,2]}', contentType: 'application/json'));

    final result = await service(draft, CancelSignal());

    expect(
      result.valueOrNull!.prettyBody,
      '{\n  "a": [\n    1,\n    2\n  ]\n}',
    );
  });

  test('detects JSON without a content type', () async {
    stubSend(_response('[1]'));

    final result = await service(draft, CancelSignal());

    expect(result.valueOrNull!.prettyBody, isNotNull);
  });

  test('leaves invalid JSON as raw only', () async {
    stubSend(_response('{oops', contentType: 'application/json'));

    final result = await service(draft, CancelSignal());

    expect(result.valueOrNull!.prettyBody, isNull);
    expect(result.valueOrNull!.body, '{oops');
  });

  test('does not format plain text', () async {
    stubSend(_response('hello', contentType: 'text/plain'));

    final result = await service(draft, CancelSignal());

    expect(result.valueOrNull!.prettyBody, isNull);
  });

  test('formats a 5 MB JSON body (off the main isolate)', () async {
    const item = '{"id":1,"name":"item","tags":["a","b","c"]}';
    final body =
        '[${List.filled(5 * 1024 * 1024 ~/ (item.length + 1), item).join(',')}]';
    expect(body.length, greaterThan(5 * 1000 * 1000));
    stubSend(_response(body, contentType: 'application/json'));

    final result = await service(draft, CancelSignal());

    expect(result.valueOrNull!.prettyBody!.length, greaterThan(body.length));
  });
}
