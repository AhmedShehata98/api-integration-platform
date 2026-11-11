import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:test_point/modules/requests/requests.dart';

import '../../support/fake_backend.dart';
import '../../support/pump_app.dart';

final _dialog = find.byType(AlertDialog);

void main() {
  Future<void> openOverview(WidgetTester tester, String collectionName) async {
    await tester.tap(find.text(collectionName));
    await tester.pumpAndSettle();
  }

  testWidgets('clicking a collection opens its overview', (tester) async {
    await pumpApp(tester, sampleStore());

    await openOverview(tester, 'Users API');

    // Headline, plus the sidebar row.
    expect(find.text('Users API'), findsNWidgets(2));
    expect(find.text('2 requests'), findsOneWidget);
    // Each request is listed in the overview and in the expanded sidebar.
    expect(find.text('List users'), findsNWidgets(2));
    expect(find.text('Create user'), findsNWidgets(2));
    expect(find.text('https://a.test/users'), findsNWidgets(2));
    expect(find.text('List invoices'), findsNothing);
  });

  testWidgets('clicking opens the collection in the sidebar too', (
    tester,
  ) async {
    await pumpApp(tester, sampleStore());

    await openOverview(tester, 'Billing');

    // Selecting a collection expands it.
    expect(find.text('List invoices'), findsNWidgets(2));
  });

  testWidgets('a request in the overview opens in a tab', (tester) async {
    final container = await pumpApp(tester, sampleStore());
    await openOverview(tester, 'Billing');

    await tester.tap(find.text('https://a.test/invoices'));
    await tester.pumpAndSettle();

    expect(container.read(requestTabsProvider).active!.savedRequestId, 'r3');
    expect(find.text('Enter request URL'), findsOneWidget);
  });

  testWidgets('New request starts a tab for this collection', (tester) async {
    final container = await pumpApp(tester, sampleStore());
    await openOverview(tester, 'Billing');

    await tester.tap(find.widgetWithText(FilledButton, 'New request'));
    await tester.pumpAndSettle();

    expect(container.read(requestTabsProvider).active!.collectionId, 'c2');
  });

  testWidgets('rename updates the title', (tester) async {
    final store = sampleStore();
    await pumpApp(tester, store);
    await openOverview(tester, 'Billing');

    await tester.tap(find.byTooltip('Rename'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.descendant(of: _dialog, matching: find.byType(TextField)),
      'Invoices',
    );
    await tester.tap(
      find.descendant(of: _dialog, matching: find.text('Rename')),
    );
    await tester.pumpAndSettle();

    expect(store.collections.last.name, 'Invoices');
    expect(find.text('Invoices'), findsNWidgets(2));
    expect(find.text('Billing'), findsNothing);
  });

  testWidgets('duplicate adds a copy', (tester) async {
    final store = sampleStore();
    await pumpApp(tester, store);
    await openOverview(tester, 'Billing');

    await tester.tap(find.byTooltip('Duplicate'));
    await tester.pumpAndSettle();

    expect(store.collections.map((c) => c.name), contains('Billing copy'));
    expect(find.text('Billing copy'), findsOneWidget);
  });

  testWidgets('delete confirms, then goes back to the welcome screen', (
    tester,
  ) async {
    final store = sampleStore();
    await pumpApp(tester, store);
    await openOverview(tester, 'Billing');

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    expect(
      find.text('This collection and its 1 request will be deleted.'),
      findsOneWidget,
    );
    await tester.tap(
      find.descendant(of: _dialog, matching: find.text('Delete')),
    );
    await tester.pumpAndSettle();

    expect(store.collections.map((c) => c.id), ['c1']);
    expect(find.text('Welcome to Test Point'), findsOneWidget);
    expect(find.text('Billing'), findsNothing);
  });

  testWidgets('cancelling the delete keeps the collection', (tester) async {
    final store = sampleStore();
    await pumpApp(tester, store);
    await openOverview(tester, 'Billing');

    await tester.tap(find.byTooltip('Delete'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(of: _dialog, matching: find.text('Cancel')),
    );
    await tester.pumpAndSettle();

    expect(store.collections, hasLength(2));
    expect(find.text('Welcome to Test Point'), findsNothing);
  });

  testWidgets('an empty collection says so', (tester) async {
    final store = FakeStore(collections: [sampleStore().collections.first]);
    await pumpApp(tester, store);

    await openOverview(tester, 'Users API');

    expect(find.text('0 requests'), findsNWidgets(2)); // overview + footer
    expect(find.text('This collection has no requests yet.'), findsOneWidget);
  });

  testWidgets('an unknown collection id shows a message', (tester) async {
    await pumpApp(tester, sampleStore());

    GoRouter.of(tester.element(find.byType(Scaffold).first))
        .go('/collections/nope');
    await tester.pumpAndSettle();

    expect(find.text('Collection not found.'), findsOneWidget);
  });
}
