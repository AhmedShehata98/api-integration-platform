import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_point/core/database/supabase_client_provider.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/collections/models/collection.dart';
import 'package:test_point/modules/collections/repositories/collection_repository.dart';
import 'package:test_point/modules/collections/repositories/collection_repository_impl.dart';
import 'package:test_point/modules/collections/services/collection_service.dart';
import 'package:test_point/modules/workspaces/workspaces.dart';

final collectionRepositoryProvider = Provider<CollectionRepository>(
  (ref) => CollectionRepositoryImpl(ref.watch(supabaseClientProvider)),
);

final collectionServiceProvider = Provider<CollectionService>(
  (ref) => CollectionService(ref.watch(collectionRepositoryProvider)),
);

/// Collections of the current workspace. Errors carry a `Failure`.
final collectionsProvider =
    AsyncNotifierProvider<CollectionsNotifier, List<Collection>>(
      CollectionsNotifier.new,
      retry: (_, _) => null,
    );

class CollectionsNotifier extends AsyncNotifier<List<Collection>> {
  CollectionService get _service => ref.read(collectionServiceProvider);

  List<Collection> get _current => state.value ?? const [];

  @override
  Future<List<Collection>> build() async {
    final workspace = await ref.watch(currentWorkspaceProvider.future);
    final result = await ref
        .watch(collectionServiceProvider)
        .list(workspace.id);
    return result.when(
      success: (collections) => collections,
      failure: (failure) => throw failure,
    );
  }

  Future<Result<Collection>> create(String name) async {
    final workspace = await ref.read(currentWorkspaceProvider.future);
    final result = await _service.create(
      workspaceId: workspace.id,
      name: name,
      existing: _current,
    );
    if (result case Success(:final value)) {
      state = AsyncData([..._current, value]);
    }
    return result;
  }

  Future<Result<Collection>> rename(String id, String name) async {
    final result = await _service.rename(id, name);
    if (result case Success(:final value)) {
      state = AsyncData([for (final c in _current) c.id == id ? value : c]);
    }
    return result;
  }

  Future<Result<void>> delete(String id) async {
    final result = await _service.delete(id);
    if (result.isSuccess) {
      state = AsyncData([
        for (final c in _current)
          if (c.id != id) c,
      ]);
    }
    return result;
  }

  Future<Result<Collection>> duplicate(Collection source) async {
    final result = await _service.duplicate(source, _current);
    if (result case Success(:final value)) {
      state = AsyncData([..._current, value]);
    }
    return result;
  }
}
