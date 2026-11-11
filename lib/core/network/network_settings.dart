import 'package:flutter_riverpod/flutter_riverpod.dart';

/// How the shared HTTP client should behave. `core` only defines the shape;
/// the app wires the values from the settings module (see `app/di/`).
class NetworkSettings {
  const NetworkSettings({
    this.timeout = const Duration(seconds: 30),
    this.followRedirects = true,
    this.proxyUrl,
  });

  final Duration timeout;
  final bool followRedirects;

  /// `http://host:port`, or null for a direct connection.
  final String? proxyUrl;

  @override
  bool operator ==(Object other) =>
      other is NetworkSettings &&
      other.timeout == timeout &&
      other.followRedirects == followRedirects &&
      other.proxyUrl == proxyUrl;

  @override
  int get hashCode => Object.hash(timeout, followRedirects, proxyUrl);
}

final networkSettingsProvider = Provider<NetworkSettings>(
  (ref) => const NetworkSettings(),
);
