import 'package:flutter_test/flutter_test.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/modules/import/services/curl_parser.dart';
import 'package:test_point/modules/requests/requests.dart';

HttpRequestDraft _parse(String command) {
  final result = const CurlParser().parse(command);
  expect(result.failureOrNull, isNull, reason: command);
  return result.valueOrNull!.requests.single.draft;
}

void main() {
  group('CurlParser', () {
    test('a bare URL is a GET', () {
      final draft = _parse('curl https://api.test/users');
      expect(draft.method, HttpMethod.get);
      expect(draft.url, 'https://api.test/users');
      expect(draft.body.type, BodyType.none);
    });

    test('-X and --request set the method, also attached', () {
      expect(_parse('curl -X PUT https://a.test').method, HttpMethod.put);
      expect(_parse('curl -XDELETE https://a.test').method, HttpMethod.delete);
      expect(
        _parse('curl --request=PATCH https://a.test').method,
        HttpMethod.patch,
      );
      expect(_parse('curl -I https://a.test').method, HttpMethod.head);
    });

    test('headers keep their order; a malformed header is skipped', () {
      final result = const CurlParser().parse(
        "curl https://a.test -H 'Accept: text/plain' -H 'X-Id:  7 ' -H 'oops'",
      );
      final draft = result.valueOrNull!.requests.single.draft;
      expect(draft.headers, const [
        KeyValue(key: 'Accept', value: 'text/plain'),
        KeyValue(key: 'X-Id', value: '7'),
      ]);
      expect(result.valueOrNull!.skipped, ['Header "oops" was skipped.']);
    });

    test('JSON data becomes a JSON body and POST', () {
      final draft = _parse(
        'curl https://a.test/u -H "Content-Type: application/json" '
        '-d \'{"name":"Rex"}\'',
      );
      expect(draft.method, HttpMethod.post);
      expect(
        draft.body,
        const RequestBody(type: BodyType.json, text: '{"name":"Rex"}'),
      );
      // The builder sets this header itself, so it is not duplicated.
      expect(draft.headers, isEmpty);
    });

    test('JSON data without a content type is still detected', () {
      final draft = _parse("curl https://a.test --data-raw '[1,2]'");
      expect(draft.body.type, BodyType.json);
    });

    test('form data becomes urlencoded fields, decoded', () {
      final draft = _parse(
        "curl https://a.test -d 'a=1&b=hello%20world' -d 'c=3'",
      );
      expect(draft.body.type, BodyType.urlEncoded);
      expect(draft.body.fields, const [
        KeyValue(key: 'a', value: '1'),
        KeyValue(key: 'b', value: 'hello world'),
        KeyValue(key: 'c', value: '3'),
      ]);
    });

    test('plain text with another content type stays raw', () {
      final draft = _parse(
        "curl https://a.test -H 'Content-Type: text/plain' -d 'hello there'",
      );
      expect(
        draft.body,
        const RequestBody(type: BodyType.raw, text: 'hello there'),
      );
      expect(draft.headers.single.key, 'Content-Type');
    });

    test('-u becomes basic auth', () {
      final draft = _parse('curl -u rex:pa:ss https://a.test');
      expect(
        draft.auth,
        const RequestAuth.basic(username: 'rex', password: 'pa:ss'),
      );
    });

    test('a Bearer Authorization header becomes bearer auth', () {
      final draft = _parse(
        "curl https://a.test -H 'Authorization: Bearer abc'",
      );
      expect(draft.auth, const RequestAuth.bearer(token: 'abc'));
      expect(draft.headers, isEmpty);
    });

    test('-F builds form-data and skips file uploads', () {
      final result = const CurlParser().parse(
        "curl https://a.test -F 'title=cat' -F 'photo=@cat.png'",
      );
      final draft = result.valueOrNull!.requests.single.draft;
      expect(draft.method, HttpMethod.post);
      expect(draft.body.type, BodyType.formData);
      expect(draft.body.fields, const [KeyValue(key: 'title', value: 'cat')]);
      expect(result.valueOrNull!.skipped, hasLength(1));
    });

    test('-G moves the data into the query string', () {
      final draft = _parse('curl -G https://a.test/s -d q=dart -d page=2');
      expect(draft.method, HttpMethod.get);
      expect(draft.url, 'https://a.test/s?q=dart&page=2');
      expect(draft.body.type, BodyType.none);
    });

    test('line continuations, double quotes and the bash \$\'...\' form', () {
      final draft = _parse(
        'curl "https://a.test/x" \\\n'
        '  -H "X-A: say \\"hi\\"" \\\n'
        "  --data-raw \$'{\"t\":\"a\\nb\"}'",
      );
      expect(draft.url, 'https://a.test/x');
      expect(draft.headers.single.value, 'say "hi"');
      expect(draft.body.text, '{"t":"a\nb"}');
    });

    test('--url, cookies and user agent are read; noise flags are ignored', () {
      final result = const CurlParser().parse(
        "curl -sSL --compressed --url https://a.test -b 'k=v' -A 'tp/1' "
        '--max-time 5',
      );
      final import = result.valueOrNull!;
      final draft = import.requests.single.draft;
      expect(draft.url, 'https://a.test');
      expect(draft.headers, const [
        KeyValue(key: 'Cookie', value: 'k=v'),
        KeyValue(key: 'User-Agent', value: 'tp/1'),
      ]);
      expect(import.skipped, ['Option --max-time was ignored.']);
    });

    test('the request is named after method and path', () {
      final result = const CurlParser().parse(
        'curl -X POST https://a.test/users?x=1',
      );
      expect(result.valueOrNull!.requests.single.name, 'POST /users');
      final bare = const CurlParser().parse('curl https://a.test');
      expect(bare.valueOrNull!.requests.single.name, 'GET a.test');
    });

    test('rejects input that is not a cURL command or has no URL', () {
      for (final input in [
        '',
        'wget https://a.test',
        'curl -X POST',
        "curl 'oops",
      ]) {
        expect(
          const CurlParser().parse(input).failureOrNull,
          isA<ValidationFailure>(),
          reason: input,
        );
      }
    });

    test('variables survive untouched', () {
      final draft = _parse("curl '{{baseUrl}}/u' -H 'X-T: {{token}}'");
      expect(draft.url, '{{baseUrl}}/u');
      expect(draft.headers.single.value, '{{token}}');
    });
  });
}
