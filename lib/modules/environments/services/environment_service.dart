import 'package:test_point/core/error/failure.dart';
import 'package:test_point/core/error/result.dart';
import 'package:test_point/core/utils/names.dart';
import 'package:test_point/modules/environments/models/environment.dart';
import 'package:test_point/modules/environments/models/environment_variable.dart';
import 'package:test_point/modules/environments/repositories/environment_repository.dart';

/// Environment rules (names, variable keys) on top of the repository.
class EnvironmentService {
  EnvironmentService(this._repository);

  final EnvironmentRepository _repository;

  Future<Result<List<Environment>>> list(String workspaceId) =>
      _repository.list(workspaceId);

  Future<Result<Environment>> create({
    required String workspaceId,
    required String name,
  }) {
    final valid = validateName(name, label: 'Environment name');
    if (valid.failure != null) {
      return Future.value(Result.failure(valid.failure!));
    }
    return _repository.create(workspaceId: workspaceId, name: valid.name!);
  }

  Future<Result<Environment>> rename(String id, String name) {
    final valid = validateName(name, label: 'Environment name');
    if (valid.failure != null) {
      return Future.value(Result.failure(valid.failure!));
    }
    return _repository.rename(id, valid.name!);
  }

  /// Blank rows are dropped; keys must not contain whitespace or braces so
  /// they can be written as `{{key}}`.
  Future<Result<Environment>> saveVariables(
    String id,
    List<EnvironmentVariable> variables,
  ) {
    final cleaned = [
      for (final v in variables)
        if (v.key.trim().isNotEmpty || v.value.isNotEmpty)
          v.copyWith(key: v.key.trim()),
    ];
    for (final v in cleaned) {
      if (v.key.isEmpty || RegExp(r'[\s{}]').hasMatch(v.key)) {
        return Future.value(
          Result.failure(
            ValidationFailure(
              v.key.isEmpty
                  ? 'Every variable needs a name.'
                  : 'Variable "${v.key}" must not contain spaces or braces.',
            ),
          ),
        );
      }
    }
    return _repository.saveVariables(id, cleaned);
  }

  Future<Result<void>> delete(String id) => _repository.delete(id);
}
