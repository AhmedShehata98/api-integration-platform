import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:test_point/modules/environments/models/environment_variable.dart';

part 'environment.freezed.dart';
part 'environment.g.dart';

@freezed
abstract class Environment with _$Environment {
  const Environment._();

  const factory Environment({
    required String id,
    required String workspaceId,
    required String name,
    @Default([]) List<EnvironmentVariable> variables,
  }) = _Environment;

  factory Environment.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentFromJson(json);

  /// `key -> value` of the enabled variables. A later row wins over an
  /// earlier one with the same key.
  Map<String, String> get values => {
    for (final v in variables)
      if (v.enabled && v.key.trim().isNotEmpty) v.key.trim(): v.value,
  };
}
