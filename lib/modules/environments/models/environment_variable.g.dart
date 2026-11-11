// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environment_variable.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_EnvironmentVariable _$EnvironmentVariableFromJson(Map<String, dynamic> json) =>
    _EnvironmentVariable(
      key: json['key'] as String? ?? '',
      value: json['value'] as String? ?? '',
      secret: json['secret'] as bool? ?? false,
      enabled: json['enabled'] as bool? ?? true,
    );

Map<String, dynamic> _$EnvironmentVariableToJson(
  _EnvironmentVariable instance,
) => <String, dynamic>{
  'key': instance.key,
  'value': instance.value,
  'secret': instance.secret,
  'enabled': instance.enabled,
};
