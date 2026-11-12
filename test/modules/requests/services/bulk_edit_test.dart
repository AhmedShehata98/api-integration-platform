import 'package:flutter_test/flutter_test.dart';
import 'package:test_point/modules/requests/models/key_value.dart';
import 'package:test_point/modules/requests/services/bulk_edit.dart';

void main() {
  test('formats one row per line and marks disabled rows', () {
    expect(
      formatBulk(const [
        KeyValue(key: 'limit', value: '20'),
        KeyValue(key: 'debug', value: '1', enabled: false),
        KeyValue(),
      ]),
      'limit: 20\n# debug: 1',
    );
  });

  test('parses keys, values and disabled rows', () {
    expect(parseBulk('limit: 20\n# debug: 1\n\nflag'), const [
      KeyValue(key: 'limit', value: '20'),
      KeyValue(key: 'debug', value: '1', enabled: false),
      KeyValue(key: 'flag'),
    ]);
  });

  test('the key ends at the first colon, so values can hold colons', () {
    expect(parseBulk('Referer: https://a.test:8080/x'), const [
      KeyValue(key: 'Referer', value: 'https://a.test:8080/x'),
    ]);
  });

  test('format then parse keeps the rows', () {
    const rows = [
      KeyValue(key: 'a', value: 'b'),
      KeyValue(key: 'c', value: 'd', enabled: false),
    ];
    expect(parseBulk(formatBulk(rows)), rows);
  });
}
