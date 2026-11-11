import 'package:flutter_test/flutter_test.dart';
import 'package:test_point/modules/requests/models/key_value.dart';
import 'package:test_point/modules/requests/services/url_params_sync.dart';

void main() {
  group('paramsFromUrl', () {
    test('parses query pairs', () {
      final params = UrlParamsSync.paramsFromUrl(
        'http://a.test/p?a=1&b=&c',
        [],
      );

      expect(params, const [
        KeyValue(key: 'a', value: '1'),
        KeyValue(key: 'b'),
        KeyValue(key: 'c'),
      ]);
    });

    test('keeps values containing = and {{variables}}', () {
      final params = UrlParamsSync.paramsFromUrl(
        '{{baseUrl}}/p?t={{token}}&q=a=b',
        [],
      );

      expect(params, const [
        KeyValue(key: 't', value: '{{token}}'),
        KeyValue(key: 'q', value: 'a=b'),
      ]);
    });

    test('ignores the fragment and empty segments', () {
      final params = UrlParamsSync.paramsFromUrl(
        'http://a.test?a=1&&#frag?x=1',
        [],
      );

      expect(params, const [KeyValue(key: 'a', value: '1')]);
    });

    test('keeps disabled params after the URL params', () {
      final params = UrlParamsSync.paramsFromUrl('http://a.test?a=1', const [
        KeyValue(key: 'old', value: '2'),
        KeyValue(key: 'off', value: '3', enabled: false),
      ]);

      expect(params, const [
        KeyValue(key: 'a', value: '1'),
        KeyValue(key: 'off', value: '3', enabled: false),
      ]);
    });

    test('no query gives no params', () {
      expect(UrlParamsSync.paramsFromUrl('http://a.test', []), isEmpty);
    });
  });

  group('urlWithParams', () {
    test('rewrites the query from enabled params', () {
      final url = UrlParamsSync.urlWithParams('http://a.test/p?old=1', const [
        KeyValue(key: 'a', value: '1'),
        KeyValue(key: 'b'),
        KeyValue(key: 'off', value: '2', enabled: false),
        KeyValue(value: 'no key'),
      ]);

      expect(url, 'http://a.test/p?a=1&b');
    });

    test('removes the ? when no params are enabled', () {
      final url = UrlParamsSync.urlWithParams('http://a.test/p?a=1', const [
        KeyValue(key: 'a', value: '1', enabled: false),
      ]);

      expect(url, 'http://a.test/p');
    });

    test('keeps the fragment', () {
      final url = UrlParamsSync.urlWithParams('http://a.test/p#top', const [
        KeyValue(key: 'a', value: '1'),
      ]);

      expect(url, 'http://a.test/p?a=1#top');
    });
  });
}
