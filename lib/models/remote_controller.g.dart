// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remote_controller.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RemoteController _$RemoteControllerFromJson(Map<String, dynamic> json) =>
    _RemoteController(
      documentId: json['documentId'] as String,
      rcType: json['rcType'] as String,
      currentPairedDroneSn: json['currentPairedDroneSn'] as String?,
      currentKeeper: json['currentKeeper'] as String,
    );

Map<String, dynamic> _$RemoteControllerToJson(_RemoteController instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'rcType': instance.rcType,
      'currentPairedDroneSn': instance.currentPairedDroneSn,
      'currentKeeper': instance.currentKeeper,
    };
