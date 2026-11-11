import 'package:test_point/modules/requests/models/key_value.dart';

/// Keeps the URL query string and the Params table in sync. Works on the raw
/// text (no URI parsing) so `{{variables}}` survive untouched.
abstract final class UrlParamsSync {
  /// Params for [url]'s query, followed by the [existing] disabled params.
  static List<KeyValue> paramsFromUrl(String url, List<KeyValue> existing) {
    final query = _query(url);
    final fromUrl = <KeyValue>[
      if (query.isNotEmpty)
        for (final pair in query.split('&'))
          if (pair.isNotEmpty) _pair(pair),
    ];
    return [...fromUrl, ...existing.where((p) => !p.enabled)];
  }

  /// [url] with its query rebuilt from the enabled [params].
  static String urlWithParams(String url, List<KeyValue> params) {
    final hashAt = url.indexOf('#');
    final fragment = hashAt == -1 ? '' : url.substring(hashAt);
    final withoutFragment = hashAt == -1 ? url : url.substring(0, hashAt);
    final queryAt = withoutFragment.indexOf('?');
    final base = queryAt == -1
        ? withoutFragment
        : withoutFragment.substring(0, queryAt);

    final query = params
        .where((p) => p.enabled && p.key.isNotEmpty)
        .map((p) => p.value.isEmpty ? p.key : '${p.key}=${p.value}')
        .join('&');
    return '$base${query.isEmpty ? '' : '?$query'}$fragment';
  }

  static String _query(String url) {
    final withoutFragment = url.contains('#')
        ? url.substring(0, url.indexOf('#'))
        : url;
    final queryAt = withoutFragment.indexOf('?');
    return queryAt == -1 ? '' : withoutFragment.substring(queryAt + 1);
  }

  static KeyValue _pair(String pair) {
    final eq = pair.indexOf('=');
    return eq == -1
        ? KeyValue(key: pair)
        : KeyValue(key: pair.substring(0, eq), value: pair.substring(eq + 1));
  }
}
