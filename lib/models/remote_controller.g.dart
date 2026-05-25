// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_controller.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RemoteController _$RemoteControllerFromJson(Map<String, dynamic> json) =>
    _RemoteController(
      documentId: json['documentId'] as String,
      serialNumber: json['serialNumber'] as String?,
      rcType: json['rcType'] as String,
      currentPackageId: json['currentPackageId'] as String?,
      status: json['status'] as String? ?? '正常',
    );

Map<String, dynamic> _$RemoteControllerToJson(_RemoteController instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'serialNumber': instance.serialNumber,
      'rcType': instance.rcType,
      'currentPackageId': instance.currentPackageId,
      'status': instance.status,
    };
