// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'battery.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Battery {

/// 系統內部 UUID (作為 Document ID)
 String get documentId;/// 電池出廠序號 (唯一不可變的硬體 SN)
 String? get serialNumber;/// 外場標籤名稱 (可變動，如 M301, P01)
@JsonKey(readValue: _readTagName) String get tagName;/// 電池型號
 String get batteryModel;/// 採購日期
 DateTime? get purchaseDate;/// 循環次數
 int get cycleCount;/// 膨脹狀態 / 健康狀態
 String get healthStatus;/// 目前配置套裝 ID (可為 null，代表在庫存中)
 String? get currentPackageId;
/// Create a copy of Battery
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BatteryCopyWith<Battery> get copyWith => _$BatteryCopyWithImpl<Battery>(this as Battery, _$identity);

  /// Serializes this Battery to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Battery&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.tagName, tagName) || other.tagName == tagName)&&(identical(other.batteryModel, batteryModel) || other.batteryModel == batteryModel)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate)&&(identical(other.cycleCount, cycleCount) || other.cycleCount == cycleCount)&&(identical(other.healthStatus, healthStatus) || other.healthStatus == healthStatus)&&(identical(other.currentPackageId, currentPackageId) || other.currentPackageId == currentPackageId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentId,serialNumber,tagName,batteryModel,purchaseDate,cycleCount,healthStatus,currentPackageId);

@override
String toString() {
  return 'Battery(documentId: $documentId, serialNumber: $serialNumber, tagName: $tagName, batteryModel: $batteryModel, purchaseDate: $purchaseDate, cycleCount: $cycleCount, healthStatus: $healthStatus, currentPackageId: $currentPackageId)';
}


}

