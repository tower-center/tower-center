// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drone.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Drone _$DroneFromJson(Map<String, dynamic> json) => _Drone(
  documentId: json['documentId'] as String,
  serialNumber: json['serialNumber'] as String?,
  modelType: json['modelType'] as String,
  currentPackageId: json['currentPackageId'] as String?,
  status: json['status'] as String? ?? '正常',
  insuranceExpiry: json['insuranceExpiry'] == null
      ? null
      : DateTime.parse(json['insuranceExpiry'] as String),
);

Map<String, dynamic> _$DroneToJson(_Drone instance) => <String, dynamic>{
  'documentId': instance.documentId,
  'serialNumber': instance.serialNumber,
  'modelType': instance.modelType,
  'currentPackageId': instance.currentPackageId,
  'status': instance.status,
  'insuranceExpiry': instance.insuranceExpiry?.toIso8601String(),
};
