// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_log.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ActionLog _$ActionLogFromJson(Map<String, dynamic> json) => _ActionLog(
  documentId: json['documentId'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  eventType: json['eventType'] as String,
  packageId: json['packageId'] as String?,
  droneSn: json['droneSn'] as String?,
  rcSn: json['rcSn'] as String?,
  batterySn: json['batterySn'] as String?,
  description: json['description'] as String,
  cost: (json['cost'] as num?)?.toDouble() ?? 0.0,
  aiTags:
      (json['aiTags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$ActionLogToJson(_ActionLog instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'timestamp': instance.timestamp.toIso8601String(),
      'eventType': instance.eventType,
      'packageId': instance.packageId,
      'droneSn': instance.droneSn,
      'rcSn': instance.rcSn,
      'batterySn': instance.batterySn,
      'description': instance.description,
      'cost': instance.cost,
      'aiTags': instance.aiTags,
    };
