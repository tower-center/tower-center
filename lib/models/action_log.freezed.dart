// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'action_log.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ActionLog {

/// 事件 UUID (作為 Document ID)
 String get documentId;/// 發生時間
 DateTime get timestamp;/// 事件類型 (例如：crash, repair, battery_transfer, health_check)
 String get eventType;/// 關聯機身序號
 String? get droneSn;/// 關聯遙控器序號
 String? get rcSn;/// 關聯電池序號
 String? get batterySn;/// 事件詳述
 String get description;/// 維修花費或相關成本
 double get cost;/// AI 分析標籤
 List<String> get aiTags;
/// Create a copy of ActionLog
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActionLogCopyWith<ActionLog> get copyWith => _$ActionLogCopyWithImpl<ActionLog>(this as ActionLog, _$identity);

  /// Serializes this ActionLog to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ActionLog&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.droneSn, droneSn) || other.droneSn == droneSn)&&(identical(other.rcSn, rcSn) || other.rcSn == rcSn)&&(identical(other.batterySn, batterySn) || other.batterySn == batterySn)&&(identical(other.description, description) || other.description == description)&&(identical(other.cost, cost) || other.cost == cost)&&const DeepCollectionEquality().equals(other.aiTags, aiTags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentId,timestamp,eventType,droneSn,rcSn,batterySn,description,cost,const DeepCollectionEquality().hash(aiTags));

@override
String toString() {
  return 'ActionLog(documentId: $documentId, timestamp: $timestamp, eventType: $eventType, droneSn: $droneSn, rcSn: $rcSn, batterySn: $batterySn, description: $description, cost: $cost, aiTags: $aiTags)';
}


}

/// @nodoc
abstract mixin class $ActionLogCopyWith<$Res>  {
  factory $ActionLogCopyWith(ActionLog value, $Res Function(ActionLog) _then) = _$ActionLogCopyWithImpl;
@useResult
$Res call({
 String documentId, DateTime timestamp, String eventType, String? droneSn, String? rcSn, String? batterySn, String description, double cost, List<String> aiTags
});




}
/// @nodoc
class _$ActionLogCopyWithImpl<$Res>
    implements $ActionLogCopyWith<$Res> {
  _$ActionLogCopyWithImpl(this._self, this._then);

  final ActionLog _self;
  final $Res Function(ActionLog) _then;

/// Create a copy of ActionLog
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? documentId = null,Object? timestamp = null,Object? eventType = null,Object? droneSn = freezed,Object? rcSn = freezed,Object? batterySn = freezed,Object? description = null,Object? cost = null,Object? aiTags = null,}) {
  return _then(_self.copyWith(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,droneSn: freezed == droneSn ? _self.droneSn : droneSn // ignore: cast_nullable_to_non_nullable
as String?,rcSn: freezed == rcSn ? _self.rcSn : rcSn // ignore: cast_nullable_to_non_nullable
as String?,batterySn: freezed == batterySn ? _self.batterySn : batterySn // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as double,aiTags: null == aiTags ? _self.aiTags : aiTags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ActionLog].
extension ActionLogPatterns on ActionLog {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ActionLog value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ActionLog() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ActionLog value)  $default,){
final _that = this;
switch (_that) {
case _ActionLog():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ActionLog value)?  $default,){
final _that = this;
switch (_that) {
case _ActionLog() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String documentId,  DateTime timestamp,  String eventType,  String? droneSn,  String? rcSn,  String? batterySn,  String description,  double cost,  List<String> aiTags)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ActionLog() when $default != null:
return $default(_that.documentId,_that.timestamp,_that.eventType,_that.droneSn,_that.rcSn,_that.batterySn,_that.description,_that.cost,_that.aiTags);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String documentId,  DateTime timestamp,  String eventType,  String? droneSn,  String? rcSn,  String? batterySn,  String description,  double cost,  List<String> aiTags)  $default,) {final _that = this;
switch (_that) {
case _ActionLog():
return $default(_that.documentId,_that.timestamp,_that.eventType,_that.droneSn,_that.rcSn,_that.batterySn,_that.description,_that.cost,_that.aiTags);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String documentId,  DateTime timestamp,  String eventType,  String? droneSn,  String? rcSn,  String? batterySn,  String description,  double cost,  List<String> aiTags)?  $default,) {final _that = this;
switch (_that) {
case _ActionLog() when $default != null:
return $default(_that.documentId,_that.timestamp,_that.eventType,_that.droneSn,_that.rcSn,_that.batterySn,_that.description,_that.cost,_that.aiTags);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ActionLog implements ActionLog {
  const _ActionLog({required this.documentId, required this.timestamp, required this.eventType, this.droneSn, this.rcSn, this.batterySn, required this.description, this.cost = 0.0, final  List<String> aiTags = const []}): _aiTags = aiTags;
  factory _ActionLog.fromJson(Map<String, dynamic> json) => _$ActionLogFromJson(json);

/// 事件 UUID (作為 Document ID)
@override final  String documentId;
/// 發生時間
@override final  DateTime timestamp;
/// 事件類型 (例如：crash, repair, battery_transfer, health_check)
@override final  String eventType;
/// 關聯機身序號
@override final  String? droneSn;
/// 關聯遙控器序號
@override final  String? rcSn;
/// 關聯電池序號
@override final  String? batterySn;
/// 事件詳述
@override final  String description;
/// 維修花費或相關成本
@override@JsonKey() final  double cost;
/// AI 分析標籤
 final  List<String> _aiTags;
/// AI 分析標籤
@override@JsonKey() List<String> get aiTags {
  if (_aiTags is EqualUnmodifiableListView) return _aiTags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_aiTags);
}


/// Create a copy of ActionLog
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActionLogCopyWith<_ActionLog> get copyWith => __$ActionLogCopyWithImpl<_ActionLog>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActionLogToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ActionLog&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.eventType, eventType) || other.eventType == eventType)&&(identical(other.droneSn, droneSn) || other.droneSn == droneSn)&&(identical(other.rcSn, rcSn) || other.rcSn == rcSn)&&(identical(other.batterySn, batterySn) || other.batterySn == batterySn)&&(identical(other.description, description) || other.description == description)&&(identical(other.cost, cost) || other.cost == cost)&&const DeepCollectionEquality().equals(other._aiTags, _aiTags));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentId,timestamp,eventType,droneSn,rcSn,batterySn,description,cost,const DeepCollectionEquality().hash(_aiTags));

