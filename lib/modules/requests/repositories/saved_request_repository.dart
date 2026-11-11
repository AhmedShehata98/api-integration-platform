import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/requests/models/http_request_draft.dart';
import 'package:test_point/modules/requests/models/saved_request.dart';

abstract interface class SavedRequestRepository {
  Future<Result<List<SavedRequest>>> listByCollections(
    List<String> collectionIds,
  );

  Future<Result<SavedRequest>> create({
    required String collectionId,
    required String name,
    required int position,
    required HttpRequestDraft draft,
  });

  Future<Result<SavedRequest>> update(
    String id, {
    required String name,
    required HttpRequestDraft draft,
  });

  Future<Result<SavedRequest>> rename(String id, String name);

  Future<Result<void>> delete(String id);
}
