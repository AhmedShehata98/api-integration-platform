import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/collections/collections.dart';
import 'package:test_point/modules/import/models/import_result.dart';
import 'package:test_point/modules/import/services/curl_parser.dart';
import 'package:test_point/modules/import/services/postman_importer.dart';
import 'package:test_point/modules/requests/requests.dart';

/// Lets the user choose a Postman JSON file and returns its text, or null if
/// they cancel. A provider so tests can replace the native picker.
typedef PickImportFile = Future<String?> Function();

final pickImportFileProvider = Provider<PickImportFile>(
  (ref) => () async {
    final file = await FilePicker.pickFile(
      dialogTitle: 'Choose a Postman collection',
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    if (file == null) return null;
    return utf8.decode(await file.readAsBytes(), allowMalformed: true);
  },
);

final importActionsProvider = Provider<ImportActions>(ImportActions.new);

/// Runs an import: parse, then store the result through the `requests` and
/// `collections` modules.
class ImportActions {
  const ImportActions(this._ref);

  final Ref _ref;

  /// Opens the command as a new, unsaved tab.
  Result<ImportSummary> importCurl(String command) {
    final parsed = const CurlParser().parse(command);
    final import = parsed.valueOrNull;
    if (import == null) return Result.failure(parsed.failureOrNull!);

    final request = import.requests.single;
    _ref
        .read(requestTabsProvider.notifier)
        .openDraft(request.draft, name: request.name);
    return Result.success(
      ImportSummary(importedCount: 1, skipped: import.skipped),
    );
  }

  /// Creates a collection with the file's requests.
  Future<Result<ImportSummary>> importPostman(String source) async {
    final parsed = await const PostmanImporter().parse(source);
    final import = parsed.valueOrNull;
    if (import == null) return Result.failure(parsed.failureOrNull!);
    if (import.requests.isEmpty) {
      return const Result.failure(
        ValidationFailure('The collection has no requests to import.'),
      );
    }

    final created = await _ref
        .read(collectionsProvider.notifier)
        .create(import.name);
    final collection = created.valueOrNull;
    if (collection == null) return Result.failure(created.failureOrNull!);

    final saved = await _ref.read(savedRequestsProvider.notifier).createMany(
      collection.id,
      [for (final r in import.requests) (name: r.name, draft: r.draft)],
    );
    final failure = saved.failureOrNull;
    if (failure != null) return Result.failure(failure);

    return Result.success(
      ImportSummary(
        importedCount: import.requests.length,
        skipped: import.skipped,
        collectionName: collection.name,
      ),
    );
  }
}
