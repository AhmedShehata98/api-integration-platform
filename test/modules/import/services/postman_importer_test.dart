import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/modules/import/models/import_result.dart';
import 'package:test_point/modules/import/services/postman_importer.dart';
import 'package:test_point/modules/requests/requests.dart';

Future<ParsedImport> _sample() async {
  final source = File('test/fixtures/postman_sample_v21.json')
      .readAsStringSync();
  final result = await const PostmanImporter().parse(source);
  expect(result.failureOrNull, isNull);
  return result.valueOrNull!;
}

ImportedRequest _named(ParsedImport import, String name) =>
    import.requests.firstWhere((r) => r.name == name);

void main() {
  group('PostmanImporter', () {
    test('reads the collection name and flattens folders', () async {
      final import = await _sample();
      expect(import.name, 'Petstore');
      expect(import.requests.map((r) => r.name), [
        'List pets',
        'Admin / Users / Create user',
        'Admin / Users / Login form',
        'Admin / Upload',
        'Search',
        'Graph',
      ]);
    });

    test('url, headers and disabled items', () async {
      final draft = _named(await _sample(), 'List pets').draft;
      expect(draft.method, HttpMethod.get);
      expect(draft.url, '{{baseUrl}}/pets?limit=10');
      expect(draft.headers, const [
        KeyValue(key: 'Accept', value: 'application/json'),
        KeyValue(key: 'X-Debug', value: '1', enabled: false),
      ]);
      // Only the disabled query param is kept here; enabled ones come from
      // the URL when the draft is stored.
      expect(draft.params, const [
        KeyValue(key: 'offset', value: '5', enabled: false),
      ]);
    });

    test('auth is inherited from the collection and folders', () async {
      final import = await _sample();
      expect(
        _named(import, 'List pets').draft.auth,
        const RequestAuth.bearer(token: '{{token}}'),
      );
      expect(
        _named(import, 'Admin / Users / Create user').draft.auth,
        const RequestAuth.basic(username: 'admin', password: 'secret'),
      );
      // "noauth" on the request overrides the folder.
      expect(
        _named(import, 'Admin / Users / Login form').draft.auth,
        const RequestAuth.none(),
      );
      expect(
        _named(import, 'Search').draft.auth,
        const RequestAuth.apiKey(
          name: 'api_key',
          value: 'k-123',
          location: ApiKeyLocation.query,
        ),
      );
    });

    test('body modes', () async {
      final import = await _sample();
      expect(
        _named(import, 'Admin / Users / Create user').draft.body,
        const RequestBody(type: BodyType.json, text: '{"name": "Rex"}'),
      );
      expect(
        _named(import, 'Admin / Users / Login form').draft.body,
        const RequestBody(
          type: BodyType.urlEncoded,
          fields: [
            KeyValue(key: 'user', value: 'rex'),
            KeyValue(key: 'remember', value: '1', enabled: false),
          ],
        ),
      );
      expect(
        _named(import, 'Admin / Upload').draft.body,
        const RequestBody(
          type: BodyType.formData,
          fields: [KeyValue(key: 'title', value: 'cat')],
        ),
      );
    });

    test('a url object without "raw" is rebuilt from its parts', () async {
      expect(
        _named(await _sample(), 'Admin / Upload').draft.url,
        'https://api.test/upload',
      );
    });

    test('lists what it could not import', () async {
      final import = await _sample();
      expect(
        import.skipped,
        containsAll([
          'Scripts on "Admin / Upload" were skipped.',
          'File field "photo" in "Admin / Upload" was skipped.',
          'Auth type "oauth2" on "Graph" is not supported.',
          'Body mode "graphql" in "Graph" is not supported.',
          '"Trace" uses method TRACE, which is not supported.',
        ]),
      );
      // The unsupported TRACE request is not imported at all.
      expect(import.requests.any((r) => r.name == 'Trace'), isFalse);
    });

    test(
      'rejects other schema versions, non-collections and bad JSON',
      () async {
        Future<Failure?> failure(String source) async =>
            (await const PostmanImporter().parse(source)).failureOrNull;

        expect(
          (await failure(
            '{"info":{"name":"x","schema":"https://schema.getpostman.com/json/collection/v2.0.0/collection.json"},"item":[]}',
          ))!.message,
          contains('v2.1'),
        );
        expect(await failure('{"hello": 1}'), isA<ValidationFailure>());
        expect(await failure('[1,2]'), isA<ValidationFailure>());
        expect(await failure('not json'), isA<ValidationFailure>());
      },
    );

    test('a collection with no requests parses to an empty list', () async {
      final result = await const PostmanImporter().parse(
        '{"info":{"name":"","schema":"https://schema.getpostman.com/json/collection/v2.1.0/collection.json"},"item":[]}',
      );
      expect(result.valueOrNull!.requests, isEmpty);
      expect(result.valueOrNull!.name, 'Imported collection');
    });
  });
}
