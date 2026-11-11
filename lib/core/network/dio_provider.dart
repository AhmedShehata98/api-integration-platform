import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_point/core/network/network_settings.dart';

/// Shared Dio client. 4xx/5xx responses are returned as normal responses so
/// the response viewer can show them; only transport problems throw.
/// Rebuilt when the network settings (timeout, redirects, proxy) change.
final dioProvider = Provider<Dio>((ref) {
  final settings = ref.watch(networkSettingsProvider);
  final dio = Dio(
    BaseOptions(
      connectTimeout: settings.timeout,
      receiveTimeout: settings.timeout,
      followRedirects: settings.followRedirects,
      responseType: ResponseType.bytes,
      validateStatus: (_) => true,
    ),
  );
  final proxy = _proxyHost(settings.proxyUrl);
  if (proxy != null) {
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () => HttpClient()..findProxy = (_) => 'PROXY $proxy',
    );
  }
  ref.onDispose(dio.close);
  return dio;
});

/// `host:port` of a proxy URL, or null when there is no usable proxy.
String? _proxyHost(String? url) {
  if (url == null) return null;
  final uri = Uri.tryParse(url.trim());
  if (uri == null || uri.host.isEmpty) return null;
  return '${uri.host}:${uri.hasPort ? uri.port : 8080}';
}
