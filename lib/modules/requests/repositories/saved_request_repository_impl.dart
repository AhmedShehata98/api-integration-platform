import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:test_point/core/database/supabase_failure_mapper.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/requests/models/http_request_draft.dart';
import 'package:test_point/modules/requests/models/saved_request.dart';
import 'package:test_point/modules/requests/repositories/request_row_mapper.dart';
import 'package:test_point/modules/requests/repositories/saved_request_repository.dart';

class SavedRequestRepositoryImpl implements SavedRequestRepository {
  SavedRequestRepositoryImpl(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<List<SavedRequest>>> listByCollections(
    List<String> collectionIds,
  ) async {
    try {
      final rows = await _client
          .from('requests')
          .select()
          .inFilter('collection_id', collectionIds)
          .order('position')
          .order('created_at');
      return Result.success(rows.map(RequestRowMapper.fromRow).toList());
    } on Object catch (error) {
      return Result.failure(mapSupabaseError(error));
    }
  }

  @override
  Future<Result<SavedRequest>> create({
    required String collectionId,
    required String name,
    required int position,
    required HttpRequestDraft draft,
  }) async {
    try {
      final row = await _client
          .from('requests')
          .insert({
            'collection_id': collectionId,
            'name': name,
            'position': position,
            ...RequestRowMapper.toRow(draft),
          })
          .select()
          .single();
      return Result.success(RequestRowMapper.fromRow(row));
    } on Object catch (error) {
      return Result.failure(mapSupabaseError(error));
    }
  }

  @override
  Future<Result<SavedRequest>> update(
    String id, {
    required String name,
    required HttpRequestDraft draft,
  }) async {
    try {
      final row = await _client
          .from('requests')
          .update({'name': name, ...RequestRowMapper.toRow(draft)})
          .eq('id', id)
          .select()
          .single();
      return Result.success(RequestRowMapper.fromRow(row));
    } on Object catch (error) {
      return Result.failure(mapSupabaseError(error));
    }
  }

  @override
  Future<Result<SavedRequest>> rename(String id, String name) async {
    try {
      final row = await _client
          .from('requests')
          .update({'name': name})
          .eq('id', id)
          .select()
          .single();
      return Result.success(RequestRowMapper.fromRow(row));
    } on Object catch (error) {
      return Result.failure(mapSupabaseError(error));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _client.from('requests').delete().eq('id', id);
      return const Result.success(null);
    } on Object catch (error) {
      return Result.failure(mapSupabaseError(error));
    }
  }
}
