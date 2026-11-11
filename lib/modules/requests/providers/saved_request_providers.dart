import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_point/core/database/supabase_client_provider.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/collections/collections.dart';
import 'package:test_point/modules/requests/models/http_request_draft.dart';
import 'package:test_point/modules/requests/models/saved_request.dart';
import 'package:test_point/modules/requests/providers/request_tabs_providers.dart';
import 'package:test_point/modules/requests/repositories/saved_request_repository.dart';
import 'package:test_point/modules/requests/repositories/saved_request_repository_impl.dart';
import 'package:test_point/modules/requests/services/saved_request_service.dart';

final savedRequestRepositoryProvider = Provider<SavedRequestRepository>(
  (ref) => SavedRequestRepositoryImpl(ref.watch(supabaseClientProvider)),
);

final savedRequestServiceProvider = Provider<SavedRequestService>(
  (ref) => SavedRequestService(ref.watch(savedRequestRepositoryProvider)),
);

/// All saved requests in the current workspace's collections.
/// Reloads when the set of collections changes. Errors carry a `Failure`.
final savedRequestsProvider =
    AsyncNotifierProvider<SavedRequestsNotifier, List<SavedRequest>>(
      SavedRequestsNotifier.new,
      retry: (_, _) => null,
    );

class SavedRequestsNotifier extends AsyncNotifier<List<SavedRequest>> {
  SavedRequestService get _service => ref.read(savedRequestServiceProvider);

  List<SavedRequest> get _current => state.value ?? const [];

  @override
  Future<List<SavedRequest>> build() async {
    // Keep open tabs in step with the stored requests (renames, deletes).
    listenSelf((_, next) {
      final requests = next.value;
      if (next.isLoading || requests == null) return;
      ref.read(requestTabsProvider.notifier).reconcile(requests);
    });

    // Only the ids matter: renaming a collection must not reload requests.
    final ids = await ref.watch(
      collectionsProvider.selectAsync((all) => all.map((c) => c.id).join(',')),
    );
    if (ids.isEmpty) return const [];

    final result = await ref
        .watch(savedRequestServiceProvider)
        .list(ids.split(','));
    return result.when(
      success: (requests) => requests,
      failure: (failure) => throw failure,
    );
  }

  /// Saves the tab: updates its request if it has one, otherwise creates it
  /// in [collectionId] under [name].
  Future<Result<SavedRequest>> saveTab(
    String tabId, {
    String? collectionId,
    String? name,
  }) async {
    final tab = ref
        .read(requestTabsProvider)
        .tabs
        .where((t) => t.id == tabId)
        .firstOrNull;
    if (tab == null) {
      return const Result.failure(ValidationFailure('This tab was closed.'));
    }

    final existingId = tab.savedRequestId;
    final Result<SavedRequest> result;
    if (existingId != null) {
      result = await _service.update(
        existingId,
        name: name ?? tab.name,
        draft: tab.draft,
      );
    } else if (collectionId == null) {
      return const Result.failure(
        ValidationFailure('Choose a collection to save in.'),
      );
    } else {
      result = await _service.create(
        collectionId: collectionId,
        name: name ?? tab.name,
        draft: tab.draft,
        existing: _current,
      );
    }

    if (result case Success(:final value)) {
      _upsert(value);
      ref.read(requestTabsProvider.notifier).markSaved(tabId, value);
    }
    return result;
  }

  /// Creates a collection named [collectionName], then saves the tab in it.
  Future<Result<SavedRequest>> saveTabInNewCollection(
    String tabId, {
    required String collectionName,
    required String name,
  }) async {
    final created = await ref
        .read(collectionsProvider.notifier)
        .create(collectionName);
    final collection = created.valueOrNull;
    if (collection == null) return Result.failure(created.failureOrNull!);
    return saveTab(tabId, collectionId: collection.id, name: name);
  }

  /// Creates [items] in [collectionId], in order, after the requests already
  /// there. Stops at the first failure; the ones created before it stay.
  Future<Result<List<SavedRequest>>> createMany(
    String collectionId,
    List<({String name, HttpRequestDraft draft})> items,
  ) async {
    final created = <SavedRequest>[];
    for (final item in items) {
      final result = await _service.create(
        collectionId: collectionId,
        name: item.name,
        draft: withParamsFromUrl(item.draft),
        existing: _current,
      );
      switch (result) {
        case Success(:final value):
          _upsert(value);
          created.add(value);
        case Err(:final failure):
          return Result.failure(failure);
      }
    }
    return Result.success(created);
  }

  Future<Result<SavedRequest>> rename(String id, String name) async {
    final result = await _service.rename(id, name);
    if (result case Success(:final value)) _upsert(value);
    return result;
  }

  Future<Result<SavedRequest>> duplicate(SavedRequest source) async {
    final result = await _service.duplicate(source, _current);
    if (result case Success(:final value)) _upsert(value);
    return result;
  }

  Future<Result<void>> delete(String id) async {
    final result = await _service.delete(id);
    if (result.isSuccess) {
      state = AsyncData([
        for (final r in _current)
          if (r.id != id) r,
      ]);
    }
    return result;
  }

  void _upsert(SavedRequest saved) {
    final exists = _current.any((r) => r.id == saved.id);
    state = AsyncData(
      exists
          ? [for (final r in _current) r.id == saved.id ? saved : r]
          : [..._current, saved],
    );
  }
}
