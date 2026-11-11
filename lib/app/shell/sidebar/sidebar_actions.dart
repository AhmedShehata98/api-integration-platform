import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/core/ui/widgets/confirm_dialog.dart';
import 'package:test_point/core/ui/widgets/failure_snackbar.dart';
import 'package:test_point/core/ui/widgets/name_dialog.dart';
import 'package:test_point/modules/collections/collections.dart';
import 'package:test_point/modules/requests/requests.dart';

/// User flows for collections and saved requests: ask, call the provider,
/// show a failure if there is one. Shared by the sidebar and overview screen.
class CollectionActions {
  const CollectionActions(this.context, this.ref);

  final BuildContext context;
  final WidgetRef ref;

  Future<void> create() async {
    final name = await showNameDialog(
      context,
      title: 'New collection',
      confirmLabel: 'Create',
      label: 'Collection name',
    );
    if (name == null) return;
    _report(await ref.read(collectionsProvider.notifier).create(name));
  }

  Future<void> rename(Collection collection) async {
    final name = await showNameDialog(
      context,
      title: 'Rename collection',
      confirmLabel: 'Rename',
      label: 'Collection name',
      initialValue: collection.name,
    );
    if (name == null || name.trim() == collection.name) return;
    _report(
      await ref.read(collectionsProvider.notifier).rename(collection.id, name),
    );
  }

  Future<void> duplicate(Collection collection) async => _report(
    await ref.read(collectionsProvider.notifier).duplicate(collection),
  );

  /// Returns true if the collection was deleted.
  Future<bool> delete(
    Collection collection, {
    required int requestCount,
  }) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete "${collection.name}"?',
      message: requestCount == 0
          ? 'This collection will be deleted.'
          : 'This collection and its $requestCount '
                '${requestCount == 1 ? 'request' : 'requests'} will be deleted.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed) return false;
    final result = await ref
        .read(collectionsProvider.notifier)
        .delete(collection.id);
    _report(result);
    return result.isSuccess;
  }

  /// Opens a new tab that will be saved into [collection].
  void newRequestIn(Collection collection) {
    ref.read(requestTabsProvider.notifier).openNew(collectionId: collection.id);
    context.go(requestPath);
  }

  void _report(Result<Object?> result) {
    final failure = result.failureOrNull;
    if (failure != null) showFailureSnackBar(context, failure);
  }
}

class SavedRequestActions {
  const SavedRequestActions(this.context, this.ref);

  final BuildContext context;
  final WidgetRef ref;

  void open(SavedRequest request) {
    ref.read(requestTabsProvider.notifier).openSaved(request);
    context.go(requestPath);
  }

  Future<void> rename(SavedRequest request) async {
    final name = await showNameDialog(
      context,
      title: 'Rename request',
      confirmLabel: 'Rename',
      label: 'Request name',
      initialValue: request.name,
    );
    if (name == null || name.trim() == request.name) return;
    _report(
      await ref.read(savedRequestsProvider.notifier).rename(request.id, name),
    );
  }

  Future<void> duplicate(SavedRequest request) async => _report(
    await ref.read(savedRequestsProvider.notifier).duplicate(request),
  );

  Future<void> delete(SavedRequest request) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete "${request.name}"?',
      message: 'This request will be deleted.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed) return;
    _report(await ref.read(savedRequestsProvider.notifier).delete(request.id));
  }

  void _report(Result<Object?> result) {
    final failure = result.failureOrNull;
    if (failure != null) showFailureSnackBar(context, failure);
  }
}
