import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/environments/models/environment.dart';
import 'package:test_point/modules/environments/models/environment_variable.dart';

abstract interface class EnvironmentRepository {
  Future<Result<List<Environment>>> list(String workspaceId);

  Future<Result<Environment>> create({
    required String workspaceId,
    required String name,
  });

  Future<Result<Environment>> rename(String id, String name);

  Future<Result<Environment>> saveVariables(
    String id,
    List<EnvironmentVariable> variables,
  );

  Future<Result<void>> delete(String id);
}
