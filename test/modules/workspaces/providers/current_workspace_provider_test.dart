import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/workspaces/workspaces.dart';

import '../../../support/fake_backend.dart';

void main() {
  test('loads the default workspace for the session user', () async {
    final container = ProviderContainer.test(overrides: fakeBackend());

    final workspace = await container.read(currentWorkspaceProvider.future);

    expect(workspace, testWorkspace);
  });

  test('exposes the repository failure', () async {
    final container = ProviderContainer.test(
      overrides: fakeBackend(
        workspaces: stubWorkspaces(
          const Result.failure(StorageFailure('No workspace found.')),
        ),
      ),
    );

    await expectLater(
      container.read(currentWorkspaceProvider.future),
      throwsA(isA<StorageFailure>()),
    );
  });

  test('Workspace maps from a snake_case Supabase row', () {
    final workspace = Workspace.fromJson({
      'id': 'ws-1',
      'organization_id': 'org-1',
      'name': 'My Workspace',
      'created_at': '2026-11-11T00:00:00Z',
    });

    expect(workspace, testWorkspace);
  });
}
