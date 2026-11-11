import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:re_editor/re_editor.dart';
import 'package:test_point/core/ui/theme/app_theme.dart';
import 'package:test_point/core/ui/widgets/code_view.dart';

/// A pretty-printed JSON array of roughly [megabytes] MB.
String _bigJson(int megabytes) {
  final item = const JsonEncoder.withIndent('  ').convert({
    'id': 123456,
    'name': 'Example user with a long enough name',
    'email': 'user@example.com',
    'tags': ['alpha', 'beta', 'gamma'],
    'active': true,
  });
  final count = megabytes * 1024 * 1024 ~/ (item.length + 2) + 1;
  return '[${List.filled(count, item).join(',\n')}]';
}

void main() {
  testWidgets('a 5 MB JSON body opens in the viewer within budget', (
    tester,
  ) async {
    final body = _bigJson(5);
    expect(body.length, greaterThan(5 * 1024 * 1024));

    final watch = Stopwatch()..start();
    final controller = CodeLineEditingController.fromText(body);
    final createMs = watch.elapsedMilliseconds;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: CodeView(
            controller: controller,
            readOnly: true,
            highlightJson: true,
          ),
        ),
      ),
    );
    await tester.pump();
    final totalMs = watch.elapsedMilliseconds;
    // ignore: avoid_print
    print('5 MB JSON: controller $createMs ms, first frame $totalMs ms');

    expect(find.byType(CodeEditor), findsOneWidget);
    expect(totalMs, lessThan(3000));
    controller.dispose();
  });
}
