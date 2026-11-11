import 'package:test_point/modules/environments/environments.dart';
import 'package:test_point/modules/requests/models/http_request_draft.dart';
import 'package:test_point/modules/requests/models/key_value.dart';
import 'package:test_point/modules/requests/models/request_auth.dart';

/// A draft with its `{{variables}}` replaced, ready for [RequestBuilder].
class ResolvedDraft {
  const ResolvedDraft(this.draft, this.unresolvedInUrl);

  final HttpRequestDraft draft;

  /// Variables in the URL that have no value. The URL cannot be sent as is.
  final Set<String> unresolvedInUrl;
}

/// Applies a [VariableResolver] to the URL, headers, auth and body of a draft.
/// Params are not touched: enabled params live in the URL, which is resolved.
class DraftVariableResolver {
  const DraftVariableResolver(this._resolver);

  final VariableResolver _resolver;

  ResolvedDraft resolve(HttpRequestDraft draft) {
    final url = _resolver.resolve(draft.url);
    return ResolvedDraft(
      draft.copyWith(
        url: url.text,
        headers: _pairs(draft.headers),
        auth: _auth(draft.auth),
        body: draft.body.copyWith(
          text: _resolver.apply(draft.body.text),
          fields: _pairs(draft.body.fields),
        ),
      ),
      url.unresolved,
    );
  }

  List<KeyValue> _pairs(List<KeyValue> items) => [
    for (final item in items)
      item.copyWith(
        key: _resolver.apply(item.key),
        value: _resolver.apply(item.value),
      ),
  ];

  RequestAuth _auth(RequestAuth auth) => switch (auth) {
    NoAuth() => auth,
    BearerAuth(:final token) => RequestAuth.bearer(
      token: _resolver.apply(token),
    ),
    BasicAuth(:final username, :final password) => RequestAuth.basic(
      username: _resolver.apply(username),
      password: _resolver.apply(password),
    ),
    ApiKeyAuth(:final name, :final value, :final location) =>
      RequestAuth.apiKey(
        name: _resolver.apply(name),
        value: _resolver.apply(value),
        location: location,
      ),
  };
}
