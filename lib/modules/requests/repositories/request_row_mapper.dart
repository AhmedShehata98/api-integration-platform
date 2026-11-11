import 'dart:convert';

import 'package:test_point/modules/requests/models/http_method.dart';
import 'package:test_point/modules/requests/models/http_request_draft.dart';
import 'package:test_point/modules/requests/models/key_value.dart';
import 'package:test_point/modules/requests/models/request_auth.dart';
import 'package:test_point/modules/requests/models/request_body.dart';
import 'package:test_point/modules/requests/models/saved_request.dart';

/// Maps `requests` table rows to [SavedRequest] and back (see docs/data_model.md).
///
/// `body` holds the text for JSON / raw bodies and a JSON-encoded list of
/// `{key, value, enabled}` for form-data / urlencoded bodies.
abstract final class RequestRowMapper {
  static SavedRequest fromRow(Map<String, dynamic> row) {
    final type = BodyType.values.firstWhere(
      (t) => t.name == row['body_type'],
      orElse: () => BodyType.none,
    );
    final bodyText = row['body'] as String? ?? '';
    final isForm = type == BodyType.formData || type == BodyType.urlEncoded;

    return SavedRequest(
      id: row['id'] as String,
      collectionId: row['collection_id'] as String,
      name: row['name'] as String,
      position: row['position'] as int? ?? 0,
      draft: HttpRequestDraft(
        method: HttpMethod.values.firstWhere(
          (m) => m.label == row['method'],
          orElse: () => HttpMethod.get,
        ),
        url: row['url'] as String? ?? '',
        params: _keyValuesFromJson(row['params']),
        headers: _keyValuesFromJson(row['headers']),
        auth: _authFromJson(row['auth']),
        body: RequestBody(
          type: type,
          text: isForm ? '' : bodyText,
          fields: isForm ? _keyValuesFromJson(_tryDecode(bodyText)) : const [],
        ),
      ),
    );
  }

  /// Columns for [draft]; callers add `collection_id`, `name` and `position`.
  static Map<String, dynamic> toRow(HttpRequestDraft draft) {
    final body = draft.body;
    final isForm =
        body.type == BodyType.formData || body.type == BodyType.urlEncoded;
    return {
      'method': draft.method.label,
      'url': draft.url,
      'params': _keyValuesToJson(draft.params),
      'headers': _keyValuesToJson(draft.headers),
      'auth': _authToJson(draft.auth),
      'body_type': body.type.name,
      'body': switch (body.type) {
        BodyType.none => null,
        _ when isForm => jsonEncode(_keyValuesToJson(body.fields)),
        _ => body.text,
      },
    };
  }

  static List<Map<String, dynamic>> _keyValuesToJson(List<KeyValue> items) => [
    for (final i in items)
      {'key': i.key, 'value': i.value, 'enabled': i.enabled},
  ];

  static List<KeyValue> _keyValuesFromJson(Object? json) => [
    if (json is List)
      for (final item in json.whereType<Map<String, dynamic>>())
        KeyValue(
          key: item['key'] as String? ?? '',
          value: item['value'] as String? ?? '',
          enabled: item['enabled'] as bool? ?? true,
        ),
  ];

  static Map<String, dynamic> _authToJson(RequestAuth auth) => switch (auth) {
    NoAuth() => {'type': 'none'},
    BearerAuth(:final token) => {'type': 'bearer', 'token': token},
    BasicAuth(:final username, :final password) => {
      'type': 'basic',
      'username': username,
      'password': password,
    },
    ApiKeyAuth(:final name, :final value, :final location) => {
      'type': 'apiKey',
      'name': name,
      'value': value,
      'location': location.name,
    },
  };

  static RequestAuth _authFromJson(Object? json) {
    if (json is! Map<String, dynamic>) return const RequestAuth.none();
    return switch (json['type']) {
      'bearer' => RequestAuth.bearer(token: json['token'] as String? ?? ''),
      'basic' => RequestAuth.basic(
        username: json['username'] as String? ?? '',
        password: json['password'] as String? ?? '',
      ),
      'apiKey' => RequestAuth.apiKey(
        name: json['name'] as String? ?? '',
        value: json['value'] as String? ?? '',
        location: ApiKeyLocation.values.firstWhere(
          (l) => l.name == json['location'],
          orElse: () => ApiKeyLocation.header,
        ),
      ),
      _ => const RequestAuth.none(),
    };
  }

  static Object? _tryDecode(String text) {
    try {
      return jsonDecode(text);
    } on FormatException {
      return null;
    }
  }
}
