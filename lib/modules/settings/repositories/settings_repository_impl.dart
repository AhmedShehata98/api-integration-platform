import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/settings/models/app_settings.dart';
import 'package:test_point/modules/settings/repositories/settings_repository.dart';

const _themeKey = 'settings.themeMode';
const _timeoutKey = 'settings.timeoutSeconds';
const _redirectsKey = 'settings.followRedirects';
const _proxyKey = 'settings.proxyUrl';
const _stackedKey = 'settings.stackedLayout';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._prefs);

  final SharedPreferences _prefs;

  @override
  AppSettings load() {
    const defaults = AppSettings();
    return AppSettings(
      themeMode:
          ThemeMode.values.asNameMap()[_prefs.getString(_themeKey)] ??
          defaults.themeMode,
      timeoutSeconds: _prefs.getInt(_timeoutKey) ?? defaults.timeoutSeconds,
      followRedirects:
          _prefs.getBool(_redirectsKey) ?? defaults.followRedirects,
      proxyUrl: _prefs.getString(_proxyKey),
      stackedLayout: _prefs.getBool(_stackedKey) ?? defaults.stackedLayout,
    );
  }

  @override
  Future<Result<void>> save(AppSettings settings) async {
    try {
      await _prefs.setString(_themeKey, settings.themeMode.name);
      await _prefs.setInt(_timeoutKey, settings.timeoutSeconds);
      await _prefs.setBool(_redirectsKey, settings.followRedirects);
      await _prefs.setBool(_stackedKey, settings.stackedLayout);
      final proxy = settings.proxyUrl;
      if (proxy == null) {
        await _prefs.remove(_proxyKey);
      } else {
        await _prefs.setString(_proxyKey, proxy);
      }
      return const Result.success(null);
    } on Object {
      return const Result.failure(
        StorageFailure('Could not save settings on this device.'),
      );
    }
  }
}
