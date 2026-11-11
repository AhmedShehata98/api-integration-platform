import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test_point/app/shell/sidebar/sidebar.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/requests/models/prepared_request.dart';
import 'package:test_point/modules/requests/requests.dart';

import '../../../support/fake_backend.dart';
import '../../../support/pump_app.dart';

class MockHttpRequestRepository extends Mock implements HttpRequestRepository {}

final _urlField = find.byWidgetPredicate(
  (w) => w is TextField && w.decoration?.hintText == 'Enter request URL',
);
final _unsavedDot = find.byKey(const ValueKey('unsaved-dot'));
final _dialog = find.byType(AlertDialog);

Future<void> _newTab(WidgetTester tester) async {
  await tester.tap(find.byTooltip('New request'));
  await tester.pumpAndSettle();
}

Future<void> _type(WidgetTester tester, String url) async {
  await tester.enterText(_urlField, url);
  await tester.pumpAndSettle();
}

Future<void> _tapInDialog(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: _dialog, matching: find.text(label)).last,
  );
  await tester.pumpAndSettle();
}

Future<void> _ctrl(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyEvent(key);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pumpAndSettle();
}

void main() {
  group('tab bar', () {
    testWidgets('"+" opens an untitled tab with the builder', (tester) async {
      await pumpApp(tester, FakeStore());
      expect(find.text('Send a request to see the response.'), findsNothing);

      await _newTab(tester);

      expect(find.text(untitledRequestName), findsOneWidget);
      expect(_urlField, findsOneWidget);
      expect(_unsavedDot, findsNothing);
    });

    testWidgets('Welcome "New request" opens a tab too', (tester) async {
      final container = await pumpApp(tester, FakeStore());

      await tester.tap(find.text('New request'));
      await tester.pumpAndSettle();

      expect(container.read(requestTabsProvider).tabs, hasLength(1));
      expect(_urlField, findsOneWidget);
    });

    testWidgets('editing shows the unsaved dot', (tester) async {
      await pumpApp(tester, FakeStore());
      await _newTab(tester);

      await _type(tester, 'http://a.test');

      expect(_unsavedDot, findsOneWidget);
    });

    testWidgets('closing a clean tab needs no confirmation', (tester) async {
      await pumpApp(tester, FakeStore());
      await _newTab(tester);

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      expect(_dialog, findsNothing);
      expect(find.text('No open requests'), findsOneWidget);
    });

    testWidgets('closing an unsaved tab asks to discard', (tester) async {
      final container = await pumpApp(tester, FakeStore());
      await _newTab(tester);
      await _type(tester, 'http://a.test');

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(find.textContaining('unsaved changes'), findsOneWidget);
      await _tapInDialog(tester, 'Cancel');
      expect(container.read(requestTabsProvider).tabs, hasLength(1));

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      await _tapInDialog(tester, 'Discard');
      expect(container.read(requestTabsProvider).tabs, isEmpty);
      expect(find.text('No open requests'), findsOneWidget);
    });

    testWidgets('each tab keeps its own request and response', (tester) async {
      final http = MockHttpRequestRepository();
      registerFallbackValue(PreparedRequest(method: 'GET', url: Uri()));
      registerFallbackValue(CancelSignal());
      when(() => http.send(any(), any())).thenAnswer(
        (_) async => const Result.success(
          HttpResponseResult(
            statusCode: 201,
            reason: 'Created',
            headers: {},
            body: 'ok',
            duration: Duration(milliseconds: 5),
            sizeBytes: 2,
          ),
        ),
      );
      await pumpApp(
        tester,
        FakeStore(),
        extraOverrides: [httpRequestRepositoryProvider.overrideWithValue(http)],
      );

      await _newTab(tester);
      await _type(tester, 'http://first.test');
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();
      expect(find.text('201 Created'), findsOneWidget);

      await _newTab(tester);
      expect(tester.widget<TextField>(_urlField).controller!.text, '');
      expect(find.text('201 Created'), findsNothing);
      expect(find.text('Send a request to see the response.'), findsOneWidget);

      await tester.tap(find.text(untitledRequestName).first);
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(_urlField).controller!.text,
        'http://first.test',
      );
      expect(find.text('201 Created'), findsOneWidget);
    });
  });

  group('saving', () {
    testWidgets('a new request is saved into a new collection', (tester) async {
      final store = FakeStore();
      final container = await pumpApp(tester, store);
      await _newTab(tester);
      await _type(tester, 'http://a.test/users');

      await tester.tap(find.byTooltip('Save (Ctrl+S)'));
      await tester.pumpAndSettle();
      expect(find.text('Save request'), findsOneWidget);
      // With no collections the only choice is a new one.
      expect(find.text('Collection name'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextField, 'Request name'),
        'List users',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Collection name'),
        'Users API',
      );
      await _tapInDialog(tester, 'Save');

      expect(store.collections.single.name, 'Users API');
      expect(store.requests.single.name, 'List users');
      expect(store.requests.single.draft.url, 'http://a.test/users');
      final tab = container.read(requestTabsProvider).active!;
      expect(tab.isSaved, isTrue);
      expect(tab.name, 'List users');
      expect(_unsavedDot, findsNothing);
      // The sidebar shows the new collection and count.
      expect(find.text('Users API'), findsOneWidget);
      expect(find.text('1 request'), findsOneWidget);
    });

    testWidgets('saves into an existing collection chosen in the dialog', (
      tester,
    ) async {
      final store = sampleStore();
      await pumpApp(tester, store);
      await _newTab(tester);
      await _type(tester, 'http://a.test/new');

      await tester.tap(find.byTooltip('Save (Ctrl+S)'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Billing').last);
      await tester.pumpAndSettle();
      await _tapInDialog(tester, 'Save');

      final saved = store.requests.last;
      expect(saved.collectionId, 'c2');
      expect(saved.name, untitledRequestName);
      expect(store.collections, hasLength(2));
    });

    testWidgets('a tab opened from a collection preselects it', (tester) async {
      final store = sampleStore();
      await pumpApp(tester, store);
      await tester.tap(find.byTooltip('More').at(1)); // Billing
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(MenuItemButton, 'New request'));
      await tester.pumpAndSettle();
      await _type(tester, 'http://a.test/x');

      await tester.tap(find.byTooltip('Save (Ctrl+S)'));
      await tester.pumpAndSettle();
      await _tapInDialog(tester, 'Save');

      expect(store.requests.last.collectionId, 'c2');
    });

    testWidgets('cancelling the dialog saves nothing', (tester) async {
      final store = FakeStore();
      final container = await pumpApp(tester, store);
      await _newTab(tester);
      await _type(tester, 'http://a.test');

      await tester.tap(find.byTooltip('Save (Ctrl+S)'));
      await tester.pumpAndSettle();
      await _tapInDialog(tester, 'Cancel');

      expect(store.requests, isEmpty);
      expect(container.read(requestTabsProvider).active!.isSaved, isFalse);
      expect(_unsavedDot, findsOneWidget);
    });

    testWidgets('invalid names are reported and nothing is stored', (
      tester,
    ) async {
      final store = FakeStore();
      await pumpApp(tester, store);
      await _newTab(tester);
      await _type(tester, 'http://a.test');

      await tester.tap(find.byTooltip('Save (Ctrl+S)'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Request name'),
        ' ',
      );
      await _tapInDialog(tester, 'Save');

      expect(find.text('Collection name is required.'), findsOneWidget);
      expect(store.requests, isEmpty);
    });

    testWidgets('Ctrl+S updates a saved request without asking', (
      tester,
    ) async {
      final store = sampleStore();
      await pumpApp(tester, store);
      await tester.tap(find.byTooltip('Expand').first);
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(ShellSidebar),
          matching: find.text('List users'),
        ),
      );
      await tester.pumpAndSettle();

      await _type(tester, 'https://a.test/v2/users');
      expect(_unsavedDot, findsOneWidget);
      await _ctrl(tester, LogicalKeyboardKey.keyS);

      expect(_dialog, findsNothing);
      expect(
        store.requests.firstWhere((r) => r.id == 'r1').draft.url,
        'https://a.test/v2/users',
      );
      expect(_unsavedDot, findsNothing);
    });

    testWidgets('a failed save keeps the unsaved dot and shows why', (
      tester,
    ) async {
      final store = sampleStore();
      await pumpApp(tester, store);
      await tester.tap(find.byTooltip('Expand').first);
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(ShellSidebar),
          matching: find.text('List users'),
        ),
      );
      await tester.pumpAndSettle();
      await _type(tester, 'https://a.test/v2');
      store.failure = const NetworkFailure('Cannot reach the server.');

      await tester.tap(find.byTooltip('Save (Ctrl+S)'));
      await tester.pumpAndSettle();

      expect(find.text('Cannot reach the server.'), findsOneWidget);
      expect(_unsavedDot, findsOneWidget);
    });
  });
}
