// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drone.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Drone _$DroneFromJson(Map<String, dynamic> json) => _Drone(
  documentId: json['documentId'] as String,
  modelType: json['modelType'] as String,
  currentName: json['currentName'] as String,
  currentKeeper: json['currentKeeper'] as String,
  insuranceExpiry: json['insuranceExpiry'] == null
      ? null
      : DateTime.parse(json['insuranceExpiry'] as String),
);

Map<String, dynamic> _$DroneToJson(_Drone instance) => <String, dynamic>{
  'documentId': instance.documentId,
  'modelType': instance.modelType,
  'currentName': instance.currentName,
  'currentKeeper': instance.currentKeeper,
  'insuranceExpiry': instance.insuranceExpiry?.toIso8601String(),
};
