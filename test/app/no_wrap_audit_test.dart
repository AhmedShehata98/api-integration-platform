import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_point/core/ui/theme/app_theme.dart';
import 'package:test_point/modules/auth/auth.dart';

import '../support/fake_backend.dart';
import '../support/pump_app.dart';

/// PRD §7 / design shell standard: labels, chips, tabs and status text stay on
/// one line (ellipsis instead of wrapping). This renders the main screens at
/// the minimum window size and fails on any text that wraps.
///
/// Prose that is meant to wrap (dialog explanations, error messages, empty
/// state hints) is listed in [_proseStartsWith].
const _proseStartsWith = [
  'This request does not use authorization',
  'Your guest workspace will not be carried over',
  'This GitHub account already has',
  'Paste a cURL command',
  'Choose a Postman',
  'curl -X POST',
];

/// Number of lines the paragraph is laid out on (distinct vertical positions
/// of its text boxes).
int _lineCount(RenderParagraph paragraph) {
  final length = paragraph.text.toPlainText().length;
  if (length == 0) return 0;
  final boxes = paragraph.getBoxesForSelection(
    TextSelection(baseOffset: 0, extentOffset: length),
  );
  return {for (final box in boxes) box.top.round()}.length;
}

List<String> _wrappedTexts(WidgetTester tester) {
  final wrapped = <String>[];
  void visit(RenderObject node) {
    if (node is RenderParagraph) {
      final text = node.text.toPlainText();
      final prose = _proseStartsWith.any(text.startsWith);
      if (!prose && _lineCount(node) > 1) {
        wrapped.add(text.replaceAll('\n', ' '));
      }
    }
    node.visitChildren(visit);
  }

  visit(tester.binding.renderViews.first);
  return wrapped;
}

Future<void> _pumpMinimum(
  WidgetTester tester, {
  ThemeData? theme,
  FakeStore? store,
  AuthRepository? auth,
}) async {
  final container = await pumpApp(
    tester,
    store ?? sampleStore(),
    theme: theme,
    auth: auth,
  );
  tester.view.physicalSize = const Size(1024, 640);
  await tester.pumpAndSettle();
  expect(container, isNotNull);
}

Future<void> _openRequest(WidgetTester tester) async {
  await tester.tap(find.text('Users API'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('List users').first);
  await tester.pumpAndSettle();
}

void main() {
  for (final entry in {
    'dark': AppTheme.dark,
    'light': AppTheme.light,
  }.entries) {
    group('no wrapping (${entry.key})', () {
      testWidgets('workspace shell with open request', (tester) async {
        await _pumpMinimum(tester, theme: entry.value);
        await _openRequest(tester);
        expect(_wrappedTexts(tester), isEmpty);
      });

      testWidgets('request tabs: Auth and Body', (tester) async {
        await _pumpMinimum(tester, theme: entry.value);
        await _openRequest(tester);
        for (final tab in ['Auth', 'Body']) {
          await tester.tap(find.widgetWithText(Tab, tab));
          await tester.pumpAndSettle();
          expect(_wrappedTexts(tester), isEmpty, reason: tab);
        }
      });

      testWidgets('environments and settings', (tester) async {
        await _pumpMinimum(tester, theme: entry.value);
        for (final section in ['Environments', 'Settings']) {
          await tester.tap(find.text(section).first);
          await tester.pumpAndSettle();
          expect(_wrappedTexts(tester), isEmpty, reason: section);
        }
      });

      testWidgets('import and account dialogs', (tester) async {
        await _pumpMinimum(tester, theme: entry.value);
        await tester.tap(find.byTooltip('Import'));
        await tester.pumpAndSettle();
        expect(_wrappedTexts(tester), isEmpty, reason: 'import');
        await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
        await tester.pumpAndSettle();

        await tester.tap(find.byType(UserAvatar));
        await tester.pumpAndSettle();
        expect(_wrappedTexts(tester), isEmpty, reason: 'account');
      });
    });
  }
}
