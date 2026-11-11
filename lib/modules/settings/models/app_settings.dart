import 'package:flutter/material.dart' show ThemeMode;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';

/// Preferences stored on the device.
@freezed
abstract class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(ThemeMode.dark) ThemeMode themeMode,
    @Default(30) int timeoutSeconds,
    @Default(true) bool followRedirects,

    /// Proxy URL; null means the proxy is off.
    String? proxyUrl,
  }) = _AppSettings;
}
