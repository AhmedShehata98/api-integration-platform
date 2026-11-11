import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/core/utils/names.dart';
import 'package:test_point/modules/requests/models/http_request_draft.dart';
import 'package:test_point/modules/requests/models/saved_request.dart';
import 'package:test_point/modules/requests/repositories/saved_request_repository.dart';

/// Rules for saving requests (names, ordering, copy naming).
class SavedRequestService {
  SavedRequestService(this._repository);

  final SavedRequestRepository _repository;

  Future<Result<List<SavedRequest>>> list(List<String> collectionIds) =>
      _repository.listByCollections(collectionIds);

  /// Adds [draft] to [collectionId] after the requests already in it.
  Future<Result<SavedRequest>> create({
    required String collectionId,
    required String name,
    required HttpRequestDraft draft,
    required List<SavedRequest> existing,
  }) {
    final valid = validateName(name, label: 'Request name');
    if (valid.failure != null) return _fail(valid.failure!);
    return _repository.create(
      collectionId: collectionId,
      name: valid.name!,
      position: _nextPosition(existing, collectionId),
      draft: draft,
    );
  }

  Future<Result<SavedRequest>> update(
    String id, {
    required String name,
    required HttpRequestDraft draft,
  }) {
    final valid = validateName(name, label: 'Request name');
    if (valid.failure != null) return _fail(valid.failure!);
    return _repository.update(id, name: valid.name!, draft: draft);
  }

  Future<Result<SavedRequest>> rename(String id, String name) {
    final valid = validateName(name, label: 'Request name');
    if (valid.failure != null) return _fail(valid.failure!);
    return _repository.rename(id, valid.name!);
  }

  Future<Result<void>> delete(String id) => _repository.delete(id);

  /// Copies [source] into the same collection as `X copy`.
  Future<Result<SavedRequest>> duplicate(
    SavedRequest source,
    List<SavedRequest> existing,
  ) {
    final siblings = existing.where(
      (r) => r.collectionId == source.collectionId,
    );
    return _repository.create(
      collectionId: source.collectionId,
      name: nextCopyName(source.name, siblings.map((r) => r.name)),
      position: _nextPosition(existing, source.collectionId),
      draft: source.draft,
    );
  }

  int _nextPosition(List<SavedRequest> existing, String collectionId) {
    final positions = existing
        .where((r) => r.collectionId == collectionId)
        .map((r) => r.position);
    return positions.isEmpty
        ? 0
        : positions.reduce((a, b) => a > b ? a : b) + 1;
  }

  Future<Result<SavedRequest>> _fail(Failure failure) =>
      Future.value(Result.failure(failure));
}
