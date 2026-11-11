import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:test_point/modules/requests/models/http_request_draft.dart';

part 'saved_request.freezed.dart';

/// A request stored in a collection.
@freezed
abstract class SavedRequest with _$SavedRequest {
  const factory SavedRequest({
    required String id,
    required String collectionId,
    required String name,
    required HttpRequestDraft draft,
    @Default(0) int position,
  }) = _SavedRequest;
}
