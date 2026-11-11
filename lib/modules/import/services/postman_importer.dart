import 'dart:convert';
import 'dart:isolate';

import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/import/models/import_result.dart';
import 'package:test_point/modules/requests/requests.dart';

/// Files above this size are decoded off the main isolate.
const _isolateThreshold = 1024 * 1024;
const _maxNameLength = 255;
const _unnamedRequest = 'Untitled request';

/// Reads a Postman Collection v2.1 file. Folders are flattened into the
/// request name (`Folder / Request`); anything unsupported is listed in
/// [ParsedImport.skipped] instead of failing the import.
class PostmanImporter {
  const PostmanImporter();

  Future<Result<ParsedImport>> parse(String source) async {
    final Object? decoded;
    try {
      decoded = source.length > _isolateThreshold
          ? await Isolate.run(() => jsonDecode(source))
          : jsonDecode(source);
    } on FormatException {
      return const Result.failure(
        ValidationFailure('This file is not valid JSON.'),
      );
    }
    return _read(decoded);
  }

  Result<ParsedImport> _read(Object? root) {
    if (root is! Map<String, dynamic>) return _notPostman;
    final info = root['info'];
    final items = root['item'];
    if (info is! Map<String, dynamic> || items is! List) return _notPostman;

    final schema = '${info['schema'] ?? ''}';
    if (!schema.contains('/collection/v2.1')) {
      return const Result.failure(
        ValidationFailure('Only Postman Collection v2.1 files are supported.'),
      );
    }

    final reader = _Reader();
    reader.readItems(
      items,
      const [],
      _auth(root['auth'], reader, 'collection'),
    );
    final name = '${info['name'] ?? ''}'.trim();
    return Result.success(
      ParsedImport(
        name: name.isEmpty ? 'Imported collection' : _clip(name),
        requests: reader.requests,
        skipped: reader.skipped,
      ),
    );
  }

  static const _notPostman = Result<ParsedImport>.failure(
    ValidationFailure('This file is not a Postman collection.'),
  );
}

String _clip(String name) =>
    name.length > _maxNameLength ? name.substring(0, _maxNameLength) : name;

/// Auth declared at a level: null means "not declared, inherit".
RequestAuth? _auth(Object? raw, _Reader reader, String where) {
  if (raw is! Map<String, dynamic>) return null;
  final type = raw['type'];
  switch (type) {
    case 'noauth':
      return const RequestAuth.none();
    case 'bearer':
      return RequestAuth.bearer(token: _param(raw['bearer'], 'token'));
    case 'basic':
      return RequestAuth.basic(
        username: _param(raw['basic'], 'username'),
        password: _param(raw['basic'], 'password'),
      );
    case 'apikey':
      return RequestAuth.apiKey(
        name: _param(raw['apikey'], 'key'),
        value: _param(raw['apikey'], 'value'),
        location: _param(raw['apikey'], 'in') == 'query'
            ? ApiKeyLocation.query
            : ApiKeyLocation.header,
      );
    default:
      reader.skipped.add('Auth type "$type" on $where is not supported.');
      return null;
  }
}

/// Postman stores auth settings as `[{key, value}]`.
String _param(Object? list, String key) {
  if (list is! List) return '';
  for (final entry in list) {
    if (entry is Map<String, dynamic> && entry['key'] == key) {
      return '${entry['value'] ?? ''}';
    }
  }
  return '';
}

class _Reader {
  final requests = <ImportedRequest>[];
  final skipped = <String>[];

  void readItems(List<Object?> items, List<String> path, RequestAuth? auth) {
    for (final item in items) {
      if (item is! Map<String, dynamic>) continue;
      final name = '${item['name'] ?? ''}'.trim();
      final here = [...path, if (name.isNotEmpty) name];
      final label = here.isEmpty ? 'an item' : '"${here.join(' / ')}"';

      if (item['event'] is List && (item['event'] as List).isNotEmpty) {
        skipped.add('Scripts on $label were skipped.');
      }
      final children = item['item'];
      final request = item['request'];
      if (children is List) {
        readItems(children, here, _auth(item['auth'], this, label) ?? auth);
      } else if (request is Map<String, dynamic>) {
        _readRequest(request, here, label, auth);
      }
    }
  }

