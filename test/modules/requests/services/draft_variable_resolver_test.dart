import 'package:flutter_test/flutter_test.dart';
import 'package:test_point/modules/environments/environments.dart';
import 'package:test_point/modules/requests/models/http_request_draft.dart';
import 'package:test_point/modules/requests/models/key_value.dart';
import 'package:test_point/modules/requests/models/request_auth.dart';
import 'package:test_point/modules/requests/models/request_body.dart';
import 'package:test_point/modules/requests/services/draft_variable_resolver.dart';

void main() {
  const resolver = DraftVariableResolver(
    VariableResolver({'host': 'a.test', 'tok': 'T', 'v': '1'}),
  );

  test('resolves url, headers, auth and body', () {
    final resolved = resolver.resolve(
      const HttpRequestDraft(
        url: 'https://{{host}}/x?v={{v}}',
        headers: [KeyValue(key: 'X-{{v}}', value: '{{tok}}')],
        auth: RequestAuth.bearer(token: '{{tok}}'),
        body: RequestBody(
          type: BodyType.json,
          text: '{"v": {{v}}}',
          fields: [KeyValue(key: 'k', value: '{{host}}')],
        ),
      ),
    );
    final draft = resolved.draft;
    expect(draft.url, 'https://a.test/x?v=1');
    expect(draft.headers.single, const KeyValue(key: 'X-1', value: 'T'));
    expect(draft.auth, const RequestAuth.bearer(token: 'T'));
    expect(draft.body.text, '{"v": 1}');
    expect(draft.body.fields.single.value, 'a.test');
    expect(resolved.unresolvedInUrl, isEmpty);
  });

  test('resolves basic and api key auth', () {
    expect(
      resolver
          .resolve(
            const HttpRequestDraft(
              auth: RequestAuth.basic(username: '{{v}}', password: '{{tok}}'),
            ),
          )
          .draft
          .auth,
      const RequestAuth.basic(username: '1', password: 'T'),
    );
    expect(
      resolver
          .resolve(
            const HttpRequestDraft(
              auth: RequestAuth.apiKey(name: 'k', value: '{{tok}}'),
            ),
          )
          .draft
          .auth,
      const RequestAuth.apiKey(name: 'k', value: 'T'),
    );
  });

  test('reports variables missing from the url only', () {
    final resolved = resolver.resolve(
      const HttpRequestDraft(
        url: 'https://{{nope}}/x',
        body: RequestBody(type: BodyType.raw, text: '{{other}}'),
      ),
    );
    expect(resolved.unresolvedInUrl, {'nope'});
    expect(resolved.draft.body.text, '{{other}}');
  });
}
