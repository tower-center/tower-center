// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'aircraft_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AircraftModel _$AircraftModelFromJson(Map<String, dynamic> json) =>
    _AircraftModel(
      documentId: json['documentId'] as String,
      name: json['name'] as String,
      manufacturer: json['manufacturer'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      customFields:
          (json['customFields'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$AircraftModelToJson(_AircraftModel instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'name': instance.name,
      'manufacturer': instance.manufacturer,
      'createdAt': instance.createdAt.toIso8601String(),
      'isActive': instance.isActive,
      'customFields': instance.customFields,
    };
