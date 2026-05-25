// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'drone_package.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DronePackage {

/// 套裝 ID (UUID)
 String get documentId;/// 戰術編號 (如 Mavic 3 - A)
 String get tacticalName;/// 出廠機型 (如 DJI Mavic 3)
 String get modelType;/// 目前保管人
 String get currentKeeper;/// 配件清單 (Key: 配件名稱, Value: 數量)
 Map<String, int> get accessories;/// 目前綁定的母艦機身 SN (可為 null，代表目前無飛機或送修中)
 String? get currentDroneSn;/// 目前綁定的遙控器 SN (可為 null)
 String? get currentRcSn;/// 建立時間
 DateTime get createdAt;
/// Create a copy of DronePackage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DronePackageCopyWith<DronePackage> get copyWith => _$DronePackageCopyWithImpl<DronePackage>(this as DronePackage, _$identity);

  /// Serializes this DronePackage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DronePackage&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.tacticalName, tacticalName) || other.tacticalName == tacticalName)&&(identical(other.modelType, modelType) || other.modelType == modelType)&&(identical(other.currentKeeper, currentKeeper) || other.currentKeeper == currentKeeper)&&const DeepCollectionEquality().equals(other.accessories, accessories)&&(identical(other.currentDroneSn, currentDroneSn) || other.currentDroneSn == currentDroneSn)&&(identical(other.currentRcSn, currentRcSn) || other.currentRcSn == currentRcSn)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentId,tacticalName,modelType,currentKeeper,const DeepCollectionEquality().hash(accessories),currentDroneSn,currentRcSn,createdAt);