/// @nodoc
abstract mixin class $BatteryCopyWith<$Res>  {
  factory $BatteryCopyWith(Battery value, $Res Function(Battery) _then) = _$BatteryCopyWithImpl;
@useResult
$Res call({
 String documentId, String? serialNumber,@JsonKey(readValue: _readTagName) String tagName, String batteryModel, DateTime? purchaseDate, int cycleCount, String healthStatus, String? currentPackageId
});




}
/// @nodoc
class _$BatteryCopyWithImpl<$Res>
    implements $BatteryCopyWith<$Res> {
  _$BatteryCopyWithImpl(this._self, this._then);

  final Battery _self;
  final $Res Function(Battery) _then;

/// Create a copy of Battery
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? documentId = null,Object? serialNumber = freezed,Object? tagName = null,Object? batteryModel = null,Object? purchaseDate = freezed,Object? cycleCount = null,Object? healthStatus = null,Object? currentPackageId = freezed,}) {
  return _then(_self.copyWith(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,serialNumber: freezed == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String?,tagName: null == tagName ? _self.tagName : tagName // ignore: cast_nullable_to_non_nullable
as String,batteryModel: null == batteryModel ? _self.batteryModel : batteryModel // ignore: cast_nullable_to_non_nullable
as String,purchaseDate: freezed == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,cycleCount: null == cycleCount ? _self.cycleCount : cycleCount // ignore: cast_nullable_to_non_nullable
as int,healthStatus: null == healthStatus ? _self.healthStatus : healthStatus // ignore: cast_nullable_to_non_nullable
as String,currentPackageId: freezed == currentPackageId ? _self.currentPackageId : currentPackageId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Battery].
extension BatteryPatterns on Battery {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Battery value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Battery() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Battery value)  $default,){
final _that = this;
switch (_that) {
case _Battery():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Battery value)?  $default,){
final _that = this;
switch (_that) {
case _Battery() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String documentId,  String? serialNumber, @JsonKey(readValue: _readTagName)  String tagName,  String batteryModel,  DateTime? purchaseDate,  int cycleCount,  String healthStatus,  String? currentPackageId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Battery() when $default != null:
return $default(_that.documentId,_that.serialNumber,_that.tagName,_that.batteryModel,_that.purchaseDate,_that.cycleCount,_that.healthStatus,_that.currentPackageId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String documentId,  String? serialNumber, @JsonKey(readValue: _readTagName)  String tagName,  String batteryModel,  DateTime? purchaseDate,  int cycleCount,  String healthStatus,  String? currentPackageId)  $default,) {final _that = this;
switch (_that) {
case _Battery():
return $default(_that.documentId,_that.serialNumber,_that.tagName,_that.batteryModel,_that.purchaseDate,_that.cycleCount,_that.healthStatus,_that.currentPackageId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String documentId,  String? serialNumber, @JsonKey(readValue: _readTagName)  String tagName,  String batteryModel,  DateTime? purchaseDate,  int cycleCount,  String healthStatus,  String? currentPackageId)?  $default,) {final _that = this;
switch (_that) {
case _Battery() when $default != null:
return $default(_that.documentId,_that.serialNumber,_that.tagName,_that.batteryModel,_that.purchaseDate,_that.cycleCount,_that.healthStatus,_that.currentPackageId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Battery implements Battery {
  const _Battery({required this.documentId, this.serialNumber, @JsonKey(readValue: _readTagName) required this.tagName, required this.batteryModel, this.purchaseDate, required this.cycleCount, required this.healthStatus, this.currentPackageId});
  factory _Battery.fromJson(Map<String, dynamic> json) => _$BatteryFromJson(json);

/// 系統內部 UUID (作為 Document ID)
@override final  String documentId;
/// 電池出廠序號 (唯一不可變的硬體 SN)
@override final  String? serialNumber;
/// 外場標籤名稱 (可變動，如 M301, P01)
@override@JsonKey(readValue: _readTagName) final  String tagName;
/// 電池型號
@override final  String batteryModel;
/// 採購日期
@override final  DateTime? purchaseDate;
/// 循環次數
@override final  int cycleCount;
/// 膨脹狀態 / 健康狀態
@override final  String healthStatus;
/// 目前配置套裝 ID (可為 null，代表在庫存中)
@override final  String? currentPackageId;

/// Create a copy of Battery
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BatteryCopyWith<_Battery> get copyWith => __$BatteryCopyWithImpl<_Battery>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BatteryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Battery&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.tagName, tagName) || other.tagName == tagName)&&(identical(other.batteryModel, batteryModel) || other.batteryModel == batteryModel)&&(identical(other.purchaseDate, purchaseDate) || other.purchaseDate == purchaseDate)&&(identical(other.cycleCount, cycleCount) || other.cycleCount == cycleCount)&&(identical(other.healthStatus, healthStatus) || other.healthStatus == healthStatus)&&(identical(other.currentPackageId, currentPackageId) || other.currentPackageId == currentPackageId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentId,serialNumber,tagName,batteryModel,purchaseDate,cycleCount,healthStatus,currentPackageId);

@override
String toString() {
  return 'Battery(documentId: $documentId, serialNumber: $serialNumber, tagName: $tagName, batteryModel: $batteryModel, purchaseDate: $purchaseDate, cycleCount: $cycleCount, healthStatus: $healthStatus, currentPackageId: $currentPackageId)';
}


}

/// @nodoc
abstract mixin class _$BatteryCopyWith<$Res> implements $BatteryCopyWith<$Res> {
  factory _$BatteryCopyWith(_Battery value, $Res Function(_Battery) _then) = __$BatteryCopyWithImpl;
@override @useResult
$Res call({
 String documentId, String? serialNumber,@JsonKey(readValue: _readTagName) String tagName, String batteryModel, DateTime? purchaseDate, int cycleCount, String healthStatus, String? currentPackageId
});




}
/// @nodoc
class __$BatteryCopyWithImpl<$Res>
    implements _$BatteryCopyWith<$Res> {
  __$BatteryCopyWithImpl(this._self, this._then);

  final _Battery _self;
  final $Res Function(_Battery) _then;

/// Create a copy of Battery
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? documentId = null,Object? serialNumber = freezed,Object? tagName = null,Object? batteryModel = null,Object? purchaseDate = freezed,Object? cycleCount = null,Object? healthStatus = null,Object? currentPackageId = freezed,}) {
  return _then(_Battery(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,serialNumber: freezed == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String?,tagName: null == tagName ? _self.tagName : tagName // ignore: cast_nullable_to_non_nullable
as String,batteryModel: null == batteryModel ? _self.batteryModel : batteryModel // ignore: cast_nullable_to_non_nullable
as String,purchaseDate: freezed == purchaseDate ? _self.purchaseDate : purchaseDate // ignore: cast_nullable_to_non_nullable
as DateTime?,cycleCount: null == cycleCount ? _self.cycleCount : cycleCount // ignore: cast_nullable_to_non_nullable
as int,healthStatus: null == healthStatus ? _self.healthStatus : healthStatus // ignore: cast_nullable_to_non_nullable
as String,currentPackageId: freezed == currentPackageId ? _self.currentPackageId : currentPackageId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
