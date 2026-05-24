// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drone_operator.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DroneOperator _$DroneOperatorFromJson(Map<String, dynamic> json) =>
    _DroneOperator(
      documentId: json['documentId'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      licenseNumber: json['licenseNumber'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      customFields:
          (json['customFields'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
    );

Map<String, dynamic> _$DroneOperatorToJson(_DroneOperator instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'name': instance.name,
      'phone': instance.phone,
      'licenseNumber': instance.licenseNumber,
      'createdAt': instance.createdAt.toIso8601String(),
      'isActive': instance.isActive,
      'customFields': instance.customFields,
    };
