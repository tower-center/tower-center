// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drone_package.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DronePackage _$DronePackageFromJson(Map<String, dynamic> json) =>
    _DronePackage(
      documentId: json['documentId'] as String,
      tacticalName: json['tacticalName'] as String,
      modelType: json['modelType'] as String,
      currentKeeper: json['currentKeeper'] as String,
      accessories:
          (json['accessories'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, (e as num).toInt()),
          ) ??
          const {},
      currentDroneSn: json['currentDroneSn'] as String?,
      currentRcSn: json['currentRcSn'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$DronePackageToJson(_DronePackage instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'tacticalName': instance.tacticalName,
      'modelType': instance.modelType,
      'currentKeeper': instance.currentKeeper,
      'accessories': instance.accessories,
      'currentDroneSn': instance.currentDroneSn,
      'currentRcSn': instance.currentRcSn,
      'createdAt': instance.createdAt.toIso8601String(),
    };
