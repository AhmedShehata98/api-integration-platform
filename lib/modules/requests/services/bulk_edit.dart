import 'package:test_point/modules/requests/models/key_value.dart';

/// Text form of a key/value table for Bulk Edit: one `key: value` per line,
/// and a leading `# ` marks a disabled row.
String formatBulk(List<KeyValue> items) => [
  for (final item in items)
    if (item.key.isNotEmpty || item.value.isNotEmpty)
      '${item.enabled ? '' : '# '}${item.key}: ${item.value}',
].join('\n');

/// Parses [formatBulk] text back into rows. Blank lines are skipped. The key
/// ends at the first `:`, so values may contain colons (`https://...`).
List<KeyValue> parseBulk(String text) {
  final items = <KeyValue>[];
  for (final raw in text.split('\n')) {
    var line = raw.trim();
    if (line.isEmpty) continue;
    var enabled = true;
    if (line.startsWith('#')) {
      enabled = false;
      line = line.substring(1).trim();
      if (line.isEmpty) continue;
    }
    final colon = line.indexOf(':');
    items.add(
      colon < 0
          ? KeyValue(key: line, enabled: enabled)
          : KeyValue(
              key: line.substring(0, colon).trim(),
              value: line.substring(colon + 1).trim(),
              enabled: enabled,
            ),
    );
  }
  return items;
}
