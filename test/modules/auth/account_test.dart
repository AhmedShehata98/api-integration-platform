import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/modules/auth/auth.dart';
import 'package:test_point/modules/requests/requests.dart';

import '../../support/fake_backend.dart';
import '../../support/pump_app.dart';

final _dialog = find.byType(AlertDialog);
final _github = find.widgetWithText(OutlinedButton, 'Continue with GitHub');

Future<void> _openAccount(WidgetTester tester) async {
  await tester.tap(find.byType(UserAvatar));
  await tester.pumpAndSettle();
}

Future<void> _tapText(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// The "browser" returns to the app.
Future<void> _returnFromBrowser(
  WidgetTester tester,
  FakeAuthRepository auth,
) async {
  auth.finishBrowser();
  await tester.pumpAndSettle();
}

void main() {
  group('Guest dialog', () {
    testWidgets('shows one GitHub action and no email or password', (
      tester,
    ) async {
      await pumpApp(tester, FakeStore());
      expect(find.byIcon(Icons.person_outline), findsOneWidget);

      await _openAccount(tester);
      expect(find.text('You are using Test Point as a guest.'), findsOneWidget);
      expect(_github, findsOneWidget);
      expect(
        find.text('Signing in with GitHub keeps your guest workspace.'),
        findsOneWidget,
      );
      expect(
        find.descendant(of: _dialog, matching: find.byType(TextField)),
        findsNothing,
      );
      expect(find.byType(TabBar), findsNothing);
    });

    testWidgets('linking keeps the same user and shows the account', (
      tester,
    ) async {
      final auth = FakeAuthRepository();
      final container = await pumpApp(tester, FakeStore(), auth: auth);

      await _openAccount(tester);
      await _tapText(tester, _github);

      expect(_dialog, findsNothing);
      expect(auth.calls, ['link']);
      final user = container.read(sessionProvider).value!;
      expect(user.id, guestUser.id);
      expect(user.isAnonymous, isFalse);
      expect(find.text('R'), findsOneWidget); // avatar initial of "rex"
    });

    testWidgets('waits for the browser and Cancel returns to the start', (
      tester,
    ) async {
      final auth = FakeAuthRepository()..holdBrowser = true;
      final container = await pumpApp(tester, FakeStore(), auth: auth);
      await _openAccount(tester);

      await tester.tap(_github);
      await tester.pump();
      expect(find.text('Waiting for GitHub'), findsOneWidget);
      expect(find.text('Finish signing in in your browser.'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await _tapText(tester, find.widgetWithText(TextButton, 'Cancel'));
      expect(auth.calls, contains('cancel'));
      expect(_github, findsOneWidget);
      expect(find.textContaining('cancelled'), findsNothing); // no error shown
      expect(container.read(sessionProvider).value!.isAnonymous, isTrue);
    });

    testWidgets('closes when the browser returns', (tester) async {
      final auth = FakeAuthRepository()..holdBrowser = true;
      final container = await pumpApp(tester, FakeStore(), auth: auth);
      await _openAccount(tester);
      await tester.tap(_github);
      await tester.pump();

      await _returnFromBrowser(tester, auth);

      expect(_dialog, findsNothing);
      expect(container.read(sessionProvider).value!.isAnonymous, isFalse);
    });

    testWidgets('a failure is explained and GitHub can be tried again', (
      tester,
    ) async {
      final auth = FakeAuthRepository()
        ..nextFailure = const AuthFailure(
          'GitHub sign-in is not available right now.',
        );
      await pumpApp(tester, FakeStore(), auth: auth);
      await _openAccount(tester);

      await _tapText(tester, _github);
      expect(
        find.text('GitHub sign-in is not available right now.'),
        findsOneWidget,
      );
      expect(_dialog, findsOneWidget);

      await _tapText(tester, _github);
      expect(_dialog, findsNothing);
    });

    testWidgets('the close button cancels a pending sign-in', (tester) async {
      final auth = FakeAuthRepository()..holdBrowser = true;
      await pumpApp(tester, FakeStore(), auth: auth);
      await _openAccount(tester);
      await tester.tap(_github);
      await tester.pump();

      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();

      expect(_dialog, findsNothing);
      expect(auth.calls, contains('cancel'));
    });
  });

  group('GitHub account already registered', () {
    testWidgets('with no guest data it signs in without a warning', (
      tester,
    ) async {
      final auth = FakeAuthRepository()..githubAccountExists = true;
      final container = await pumpApp(tester, FakeStore(), auth: auth);
      await _openAccount(tester);

      await _tapText(tester, _github);

      expect(find.text('Sign in to an existing account?'), findsNothing);
      expect(auth.calls, ['link', 'signIn']);
      expect(container.read(sessionProvider).value!.id, 'acct-github');
      expect(_dialog, findsNothing);
    });

    testWidgets('guest data triggers a warning; Cancel keeps the guest', (
      tester,
    ) async {
      final auth = FakeAuthRepository()..githubAccountExists = true;
      final container = await pumpApp(tester, sampleStore(), auth: auth);
      await _openAccount(tester);

      await _tapText(tester, _github);
      expect(find.text('Sign in to an existing account?'), findsOneWidget);
      expect(find.textContaining('will not be carried over'), findsOneWidget);

      await _tapText(tester, find.widgetWithText(TextButton, 'Cancel').last);
      expect(auth.calls, ['link']); // never signed in
      expect(container.read(sessionProvider).value!.isAnonymous, isTrue);
      expect(_github, findsOneWidget);
    });

    testWidgets('guest data: Sign in anyway switches to the account', (
      tester,
    ) async {
      final auth = FakeAuthRepository()..githubAccountExists = true;
      final container = await pumpApp(tester, sampleStore(), auth: auth);
      await _openAccount(tester);
      await _tapText(tester, _github);

      await _tapText(
        tester,
        find.widgetWithText(FilledButton, 'Sign in anyway'),
      );

      expect(auth.calls, ['link', 'signIn']);
      expect(container.read(sessionProvider).value!.id, 'acct-github');
      expect(_dialog, findsNothing);
    });
  });

  group('Already have an account', () {
    final existing = find.widgetWithText(
      TextButton,
      'Already have an account? Sign in with GitHub',
    );

    testWidgets('signs in directly, with no guest data and no warning', (
      tester,
    ) async {
      final auth = FakeAuthRepository();
      final container = await pumpApp(tester, FakeStore(), auth: auth);
      await _openAccount(tester);

      await _tapText(tester, existing);

      expect(auth.calls, ['signIn']); // never tried to link
      expect(container.read(sessionProvider).value!.id, 'acct-github');
      expect(_dialog, findsNothing);
    });

    testWidgets('warns first when the guest has data; Cancel keeps the guest', (
      tester,
    ) async {
      final auth = FakeAuthRepository();
      final container = await pumpApp(tester, sampleStore(), auth: auth);
      await _openAccount(tester);

      await _tapText(tester, existing);
      expect(find.text('Sign in to an existing account?'), findsOneWidget);
      await _tapText(tester, find.widgetWithText(TextButton, 'Cancel').last);

      expect(auth.calls, isEmpty);
      expect(container.read(sessionProvider).value!.isAnonymous, isTrue);
      expect(_github, findsOneWidget);

      await _tapText(tester, existing);
      await _tapText(
        tester,
        find.widgetWithText(FilledButton, 'Sign in anyway'),
      );
      expect(auth.calls, ['signIn']);
      expect(container.read(sessionProvider).value!.id, 'acct-github');
    });
  });

  group('Signed in', () {
    const account = AuthUser(
      id: 'acct-1',
      isAnonymous: false,
      email: 'rex@test.dev',
      name: 'rex',
    );

    testWidgets('shows the GitHub name and signs out to a fresh guest', (
      tester,
    ) async {
      final auth = FakeAuthRepository(user: account);
      final container = await pumpApp(tester, FakeStore(), auth: auth);

      await _openAccount(tester);
      expect(find.text('rex'), findsOneWidget);
      expect(_github, findsNothing);
      await _tapText(tester, find.widgetWithText(FilledButton, 'Sign out'));

      expect(_dialog, findsNothing);
      expect(auth.calls, containsAllInOrder(['signOut', 'guest']));
      final user = container.read(sessionProvider).value!;
      expect(user.isAnonymous, isTrue);
      expect(user.id, isNot(account.id));
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('a failed sign-out is reported and the user stays signed in', (
      tester,
    ) async {
      final auth = FakeAuthRepository(user: account)
        ..nextFailure = const NetworkFailure('Cannot reach the server.');
      final container = await pumpApp(tester, FakeStore(), auth: auth);

      await _openAccount(tester);
      await _tapText(tester, find.widgetWithText(FilledButton, 'Sign out'));

      expect(find.text('Cannot reach the server.'), findsOneWidget);
      expect(container.read(sessionProvider).value!.name, 'rex');
    });
  });

  group('AuthUser', () {
    test('label prefers the GitHub name, then the email', () {
      const both = AuthUser(
        id: '1',
        isAnonymous: false,
        email: 'a@b.co',
        name: 'rex',
      );
      const emailOnly = AuthUser(id: '1', isAnonymous: false, email: 'a@b.co');
      const neither = AuthUser(id: '1', isAnonymous: false);
      expect(both.label, 'rex');
      expect(both.initial, 'R');
      expect(emailOnly.label, 'a@b.co');
      expect(neither.label, isNull);
      expect(neither.initial, '?');
    });
  });

  group('open tabs follow the user', () {
    testWidgets('are kept when a guest links GitHub, cleared on another user', (
      tester,
    ) async {
      final auth = FakeAuthRepository();
      final container = await pumpApp(tester, FakeStore(), auth: auth);
      container.read(requestTabsProvider.notifier).openNew();
      await tester.pumpAndSettle();

      // Linking keeps the same user, so the tab stays.
      await _openAccount(tester);
      await _tapText(tester, _github);
      expect(container.read(requestTabsProvider).tabs, hasLength(1));

      // Sign out, work as a new guest, then sign in to an existing account.
      await _openAccount(tester);
      await _tapText(tester, find.widgetWithText(FilledButton, 'Sign out'));
      container.read(requestTabsProvider.notifier).openNew();
      expect(container.read(requestTabsProvider).tabs, hasLength(1));
      auth.githubAccountExists = true;
      await _openAccount(tester);
      await _tapText(tester, _github);

      expect(container.read(requestTabsProvider).tabs, isEmpty);
    });
  });
}
