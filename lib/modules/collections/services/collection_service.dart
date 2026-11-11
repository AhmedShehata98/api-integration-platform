import 'package:test_point/core/error/result.dart';
import 'package:test_point/core/utils/names.dart';
import 'package:test_point/modules/collections/models/collection.dart';
import 'package:test_point/modules/collections/repositories/collection_repository.dart';

/// Collection rules (names, copy naming) on top of the repository.
class CollectionService {
  CollectionService(this._repository);

  final CollectionRepository _repository;

  Future<Result<List<Collection>>> list(String workspaceId) =>
      _repository.list(workspaceId);

  Future<Result<Collection>> create({
    required String workspaceId,
    required String name,
    required List<Collection> existing,
  }) {
    final valid = validateName(name, label: 'Collection name');
    if (valid.failure != null) {
      return Future.value(Result.failure(valid.failure!));
    }
    final position = existing.isEmpty
        ? 0
        : existing.map((c) => c.position).reduce((a, b) => a > b ? a : b) + 1;
    return _repository.create(
      workspaceId: workspaceId,
      name: valid.name!,
      position: position,
    );
  }

  Future<Result<Collection>> rename(String id, String name) {
    final valid = validateName(name, label: 'Collection name');
    if (valid.failure != null) {
      return Future.value(Result.failure(valid.failure!));
    }
    return _repository.rename(id, valid.name!);
  }

  Future<Result<void>> delete(String id) => _repository.delete(id);

  Future<Result<Collection>> duplicate(
    Collection source,
    List<Collection> existing,
  ) => _repository.duplicate(
    source.id,
    nextCopyName(source.name, existing.map((c) => c.name)),
  );
}
