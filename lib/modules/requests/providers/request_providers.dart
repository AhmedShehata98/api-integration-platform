import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_point/core/network/dio_provider.dart';
import 'package:test_point/modules/environments/environments.dart';
import 'package:test_point/modules/requests/models/http_method.dart';
import 'package:test_point/modules/requests/models/http_request_draft.dart';
import 'package:test_point/modules/requests/models/key_value.dart';
import 'package:test_point/modules/requests/models/request_auth.dart';
import 'package:test_point/modules/requests/models/request_body.dart';
import 'package:test_point/modules/requests/models/send_state.dart';
import 'package:test_point/modules/requests/providers/request_tabs_providers.dart';
import 'package:test_point/modules/requests/repositories/http_request_repository.dart';
import 'package:test_point/modules/requests/repositories/http_request_repository_impl.dart';
import 'package:test_point/modules/requests/services/send_request_service.dart';
import 'package:test_point/modules/requests/services/url_params_sync.dart';

final httpRequestRepositoryProvider = Provider<HttpRequestRepository>(
  (ref) => HttpRequestRepositoryImpl(ref.watch(dioProvider)),
);

final sendRequestServiceProvider = Provider<SendRequestService>(
  (ref) => SendRequestService(
    ref.watch(httpRequestRepositoryProvider),
    resolver: ref.watch(variableResolverProvider),
  ),
);

/// The draft of the active tab. Reads follow the active tab; the setters edit it.
final requestDraftProvider =
    NotifierProvider<RequestDraftNotifier, HttpRequestDraft>(
      RequestDraftNotifier.new,
    );

class RequestDraftNotifier extends Notifier<HttpRequestDraft> {
  @override
  HttpRequestDraft build() => ref.watch(
    requestTabsProvider.select(
      (tabs) => tabs.active?.draft ?? const HttpRequestDraft(),
    ),
  );

  void _edit(HttpRequestDraft Function(HttpRequestDraft draft) change) =>
      ref.read(requestTabsProvider.notifier).editActive(change);

  void setMethod(HttpMethod method) => _edit((d) => d.copyWith(method: method));

  /// Editing the URL rebuilds the Params table from its query string.
  void setUrl(String url) => _edit(
    (d) => d.copyWith(
      url: url,
      params: UrlParamsSync.paramsFromUrl(url, d.params),
    ),
  );

  /// Editing Params rewrites the URL query string.
  void setParams(List<KeyValue> params) => _edit(
    (d) => d.copyWith(
      params: params,
      url: UrlParamsSync.urlWithParams(d.url, params),
    ),
  );

  void setHeaders(List<KeyValue> headers) =>
      _edit((d) => d.copyWith(headers: headers));

  void setAuth(RequestAuth auth) => _edit((d) => d.copyWith(auth: auth));

  void setBody(RequestBody body) => _edit((d) => d.copyWith(body: body));
}

/// Send / cancel the active tab's request. The outcome is stored on the tab,
/// so every tab keeps its own response.
final sendStateProvider = NotifierProvider<SendNotifier, SendState>(
  SendNotifier.new,
);

class SendNotifier extends Notifier<SendState> {
  Map<String, CancelSignal> get _signals => ref.read(inFlightRequestsProvider);

  @override
  SendState build() => ref.watch(
    requestTabsProvider.select((s) => s.active?.sendState ?? const SendIdle()),
  );

  Future<void> send() async {
    final tabs = ref.read(requestTabsProvider.notifier);
    final tab = ref.read(requestTabsProvider).active;
    if (tab == null || tab.sendState is SendLoading) return;

    final signal = CancelSignal();
    _signals[tab.id] = signal;
    tabs.setSendState(tab.id, const SendLoading());

    final result = await ref.read(sendRequestServiceProvider)(
      tab.draft,
      signal,
    );

    // Ignore the outcome if the request was cancelled or the tab closed.
    if (!ref.mounted || !identical(_signals[tab.id], signal)) return;
    _signals.remove(tab.id);
    tabs.setSendState(
      tab.id,
      result.when(success: SendSuccess.new, failure: SendFailed.new),
    );
  }

  void cancel() {
    final id = ref.read(requestTabsProvider).activeId;
    final signal = id == null ? null : _signals.remove(id);
    if (id == null || signal == null) return;
    signal.cancel();
    ref.read(requestTabsProvider.notifier).setSendState(id, const SendIdle());
  }
}

/// Whether the request builder sits above the response (true) or beside it.
/// The app wires this to the user's layout setting (see `app/di/`).
final requestPanesStackedProvider = Provider<bool>((ref) => true);
