import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test_point/core/database/supabase_failure_mapper.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/environments/models/environment.dart';
import 'package:test_point/modules/environments/models/environment_variable.dart';
import 'package:test_point/modules/environments/repositories/environment_repository.dart';

class EnvironmentRepositoryImpl implements EnvironmentRepository {
  EnvironmentRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<List<Environment>>> list(String workspaceId) async {
    try {
      final rows = await _client
          .from('environments')
          .select()
          .eq('workspace_id', workspaceId)
          .order('created_at');
      return Result.success(rows.map(Environment.fromJson).toList());
    } on Object catch (error) {
      return Result.failure(mapSupabaseError(error));
    }
  }

  @override
  Future<Result<Environment>> create({
    required String workspaceId,
    required String name,
  }) async {
    try {
      final row = await _client
          .from('environments')
          .insert({'workspace_id': workspaceId, 'name': name})
          .select()
          .single();
      return Result.success(Environment.fromJson(row));
    } on Object catch (error) {
      return Result.failure(mapSupabaseError(error));
    }
  }

  @override
  Future<Result<Environment>> rename(String id, String name) =>
      _update(id, {'name': name});

  @override
  Future<Result<Environment>> saveVariables(
    String id,
    List<EnvironmentVariable> variables,
  ) => _update(id, {'variables': variables.map((v) => v.toJson()).toList()});

  Future<Result<Environment>> _update(
    String id,
    Map<String, Object?> values,
  ) async {
    try {
      final row = await _client
          .from('environments')
          .update(values)
          .eq('id', id)
          .select()
          .single();
      return Result.success(Environment.fromJson(row));
    } on Object catch (error) {
      return Result.failure(mapSupabaseError(error));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _client.from('environments').delete().eq('id', id);
      return const Result.success(null);
    } on Object catch (error) {
      return Result.failure(mapSupabaseError(error));
    }
  }
}
