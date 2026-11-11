import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_point/app/shell/sidebar/sidebar.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/ui/theme/app_theme.dart';
import 'package:test_point/core/ui/widgets/method_pill.dart';
import 'package:test_point/modules/requests/requests.dart';

import '../../../support/fake_backend.dart';
import '../../../support/pump_app.dart';

final _filterField = find.byWidgetPredicate(
  (w) => w is TextField && w.decoration?.hintText == 'Filter requests',
);
final _dialog = find.byType(AlertDialog);

/// [text] inside the sidebar (an open tab can show the same name).
Finder _inSidebar(String text) =>
    find.descendant(of: find.byType(ShellSidebar), matching: find.text(text));

Future<void> _enterInDialog(WidgetTester tester, String text) async {
  await tester.enterText(
    find.descendant(of: _dialog, matching: find.byType(TextField)).first,
    text,
  );
}

Future<void> _tapInDialog(WidgetTester tester, String label) async {
  await tester.tap(
    find.descendant(of: _dialog, matching: find.text(label)).last,
  );
  await tester.pumpAndSettle();
}

Future<void> _expandAll(WidgetTester tester) async {
  while (find.byTooltip('Expand').evaluate().isNotEmpty) {
    await tester.tap(find.byTooltip('Expand').first);
    await tester.pumpAndSettle();
  }
}

