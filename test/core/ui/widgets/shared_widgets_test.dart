import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_point/core/ui/theme/app_theme.dart';
import 'package:test_point/core/ui/theme/http_colors.dart';
import 'package:test_point/core/ui/widgets/method_pill.dart';
import 'package:test_point/core/ui/widgets/status_chip.dart';
import 'package:test_point/core/ui/widgets/variable_chip.dart';

Widget _host(ThemeData theme, Widget child) => MaterialApp(
  theme: theme,
  home: Scaffold(body: Center(child: child)),
);

void main() {
  for (final entry in {
    'dark': AppTheme.dark,
    'light': AppTheme.light,
  }.entries) {
    group('${entry.key} theme', () {
      testWidgets('MethodPill has fixed width and method text', (tester) async {
        await tester.pumpWidget(
          _host(entry.value, const MethodPill(method: 'get')),
        );
        expect(find.text('GET'), findsOneWidget);
        expect(tester.getSize(find.byType(MethodPill)).width, MethodPill.width);
      });

      testWidgets('StatusChip shows code and reason', (tester) async {
        await tester.pumpWidget(
          _host(
            entry.value,
            const StatusChip(statusCode: 404, reason: 'Not Found'),
          ),
        );
        expect(find.text('404 Not Found'), findsOneWidget);
      });

      testWidgets('VariableChip is amber when unresolved', (tester) async {
        await tester.pumpWidget(
          _host(
            entry.value,
            const VariableChip(name: 'baseUrl', resolved: false),
          ),
        );
        final text = tester.widget<Text>(find.text('{{baseUrl}}'));
        final amber = entry.value.extension<HttpColors>()!.status4xx;
        expect(text.style!.color, amber);
      });
    });
  }
}
