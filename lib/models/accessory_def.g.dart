// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accessory_def.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AccessoryDef _$AccessoryDefFromJson(Map<String, dynamic> json) =>
    _AccessoryDef(
      documentId: json['documentId'] as String,
      name: json['name'] as String,
      aircraftModelName: json['aircraftModelName'] as String,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AccessoryDefToJson(_AccessoryDef instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'name': instance.name,
      'aircraftModelName': instance.aircraftModelName,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt.toIso8601String(),
    };
