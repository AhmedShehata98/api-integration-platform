import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/modules/import/import.dart';
import 'package:test_point/modules/requests/requests.dart';

import '../../../support/fake_backend.dart';
import '../../../support/pump_app.dart';

final _dialog = find.byType(AlertDialog);

Future<void> _openDialog(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Import'));
  await tester.pumpAndSettle();
}

void main() {
  group('cURL', () {
    testWidgets('a pasted command opens as a new unsaved tab', (tester) async {
      final container = await pumpApp(tester, FakeStore());
      await _openDialog(tester);

      await tester.enterText(
        find.descendant(of: _dialog, matching: find.byType(TextField)),
        "curl -X POST https://api.test/users -H 'Content-Type: application/json' "
        '-d \'{"name":"Rex"}\'',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Import'));
      await tester.pumpAndSettle();

      expect(_dialog, findsNothing);
      final tab = container.read(requestTabsProvider).active!;
      expect(tab.name, 'POST /users');
      expect(tab.draft.method, HttpMethod.post);
      expect(tab.draft.url, 'https://api.test/users');
      expect(tab.draft.body.type, BodyType.json);
      expect(tab.isDirty, isTrue);
      expect(tab.isSaved, isFalse);
    });

    testWidgets('query params appear in the Params table', (tester) async {
      final container = await pumpApp(tester, FakeStore());
      await _openDialog(tester);

      await tester.enterText(
        find.descendant(of: _dialog, matching: find.byType(TextField)),
        'curl "https://api.test/s?q=dart&page=2"',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Import'));
      await tester.pumpAndSettle();

      expect(container.read(requestTabsProvider).active!.draft.params, const [
        KeyValue(key: 'q', value: 'dart'),
        KeyValue(key: 'page', value: '2'),
      ]);
    });

    testWidgets('options that were ignored are listed', (tester) async {
      await pumpApp(tester, FakeStore());
      await _openDialog(tester);

      await tester.enterText(
        find.descendant(of: _dialog, matching: find.byType(TextField)),
        'curl https://api.test --max-time 5',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Import'));
      await tester.pumpAndSettle();

      expect(find.text('Imported 1 request.'), findsOneWidget);
      expect(find.text('• Option --max-time was ignored.'), findsOneWidget);
    });

    testWidgets('a bad command shows why and keeps the dialog open', (
      tester,
    ) async {
      final container = await pumpApp(tester, FakeStore());
      await _openDialog(tester);

      await tester.enterText(
        find.descendant(of: _dialog, matching: find.byType(TextField)),
        'hello',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Import'));
      await tester.pumpAndSettle();

      expect(
        find.text('This does not look like a cURL command.'),
        findsOneWidget,
      );
      expect(container.read(requestTabsProvider).tabs, isEmpty);
    });
  });

  group('Postman', () {
    final sample = File('test/fixtures/postman_sample_v21.json')
        .readAsStringSync();

    Future<void> chooseFile(WidgetTester tester) async {
      await tester.tap(
        find.descendant(of: _dialog, matching: find.text('Postman')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose file'));
      await tester.pumpAndSettle();
    }

    testWidgets('creates a collection with its requests and shows a summary', (
      tester,
    ) async {
      final store = FakeStore();
      await pumpApp(
        tester,
        store,
        extraOverrides: [
          pickImportFileProvider.overrideWithValue(() async => sample),
        ],
      );
      await _openDialog(tester);

      await chooseFile(tester);

      expect(store.collections.single.name, 'Petstore');
      expect(store.requests, hasLength(6));
      expect(store.requests.map((r) => r.position), [0, 1, 2, 3, 4, 5]);
      expect(
        store.requests.firstWhere((r) => r.name == 'List pets').draft.params,
        const [
          KeyValue(key: 'limit', value: '10'),
          KeyValue(key: 'offset', value: '5', enabled: false),
        ],
      );
      expect(find.text('Imported 6 requests into "Petstore".'), findsOneWidget);
      expect(find.text('Skipped (5)'), findsOneWidget);
      expect(
        find.text('• Auth type "oauth2" on "Graph" is not supported.'),
        findsOneWidget,
      );

      await tester.tap(find.widgetWithText(TextButton, 'Done'));
      await tester.pumpAndSettle();
      // The new collection shows up in the sidebar.
      expect(find.text('Petstore'), findsOneWidget);
    });

    testWidgets('cancelling the picker does nothing', (tester) async {
      final store = FakeStore();
      await pumpApp(
        tester,
        store,
        extraOverrides: [
          pickImportFileProvider.overrideWithValue(() async => null),
        ],
      );
      await _openDialog(tester);

      await chooseFile(tester);

      expect(store.collections, isEmpty);
      expect(_dialog, findsOneWidget);
    });

    testWidgets('a file that is not a v2.1 collection is reported', (
      tester,
    ) async {
      final store = FakeStore();
      await pumpApp(
        tester,
        store,
        extraOverrides: [
          pickImportFileProvider.overrideWithValue(() async => '{"hello":1}'),
        ],
      );
      await _openDialog(tester);

      await chooseFile(tester);

      expect(
        find.text('This file is not a Postman collection.'),
        findsOneWidget,
      );
      expect(store.collections, isEmpty);
    });

    testWidgets('a storage failure is shown and nothing is claimed imported', (
      tester,
    ) async {
      final store = FakeStore();
      await pumpApp(
        tester,
        store,
        extraOverrides: [
          pickImportFileProvider.overrideWithValue(() async => sample),
        ],
      );
      await _openDialog(tester);
      store.failure = const StorageFailure('Disk is full.');

      await chooseFile(tester);

      expect(find.text('Disk is full.'), findsOneWidget);
      expect(find.textContaining('Imported'), findsNothing);
    });
  });
}
