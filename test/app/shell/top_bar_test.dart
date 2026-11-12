import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_point/modules/requests/requests.dart';
import 'package:test_point/modules/settings/settings.dart';

import '../../support/fake_backend.dart';
import '../../support/pump_app.dart';

void main() {
  testWidgets('the layout toggle switches the panes and is stored', (
    tester,
  ) async {
    final settings = FakeSettingsRepository();
    final container = await pumpApp(tester, sampleStore(), settings: settings);
    expect(container.read(requestPanesStackedProvider), isTrue);

    // One button in the top bar, one in the status bar.
    expect(find.byTooltip('Show panes side by side'), findsNWidgets(2));
    await tester.tap(find.byTooltip('Show panes side by side').first);
    await tester.pumpAndSettle();

    expect(container.read(settingsProvider).stackedLayout, isFalse);
    expect(container.read(requestPanesStackedProvider), isFalse);
    expect(settings.settings.stackedLayout, isFalse);
    expect(find.byTooltip('Stack the panes'), findsNWidgets(2));
  });

  testWidgets('the overflow menu closes all tabs', (tester) async {
    final container = await pumpApp(tester, sampleStore());
    await tester.tap(find.text('New request').first);
    await tester.pumpAndSettle();
    expect(container.read(requestTabsProvider).tabs, isNotEmpty);

    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();
    expect(find.text('Import…'), findsOneWidget);
    expect(find.text('Settings'), findsNWidgets(2)); // rail + menu
    await tester.tap(find.text('Close all tabs'));
    await tester.pumpAndSettle();

    expect(container.read(requestTabsProvider).tabs, isEmpty);
  });

  testWidgets('Close all tabs is disabled without open tabs', (tester) async {
    await pumpApp(tester, sampleStore());
    await tester.tap(find.byTooltip('More options'));
    await tester.pumpAndSettle();

    final item = tester.widget<MenuItemButton>(
      find.widgetWithText(MenuItemButton, 'Close all tabs'),
    );
    expect(item.onPressed, isNull);
  });
}
