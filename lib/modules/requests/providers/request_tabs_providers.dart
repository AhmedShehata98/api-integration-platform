import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_point/modules/auth/auth.dart';
import 'package:test_point/modules/requests/models/http_request_draft.dart';
import 'package:test_point/modules/requests/models/request_tab.dart';
import 'package:test_point/modules/requests/models/saved_request.dart';
import 'package:test_point/modules/requests/models/send_state.dart';
import 'package:test_point/modules/requests/repositories/http_request_repository.dart';
import 'package:test_point/modules/requests/services/url_params_sync.dart';

const untitledRequestName = 'Untitled request';

/// The open request tabs and which one is active. Starts with none.
final requestTabsProvider =
    NotifierProvider<RequestTabsNotifier, RequestTabsState>(
      RequestTabsNotifier.new,
    );

/// Cancel handles of requests in flight, by tab id. A separate provider so
/// closing a tab can cancel its request without the tabs depending on the
/// send notifier (which depends on the tabs).
final inFlightRequestsProvider = Provider<Map<String, CancelSignal>>(
  (ref) => {},
);

final activeRequestTabProvider = Provider<RequestTab?>(
  (ref) => ref.watch(requestTabsProvider).active,
);

/// [draft] with its Params table rebuilt from the URL's query string; disabled
/// params it already has are kept.
HttpRequestDraft withParamsFromUrl(HttpRequestDraft draft) => draft.copyWith(
  params: UrlParamsSync.paramsFromUrl(draft.url, draft.params),
);

class RequestTabsNotifier extends Notifier<RequestTabsState> {
  int _counter = 0;

  /// The session user the open tabs belong to.
  String? _userId;

  @override
  RequestTabsState build() {
    // Tabs hold one user's requests: drop them when another user takes over.
    // Upgrading a guest keeps the same id, so nothing is lost then.
    ref.listen(sessionProvider.select((s) => s.value?.id), (_, id) {
      if (id == null) return; // signing out: the guest session follows
      final previous = _userId;
      _userId = id;
      if (previous != null && previous != id) _closeAll();
    }, fireImmediately: true);
    return const RequestTabsState();
  }

  void _closeAll() {
    final signals = ref.read(inFlightRequestsProvider);
    for (final signal in signals.values) {
      signal.cancel();
    }
    signals.clear();
    state = const RequestTabsState();
  }

  /// Opens an empty tab; [collectionId] preselects where it will be saved.
  String openNew({String? collectionId}) {
    final id = 'tab-${++_counter}';
    final tab = RequestTab(
      id: id,
      name: untitledRequestName,
      draft: const HttpRequestDraft(),
      collectionId: collectionId,
    );
    state = state.copyWith(tabs: [...state.tabs, tab], activeId: id);
    return id;
  }

  /// Opens a new, unsaved tab holding [draft] (e.g. from an import). The
  /// Params table is rebuilt from the URL's query string.
  String openDraft(HttpRequestDraft draft, {String? name}) {
    final id = 'tab-${++_counter}';
    final tab = RequestTab(
      id: id,
      name: name ?? untitledRequestName,
      draft: withParamsFromUrl(draft),
    );
    state = state.copyWith(tabs: [...state.tabs, tab], activeId: id);
    return id;
  }

  /// Opens [request], or just activates its tab if it is already open.
  void openSaved(SavedRequest request) {
    for (final tab in state.tabs) {
      if (tab.savedRequestId == request.id) {
        activate(tab.id);
        return;
      }
    }
    final id = 'tab-${++_counter}';
    final tab = RequestTab(
      id: id,
      name: request.name,
      draft: request.draft,
      savedDraft: request.draft,
      savedRequestId: request.id,
      collectionId: request.collectionId,
    );
    state = state.copyWith(tabs: [...state.tabs, tab], activeId: id);
  }

  void activate(String id) {
    if (state.tabs.any((t) => t.id == id)) {
      state = state.copyWith(activeId: id);
    }
  }

  void close(String id) {
    final index = state.tabs.indexWhere((t) => t.id == id);
    if (index == -1) return;
    ref.read(inFlightRequestsProvider).remove(id)?.cancel();
    final remaining = [...state.tabs]..removeAt(index);
    var activeId = state.activeId;
    if (activeId == id) {
      activeId = remaining.isEmpty ? null : remaining[max(0, index - 1)].id;
    }
    state = RequestTabsState(tabs: remaining, activeId: activeId);
  }

  /// Applies [edit] to the active tab's draft.
  void editActive(HttpRequestDraft Function(HttpRequestDraft draft) edit) {
    final id = state.activeId;
    if (id == null) return;
    _update(id, (tab) => tab.copyWith(draft: edit(tab.draft)));
  }

  void setSendState(String id, SendState sendState) =>
      _update(id, (tab) => tab.copyWith(sendState: sendState));

  /// Links tab [id] to [saved] after a successful save.
  void markSaved(String id, SavedRequest saved) => _update(
    id,
    (tab) => tab.copyWith(
      name: saved.name,
      savedRequestId: saved.id,
      savedDraft: saved.draft,
      collectionId: saved.collectionId,
    ),
  );

  void _update(String id, RequestTab Function(RequestTab tab) change) {
    state = state.copyWith(
      tabs: [for (final tab in state.tabs) tab.id == id ? change(tab) : tab],
    );
  }

  /// Called by the saved-requests provider (never the other way round, which
  /// would be a circular dependency). Follows renames; a tab whose request was
  /// deleted keeps its content as an unsaved request instead of disappearing.
  void reconcile(List<SavedRequest> saved) {
    final byId = {for (final s in saved) s.id: s};
    final tabs = [
      for (final tab in state.tabs)
        if (tab.savedRequestId == null)
          tab
        else if (byId[tab.savedRequestId] case final current?)
          tab.copyWith(name: current.name, collectionId: current.collectionId)
        else
          tab.copyWith(savedRequestId: null, savedDraft: null),
    ];
    if (!listEquals(tabs, state.tabs)) state = state.copyWith(tabs: tabs);
  }
}
