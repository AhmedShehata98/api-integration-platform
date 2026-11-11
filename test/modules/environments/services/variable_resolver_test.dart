import 'package:flutter_test/flutter_test.dart';
import 'package:test_point/modules/environments/environments.dart';

void main() {
  group('VariableResolver', () {
    test('replaces variables, also with spaces inside the braces', () {
      const resolver = VariableResolver({'host': 'a.test', 'id': '7'});
      final result = resolver.resolve('https://{{host}}/u/{{ id }}');
      expect(result.text, 'https://a.test/u/7');
      expect(result.unresolved, isEmpty);
    });

    test('resolves nested variables', () {
      const resolver = VariableResolver({
        'baseUrl': 'https://{{host}}/v1',
        'host': 'a.test',
      });
      expect(resolver.apply('{{baseUrl}}/users'), 'https://a.test/v1/users');
    });

    test('keeps missing variables as written and reports them', () {
      const resolver = VariableResolver({'a': '1'});
      final result = resolver.resolve('{{a}}-{{missing}}-{{missing}}');
      expect(result.text, '1-{{missing}}-{{missing}}');
      expect(result.unresolved, {'missing'});
    });

    test('a cycle does not loop and is reported', () {
      const resolver = VariableResolver({'a': '{{b}}', 'b': '{{a}}'});
      final result = resolver.resolve('{{a}}');
      expect(result.unresolved, isNotEmpty);
      expect(result.text, contains('{{'));
    });

    test('empty resolver leaves everything unresolved', () {
      final result = VariableResolver.empty.resolve('{{x}}');
      expect(result.text, '{{x}}');
      expect(result.unresolved, {'x'});
    });

    test('namesIn lists each name once, in order', () {
      expect(VariableResolver.namesIn('{{b}}/{{a}}/{{b}}'), ['b', 'a']);
    });
  });

  group('Environment.values', () {
    test('skips disabled and unnamed rows; secrets still resolve', () {
      const environment = Environment(
        id: 'e',
        workspaceId: 'w',
        name: 'Dev',
        variables: [
          EnvironmentVariable(key: 'a', value: '1'),
          EnvironmentVariable(key: 'off', value: 'x', enabled: false),
          EnvironmentVariable(key: ' ', value: 'blank'),
          EnvironmentVariable(key: 'token', value: 's3', secret: true),
        ],
      );
      expect(environment.values, {'a': '1', 'token': 's3'});
    });
  });
}
