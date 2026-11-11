import 'dart:convert';
import 'dart:isolate';

/// Bodies above this size are formatted off the main isolate.
const _isolateThreshold = 64 * 1024;

bool looksLikeJson(String body, {String? contentType}) {
  if (contentType != null && contentType.toLowerCase().contains('json')) {
    return true;
  }
  final start = body.trimLeft();
  return start.startsWith('{') || start.startsWith('[');
}

/// Indented JSON for [body], or null when it is not valid JSON.
Future<String?> prettyPrintJson(String body) {
  if (body.length > _isolateThreshold) {
    return Isolate.run(() => _format(body));
  }
  return Future.value(_format(body));
}

String? _format(String body) {
  try {
    return const JsonEncoder.withIndent('  ').convert(jsonDecode(body));
  } on FormatException {
    return null;
  }
}