  void _readRequest(
    Map<String, dynamic> request,
    List<String> path,
    String label,
    RequestAuth? inherited,
  ) {
    final method = HttpMethod.values
        .asNameMap()['${request['method']}'.toLowerCase()];
    if (method == null) {
      skipped.add(
        '$label uses method ${request['method']}, which is not supported.',
      );
      return;
    }

    final url = _url(request['url']);
    final headers = _pairs(request['header']);
    final body = _body(request['body'], headers, label);
    final auth = _auth(request['auth'], this, label) ?? inherited;

    requests.add(
      ImportedRequest(
        name: path.isEmpty ? _unnamedRequest : _clip(path.join(' / ')),
        draft: HttpRequestDraft(
          method: method,
          url: url.text,
          // Disabled query params are not in the URL; the requests module
          // adds the enabled ones from the URL when the draft is stored.
          params: url.disabled,
          headers: headers,
          auth: auth ?? const RequestAuth.none(),
          body: body,
        ),
      ),
    );
  }

  ({String text, List<KeyValue> disabled}) _url(Object? raw) {
    if (raw is String) return (text: raw, disabled: const []);
    if (raw is! Map<String, dynamic>) return (text: '', disabled: const []);

    final query = _pairs(raw['query']);
    final disabled = [
      for (final p in query)
        if (!p.enabled) p,
    ];
    final rawUrl = raw['raw'];
    if (rawUrl is String && rawUrl.isNotEmpty) {
      return (text: rawUrl, disabled: disabled);
    }

    // Rebuild from the parts when there is no "raw".
    final host = raw['host'] is List
        ? (raw['host'] as List).join('.')
        : '${raw['host'] ?? ''}';
    final path = raw['path'] is List
        ? (raw['path'] as List).join('/')
        : '${raw['path'] ?? ''}';
    final protocol = raw['protocol'] == null ? '' : '${raw['protocol']}://';
    final port = raw['port'] == null ? '' : ':${raw['port']}';
    final enabledQuery = query
        .where((p) => p.enabled)
        .map((p) => p.value.isEmpty ? p.key : '${p.key}=${p.value}')
        .join('&');
    return (
      text:
          '$protocol$host$port${path.isEmpty ? '' : '/$path'}'
          '${enabledQuery.isEmpty ? '' : '?$enabledQuery'}',
      disabled: disabled,
    );
  }

  /// Postman `[{key, value, disabled}]` lists.
  List<KeyValue> _pairs(Object? list) {
    if (list is! List) return const [];
    return [
      for (final entry in list)
        if (entry is Map<String, dynamic>)
          KeyValue(
            key: '${entry['key'] ?? ''}',
            value: '${entry['value'] ?? ''}',
            enabled: entry['disabled'] != true,
          ),
    ];
  }

  RequestBody _body(Object? raw, List<KeyValue> headers, String label) {
    if (raw is! Map<String, dynamic>) return const RequestBody();
    switch (raw['mode']) {
      case null || 'none':
        return const RequestBody();
      case 'raw':
        final text = '${raw['raw'] ?? ''}';
        final options = raw['options'];
        final rawOptions = options is Map<String, dynamic>
            ? options['raw']
            : null;
        final language = rawOptions is Map<String, dynamic>
            ? rawOptions['language']
            : null;
        final contentType = headers
            .where((h) => h.key.toLowerCase() == 'content-type')
            .map((h) => h.value.toLowerCase())
            .firstOrNull;
        final isJson =
            language == 'json' || (contentType?.contains('json') ?? false);
        return RequestBody(
          type: isJson ? BodyType.json : BodyType.raw,
          text: text,
        );
      case 'urlencoded':
        return RequestBody(
          type: BodyType.urlEncoded,
          fields: _pairs(raw['urlencoded']),
        );
      case 'formdata':
        final fields = <KeyValue>[];
        for (final entry in (raw['formdata'] as List? ?? const [])) {
          if (entry is! Map<String, dynamic>) continue;
          if (entry['type'] == 'file') {
            skipped.add('File field "${entry['key']}" in $label was skipped.');
            continue;
          }
          fields.add(
            KeyValue(
              key: '${entry['key'] ?? ''}',
              value: '${entry['value'] ?? ''}',
              enabled: entry['disabled'] != true,
            ),
          );
        }
        return RequestBody(type: BodyType.formData, fields: fields);
      default:
        skipped.add('Body mode "${raw['mode']}" in $label is not supported.');
        return const RequestBody();
    }
  }
}
