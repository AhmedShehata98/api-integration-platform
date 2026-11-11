import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/settings/models/app_settings.dart';

abstract interface class SettingsRepository {
  /// Stored settings; anything missing or unreadable falls back to defaults.
  AppSettings load();

  Future<Result<void>> save(AppSettings settings);
}
