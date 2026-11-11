import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/modules/requests/models/http_method.dart';
import 'package:test_point/modules/requests/models/http_request_draft.dart';
import 'package:test_point/modules/requests/models/key_value.dart';
import 'package:test_point/modules/requests/models/prepared_request.dart';
import 'package:test_point/modules/requests/models/request_auth.dart';
import 'package:test_point/modules/requests/models/request_body.dart';
import 'package:test_point/modules/requests/services/request_builder.dart';

PreparedRequest _build(HttpRequestDraft draft) {
  final result = const RequestBuilder().build(draft);
  return result.valueOrNull ??
      fail('Expected success, got ${result.failureOrNull}');
}

void main() {
  group('URL', () {
    test('keeps method and URL', () {
      final request = _build(
        const HttpRequestDraft(
          method: HttpMethod.post,
          url: 'https://api.test/v1?a=1',
        ),
      );

      expect(request.method, 'POST');
      expect(request.url, Uri.parse('https://api.test/v1?a=1'));
    });

    test('adds http:// when the scheme is missing', () {
      final request = _build(const HttpRequestDraft(url: 'localhost:3000/x'));

      expect(request.url.toString(), 'http://localhost:3000/x');
    });

    test('rejects an empty URL', () {
      final result = const RequestBuilder().build(const HttpRequestDraft());

      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(result.failureOrNull!.message, 'Enter a URL.');
    });

    for (final bad in ['http://', 'ftp://host/file', 'ht tp://x']) {
      test('rejects invalid URL "$bad"', () {
        final result = const RequestBuilder().build(HttpRequestDraft(url: bad));

        expect(result.failureOrNull, isA<ValidationFailure>());
      });
    }
  });

  group('headers', () {
    test('sends only enabled, named headers', () {
      final request = _build(
        const HttpRequestDraft(
          url: 'http://a.test',
          headers: [
            KeyValue(key: 'X-On', value: '1'),
            KeyValue(key: 'X-Off', value: '2', enabled: false),
            KeyValue(value: 'no key'),
          ],
        ),
      );

      expect(request.headers, {'X-On': '1'});
    });
  });

  group('auth', () {
    HttpRequestDraft draft(
      RequestAuth auth, [
      List<KeyValue> headers = const [],
    ]) =>
        HttpRequestDraft(url: 'http://a.test/p', auth: auth, headers: headers);

    test('bearer', () {
      final request = _build(draft(const RequestAuth.bearer(token: 'abc')));

      expect(request.headers['Authorization'], 'Bearer abc');
    });

    test('basic', () {
      final request = _build(
        draft(const RequestAuth.basic(username: 'u', password: 'p')),
      );

      expect(
        request.headers['Authorization'],
        'Basic ${base64.encode(utf8.encode('u:p'))}',
      );
    });

    test('auth replaces a manual Authorization header (case-insensitive)', () {
      final request = _build(
        draft(const RequestAuth.bearer(token: 'new'), const [
          KeyValue(key: 'authorization', value: 'old'),
        ]),
      );

      expect(request.headers, {'Authorization': 'Bearer new'});
    });

    test('API key in header', () {
      final request = _build(
        draft(const RequestAuth.apiKey(name: 'X-Key', value: 'k')),
      );

      expect(request.headers['X-Key'], 'k');
    });

    test('API key in query keeps existing query params', () {
      final request = _build(
        const HttpRequestDraft(
          url: 'http://a.test/p?a=1',
          auth: RequestAuth.apiKey(
            name: 'key',
            value: 'k',
            location: ApiKeyLocation.query,
          ),
        ),
      );

      expect(request.url.queryParameters, {'a': '1', 'key': 'k'});
    });
  });

  group('body', () {
    HttpRequestDraft draft(RequestBody body) => HttpRequestDraft(
      method: HttpMethod.post,
      url: 'http://a.test',
      body: body,
    );

    test('none sends no body', () {
      final request = _build(draft(const RequestBody()));

      expect(request.body, isNull);
      expect(request.multipartFields, isNull);
    });

    test('JSON sets the text and a default Content-Type', () {
      final request = _build(
        draft(const RequestBody(type: BodyType.json, text: '{"a":1}')),
      );

      expect(request.body, '{"a":1}');
      expect(request.headers['Content-Type'], 'application/json');
    });

    test('JSON keeps a user Content-Type', () {
      final request = _build(
        const HttpRequestDraft(
          url: 'http://a.test',
          headers: [
            KeyValue(key: 'content-type', value: 'application/vnd.x+json'),
          ],
          body: RequestBody(type: BodyType.json, text: '{}'),
        ),
      );

      expect(request.headers, {'content-type': 'application/vnd.x+json'});
    });

    test('empty JSON text sends no body and no Content-Type', () {
      final request = _build(
        draft(const RequestBody(type: BodyType.json, text: '  ')),
      );

      expect(request.body, isNull);
      expect(request.headers, isEmpty);
    });

    test('raw is text/plain', () {
      final request = _build(
        draft(const RequestBody(type: BodyType.raw, text: 'hello')),
      );

      expect(request.body, 'hello');
      expect(request.headers['Content-Type'], 'text/plain');
    });

    test('urlencoded encodes enabled fields', () {
      final request = _build(
        draft(
          const RequestBody(
            type: BodyType.urlEncoded,
            fields: [
              KeyValue(key: 'a b', value: 'x&y'),
              KeyValue(key: 'off', value: '1', enabled: false),
            ],
          ),
        ),
      );

      expect(request.body, 'a+b=x%26y');
      expect(
        request.headers['Content-Type'],
        'application/x-www-form-urlencoded',
      );
    });

    test('form-data becomes multipart fields without a Content-Type', () {
      final request = _build(
        const HttpRequestDraft(
          url: 'http://a.test',
          headers: [KeyValue(key: 'Content-Type', value: 'x')],
          body: RequestBody(
            type: BodyType.formData,
            fields: [KeyValue(key: 'k', value: 'v')],
          ),
        ),
      );

      expect(request.multipartFields, {'k': 'v'});
      expect(request.body, isNull);
      expect(
        request.headers.keys.map((k) => k.toLowerCase()),
        isNot(contains('content-type')),
      );
    });
  });
}
