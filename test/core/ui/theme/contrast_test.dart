import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test_point/core/ui/theme/app_theme.dart';
import 'package:test_point/core/ui/theme/http_colors.dart';

/// WCAG 2.x contrast ratio between two opaque colours.
double contrast(Color a, Color b) {
  final l1 = a.computeLuminance();
  final l2 = b.computeLuminance();
  return (math.max(l1, l2) + 0.05) / (math.min(l1, l2) + 0.05);
}

/// PRD §7: text contrast meets WCAG AA (4.5:1 for normal text) in both themes.
void main() {
  const aa = 4.5;

  for (final entry in {
    'dark': AppTheme.dark,
    'light': AppTheme.light,
  }.entries) {
    group('contrast (${entry.key})', () {
      final theme = entry.value;
      final scheme = theme.colorScheme;
      final http = theme.extension<HttpColors>()!;
      final surfaces = {
        'surface': scheme.surface,
        'surfaceContainer': scheme.surfaceContainer,
        'surfaceContainerHigh': scheme.surfaceContainerHigh,
      };

      for (final surface in surfaces.entries) {
        test('body and muted text on ${surface.key}', () {
          expect(
            contrast(scheme.onSurface, surface.value),
            greaterThanOrEqualTo(aa),
          );
          expect(
            contrast(scheme.onSurfaceVariant, surface.value),
            greaterThanOrEqualTo(aa),
            reason: 'onSurfaceVariant (muted text)',
          );
        });

        test('brand teal text and errors on ${surface.key}', () {
          expect(
            contrast(scheme.primary, surface.value),
            greaterThanOrEqualTo(aa),
            reason: 'primary (active tab / nav label)',
          );
          expect(
            contrast(scheme.error, surface.value),
            greaterThanOrEqualTo(aa),
            reason: 'error text',
          );
        });

        test('HTTP method and status colours on ${surface.key}', () {
          final colours = {
            'GET': http.get,
            'POST': http.post,
            'PUT': http.put,
            'PATCH': http.patch,
            'DELETE': http.delete,
            'other': http.other,
            '2xx': http.status2xx,
            '3xx': http.status3xx,
            '4xx': http.status4xx,
            '5xx': http.status5xx,
          };
          for (final c in colours.entries) {
            expect(
              contrast(c.value, surface.value),
              greaterThanOrEqualTo(aa),
              reason: '${c.key} on ${surface.key}',
            );
          }
        });
      }

      test('filled buttons and containers', () {
        expect(
          contrast(scheme.onPrimary, scheme.primary),
          greaterThanOrEqualTo(aa),
          reason: 'Send button',
        );
        expect(
          contrast(scheme.onPrimaryContainer, scheme.primaryContainer),
          greaterThanOrEqualTo(aa),
          reason: 'avatar / selected chip',
        );
        expect(
          contrast(scheme.onSecondaryContainer, scheme.secondaryContainer),
          greaterThanOrEqualTo(aa),
          reason: 'selected segment / tonal pill',
        );
        expect(
          contrast(scheme.onError, scheme.error),
          greaterThanOrEqualTo(aa),
          reason: 'destructive button',
        );
      });

      test('borders are visible enough (3:1) against surfaces', () {
        // WCAG 1.4.11 non-text contrast, for input outlines.
        expect(
          contrast(
            (theme.inputDecorationTheme.enabledBorder! as OutlineInputBorder)
                .borderSide
                .color,
            scheme.surfaceContainerHigh,
          ),
          greaterThanOrEqualTo(3),
        );
      });
    });
  }
}
