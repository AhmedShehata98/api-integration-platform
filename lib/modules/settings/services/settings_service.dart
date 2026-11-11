import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/settings/models/app_settings.dart';
import 'package:test_point/modules/settings/repositories/settings_repository.dart';

const minTimeoutSeconds = 1;
const maxTimeoutSeconds = 300;

/// Validates settings before they are stored.
class SettingsService {
  SettingsService(this._repository);

  final SettingsRepository _repository;

  AppSettings load() => _repository.load();

  /// Stores [settings] if they are valid.
  Future<Result<void>> save(AppSettings settings) {
    final failure = validate(settings);
    if (failure != null) return Future.value(Result.failure(failure));
    return _repository.save(settings);
  }

  Failure? validate(AppSettings settings) {
    final timeout = settings.timeoutSeconds;
    if (timeout < minTimeoutSeconds || timeout > maxTimeoutSeconds) {
      return const ValidationFailure(
        'Timeout must be between $minTimeoutSeconds and $maxTimeoutSeconds '
        'seconds.',
      );
    }
    final proxy = settings.proxyUrl;
    if (proxy != null && !_isProxyUrl(proxy)) {
      return const ValidationFailure('Enter the proxy as http://host:port.');
    }
    return null;
  }

  bool _isProxyUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    return uri != null &&
        uri.host.isNotEmpty &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }
}
