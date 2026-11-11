import 'package:test_point/core/error/result.dart';
import 'package:test_point/modules/workspaces/models/workspace.dart';

abstract interface class WorkspaceRepository {
  /// The user's default workspace (the oldest one they can access).
  Future<Result<Workspace>> loadDefault();
}