@override
String toString() {
  return 'DronePackage(documentId: $documentId, tacticalName: $tacticalName, modelType: $modelType, currentKeeper: $currentKeeper, accessories: $accessories, currentDroneSn: $currentDroneSn, currentRcSn: $currentRcSn, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $DronePackageCopyWith<$Res>  {
  factory $DronePackageCopyWith(DronePackage value, $Res Function(DronePackage) _then) = _$DronePackageCopyWithImpl;
@useResult
$Res call({
 String documentId, String tacticalName, String modelType, String currentKeeper, Map<String, int> accessories, String? currentDroneSn, String? currentRcSn, DateTime createdAt
});




}
/// @nodoc
class _$DronePackageCopyWithImpl<$Res>
    implements $DronePackageCopyWith<$Res> {
  _$DronePackageCopyWithImpl(this._self, this._then);

  final DronePackage _self;
  final $Res Function(DronePackage) _then;

/// Create a copy of DronePackage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? documentId = null,Object? tacticalName = null,Object? modelType = null,Object? currentKeeper = null,Object? accessories = null,Object? currentDroneSn = freezed,Object? currentRcSn = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,tacticalName: null == tacticalName ? _self.tacticalName : tacticalName // ignore: cast_nullable_to_non_nullable
as String,modelType: null == modelType ? _self.modelType : modelType // ignore: cast_nullable_to_non_nullable
as String,currentKeeper: null == currentKeeper ? _self.currentKeeper : currentKeeper // ignore: cast_nullable_to_non_nullable
as String,accessories: null == accessories ? _self.accessories : accessories // ignore: cast_nullable_to_non_nullable
as Map<String, int>,currentDroneSn: freezed == currentDroneSn ? _self.currentDroneSn : currentDroneSn // ignore: cast_nullable_to_non_nullable
as String?,currentRcSn: freezed == currentRcSn ? _self.currentRcSn : currentRcSn // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [DronePackage].
extension DronePackagePatterns on DronePackage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DronePackage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DronePackage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DronePackage value)  $default,){
final _that = this;
switch (_that) {
case _DronePackage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DronePackage value)?  $default,){
final _that = this;
switch (_that) {
case _DronePackage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String documentId,  String tacticalName,  String modelType,  String currentKeeper,  Map<String, int> accessories,  String? currentDroneSn,  String? currentRcSn,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DronePackage() when $default != null:
return $default(_that.documentId,_that.tacticalName,_that.modelType,_that.currentKeeper,_that.accessories,_that.currentDroneSn,_that.currentRcSn,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String documentId,  String tacticalName,  String modelType,  String currentKeeper,  Map<String, int> accessories,  String? currentDroneSn,  String? currentRcSn,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _DronePackage():
return $default(_that.documentId,_that.tacticalName,_that.modelType,_that.currentKeeper,_that.accessories,_that.currentDroneSn,_that.currentRcSn,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String documentId,  String tacticalName,  String modelType,  String currentKeeper,  Map<String, int> accessories,  String? currentDroneSn,  String? currentRcSn,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _DronePackage() when $default != null:
return $default(_that.documentId,_that.tacticalName,_that.modelType,_that.currentKeeper,_that.accessories,_that.currentDroneSn,_that.currentRcSn,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DronePackage implements DronePackage {
  const _DronePackage({required this.documentId, required this.tacticalName, required this.modelType, required this.currentKeeper, final  Map<String, int> accessories = const {}, this.currentDroneSn, this.currentRcSn, required this.createdAt}): _accessories = accessories;
  factory _DronePackage.fromJson(Map<String, dynamic> json) => _$DronePackageFromJson(json);

/// 套裝 ID (UUID)
@override final  String documentId;
/// 戰術編號 (如 Mavic 3 - A)
@override final  String tacticalName;
/// 出廠機型 (如 DJI Mavic 3)
@override final  String modelType;
/// 目前保管人
@override final  String currentKeeper;
/// 配件清單 (Key: 配件名稱, Value: 數量)
 final  Map<String, int> _accessories;
/// 配件清單 (Key: 配件名稱, Value: 數量)
@override@JsonKey() Map<String, int> get accessories {
  if (_accessories is EqualUnmodifiableMapView) return _accessories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_accessories);
}

/// 目前綁定的母艦機身 SN (可為 null，代表目前無飛機或送修中)
@override final  String? currentDroneSn;
/// 目前綁定的遙控器 SN (可為 null)
@override final  String? currentRcSn;
/// 建立時間
@override final  DateTime createdAt;

/// Create a copy of DronePackage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DronePackageCopyWith<_DronePackage> get copyWith => __$DronePackageCopyWithImpl<_DronePackage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DronePackageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DronePackage&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.tacticalName, tacticalName) || other.tacticalName == tacticalName)&&(identical(other.modelType, modelType) || other.modelType == modelType)&&(identical(other.currentKeeper, currentKeeper) || other.currentKeeper == currentKeeper)&&const DeepCollectionEquality().equals(other._accessories, _accessories)&&(identical(other.currentDroneSn, currentDroneSn) || other.currentDroneSn == currentDroneSn)&&(identical(other.currentRcSn, currentRcSn) || other.currentRcSn == currentRcSn)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentId,tacticalName,modelType,currentKeeper,const DeepCollectionEquality().hash(_accessories),currentDroneSn,currentRcSn,createdAt);

@override
String toString() {
  return 'DronePackage(documentId: $documentId, tacticalName: $tacticalName, modelType: $modelType, currentKeeper: $currentKeeper, accessories: $accessories, currentDroneSn: $currentDroneSn, currentRcSn: $currentRcSn, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$DronePackageCopyWith<$Res> implements $DronePackageCopyWith<$Res> {
  factory _$DronePackageCopyWith(_DronePackage value, $Res Function(_DronePackage) _then) = __$DronePackageCopyWithImpl;
@override @useResult
$Res call({
 String documentId, String tacticalName, String modelType, String currentKeeper, Map<String, int> accessories, String? currentDroneSn, String? currentRcSn, DateTime createdAt
});




}
/// @nodoc
class __$DronePackageCopyWithImpl<$Res>
    implements _$DronePackageCopyWith<$Res> {
  __$DronePackageCopyWithImpl(this._self, this._then);

  final _DronePackage _self;
  final $Res Function(_DronePackage) _then;

/// Create a copy of DronePackage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? documentId = null,Object? tacticalName = null,Object? modelType = null,Object? currentKeeper = null,Object? accessories = null,Object? currentDroneSn = freezed,Object? currentRcSn = freezed,Object? createdAt = null,}) {
  return _then(_DronePackage(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,tacticalName: null == tacticalName ? _self.tacticalName : tacticalName // ignore: cast_nullable_to_non_nullable
as String,modelType: null == modelType ? _self.modelType : modelType // ignore: cast_nullable_to_non_nullable
as String,currentKeeper: null == currentKeeper ? _self.currentKeeper : currentKeeper // ignore: cast_nullable_to_non_nullable
as String,accessories: null == accessories ? _self._accessories : accessories // ignore: cast_nullable_to_non_nullable
as Map<String, int>,currentDroneSn: freezed == currentDroneSn ? _self.currentDroneSn : currentDroneSn // ignore: cast_nullable_to_non_nullable
as String?,currentRcSn: freezed == currentRcSn ? _self.currentRcSn : currentRcSn // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
