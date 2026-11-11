@Tags(['integration'])
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show SupabaseClient;
import 'package:test_point/modules/collections/repositories/collection_repository_impl.dart';
import 'package:test_point/modules/requests/models/http_method.dart';
import 'package:test_point/modules/requests/models/http_request_draft.dart';
import 'package:test_point/modules/requests/models/key_value.dart';
import 'package:test_point/modules/requests/models/request_auth.dart';
import 'package:test_point/modules/requests/models/request_body.dart';
import 'package:test_point/modules/requests/repositories/saved_request_repository_impl.dart';
import 'package:test_point/modules/workspaces/repositories/workspace_repository_impl.dart';

/// Runs the real repositories against a local Supabase (`supabase start`).
/// Skipped unless the connection is given:
///
///   flutter test test/integration --dart-define=SUPABASE_URL=http://127.0.0.1:54321 \
///     --dart-define=SUPABASE_ANON_KEY=ANON_KEY_FROM_SUPABASE_STATUS
const _url = String.fromEnvironment('SUPABASE_URL');
const _key = String.fromEnvironment('SUPABASE_ANON_KEY');

const _draft = HttpRequestDraft(
  method: HttpMethod.post,
  url: 'https://api.test/users?page=1&q={{term}}',
  params: [
    KeyValue(key: 'page', value: '1'),
    KeyValue(key: 'q', value: '{{term}}'),
    KeyValue(key: 'off', value: 'x', enabled: false),
  ],
  headers: [KeyValue(key: 'X-Trace', value: 'abc')],
  auth: RequestAuth.apiKey(
    name: 'key',
    value: 'secret',
    location: ApiKeyLocation.query,
  ),
  body: RequestBody(
    type: BodyType.urlEncoded,
    fields: [
      KeyValue(key: 'a', value: '1'),
      KeyValue(key: 'b', enabled: false),
    ],
  ),
);

Future<SupabaseClient> _guest() async {
  final client = SupabaseClient(_url, _key);
  await client.auth.signInAnonymously();
  return client;
}

void main() {
  final skip = _url.isEmpty || _key.isEmpty
      ? 'Set SUPABASE_URL and SUPABASE_ANON_KEY to run against local Supabase.'
      : null;

  test(
    'collections and requests round-trip through the real database',
    () async {
      final client = await _guest();
      addTearDown(client.dispose);
      final workspace = (await WorkspaceRepositoryImpl(
        client,
      ).loadDefault()).valueOrNull!;
      final collections = CollectionRepositoryImpl(client);
      final requests = SavedRequestRepositoryImpl(client);

      // Collections: create, list, rename.
      final created = (await collections.create(
        workspaceId: workspace.id,
        name: 'Integration',
        position: 0,
      )).valueOrNull!;
      expect(created.workspaceId, workspace.id);
      final renamed = (await collections.rename(
        created.id,
        'Integration 2',
      )).valueOrNull!;
      expect(renamed.name, 'Integration 2');
      expect(
        (await collections.list(workspace.id)).valueOrNull!.map((c) => c.id),
        [created.id],
      );

      // Requests: every draft field survives a write and a read.
      final saved = (await requests.create(
        collectionId: created.id,
        name: 'Search users',
        position: 0,
        draft: _draft,
      )).valueOrNull!;
      expect(saved.draft, _draft);
      final listed = (await requests.listByCollections([created.id]))
          .valueOrNull!;
      expect(listed.single.draft, _draft);
      expect(listed.single.name, 'Search users');

      final updated = (await requests.update(
        saved.id,
        name: 'Search people',
        draft: _draft.copyWith(method: HttpMethod.get),
      )).valueOrNull!;
      expect(updated.draft.method, HttpMethod.get);
      expect(
        (await requests.rename(saved.id, 'Find')).valueOrNull!.name,
        'Find',
      );

      // Duplicate through the SQL function copies the requests as well.
      final copy = (await collections.duplicate(
        created.id,
        'Integration copy',
      )).valueOrNull!;
      expect(copy.name, 'Integration copy');
      expect(copy.id, isNot(created.id));
      final copied = (await requests.listByCollections([copy.id])).valueOrNull!;
      expect(copied.single.name, 'Find');
      expect(copied.single.id, isNot(saved.id));
      expect(
        (await requests.listByCollections([created.id, copy.id])).valueOrNull,
        hasLength(2),
      );

      // Another guest cannot see any of it, or duplicate it.
      final other = await _guest();
      addTearDown(other.dispose);
      expect(
        (await CollectionRepositoryImpl(other).list(workspace.id)).valueOrNull,
        isEmpty,
      );
      expect(
        (await SavedRequestRepositoryImpl(other)
                .listByCollections([created.id, copy.id]))
            .valueOrNull,
        isEmpty,
      );
      expect(
        (await CollectionRepositoryImpl(
          other,
        ).duplicate(created.id, 'stolen')).failureOrNull,
        isNotNull,
      );

      // Deleting a request, then a collection (cascade).
      expect((await requests.delete(saved.id)).isSuccess, isTrue);
      expect(
        (await requests.listByCollections([created.id])).valueOrNull,
        isEmpty,
      );
      expect((await collections.delete(copy.id)).isSuccess, isTrue);
      expect(
        (await requests.listByCollections([copy.id])).valueOrNull,
        isEmpty,
      );
      expect((await collections.delete(created.id)).isSuccess, isTrue);
      expect((await collections.list(workspace.id)).valueOrNull, isEmpty);
    },
    skip: skip,
  );
}
