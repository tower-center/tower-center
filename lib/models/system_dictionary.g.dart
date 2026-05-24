// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'system_dictionary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SystemDictionary _$SystemDictionaryFromJson(Map<String, dynamic> json) =>
    _SystemDictionary(
      documentId: json['documentId'] as String,
      category: json['category'] as String,
      label: json['label'] as String,
      value: json['value'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$SystemDictionaryToJson(_SystemDictionary instance) =>
    <String, dynamic>{
      'documentId': instance.documentId,
      'category': instance.category,
      'label': instance.label,
      'value': instance.value,
      'createdAt': instance.createdAt.toIso8601String(),
      'sortOrder': instance.sortOrder,
      'isActive': instance.isActive,
    };