@override
String toString() {
  return 'ActionLog(documentId: $documentId, timestamp: $timestamp, eventType: $eventType, droneSn: $droneSn, rcSn: $rcSn, batterySn: $batterySn, description: $description, cost: $cost, aiTags: $aiTags)';
}


}

/// @nodoc
abstract mixin class _$ActionLogCopyWith<$Res> implements $ActionLogCopyWith<$Res> {
  factory _$ActionLogCopyWith(_ActionLog value, $Res Function(_ActionLog) _then) = __$ActionLogCopyWithImpl;
@override @useResult
$Res call({
 String documentId, DateTime timestamp, String eventType, String? droneSn, String? rcSn, String? batterySn, String description, double cost, List<String> aiTags
});




}
/// @nodoc
class __$ActionLogCopyWithImpl<$Res>
    implements _$ActionLogCopyWith<$Res> {
  __$ActionLogCopyWithImpl(this._self, this._then);

  final _ActionLog _self;
  final $Res Function(_ActionLog) _then;

/// Create a copy of ActionLog
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? documentId = null,Object? timestamp = null,Object? eventType = null,Object? droneSn = freezed,Object? rcSn = freezed,Object? batterySn = freezed,Object? description = null,Object? cost = null,Object? aiTags = null,}) {
  return _then(_ActionLog(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,eventType: null == eventType ? _self.eventType : eventType // ignore: cast_nullable_to_non_nullable
as String,droneSn: freezed == droneSn ? _self.droneSn : droneSn // ignore: cast_nullable_to_non_nullable
as String?,rcSn: freezed == rcSn ? _self.rcSn : rcSn // ignore: cast_nullable_to_non_nullable
as String?,batterySn: freezed == batterySn ? _self.batterySn : batterySn // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,cost: null == cost ? _self.cost : cost // ignore: cast_nullable_to_non_nullable
as double,aiTags: null == aiTags ? _self._aiTags : aiTags // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
