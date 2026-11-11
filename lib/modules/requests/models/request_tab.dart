import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:test_point/modules/requests/models/http_request_draft.dart';
import 'package:test_point/modules/requests/models/send_state.dart';

part 'request_tab.freezed.dart';

/// One open request in the top bar.
@freezed
abstract class RequestTab with _$RequestTab {
  const factory RequestTab({
    required String id,
    required String name,
    required HttpRequestDraft draft,

    /// What is stored in the database; null while the tab was never saved.
    HttpRequestDraft? savedDraft,
    String? savedRequestId,

    /// Collection the request is saved in, or the one a new request is meant for.
    String? collectionId,
    @Default(SendIdle()) SendState sendState,
  }) = _RequestTab;

  const RequestTab._();

  bool get isSaved => savedRequestId != null;

  /// Shows the unsaved dot: edited since the last save, or new and not empty.
  bool get isDirty => savedDraft == null
      ? draft != const HttpRequestDraft()
      : draft != savedDraft;
}

@freezed
abstract class RequestTabsState with _$RequestTabsState {
  const factory RequestTabsState({
    @Default([]) List<RequestTab> tabs,
    String? activeId,
  }) = _RequestTabsState;

  const RequestTabsState._();

  RequestTab? get active {
    for (final tab in tabs) {
      if (tab.id == activeId) return tab;
    }
    return null;
  }
}
