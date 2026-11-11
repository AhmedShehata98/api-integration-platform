import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:test_point/modules/requests/models/http_method.dart';
import 'package:test_point/modules/requests/models/key_value.dart';
import 'package:test_point/modules/requests/models/request_auth.dart';
import 'package:test_point/modules/requests/models/request_body.dart';

part 'http_request_draft.freezed.dart';

/// A request being edited in the builder (in memory only until Phase 3).
/// [url] is the source of truth for enabled query params; disabled params
/// only live in [params].
@freezed
abstract class HttpRequestDraft with _$HttpRequestDraft {
  const factory HttpRequestDraft({
    @Default(HttpMethod.get) HttpMethod method,
    @Default('') String url,
    @Default([]) List<KeyValue> params,
    @Default([]) List<KeyValue> headers,
    @Default(RequestAuth.none()) RequestAuth auth,
    @Default(RequestBody()) RequestBody body,
  }) = _HttpRequestDraft;
}
