import 'package:flutter_test/flutter_test.dart';
import 'package:test_point/core/ui/theme/app_theme.dart';
import 'package:test_point/core/ui/theme/http_colors.dart';

void main() {
  group('HttpColors', () {
    test('maps methods case-insensitively with a fallback', () {
      const c = HttpColors.dark;

      expect(c.methodColor('get'), c.get);
      expect(c.methodColor('DELETE'), c.delete);
      expect(c.methodColor('OPTIONS'), c.other);
    });

    test('maps status classes', () {
      const c = HttpColors.dark;

      expect(c.statusColor(204), c.status2xx);
      expect(c.statusColor(302), c.status3xx);
      expect(c.statusColor(404), c.status4xx);
      expect(c.statusColor(503), c.status5xx);
      expect(c.statusColor(100), c.other);
    });
  });

  group('AppTheme', () {
    test('both themes carry the HttpColors extension', () {
      expect(AppTheme.dark.extension<HttpColors>(), HttpColors.dark);
      expect(AppTheme.light.extension<HttpColors>(), HttpColors.light);
    });
  });
}
