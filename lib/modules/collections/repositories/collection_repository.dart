import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/collections/models/collection.dart';

abstract interface class CollectionRepository {
  Future<Result<List<Collection>>> list(String workspaceId);

  Future<Result<Collection>> create({
    required String workspaceId,
    required String name,
    required int position,
  });

  Future<Result<Collection>> rename(String id, String name);

  /// Deletes the collection and, by cascade, its requests.
  Future<Result<void>> delete(String id);

  /// Copies the collection and all its requests under [newName].
  Future<Result<Collection>> duplicate(String id, String newName);
}
