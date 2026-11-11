import 'package:freezed_annotation/freezed_annotation.dart';

part 'environment_variable.freezed.dart';
part 'environment_variable.g.dart';

/// One row of an environment's variable table. Stored in the
/// `environments.variables` JSON column.
@freezed
abstract class EnvironmentVariable with _$EnvironmentVariable {
  const factory EnvironmentVariable({
    @Default('') String key,
    @Default('') String value,
    @Default(false) bool secret,
    @Default(true) bool enabled,
  }) = _EnvironmentVariable;

  factory EnvironmentVariable.fromJson(Map<String, dynamic> json) =>
      _$EnvironmentVariableFromJson(json);
}
