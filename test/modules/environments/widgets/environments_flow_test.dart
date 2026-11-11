import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/core/ui/widgets/variable_chip.dart';
import 'package:test_point/modules/environments/environments.dart';
import 'package:test_point/modules/requests/models/prepared_request.dart';
import 'package:test_point/modules/requests/requests.dart';

import '../../../support/fake_backend.dart';
import '../../../support/pump_app.dart';

class MockHttpRequestRepository extends Mock implements HttpRequestRepository {}

final _urlField = find.byWidgetPredicate(
  (w) => w is TextField && w.decoration?.hintText == 'Enter request URL',
);

FakeStore _store() => FakeStore(
  environments: const [
    Environment(
      id: 'dev',
      workspaceId: 'ws-1',
      name: 'Dev',
      variables: [
        EnvironmentVariable(key: 'baseUrl', value: 'http://dev.test'),
        EnvironmentVariable(key: 'token', value: 'abc123', secret: true),
      ],
    ),
    Environment(
      id: 'prod',
      workspaceId: 'ws-1',
      name: 'Prod',
      variables: [
        EnvironmentVariable(key: 'baseUrl', value: 'http://prod.test'),
      ],
    ),
  ],
);

Future<void> _pickEnvironment(WidgetTester tester, String name) async {
  await tester.tap(
    find.descendant(
      of: find.byType(EnvironmentDropdown),
      matching: find.byType(TextButton),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(MenuItemButton, name));
  await tester.pumpAndSettle();
}

Future<void> _newTab(WidgetTester tester) async {
  await tester.tap(find.byTooltip('New request'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('switching environment changes the URL that is sent', (
    tester,
  ) async {
    final http = MockHttpRequestRepository();
    registerFallbackValue(PreparedRequest(method: 'GET', url: Uri()));
    registerFallbackValue(CancelSignal());
    when(() => http.send(any(), any())).thenAnswer(
      (_) async => const Result.success(
        HttpResponseResult(
          statusCode: 200,
          reason: 'OK',
          headers: {},
          body: 'ok',
          duration: Duration(milliseconds: 1),
          sizeBytes: 2,
        ),
      ),
    );
    await pumpApp(
      tester,
      _store(),
      extraOverrides: [httpRequestRepositoryProvider.overrideWithValue(http)],
    );
    await _newTab(tester);
    await tester.enterText(_urlField, '{{baseUrl}}/users');
    await tester.pumpAndSettle();

    await _pickEnvironment(tester, 'Dev');
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    await _pickEnvironment(tester, 'Prod');
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();

    final sent = verify(() => http.send(captureAny(), any())).captured
        .cast<PreparedRequest>();
    expect(sent.map((r) => r.url.toString()), [
      'http://dev.test/users',
      'http://prod.test/users',
    ]);
    // The field keeps the variable, not the resolved value.
    expect(
      tester.widget<TextField>(_urlField).controller!.text,
      '{{baseUrl}}/users',
    );
  });

  testWidgets('an undefined URL variable shows an amber chip and blocks send', (
    tester,
  ) async {
    await pumpApp(tester, _store());
    await _newTab(tester);
    await tester.enterText(_urlField, '{{baseUrl}}/x');
    await tester.pumpAndSettle();

    // No environment is selected, so the variable is undefined.
    expect(
      tester.widget<VariableChip>(find.byType(VariableChip)).resolved,
      false,
    );

    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Undefined variable'), findsOneWidget);

    await _pickEnvironment(tester, 'Dev');
    expect(
      tester.widget<VariableChip>(find.byType(VariableChip)).resolved,
      true,
    );
  });

  testWidgets('status bar shows the active environment and base URL', (
    tester,
  ) async {
    await pumpApp(tester, _store());
    expect(find.text('No environment'), findsWidgets);

    await _pickEnvironment(tester, 'Dev');

    expect(find.text('Dev · http://dev.test'), findsOneWidget);
  });

  testWidgets('typing {{ suggests variables and inserts the choice', (
    tester,
  ) async {
    await pumpApp(tester, _store());
    await _pickEnvironment(tester, 'Dev');
    await _newTab(tester);

    await tester.enterText(_urlField, '{{ba');
    await tester.pumpAndSettle();
    expect(find.text('{{baseUrl}}'), findsOneWidget);
    expect(find.text('{{token}}'), findsNothing);

    await tester.tap(find.text('{{baseUrl}}'));
    await tester.pumpAndSettle();

    expect(tester.widget<TextField>(_urlField).controller!.text, '{{baseUrl}}');
  });

  group('environments screen', () {
    Future<void> open(WidgetTester tester, FakeStore store) async {
      await pumpApp(tester, store);
      await tester.tap(find.text('Environments'));
      await tester.pumpAndSettle();
    }

    testWidgets('masks secret values until revealed', (tester) async {
      await open(tester, _store());
      await tester.tap(
        find.descendant(of: find.byType(ListTile), matching: find.text('Dev')),
      );
      await tester.pumpAndSettle();

      final secret = find.byWidgetPredicate(
        (w) => w is TextField && w.controller?.text == 'abc123',
      );
      expect(tester.widget<TextField>(secret).obscureText, isTrue);
      await tester.tap(find.byTooltip('Show value'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(secret).obscureText, isFalse);
    });

    testWidgets('creates an environment and saves its variables', (
      tester,
    ) async {
      final store = FakeStore();
      await open(tester, store);

      await tester.tap(find.byTooltip('New environment'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Environment name'),
        'Local',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Create'));
      await tester.pumpAndSettle();
      expect(store.environments.single.name, 'Local');

      await tester.tap(find.text('Add variable'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Key'), 'host');
      await tester.enterText(find.widgetWithText(TextField, 'Value'), 'x.test');
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Save'));
      await tester.pumpAndSettle();

      expect(store.environments.single.variables, [
        const EnvironmentVariable(key: 'host', value: 'x.test'),
      ]);
    });

    testWidgets('deleting asks for confirmation', (tester) async {
      final store = _store();
      await open(tester, store);

      await tester.tap(find.byTooltip('More').first);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(MenuItemButton, 'Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(store.environments.map((e) => e.id), ['prod']);
    });
  });
}
