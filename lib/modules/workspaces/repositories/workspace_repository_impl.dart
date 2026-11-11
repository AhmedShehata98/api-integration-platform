import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test_point/core/database/supabase_failure_mapper.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/workspaces/models/workspace.dart';
import 'package:test_point/modules/workspaces/repositories/workspace_repository.dart';

class WorkspaceRepositoryImpl implements WorkspaceRepository {
  WorkspaceRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<Workspace>> loadDefault() async {
    try {
      // Row Level Security limits this to the user's organizations.
      final row = await _client
          .from('workspaces')
          .select()
          .order('created_at')
          .limit(1)
          .maybeSingle();
      if (row == null) {
        return const Result.failure(StorageFailure('No workspace found.'));
      }
      return Result.success(Workspace.fromJson(row));
    } on Object catch (error) {
      return Result.failure(mapSupabaseError(error));
    }
  }
}
