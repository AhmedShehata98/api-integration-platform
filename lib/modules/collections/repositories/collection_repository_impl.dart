import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test_point/core/database/supabase_failure_mapper.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/collections/models/collection.dart';
import 'package:test_point/modules/collections/repositories/collection_repository.dart';

class CollectionRepositoryImpl implements CollectionRepository {
  CollectionRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<List<Collection>>> list(String workspaceId) async {
    try {
      final rows = await _client
          .from('collections')
          .select()
          .eq('workspace_id', workspaceId)
          .order('position')
          .order('created_at');
      return Result.success(rows.map(Collection.fromJson).toList());
    } on Object catch (error) {
      return Result.failure(mapSupabaseError(error));
    }
  }

  @override
  Future<Result<Collection>> create({
    required String workspaceId,
    required String name,
    required int position,
  }) async {
    try {
      final row = await _client
          .from('collections')
          .insert({
            'workspace_id': workspaceId,
            'name': name,
            'position': position,
          })
          .select()
          .single();
      return Result.success(Collection.fromJson(row));
    } on Object catch (error) {
      return Result.failure(mapSupabaseError(error));
    }
  }

  @override
  Future<Result<Collection>> rename(String id, String name) async {
    try {
      final row = await _client
          .from('collections')
          .update({'name': name})
          .eq('id', id)
          .select()
          .single();
      return Result.success(Collection.fromJson(row));
    } on Object catch (error) {
      return Result.failure(mapSupabaseError(error));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _client.from('collections').delete().eq('id', id);
      return const Result.success(null);
    } on Object catch (error) {
      return Result.failure(mapSupabaseError(error));
    }
  }

  @override
  Future<Result<Collection>> duplicate(String id, String newName) async {
    try {
      final row = await _client.rpc<Map<String, dynamic>>(
        'duplicate_collection',
        params: {'source_id': id, 'new_name': newName},
      );
      return Result.success(Collection.fromJson(row));
    } on Object catch (error) {
      return Result.failure(mapSupabaseError(error));
    }
  }
}
