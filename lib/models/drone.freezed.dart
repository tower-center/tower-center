// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'drone.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Drone {

/// 機身序號 (作為 Document ID)
 String get documentId;/// 出廠機型
 String get modelType;/// 目前戰術編號
 String get currentName;/// 目前保管人
 String get currentKeeper;/// 保險/註冊到期日
 DateTime? get insuranceExpiry;
/// Create a copy of Drone
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DroneCopyWith<Drone> get copyWith => _$DroneCopyWithImpl<Drone>(this as Drone, _$identity);

  /// Serializes this Drone to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Drone&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.modelType, modelType) || other.modelType == modelType)&&(identical(other.currentName, currentName) || other.currentName == currentName)&&(identical(other.currentKeeper, currentKeeper) || other.currentKeeper == currentKeeper)&&(identical(other.insuranceExpiry, insuranceExpiry) || other.insuranceExpiry == insuranceExpiry));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentId,modelType,currentName,currentKeeper,insuranceExpiry);

@override
String toString() {
  return 'Drone(documentId: $documentId, modelType: $modelType, currentName: $currentName, currentKeeper: $currentKeeper, insuranceExpiry: $insuranceExpiry)';
}


}

/// @nodoc
abstract mixin class $DroneCopyWith<$Res>  {
  factory $DroneCopyWith(Drone value, $Res Function(Drone) _then) = _$DroneCopyWithImpl;
@useResult
$Res call({
 String documentId, String modelType, String currentName, String currentKeeper, DateTime? insuranceExpiry
});




}
/// @nodoc
class _$DroneCopyWithImpl<$Res>
    implements $DroneCopyWith<$Res> {
  _$DroneCopyWithImpl(this._self, this._then);

  final Drone _self;
  final $Res Function(Drone) _then;

/// Create a copy of Drone
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? documentId = null,Object? modelType = null,Object? currentName = null,Object? currentKeeper = null,Object? insuranceExpiry = freezed,}) {
  return _then(_self.copyWith(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,modelType: null == modelType ? _self.modelType : modelType // ignore: cast_nullable_to_non_nullable
as String,currentName: null == currentName ? _self.currentName : currentName // ignore: cast_nullable_to_non_nullable
as String,currentKeeper: null == currentKeeper ? _self.currentKeeper : currentKeeper // ignore: cast_nullable_to_non_nullable
as String,insuranceExpiry: freezed == insuranceExpiry ? _self.insuranceExpiry : insuranceExpiry // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Drone].
extension DronePatterns on Drone {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Drone value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Drone() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Drone value)  $default,){
final _that = this;
switch (_that) {
case _Drone():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Drone value)?  $default,){
final _that = this;
switch (_that) {
case _Drone() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String documentId,  String modelType,  String currentName,  String currentKeeper,  DateTime? insuranceExpiry)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Drone() when $default != null:
return $default(_that.documentId,_that.modelType,_that.currentName,_that.currentKeeper,_that.insuranceExpiry);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String documentId,  String modelType,  String currentName,  String currentKeeper,  DateTime? insuranceExpiry)  $default,) {final _that = this;
switch (_that) {
case _Drone():
return $default(_that.documentId,_that.modelType,_that.currentName,_that.currentKeeper,_that.insuranceExpiry);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String documentId,  String modelType,  String currentName,  String currentKeeper,  DateTime? insuranceExpiry)?  $default,) {final _that = this;
switch (_that) {
case _Drone() when $default != null:
return $default(_that.documentId,_that.modelType,_that.currentName,_that.currentKeeper,_that.insuranceExpiry);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Drone implements Drone {
  const _Drone({required this.documentId, required this.modelType, required this.currentName, required this.currentKeeper, this.insuranceExpiry});
  factory _Drone.fromJson(Map<String, dynamic> json) => _$DroneFromJson(json);

/// 機身序號 (作為 Document ID)
@override final  String documentId;
/// 出廠機型
@override final  String modelType;
/// 目前戰術編號
@override final  String currentName;
/// 目前保管人
@override final  String currentKeeper;
/// 保險/註冊到期日
@override final  DateTime? insuranceExpiry;

/// Create a copy of Drone
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DroneCopyWith<_Drone> get copyWith => __$DroneCopyWithImpl<_Drone>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DroneToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Drone&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.modelType, modelType) || other.modelType == modelType)&&(identical(other.currentName, currentName) || other.currentName == currentName)&&(identical(other.currentKeeper, currentKeeper) || other.currentKeeper == currentKeeper)&&(identical(other.insuranceExpiry, insuranceExpiry) || other.insuranceExpiry == insuranceExpiry));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentId,modelType,currentName,currentKeeper,insuranceExpiry);

@override
String toString() {
  return 'Drone(documentId: $documentId, modelType: $modelType, currentName: $currentName, currentKeeper: $currentKeeper, insuranceExpiry: $insuranceExpiry)';
}


}

/// @nodoc
abstract mixin class _$DroneCopyWith<$Res> implements $DroneCopyWith<$Res> {
  factory _$DroneCopyWith(_Drone value, $Res Function(_Drone) _then) = __$DroneCopyWithImpl;
@override @useResult
$Res call({
 String documentId, String modelType, String currentName, String currentKeeper, DateTime? insuranceExpiry
});




}
/// @nodoc
class __$DroneCopyWithImpl<$Res>
    implements _$DroneCopyWith<$Res> {
  __$DroneCopyWithImpl(this._self, this._then);

  final _Drone _self;
  final $Res Function(_Drone) _then;

/// Create a copy of Drone
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? documentId = null,Object? modelType = null,Object? currentName = null,Object? currentKeeper = null,Object? insuranceExpiry = freezed,}) {
  return _then(_Drone(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,modelType: null == modelType ? _self.modelType : modelType // ignore: cast_nullable_to_non_nullable
as String,currentName: null == currentName ? _self.currentName : currentName // ignore: cast_nullable_to_non_nullable
as String,currentKeeper: null == currentKeeper ? _self.currentKeeper : currentKeeper // ignore: cast_nullable_to_non_nullable
as String,insuranceExpiry: freezed == insuranceExpiry ? _self.insuranceExpiry : insuranceExpiry // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
