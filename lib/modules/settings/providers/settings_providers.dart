import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/settings/models/app_settings.dart';
import 'package:test_point/modules/settings/repositories/settings_repository.dart';
import 'package:test_point/modules/settings/repositories/settings_repository_impl.dart';
import 'package:test_point/modules/settings/services/settings_service.dart';

/// Preloaded in `main()` and overridden there; tests override it too.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw StateError('sharedPreferencesProvider was not overridden.'),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepositoryImpl(ref.watch(sharedPreferencesProvider)),
);

final settingsServiceProvider = Provider<SettingsService>(
  (ref) => SettingsService(ref.watch(settingsRepositoryProvider)),
);

/// The current settings. Changes apply at once and are stored on the device.
final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

class SettingsNotifier extends Notifier<AppSettings> {
  SettingsService get _service => ref.read(settingsServiceProvider);

  @override
  AppSettings build() => ref.watch(settingsServiceProvider).load();

  /// Applies [change] and stores the result. If the new settings are invalid
  /// or cannot be stored, nothing changes and the failure is returned.
  Future<Result<void>> update(
    AppSettings Function(AppSettings current) change,
  ) async {
    final next = change(state);
    final result = await _service.save(next);
    if (result.isSuccess) state = next;
    return result;
  }

  Future<Result<void>> setThemeMode(ThemeMode mode) =>
      update((s) => s.copyWith(themeMode: mode));

  /// Flips between dark and light (the nav-rail toggle).
  Future<Result<void>> toggleTheme() => setThemeMode(
    state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
  );

  Future<Result<void>> setTimeoutSeconds(int seconds) =>
      update((s) => s.copyWith(timeoutSeconds: seconds));

  Future<Result<void>> setFollowRedirects(bool value) =>
      update((s) => s.copyWith(followRedirects: value));

  /// A blank [url] turns the proxy off.
  Future<Result<void>> setProxyUrl(String? url) {
    final trimmed = url?.trim();
    return update(
      (s) => s.copyWith(
        proxyUrl: trimmed == null || trimmed.isEmpty ? null : trimmed,
      ),
    );
  }
}

final themeModeProvider = Provider<ThemeMode>(
  (ref) => ref.watch(settingsProvider.select((s) => s.themeMode)),
);
