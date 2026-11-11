import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/core/ui/widgets/failure_snackbar.dart';
import 'package:test_point/modules/requests/models/saved_request.dart';
import 'package:test_point/modules/requests/providers/request_tabs_providers.dart';
import 'package:test_point/modules/requests/providers/saved_request_providers.dart';
import 'package:test_point/modules/requests/widgets/save_request_dialog.dart';

/// Saves the active tab: straight away if it already has a stored request,
/// otherwise after asking for a name and collection.
Future<void> saveActiveRequest(BuildContext context, WidgetRef ref) async {
  final tab = ref.read(requestTabsProvider).active;
  if (tab == null) return;
  final saved = ref.read(savedRequestsProvider.notifier);

  final result = tab.isSaved
      ? await saved.saveTab(tab.id)
      : await _saveNew(context, saved, tab.id, tab.name, tab.collectionId);

  if (!context.mounted) return;
  final failure = result?.failureOrNull;
  if (failure != null) showFailureSnackBar(context, failure);
}

Future<Result<SavedRequest>?> _saveNew(
  BuildContext context,
  SavedRequestsNotifier saved,
  String tabId,
  String name,
  String? collectionId,
) async {
  final choice = await showDialog<SaveRequestChoice>(
    context: context,
    builder: (_) =>
        SaveRequestDialog(initialName: name, initialCollectionId: collectionId),
  );
  if (choice == null) return null;

  final newCollection = choice.newCollectionName;
  return newCollection != null
      ? saved.saveTabInNewCollection(
          tabId,
          collectionName: newCollection,
          name: choice.name,
        )
      : saved.saveTab(
          tabId,
          collectionId: choice.collectionId,
          name: choice.name,
        );
}
