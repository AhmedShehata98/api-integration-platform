import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:test_point/modules/requests/models/http_method.dart';
import 'package:test_point/modules/requests/models/http_request_draft.dart';
import 'package:test_point/modules/requests/models/key_value.dart';
import 'package:test_point/modules/requests/models/request_auth.dart';
import 'package:test_point/modules/requests/models/request_body.dart';
import 'package:test_point/modules/requests/repositories/request_row_mapper.dart';

/// What the database returns for a row written with [RequestRowMapper.toRow].
Map<String, dynamic> _row(HttpRequestDraft draft) => {
  'id': 'r1',
  'collection_id': 'c1',
  'name': 'My request',
  'position': 3,
  // jsonb columns come back as decoded JSON.
  ...(jsonDecode(jsonEncode(RequestRowMapper.toRow(draft)))
      as Map<String, dynamic>),
};

HttpRequestDraft _roundTrip(HttpRequestDraft draft) =>
    RequestRowMapper.fromRow(_row(draft)).draft;

void main() {
  test('reads the row identity fields', () {
    final saved = RequestRowMapper.fromRow(_row(const HttpRequestDraft()));

    expect(saved.id, 'r1');
    expect(saved.collectionId, 'c1');
    expect(saved.name, 'My request');
    expect(saved.position, 3);
  });

  test('round-trips method, URL, params and headers', () {
    const draft = HttpRequestDraft(
      method: HttpMethod.patch,
      url: 'https://a.test/p?x={{v}}&y=2',
      params: [
        KeyValue(key: 'x', value: '{{v}}'),
        KeyValue(key: 'y', value: '2'),
        KeyValue(key: 'off', value: '3', enabled: false),
      ],
      headers: [KeyValue(key: 'X-A', value: '1', enabled: false)],
    );

    expect(_roundTrip(draft), draft);
  });

  group('auth', () {
    for (final auth in const [
      RequestAuth.none(),
      RequestAuth.bearer(token: 'tok'),
      RequestAuth.basic(username: 'u', password: 'p'),
      RequestAuth.apiKey(name: 'k', value: 'v'),
      RequestAuth.apiKey(name: 'k', value: 'v', location: ApiKeyLocation.query),
    ]) {
      test('round-trips $auth', () {
        final draft = HttpRequestDraft(auth: auth);

        expect(_roundTrip(draft).auth, auth);
      });
    }
  });

  group('body', () {
    test('JSON and raw keep their text', () {
      for (final type in [BodyType.json, BodyType.raw]) {
        final draft = HttpRequestDraft(
          body: RequestBody(type: type, text: '{"a": 1}'),
        );

        expect(_roundTrip(draft).body, draft.body);
        expect(RequestRowMapper.toRow(draft)['body'], '{"a": 1}');
      }
    });

    test('form bodies store their fields as JSON text in the body column', () {
      for (final type in [BodyType.formData, BodyType.urlEncoded]) {
        final draft = HttpRequestDraft(
          body: RequestBody(
            type: type,
            fields: const [
              KeyValue(key: 'a', value: '1'),
              KeyValue(key: 'b', value: '2', enabled: false),
            ],
          ),
        );

        expect(RequestRowMapper.toRow(draft)['body'], isA<String>());
        expect(_roundTrip(draft).body, draft.body);
      }
    });

    test('no body stores null', () {
      expect(RequestRowMapper.toRow(const HttpRequestDraft())['body'], isNull);
      expect(_roundTrip(const HttpRequestDraft()).body, const RequestBody());
    });
  });

  group('tolerates odd rows', () {
    Map<String, dynamic> row(Map<String, dynamic> overrides) => {
      'id': 'r',
      'collection_id': 'c',
      'name': 'n',
      ...overrides,
    };

    test('missing or unknown values fall back to defaults', () {
      final draft = RequestRowMapper.fromRow(
        row({
          'method': 'NOPE',
          'url': null,
          'params': null,
          'auth': {'type': 'mystery'},
          'body_type': 'weird',
        }),
      ).draft;

      expect(draft, const HttpRequestDraft());
    });

    test('a corrupt form body becomes no fields instead of crashing', () {
      final draft = RequestRowMapper.fromRow(
        row({'body_type': 'urlEncoded', 'body': '{not json'}),
      ).draft;

      expect(draft.body, const RequestBody(type: BodyType.urlEncoded));
    });
  });
}
