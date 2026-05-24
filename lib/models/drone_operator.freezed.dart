// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'drone_operator.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DroneOperator {

/// 文件 ID (如隨機產生的 UUID)
 String get documentId;/// 空拍手姓名
 String get name;/// 聯絡電話
 String get phone;/// 證照號碼
 String get licenseNumber;/// 建立時間 (用於最新優先排序)
 DateTime get createdAt;/// 是否啟用
 bool get isActive;/// 自訂擴充欄位 (Key: 欄位名稱, Value: 欄位內容)
 Map<String, String> get customFields;
/// Create a copy of DroneOperator
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DroneOperatorCopyWith<DroneOperator> get copyWith => _$DroneOperatorCopyWithImpl<DroneOperator>(this as DroneOperator, _$identity);

  /// Serializes this DroneOperator to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DroneOperator&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.licenseNumber, licenseNumber) || other.licenseNumber == licenseNumber)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&const DeepCollectionEquality().equals(other.customFields, customFields));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentId,name,phone,licenseNumber,createdAt,isActive,const DeepCollectionEquality().hash(customFields));

@override
String toString() {
  return 'DroneOperator(documentId: $documentId, name: $name, phone: $phone, licenseNumber: $licenseNumber, createdAt: $createdAt, isActive: $isActive, customFields: $customFields)';
}


}

/// @nodoc
abstract mixin class $DroneOperatorCopyWith<$Res>  {
  factory $DroneOperatorCopyWith(DroneOperator value, $Res Function(DroneOperator) _then) = _$DroneOperatorCopyWithImpl;
@useResult
$Res call({
 String documentId, String name, String phone, String licenseNumber, DateTime createdAt, bool isActive, Map<String, String> customFields
});




}
/// @nodoc
class _$DroneOperatorCopyWithImpl<$Res>
    implements $DroneOperatorCopyWith<$Res> {
  _$DroneOperatorCopyWithImpl(this._self, this._then);

  final DroneOperator _self;
  final $Res Function(DroneOperator) _then;

/// Create a copy of DroneOperator
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? documentId = null,Object? name = null,Object? phone = null,Object? licenseNumber = null,Object? createdAt = null,Object? isActive = null,Object? customFields = null,}) {
  return _then(_self.copyWith(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,licenseNumber: null == licenseNumber ? _self.licenseNumber : licenseNumber // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,customFields: null == customFields ? _self.customFields : customFields // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}

}


/// Adds pattern-matching-related methods to [DroneOperator].
extension DroneOperatorPatterns on DroneOperator {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DroneOperator value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DroneOperator() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DroneOperator value)  $default,){
final _that = this;
switch (_that) {
case _DroneOperator():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DroneOperator value)?  $default,){
final _that = this;
switch (_that) {
case _DroneOperator() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String documentId,  String name,  String phone,  String licenseNumber,  DateTime createdAt,  bool isActive,  Map<String, String> customFields)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DroneOperator() when $default != null:
return $default(_that.documentId,_that.name,_that.phone,_that.licenseNumber,_that.createdAt,_that.isActive,_that.customFields);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String documentId,  String name,  String phone,  String licenseNumber,  DateTime createdAt,  bool isActive,  Map<String, String> customFields)  $default,) {final _that = this;
switch (_that) {
case _DroneOperator():
return $default(_that.documentId,_that.name,_that.phone,_that.licenseNumber,_that.createdAt,_that.isActive,_that.customFields);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String documentId,  String name,  String phone,  String licenseNumber,  DateTime createdAt,  bool isActive,  Map<String, String> customFields)?  $default,) {final _that = this;
switch (_that) {
case _DroneOperator() when $default != null:
return $default(_that.documentId,_that.name,_that.phone,_that.licenseNumber,_that.createdAt,_that.isActive,_that.customFields);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DroneOperator implements DroneOperator {
  const _DroneOperator({required this.documentId, required this.name, required this.phone, required this.licenseNumber, required this.createdAt, this.isActive = true, final  Map<String, String> customFields = const {}}): _customFields = customFields;
  factory _DroneOperator.fromJson(Map<String, dynamic> json) => _$DroneOperatorFromJson(json);

/// 文件 ID (如隨機產生的 UUID)
@override final  String documentId;
/// 空拍手姓名
@override final  String name;
/// 聯絡電話
@override final  String phone;
/// 證照號碼
@override final  String licenseNumber;
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


/// Create a copy of DroneOperator
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DroneOperatorCopyWith<_DroneOperator> get copyWith => __$DroneOperatorCopyWithImpl<_DroneOperator>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DroneOperatorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DroneOperator&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.name, name) || other.name == name)&&(identical(other.phone, phone) || other.phone == phone)&&(identical(other.licenseNumber, licenseNumber) || other.licenseNumber == licenseNumber)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&const DeepCollectionEquality().equals(other._customFields, _customFields));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentId,name,phone,licenseNumber,createdAt,isActive,const DeepCollectionEquality().hash(_customFields));

@override
String toString() {
  return 'DroneOperator(documentId: $documentId, name: $name, phone: $phone, licenseNumber: $licenseNumber, createdAt: $createdAt, isActive: $isActive, customFields: $customFields)';
}


}

/// @nodoc
abstract mixin class _$DroneOperatorCopyWith<$Res> implements $DroneOperatorCopyWith<$Res> {
  factory _$DroneOperatorCopyWith(_DroneOperator value, $Res Function(_DroneOperator) _then) = __$DroneOperatorCopyWithImpl;
@override @useResult
$Res call({
 String documentId, String name, String phone, String licenseNumber, DateTime createdAt, bool isActive, Map<String, String> customFields
});




}
/// @nodoc
class __$DroneOperatorCopyWithImpl<$Res>
    implements _$DroneOperatorCopyWith<$Res> {
  __$DroneOperatorCopyWithImpl(this._self, this._then);

  final _DroneOperator _self;
  final $Res Function(_DroneOperator) _then;

/// Create a copy of DroneOperator
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? documentId = null,Object? name = null,Object? phone = null,Object? licenseNumber = null,Object? createdAt = null,Object? isActive = null,Object? customFields = null,}) {
  return _then(_DroneOperator(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,phone: null == phone ? _self.phone : phone // ignore: cast_nullable_to_non_nullable
as String,licenseNumber: null == licenseNumber ? _self.licenseNumber : licenseNumber // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,customFields: null == customFields ? _self._customFields : customFields // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
