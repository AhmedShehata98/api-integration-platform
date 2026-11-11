// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Environment _$EnvironmentFromJson(Map<String, dynamic> json) => _Environment(
  id: json['id'] as String,
  workspaceId: json['workspace_id'] as String,
  name: json['name'] as String,
  variables:
      (json['variables'] as List<dynamic>?)
          ?.map((e) => EnvironmentVariable.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$EnvironmentToJson(_Environment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'workspace_id': instance.workspaceId,
      'name': instance.name,
      'variables': instance.variables,
    };
