import 'dart:convert';

import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/requests/models/http_request_draft.dart';
import 'package:test_point/modules/requests/models/key_value.dart';
import 'package:test_point/modules/requests/models/prepared_request.dart';
import 'package:test_point/modules/requests/models/request_auth.dart';
import 'package:test_point/modules/requests/models/request_body.dart';

final _schemePattern = RegExp(r'^[a-zA-Z][a-zA-Z0-9+.-]*://');

/// Turns a [HttpRequestDraft] into a [PreparedRequest]: validates the URL,
/// applies auth and sets default headers.
class RequestBuilder {
  const RequestBuilder();

  Result<PreparedRequest> build(HttpRequestDraft draft) {
    final url = _parseUrl(draft.url);
    if (url == null) {
      return Result.failure(
        ValidationFailure(
          draft.url.trim().isEmpty ? 'Enter a URL.' : 'Enter a valid URL.',
        ),
      );
    }

    final headers = <String, String>{
      for (final header in _active(draft.headers)) header.key: header.value,
    };
    var uri = url;
    switch (draft.auth) {
      case NoAuth():
        break;
      case BearerAuth(:final token):
        _setHeader(headers, 'Authorization', 'Bearer $token');
      case BasicAuth(:final username, :final password):
        final encoded = base64.encode(utf8.encode('$username:$password'));
        _setHeader(headers, 'Authorization', 'Basic $encoded');
      case ApiKeyAuth(:final name, :final value, :final location):
        if (name.isNotEmpty) {
          if (location == ApiKeyLocation.header) {
            _setHeader(headers, name, value);
          } else {
            uri = uri.replace(
              queryParameters: {...uri.queryParametersAll, name: value},
            );
          }
        }
    }

    final body = draft.body;
    String? bodyText;
    Map<String, String>? multipart;
    switch (body.type) {
      case BodyType.none:
        break;
      case BodyType.json:
        bodyText = _textOrNull(body.text);
        if (bodyText != null) {
          _setDefaultHeader(headers, 'Content-Type', 'application/json');
        }
      case BodyType.raw:
        bodyText = _textOrNull(body.text);
        if (bodyText != null) {
          _setDefaultHeader(headers, 'Content-Type', 'text/plain');
        }
      case BodyType.urlEncoded:
        bodyText = _active(body.fields)
            .map(
              (f) =>
                  '${Uri.encodeQueryComponent(f.key)}='
                  '${Uri.encodeQueryComponent(f.value)}',
            )
            .join('&');
        _setDefaultHeader(
          headers,
          'Content-Type',
          'application/x-www-form-urlencoded',
        );
      case BodyType.formData:
        // Dio sets the multipart Content-Type with its boundary.
        headers.removeWhere((k, _) => k.toLowerCase() == 'content-type');
        multipart = {for (final f in _active(body.fields)) f.key: f.value};
    }

    return Result.success(
      PreparedRequest(
        method: draft.method.label,
        url: uri,
        headers: headers,
        body: bodyText,
        multipartFields: multipart,
      ),
    );
  }

  /// Adds `http://` when the scheme is missing; null if not a usable http(s) URL.
  Uri? _parseUrl(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;
    final withScheme = _schemePattern.hasMatch(trimmed)
        ? trimmed
        : 'http://$trimmed';
    final uri = Uri.tryParse(withScheme);
    if (uri == null || uri.host.isEmpty) return null;
    // Uri keeps a host with spaces, percent-encoded, e.g. "ht%20tp".
    if (Uri.decodeComponent(uri.host).contains(RegExp(r'\s'))) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;
    return uri;
  }

  Iterable<KeyValue> _active(List<KeyValue> items) =>
      items.where((item) => item.enabled && item.key.trim().isNotEmpty);

  String? _textOrNull(String text) => text.trim().isEmpty ? null : text;

  void _setHeader(Map<String, String> headers, String name, String value) {
    headers.removeWhere((k, _) => k.toLowerCase() == name.toLowerCase());
    headers[name] = value;
  }

  void _setDefaultHeader(
    Map<String, String> headers,
    String name,
    String value,
  ) {
    final present = headers.keys.any(
      (k) => k.toLowerCase() == name.toLowerCase(),
    );
    if (!present) headers[name] = value;
  }
}
