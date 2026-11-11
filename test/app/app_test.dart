import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_point/app/app.dart';

import '../support/fake_backend.dart';

void main() {
  testWidgets('App builds the workspace shell', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(overrides: fakeBackend(), child: const App()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Test Point'), findsOneWidget);
  });
}
