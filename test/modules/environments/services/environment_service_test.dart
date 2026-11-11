import 'package:flutter_test/flutter_test.dart';
import 'package:test_point/core/error/failure.dart';
import 'package:test_point/modules/environments/environments.dart';
import 'package:test_point/modules/environments/services/environment_service.dart';

import '../../../support/fake_backend.dart';

void main() {
  late FakeStore store;
  late EnvironmentService service;

  setUp(() {
    store = FakeStore(
      environments: const [
        Environment(id: 'e1', workspaceId: 'ws-1', name: 'Dev'),
      ],
    );
    service = EnvironmentService(FakeEnvironmentRepository(store));
  });

  test('create trims the name and rejects blanks', () async {
    final ok = await service.create(workspaceId: 'ws-1', name: '  Staging ');
    expect(ok.valueOrNull!.name, 'Staging');

    final blank = await service.create(workspaceId: 'ws-1', name: ' ');
    expect(blank.failureOrNull, isA<ValidationFailure>());
    expect(store.environments, hasLength(2));
  });

  test('saveVariables drops blank rows and trims keys', () async {
    final result = await service.saveVariables('e1', const [
      EnvironmentVariable(key: ' host ', value: 'a.test'),
      EnvironmentVariable(),
    ]);
    expect(result.valueOrNull!.variables, [
      const EnvironmentVariable(key: 'host', value: 'a.test'),
    ]);
  });

  test(
    'saveVariables rejects keys that cannot be written as {{key}}',
    () async {
      for (final key in ['two words', 'a{b', '']) {
        final result = await service.saveVariables('e1', [
          EnvironmentVariable(key: key, value: 'x'),
        ]);
        expect(result.failureOrNull, isA<ValidationFailure>(), reason: key);
      }
      expect(store.environments.single.variables, isEmpty);
    },
  );
}
