import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_point/core/network/network_settings.dart';
import 'package:test_point/modules/auth/auth.dart';
import 'package:test_point/modules/collections/collections.dart';
import 'package:test_point/modules/environments/environments.dart';
import 'package:test_point/modules/requests/requests.dart';
import 'package:test_point/modules/settings/settings.dart';

/// App-level wiring between modules and `core`. Modules cannot import each
/// other's internals, so the connections that need two of them live here.
List<Override> moduleWiring() => [
  // The HTTP client follows the user's settings.
  networkSettingsProvider.overrideWith((ref) {
    final settings = ref.watch(settingsProvider);
    return NetworkSettings(
      timeout: Duration(seconds: settings.timeoutSeconds),
      followRedirects: settings.followRedirects,
      proxyUrl: settings.proxyUrl,
    );
  }),
  // The layout toggle (top bar) is a device setting stored by `settings`.
  requestPanesStackedProvider.overrideWith(
    (ref) => ref.watch(settingsProvider.select((s) => s.stackedLayout)),
  ),
  // Signing in to another account discards the guest's work: `auth` asks
  // whether there is any.
  guestHasDataProvider.overrideWith((ref) {
    final collections = ref.watch(collectionsProvider).value ?? const [];
    final environments = ref.watch(environmentsProvider).value ?? const [];
    return collections.isNotEmpty || environments.isNotEmpty;
  }),
];

/// [moduleWiring] plus the device preferences loaded in `main()`.
List<Override> appOverrides(SharedPreferences preferences) => [
  sharedPreferencesProvider.overrideWithValue(preferences),
  ...moduleWiring(),
];
