// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'aircraft_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AircraftModel {

/// 文件 ID (如隨機產生的 UUID)
 String get documentId;/// 機型名稱 (如 DJI Mavic 3 Pro)
 String get name;/// 製造商 (如 DJI)
 String get manufacturer;/// 建立時間 (用於最新優先排序)
 DateTime get createdAt;/// 是否啟用
 bool get isActive;/// 自訂擴充欄位 (Key: 欄位名稱, Value: 欄位內容)
 Map<String, String> get customFields;
/// Create a copy of AircraftModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AircraftModelCopyWith<AircraftModel> get copyWith => _$AircraftModelCopyWithImpl<AircraftModel>(this as AircraftModel, _$identity);

  /// Serializes this AircraftModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AircraftModel&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.name, name) || other.name == name)&&(identical(other.manufacturer, manufacturer) || other.manufacturer == manufacturer)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&const DeepCollectionEquality().equals(other.customFields, customFields));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentId,name,manufacturer,createdAt,isActive,const DeepCollectionEquality().hash(customFields));

@override
String toString() {
  return 'AircraftModel(documentId: $documentId, name: $name, manufacturer: $manufacturer, createdAt: $createdAt, isActive: $isActive, customFields: $customFields)';
}


}

/// @nodoc
abstract mixin class $AircraftModelCopyWith<$Res>  {
  factory $AircraftModelCopyWith(AircraftModel value, $Res Function(AircraftModel) _then) = _$AircraftModelCopyWithImpl;
@useResult
$Res call({
 String documentId, String name, String manufacturer, DateTime createdAt, bool isActive, Map<String, String> customFields
});




}
/// @nodoc
class _$AircraftModelCopyWithImpl<$Res>
    implements $AircraftModelCopyWith<$Res> {
  _$AircraftModelCopyWithImpl(this._self, this._then);

  final AircraftModel _self;
  final $Res Function(AircraftModel) _then;

/// Create a copy of AircraftModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? documentId = null,Object? name = null,Object? manufacturer = null,Object? createdAt = null,Object? isActive = null,Object? customFields = null,}) {
  return _then(_self.copyWith(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,manufacturer: null == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,customFields: null == customFields ? _self.customFields : customFields // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [AircraftModel].
extension AircraftModelPatterns on AircraftModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AircraftModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AircraftModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AircraftModel value)  $default,){
final _that = this;
switch (_that) {
case _AircraftModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AircraftModel value)?  $default,){
final _that = this;
switch (_that) {
case _AircraftModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String documentId,  String name,  String manufacturer,  DateTime createdAt,  bool isActive,  Map<String, String> customFields)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AircraftModel() when $default != null:
return $default(_that.documentId,_that.name,_that.manufacturer,_that.createdAt,_that.isActive,_that.customFields);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String documentId,  String name,  String manufacturer,  DateTime createdAt,  bool isActive,  Map<String, String> customFields)  $default,) {final _that = this;
switch (_that) {
case _AircraftModel():
return $default(_that.documentId,_that.name,_that.manufacturer,_that.createdAt,_that.isActive,_that.customFields);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String documentId,  String name,  String manufacturer,  DateTime createdAt,  bool isActive,  Map<String, String> customFields)?  $default,) {final _that = this;
switch (_that) {
case _AircraftModel() when $default != null:
return $default(_that.documentId,_that.name,_that.manufacturer,_that.createdAt,_that.isActive,_that.customFields);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AircraftModel implements AircraftModel {
  const _AircraftModel({required this.documentId, required this.name, required this.manufacturer, required this.createdAt, this.isActive = true, final  Map<String, String> customFields = const {}}): _customFields = customFields;
  factory _AircraftModel.fromJson(Map<String, dynamic> json) => _$AircraftModelFromJson(json);

/// 文件 ID (如隨機產生的 UUID)
@override final  String documentId;
/// 機型名稱 (如 DJI Mavic 3 Pro)
@override final  String name;
/// 製造商 (如 DJI)
@override final  String manufacturer;
/// 建立時間 (用於最新優先排序)
@override final  DateTime createdAt;
/// 是否啟用
@override@JsonKey() final  bool isActive;
/// 自訂擴充欄位 (Key: 欄位名稱, Value: 欄位內容)
 final  Map<String, String> _customFields;
/// 自訂擴充欄位 (Key: 欄位名稱, Value: 欄位內容)
@override@JsonKey() Map<String, String> get customFields {
  if (_customFields is EqualUnmodifiableMapView) return _customFields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_customFields);
}


/// Create a copy of AircraftModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AircraftModelCopyWith<_AircraftModel> get copyWith => __$AircraftModelCopyWithImpl<_AircraftModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AircraftModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AircraftModel&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.name, name) || other.name == name)&&(identical(other.manufacturer, manufacturer) || other.manufacturer == manufacturer)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&const DeepCollectionEquality().equals(other._customFields, _customFields));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentId,name,manufacturer,createdAt,isActive,const DeepCollectionEquality().hash(_customFields));

@override
String toString() {
  return 'AircraftModel(documentId: $documentId, name: $name, manufacturer: $manufacturer, createdAt: $createdAt, isActive: $isActive, customFields: $customFields)';
}


}

/// @nodoc
abstract mixin class _$AircraftModelCopyWith<$Res> implements $AircraftModelCopyWith<$Res> {
  factory _$AircraftModelCopyWith(_AircraftModel value, $Res Function(_AircraftModel) _then) = __$AircraftModelCopyWithImpl;
@override @useResult
$Res call({
 String documentId, String name, String manufacturer, DateTime createdAt, bool isActive, Map<String, String> customFields
});




}
/// @nodoc
class __$AircraftModelCopyWithImpl<$Res>
    implements _$AircraftModelCopyWith<$Res> {
  __$AircraftModelCopyWithImpl(this._self, this._then);

  final _AircraftModel _self;
  final $Res Function(_AircraftModel) _then;

/// Create a copy of AircraftModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? documentId = null,Object? name = null,Object? manufacturer = null,Object? createdAt = null,Object? isActive = null,Object? customFields = null,}) {
  return _then(_AircraftModel(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,manufacturer: null == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,customFields: null == customFields ? _self._customFields : customFields // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
