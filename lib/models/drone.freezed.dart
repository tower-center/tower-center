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

/// 機身序號 (作為 Document ID，若無序號則使用隨機 ID)
 String get documentId;/// 實際機身出廠序號 (可選)
 String? get serialNumber;/// 出廠機型
 String get modelType;/// 目前綁定的套裝 ID (可為 null，代表在庫存中)
 String? get currentPackageId;/// 機身狀態 (如 正常、維修中、已報廢/遺失)
 String get status;/// 保險/註冊到期日
 DateTime? get insuranceExpiry;/// 自訂欄位
 Map<String, String> get customFields;/// 是否已軟刪除
 bool get isDeleted;
/// Create a copy of Drone
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DroneCopyWith<Drone> get copyWith => _$DroneCopyWithImpl<Drone>(this as Drone, _$identity);

  /// Serializes this Drone to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Drone&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.modelType, modelType) || other.modelType == modelType)&&(identical(other.currentPackageId, currentPackageId) || other.currentPackageId == currentPackageId)&&(identical(other.status, status) || other.status == status)&&(identical(other.insuranceExpiry, insuranceExpiry) || other.insuranceExpiry == insuranceExpiry)&&const DeepCollectionEquality().equals(other.customFields, customFields)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentId,serialNumber,modelType,currentPackageId,status,insuranceExpiry,const DeepCollectionEquality().hash(customFields),isDeleted);

@override
String toString() {
  return 'Drone(documentId: $documentId, serialNumber: $serialNumber, modelType: $modelType, currentPackageId: $currentPackageId, status: $status, insuranceExpiry: $insuranceExpiry, customFields: $customFields, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class $DroneCopyWith<$Res>  {
  factory $DroneCopyWith(Drone value, $Res Function(Drone) _then) = _$DroneCopyWithImpl;
@useResult
$Res call({
 String documentId, String? serialNumber, String modelType, String? currentPackageId, String status, DateTime? insuranceExpiry, Map<String, String> customFields, bool isDeleted
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
@pragma('vm:prefer-inline') @override $Res call({Object? documentId = null,Object? serialNumber = freezed,Object? modelType = null,Object? currentPackageId = freezed,Object? status = null,Object? insuranceExpiry = freezed,Object? customFields = null,Object? isDeleted = null,}) {
  return _then(_self.copyWith(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,serialNumber: freezed == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String?,modelType: null == modelType ? _self.modelType : modelType // ignore: cast_nullable_to_non_nullable
as String,currentPackageId: freezed == currentPackageId ? _self.currentPackageId : currentPackageId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,insuranceExpiry: freezed == insuranceExpiry ? _self.insuranceExpiry : insuranceExpiry // ignore: cast_nullable_to_non_nullable
as DateTime?,customFields: null == customFields ? _self.customFields : customFields // ignore: cast_nullable_to_non_nullable
as Map<String, String>,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String documentId,  String? serialNumber,  String modelType,  String? currentPackageId,  String status,  DateTime? insuranceExpiry,  Map<String, String> customFields,  bool isDeleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Drone() when $default != null:
return $default(_that.documentId,_that.serialNumber,_that.modelType,_that.currentPackageId,_that.status,_that.insuranceExpiry,_that.customFields,_that.isDeleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String documentId,  String? serialNumber,  String modelType,  String? currentPackageId,  String status,  DateTime? insuranceExpiry,  Map<String, String> customFields,  bool isDeleted)  $default,) {final _that = this;
switch (_that) {
case _Drone():
return $default(_that.documentId,_that.serialNumber,_that.modelType,_that.currentPackageId,_that.status,_that.insuranceExpiry,_that.customFields,_that.isDeleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String documentId,  String? serialNumber,  String modelType,  String? currentPackageId,  String status,  DateTime? insuranceExpiry,  Map<String, String> customFields,  bool isDeleted)?  $default,) {final _that = this;
switch (_that) {
case _Drone() when $default != null:
return $default(_that.documentId,_that.serialNumber,_that.modelType,_that.currentPackageId,_that.status,_that.insuranceExpiry,_that.customFields,_that.isDeleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Drone implements Drone {
  const _Drone({required this.documentId, this.serialNumber, required this.modelType, this.currentPackageId, this.status = '正常', this.insuranceExpiry, final  Map<String, String> customFields = const {}, this.isDeleted = false}): _customFields = customFields;
  factory _Drone.fromJson(Map<String, dynamic> json) => _$DroneFromJson(json);

/// 機身序號 (作為 Document ID，若無序號則使用隨機 ID)
@override final  String documentId;
/// 實際機身出廠序號 (可選)
@override final  String? serialNumber;
/// 出廠機型
@override final  String modelType;
/// 目前綁定的套裝 ID (可為 null，代表在庫存中)
@override final  String? currentPackageId;
/// 機身狀態 (如 正常、維修中、已報廢/遺失)
@override@JsonKey() final  String status;
/// 保險/註冊到期日
@override final  DateTime? insuranceExpiry;
/// 自訂欄位
 final  Map<String, String> _customFields;
/// 自訂欄位
@override@JsonKey() Map<String, String> get customFields {
  if (_customFields is EqualUnmodifiableMapView) return _customFields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_customFields);
}

/// 是否已軟刪除
@override@JsonKey() final  bool isDeleted;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Drone&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.modelType, modelType) || other.modelType == modelType)&&(identical(other.currentPackageId, currentPackageId) || other.currentPackageId == currentPackageId)&&(identical(other.status, status) || other.status == status)&&(identical(other.insuranceExpiry, insuranceExpiry) || other.insuranceExpiry == insuranceExpiry)&&const DeepCollectionEquality().equals(other._customFields, _customFields)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentId,serialNumber,modelType,currentPackageId,status,insuranceExpiry,const DeepCollectionEquality().hash(_customFields),isDeleted);

@override
String toString() {
  return 'Drone(documentId: $documentId, serialNumber: $serialNumber, modelType: $modelType, currentPackageId: $currentPackageId, status: $status, insuranceExpiry: $insuranceExpiry, customFields: $customFields, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class _$DroneCopyWith<$Res> implements $DroneCopyWith<$Res> {
  factory _$DroneCopyWith(_Drone value, $Res Function(_Drone) _then) = __$DroneCopyWithImpl;
@override @useResult
$Res call({
 String documentId, String? serialNumber, String modelType, String? currentPackageId, String status, DateTime? insuranceExpiry, Map<String, String> customFields, bool isDeleted
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
@override @pragma('vm:prefer-inline') $Res call({Object? documentId = null,Object? serialNumber = freezed,Object? modelType = null,Object? currentPackageId = freezed,Object? status = null,Object? insuranceExpiry = freezed,Object? customFields = null,Object? isDeleted = null,}) {
  return _then(_Drone(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,serialNumber: freezed == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String?,modelType: null == modelType ? _self.modelType : modelType // ignore: cast_nullable_to_non_nullable
as String,currentPackageId: freezed == currentPackageId ? _self.currentPackageId : currentPackageId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,insuranceExpiry: freezed == insuranceExpiry ? _self.insuranceExpiry : insuranceExpiry // ignore: cast_nullable_to_non_nullable
as DateTime?,customFields: null == customFields ? _self._customFields : customFields // ignore: cast_nullable_to_non_nullable
as Map<String, String>,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