void main() {
  group('tree', () {
    testWidgets('lists collections collapsed, with the request count', (
      tester,
    ) async {
      await pumpApp(tester, sampleStore());

      expect(find.text('Users API'), findsOneWidget);
      expect(find.text('Billing'), findsOneWidget);
      expect(find.text('List users'), findsNothing);
      expect(find.text('3 requests'), findsOneWidget);
    });

    testWidgets('expanding shows requests with method pills', (tester) async {
      await pumpApp(tester, sampleStore());

      await tester.tap(find.byTooltip('Expand').first);
      await tester.pumpAndSettle();

      expect(find.text('List users'), findsOneWidget);
      expect(find.text('Create user'), findsOneWidget);
      expect(find.text('List invoices'), findsNothing);
      expect(find.widgetWithText(MethodPill, 'GET'), findsOneWidget);
      expect(find.widgetWithText(MethodPill, 'POST'), findsOneWidget);
    });

    testWidgets('light theme renders the tree too', (tester) async {
      await pumpApp(tester, sampleStore(), theme: AppTheme.light);
      await _expandAll(tester);

      expect(find.text('List invoices'), findsOneWidget);
    });

    testWidgets('an empty workspace offers to create a collection', (
      tester,
    ) async {
      final store = FakeStore();
      await pumpApp(tester, store);
      expect(find.text('No collections yet'), findsOneWidget);
      expect(find.text('0 requests'), findsOneWidget);

      await tester.tap(find.text('Create collection'));
      await tester.pumpAndSettle();
      await _enterInDialog(tester, 'First');
      await _tapInDialog(tester, 'Create');

      expect(store.collections.single.name, 'First');
      expect(find.text('First'), findsOneWidget);
      expect(find.text('No collections yet'), findsNothing);
    });

    testWidgets('a load error shows the message and can retry', (tester) async {
      final store = sampleStore()..failure = const NetworkFailure('Offline.');
      await pumpApp(tester, store);
      expect(find.text('Offline.'), findsOneWidget);

      store.failure = null;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('Users API'), findsOneWidget);
    });
  });

  group('filter', () {
    testWidgets('narrows to matching requests and expands their collection', (
      tester,
    ) async {
      await pumpApp(tester, sampleStore());

      await tester.enterText(_filterField, 'invoice');
      await tester.pumpAndSettle();

      expect(find.text('Billing'), findsOneWidget);
      expect(find.text('List invoices'), findsOneWidget);
      expect(find.text('Users API'), findsNothing);
      expect(find.text('List users'), findsNothing);
    });

    testWidgets('says so when nothing matches, and clears', (tester) async {
      await pumpApp(tester, sampleStore());

      await tester.enterText(_filterField, 'zzz');
      await tester.pumpAndSettle();
      expect(find.text('No matches'), findsOneWidget);

      await tester.enterText(_filterField, '');
      await tester.pumpAndSettle();
      expect(find.text('Users API'), findsOneWidget);
    });

    testWidgets('Ctrl+K focuses the filter field', (tester) async {
      await pumpApp(tester, sampleStore());
      expect(
        tester.widget<TextField>(_filterField).focusNode!.hasFocus,
        isFalse,
      );

      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();

      expect(
        tester.widget<TextField>(_filterField).focusNode!.hasFocus,
        isTrue,
      );
    });
  });

  group('opening requests', () {
    testWidgets('clicking a request opens it in a tab', (tester) async {
      final container = await pumpApp(tester, sampleStore());
      await _expandAll(tester);

      await tester.tap(find.text('Create user'));
      await tester.pumpAndSettle();

      final tab = container.read(requestTabsProvider).active!;
      expect(tab.savedRequestId, 'r2');
      expect(tab.isDirty, isFalse);
      expect(find.text('Enter request URL'), findsOneWidget);
      expect(
        tester
            .widget<TextField>(
              find.byWidgetPredicate(
                (w) =>
                    w is TextField &&
                    w.decoration?.hintText == 'Enter request URL',
              ),
            )
            .controller!
            .text,
        'https://a.test/users',
      );
    });

    testWidgets('opening the same request again reuses its tab', (
      tester,
    ) async {
      final container = await pumpApp(tester, sampleStore());
      await _expandAll(tester);

      await tester.tap(_inSidebar('Create user'));
      await tester.pumpAndSettle();
      await tester.tap(_inSidebar('List users'));
      await tester.pumpAndSettle();
      await tester.tap(_inSidebar('Create user'));
      await tester.pumpAndSettle();

      expect(container.read(requestTabsProvider).tabs, hasLength(2));
      expect(container.read(requestTabsProvider).active!.savedRequestId, 'r2');
    });

    testWidgets('the open request is highlighted in the tree', (tester) async {
      await pumpApp(tester, sampleStore());
      await _expandAll(tester);
      await tester.tap(find.text('List users'));
      await tester.pumpAndSettle();

      final row = find.ancestor(
        of: find.text('List users'),
        matching: find.byType(Container),
      );
      final colored = tester
          .widgetList<Container>(row)
          .where((c) => c.color != null);
      expect(colored, isNotEmpty);
    });
  });

  group('collection context menu', () {
    testWidgets('right-click opens the menu', (tester) async {
      await pumpApp(tester, sampleStore());

      await tester.tap(find.text('Users API'), buttons: kSecondaryMouseButton);
      await tester.pumpAndSettle();

      for (final item in ['New request', 'Rename', 'Duplicate', 'Delete']) {
        expect(find.text(item), findsWidgets);
      }
    });

    testWidgets('rename', (tester) async {
      final store = sampleStore();
      await pumpApp(tester, store);

      await tester.tap(find.byTooltip('More').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();
      await _enterInDialog(tester, 'People');
      await _tapInDialog(tester, 'Rename');

      expect(store.collections.first.name, 'People');
      expect(find.text('People'), findsOneWidget);
      expect(find.text('Users API'), findsNothing);
    });

    testWidgets('rename to a blank name shows the validation message', (
      tester,
    ) async {
      final store = sampleStore();
      await pumpApp(tester, store);

      await tester.tap(find.byTooltip('More').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();
      await _enterInDialog(tester, '  ');
      await _tapInDialog(tester, 'Rename');

      expect(find.text('Collection name is required.'), findsOneWidget);
      expect(store.collections.first.name, 'Users API');
    });

    testWidgets('duplicate copies the collection and its requests', (
      tester,
    ) async {
      final store = sampleStore();
      await pumpApp(tester, store);

      await tester.tap(find.byTooltip('More').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Duplicate'));
      await tester.pumpAndSettle();

      expect(find.text('Users API copy'), findsOneWidget);
      expect(store.requests, hasLength(5));
      expect(find.text('5 requests'), findsOneWidget);
    });

    testWidgets('delete asks first, and counts the requests', (tester) async {
      final store = sampleStore();
      await pumpApp(tester, store);

      await tester.tap(find.byTooltip('More').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(
        find.text('This collection and its 2 requests will be deleted.'),
        findsOneWidget,
      );

      await _tapInDialog(tester, 'Cancel');
      expect(store.collections, hasLength(2));

      await tester.tap(find.byTooltip('More').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await _tapInDialog(tester, 'Delete');

      expect(store.collections.single.name, 'Billing');
      expect(store.requests.single.id, 'r3');
      expect(find.text('Users API'), findsNothing);
      expect(find.text('1 request'), findsOneWidget);
    });

    testWidgets('New request opens a tab aimed at that collection', (
      tester,
    ) async {
      final container = await pumpApp(tester, sampleStore());

      await tester.tap(find.byTooltip('More').at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(MenuItemButton, 'New request'));
      await tester.pumpAndSettle();

      final tab = container.read(requestTabsProvider).active!;
      expect(tab.collectionId, 'c2');
      expect(tab.isSaved, isFalse);
    });
  });

  group('request context menu', () {
    Future<void> openMenuFor(WidgetTester tester, String requestName) async {
      // The name can also be on an open tab, so look inside the sidebar only.
      final row = find.ancestor(
        of: find.descendant(
          of: find.byType(ShellSidebar),
          matching: find.text(requestName),
        ),
        matching: find.byType(InkWell),
      );
      await tester.tap(
        find.descendant(of: row.first, matching: find.byTooltip('More')),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('rename updates the tree and an open tab', (tester) async {
      final container = await pumpApp(tester, sampleStore());
      await _expandAll(tester);
      await tester.tap(find.text('List users'));
      await tester.pumpAndSettle();

      await openMenuFor(tester, 'List users');
      await tester.tap(find.text('Rename'));
      await tester.pumpAndSettle();
      await _enterInDialog(tester, 'All users');
      await _tapInDialog(tester, 'Rename');

      expect(find.text('All users'), findsNWidgets(2)); // tree row + tab
      expect(container.read(requestTabsProvider).active!.name, 'All users');
    });

    testWidgets('duplicate adds "copy" next to it', (tester) async {
      final store = sampleStore();
      await pumpApp(tester, store);
      await _expandAll(tester);

      await openMenuFor(tester, 'List users');
      await tester.tap(find.text('Duplicate'));
      await tester.pumpAndSettle();

      expect(find.text('List users copy'), findsOneWidget);
      expect(store.requests, hasLength(4));
    });

    testWidgets('delete asks first and keeps its tab open as unsaved', (
      tester,
    ) async {
      final store = sampleStore();
      final container = await pumpApp(tester, store);
      await _expandAll(tester);
      await tester.tap(find.text('List invoices'));
      await tester.pumpAndSettle();

      await openMenuFor(tester, 'List invoices');
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await _tapInDialog(tester, 'Delete');

      expect(store.requests.map((r) => r.id), isNot(contains('r3')));
      final tab = container.read(requestTabsProvider).active!;
      expect(tab.isSaved, isFalse);
      expect(tab.draft.url, 'https://a.test/invoices');
    });
  });

  testWidgets('"+ New" menu creates a request tab or a collection', (
    tester,
  ) async {
    final store = sampleStore();
    final container = await pumpApp(tester, store);

    await tester.tap(find.text('New'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New collection'));
    await tester.pumpAndSettle();
    await _enterInDialog(tester, 'Reports');
    await _tapInDialog(tester, 'Create');
    expect(store.collections.last.name, 'Reports');
    expect(store.collections.last.position, 2);

    await tester.tap(find.text('New'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(MenuItemButton, 'New request'));
    await tester.pumpAndSettle();
    expect(container.read(requestTabsProvider).tabs, hasLength(1));
  });
}
