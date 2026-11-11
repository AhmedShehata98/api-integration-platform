import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_point/app/di/app_overrides.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/network/dio_provider.dart';
import 'package:test_point/modules/settings/repositories/settings_repository_impl.dart';
import 'package:test_point/modules/settings/services/settings_service.dart';
import 'package:test_point/modules/settings/settings.dart';

import '../../support/fake_backend.dart';
import '../../support/pump_app.dart';

Future<SharedPreferences> _prefs([Map<String, Object> values = const {}]) {
  SharedPreferences.setMockInitialValues(values);
  return SharedPreferences.getInstance();
}

void main() {
  group('SettingsRepositoryImpl', () {
    test('defaults when nothing is stored', () async {
      final repository = SettingsRepositoryImpl(await _prefs());
      expect(repository.load(), const AppSettings());
    });

    test('round-trips every setting', () async {
      final prefs = await _prefs();
      const settings = AppSettings(
        themeMode: ThemeMode.light,
        timeoutSeconds: 12,
        followRedirects: false,
        proxyUrl: 'http://127.0.0.1:8888',
      );
      expect(
        (await SettingsRepositoryImpl(prefs).save(settings)).isSuccess,
        isTrue,
      );
      expect(SettingsRepositoryImpl(prefs).load(), settings);
    });

    test('clearing the proxy removes it', () async {
      final prefs = await _prefs({'settings.proxyUrl': 'http://p:1'});
      final repository = SettingsRepositoryImpl(prefs);
      await repository.save(repository.load().copyWith(proxyUrl: null));
      expect(repository.load().proxyUrl, isNull);
    });

    test('an unknown stored theme falls back to the default', () async {
      final prefs = await _prefs({'settings.themeMode': 'sepia'});
      expect(SettingsRepositoryImpl(prefs).load().themeMode, ThemeMode.dark);
    });
  });

  group('SettingsService', () {
    final service = SettingsService(FakeSettingsRepository());

    test('rejects timeouts outside 1-300 seconds', () async {
      for (final seconds in [0, -5, 301]) {
        final result = await service.save(AppSettings(timeoutSeconds: seconds));
        expect(
          result.failureOrNull,
          isA<ValidationFailure>(),
          reason: '$seconds',
        );
      }
    });

    test('rejects proxies that are not http(s) URLs with a host', () async {
      for (final url in ['localhost:8080', 'ftp://h:1', 'http://', 'nope']) {
        final result = await service.save(AppSettings(proxyUrl: url));
        expect(result.failureOrNull, isA<ValidationFailure>(), reason: url);
      }
      expect(
        (await service.save(
          const AppSettings(proxyUrl: 'http://127.0.0.1:8888'),
        )).isSuccess,
        isTrue,
      );
    });
  });

  group('settingsProvider', () {
    test('an invalid change is not applied', () async {
      final container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            FakeSettingsRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(settingsProvider.notifier);

      final result = await notifier.setTimeoutSeconds(0);

      expect(result.failureOrNull, isA<ValidationFailure>());
      expect(container.read(settingsProvider).timeoutSeconds, 30);
    });

    test('theme, timeout, redirects and proxy changes apply to Dio', () async {
      final container = ProviderContainer(
        overrides: appOverrides(await _prefs()),
      );
      addTearDown(container.dispose);
      final notifier = container.read(settingsProvider.notifier);
      expect(container.read(themeModeProvider), ThemeMode.dark);
      expect(
        container.read(dioProvider).options.connectTimeout,
        const Duration(seconds: 30),
      );

      await notifier.setThemeMode(ThemeMode.light);
      await notifier.setTimeoutSeconds(5);
      await notifier.setFollowRedirects(false);
      await notifier.setProxyUrl('http://127.0.0.1:8888');

      expect(container.read(themeModeProvider), ThemeMode.light);
      final BaseOptions options = container.read(dioProvider).options;
      expect(options.connectTimeout, const Duration(seconds: 5));
      expect(options.receiveTimeout, const Duration(seconds: 5));
      expect(options.followRedirects, isFalse);

      await notifier.setProxyUrl('  ');
      expect(container.read(settingsProvider).proxyUrl, isNull);
    });

    test('toggleTheme flips between dark and light', () async {
      final container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            FakeSettingsRepository(),
          ),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(settingsProvider.notifier);

      await notifier.toggleTheme();
      expect(container.read(themeModeProvider), ThemeMode.light);
      await notifier.toggleTheme();
      expect(container.read(themeModeProvider), ThemeMode.dark);
    });
  });

  group('settings screen', () {
    Future<ProviderContainer> open(
      WidgetTester tester, {
      FakeSettingsRepository? repository,
    }) async {
      final container = await pumpApp(
        tester,
        FakeStore(),
        settings: repository,
      );
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      return container;
    }

    testWidgets('theme choice is applied and stored', (tester) async {
      final repository = FakeSettingsRepository();
      final container = await open(tester, repository: repository);

      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();

      expect(container.read(themeModeProvider), ThemeMode.light);
      expect(repository.settings.themeMode, ThemeMode.light);
    });

    testWidgets('timeout is applied on submit; invalid input is reverted', (
      tester,
    ) async {
      final container = await open(tester);
      final field = find.widgetWithText(TextField, 'Timeout (seconds)');

      await tester.enterText(field, '10');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(container.read(settingsProvider).timeoutSeconds, 10);

      await tester.enterText(field, '999');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(container.read(settingsProvider).timeoutSeconds, 10);
      expect(find.textContaining('between 1 and 300'), findsWidgets);
      expect(tester.widget<TextField>(field).controller!.text, '10');
    });

    testWidgets('redirects switch and proxy are applied; status bar follows', (
      tester,
    ) async {
      final container = await open(tester);

      await tester.tap(find.widgetWithText(SwitchListTile, 'Follow redirects'));
      await tester.pumpAndSettle();
      expect(container.read(settingsProvider).followRedirects, isFalse);

      expect(find.text('Proxy: Off'), findsOneWidget);
      await tester.tap(find.widgetWithText(SwitchListTile, 'Use a proxy'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Proxy URL'),
        'http://127.0.0.1:8888',
      );
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(
        container.read(settingsProvider).proxyUrl,
        'http://127.0.0.1:8888',
      );
      expect(find.text('Proxy: 127.0.0.1'), findsOneWidget);

      await tester.tap(find.widgetWithText(SwitchListTile, 'Use a proxy'));
      await tester.pumpAndSettle();
      expect(container.read(settingsProvider).proxyUrl, isNull);
      expect(find.text('Proxy: Off'), findsOneWidget);
    });

    testWidgets('nav-rail toggle switches the theme', (tester) async {
      final container = await open(tester);

      await tester.tap(find.byTooltip('Switch to light theme'));
      await tester.pumpAndSettle();

      expect(container.read(themeModeProvider), ThemeMode.light);
    });
  });
}
