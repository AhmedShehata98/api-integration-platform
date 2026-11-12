import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/modules/requests/models/send_state.dart';
import 'package:test_point/modules/requests/requests.dart';

import '../../../support/pump_app.dart';

void main() {
  testWidgets('Send shows the Ctrl+Enter hint', (tester) async {
    await pumpApp(tester, sampleStore());
    await tester.tap(find.text('New request').first);
    await tester.pumpAndSettle();

    expect(find.text('Ctrl+Enter'), findsOneWidget);
  });

  testWidgets('Params and Headers tabs count their enabled rows', (
    tester,
  ) async {
    final container = await pumpApp(tester, sampleStore());
    await tester.tap(find.text('New request').first);
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: find.byType(Tab), matching: find.text('0')),
      findsNothing,
    );

    container.read(requestDraftProvider.notifier).setParams(const [
      KeyValue(key: 'limit', value: '20'),
      KeyValue(key: 'off', value: '1', enabled: false),
      KeyValue(key: '', value: 'ignored'),
    ]);
    container.read(requestDraftProvider.notifier).setHeaders(const [
      KeyValue(key: 'Accept', value: 'json'),
    ]);
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.widgetWithText(Tab, 'Params'),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.widgetWithText(Tab, 'Headers'),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('a failed request shows the reason and a Retry button', (
    tester,
  ) async {
    final container = await pumpApp(tester, sampleStore());
    await tester.tap(find.text('New request').first);
    await tester.pumpAndSettle();
    final tabs = container.read(requestTabsProvider.notifier);
    tabs.setSendState(
      container.read(requestTabsProvider).activeId!,
      const SendFailed(NetworkFailure('Request timed out.')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Request failed'), findsOneWidget);
    expect(find.text('Request timed out.'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}
