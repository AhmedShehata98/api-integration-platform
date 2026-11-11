import 'package:test_point/modules/requests/requests.dart';

/// A request read from an import source, not yet stored anywhere.
class ImportedRequest {
  const ImportedRequest({required this.name, required this.draft});

  final String name;
  final HttpRequestDraft draft;
}

/// What a parser found: the requests plus a note for everything it left out.
class ParsedImport {
  const ParsedImport({
    required this.name,
    required this.requests,
    this.skipped = const [],
  });

  /// Collection name for a collection import; unused for a single request.
  final String name;
  final List<ImportedRequest> requests;
  final List<String> skipped;
}

/// Shown to the user once an import is done.
class ImportSummary {
  const ImportSummary({
    required this.importedCount,
    required this.skipped,
    this.collectionName,
  });

  final int importedCount;
  final List<String> skipped;

  /// Set when a collection was created.
  final String? collectionName;
}
