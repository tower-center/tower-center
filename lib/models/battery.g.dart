// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'battery.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Battery _$BatteryFromJson(Map<String, dynamic> json) => _Battery(
  documentId: json['documentId'] as String,
  serialNumber: json['serialNumber'] as String?,
  tagName: _readTagName(json, 'tagName') as String,
  batteryModel: json['batteryModel'] as String,
  purchaseDate: json['purchaseDate'] == null
      ? null
      : DateTime.parse(json['purchaseDate'] as String),
  cycleCount: (json['cycleCount'] as num).toInt(),
  healthStatus: json['healthStatus'] as String,
  currentDroneSn: json['currentDroneSn'] as String?,
);

Map<String, dynamic> _$BatteryToJson(_Battery instance) => <String, dynamic>{
  'documentId': instance.documentId,
  'serialNumber': instance.serialNumber,
  'tagName': instance.tagName,
  'batteryModel': instance.batteryModel,
  'purchaseDate': instance.purchaseDate?.toIso8601String(),
  'cycleCount': instance.cycleCount,
  'healthStatus': instance.healthStatus,
  'currentDroneSn': instance.currentDroneSn,
};
