// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'remote_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RemoteController {

/// 遙控器系統 ID (作為 Document ID)
 String get documentId;/// 實際遙控器序號 (可選)
 String? get serialNumber;/// 遙控器類型
 String get rcType;/// 目前綁定的套裝 ID (可為 null，代表在庫存中)
 String? get currentPackageId;/// 遙控器狀態 (如 正常、維修中、已報廢/遺失)
 String get status;/// 自訂欄位
 Map<String, String> get customFields;/// 是否已軟刪除
 bool get isDeleted;
/// Create a copy of RemoteController
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RemoteControllerCopyWith<RemoteController> get copyWith => _$RemoteControllerCopyWithImpl<RemoteController>(this as RemoteController, _$identity);

  /// Serializes this RemoteController to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RemoteController&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.rcType, rcType) || other.rcType == rcType)&&(identical(other.currentPackageId, currentPackageId) || other.currentPackageId == currentPackageId)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.customFields, customFields)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentId,serialNumber,rcType,currentPackageId,status,const DeepCollectionEquality().hash(customFields),isDeleted);

@override
String toString() {
  return 'RemoteController(documentId: $documentId, serialNumber: $serialNumber, rcType: $rcType, currentPackageId: $currentPackageId, status: $status, customFields: $customFields, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class $RemoteControllerCopyWith<$Res>  {
  factory $RemoteControllerCopyWith(RemoteController value, $Res Function(RemoteController) _then) = _$RemoteControllerCopyWithImpl;
@useResult
$Res call({
 String documentId, String? serialNumber, String rcType, String? currentPackageId, String status, Map<String, String> customFields, bool isDeleted
});




}
/// @nodoc
class _$RemoteControllerCopyWithImpl<$Res>
    implements $RemoteControllerCopyWith<$Res> {
  _$RemoteControllerCopyWithImpl(this._self, this._then);

  final RemoteController _self;
  final $Res Function(RemoteController) _then;

/// Create a copy of RemoteController
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? documentId = null,Object? serialNumber = freezed,Object? rcType = null,Object? currentPackageId = freezed,Object? status = null,Object? customFields = null,Object? isDeleted = null,}) {
  return _then(_self.copyWith(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,serialNumber: freezed == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String?,rcType: null == rcType ? _self.rcType : rcType // ignore: cast_nullable_to_non_nullable
as String,currentPackageId: freezed == currentPackageId ? _self.currentPackageId : currentPackageId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,customFields: null == customFields ? _self.customFields : customFields // ignore: cast_nullable_to_non_nullable
as Map<String, String>,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [RemoteController].
extension RemoteControllerPatterns on RemoteController {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RemoteController value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RemoteController() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RemoteController value)  $default,){
final _that = this;
switch (_that) {
case _RemoteController():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RemoteController value)?  $default,){
final _that = this;
switch (_that) {
case _RemoteController() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String documentId,  String? serialNumber,  String rcType,  String? currentPackageId,  String status,  Map<String, String> customFields,  bool isDeleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RemoteController() when $default != null:
return $default(_that.documentId,_that.serialNumber,_that.rcType,_that.currentPackageId,_that.status,_that.customFields,_that.isDeleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String documentId,  String? serialNumber,  String rcType,  String? currentPackageId,  String status,  Map<String, String> customFields,  bool isDeleted)  $default,) {final _that = this;
switch (_that) {
case _RemoteController():
return $default(_that.documentId,_that.serialNumber,_that.rcType,_that.currentPackageId,_that.status,_that.customFields,_that.isDeleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String documentId,  String? serialNumber,  String rcType,  String? currentPackageId,  String status,  Map<String, String> customFields,  bool isDeleted)?  $default,) {final _that = this;
switch (_that) {
case _RemoteController() when $default != null:
return $default(_that.documentId,_that.serialNumber,_that.rcType,_that.currentPackageId,_that.status,_that.customFields,_that.isDeleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RemoteController implements RemoteController {
  const _RemoteController({required this.documentId, this.serialNumber, required this.rcType, this.currentPackageId, this.status = '正常', final  Map<String, String> customFields = const {}, this.isDeleted = false}): _customFields = customFields;
  factory _RemoteController.fromJson(Map<String, dynamic> json) => _$RemoteControllerFromJson(json);

/// 遙控器系統 ID (作為 Document ID)
@override final  String documentId;
/// 實際遙控器序號 (可選)
@override final  String? serialNumber;
/// 遙控器類型
@override final  String rcType;
/// 目前綁定的套裝 ID (可為 null，代表在庫存中)
@override final  String? currentPackageId;
/// 遙控器狀態 (如 正常、維修中、已報廢/遺失)
@override@JsonKey() final  String status;
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

/// Create a copy of RemoteController
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RemoteControllerCopyWith<_RemoteController> get copyWith => __$RemoteControllerCopyWithImpl<_RemoteController>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RemoteControllerToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RemoteController&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.serialNumber, serialNumber) || other.serialNumber == serialNumber)&&(identical(other.rcType, rcType) || other.rcType == rcType)&&(identical(other.currentPackageId, currentPackageId) || other.currentPackageId == currentPackageId)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._customFields, _customFields)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentId,serialNumber,rcType,currentPackageId,status,const DeepCollectionEquality().hash(_customFields),isDeleted);

@override
String toString() {
  return 'RemoteController(documentId: $documentId, serialNumber: $serialNumber, rcType: $rcType, currentPackageId: $currentPackageId, status: $status, customFields: $customFields, isDeleted: $isDeleted)';
}


}

/// @nodoc
abstract mixin class _$RemoteControllerCopyWith<$Res> implements $RemoteControllerCopyWith<$Res> {
  factory _$RemoteControllerCopyWith(_RemoteController value, $Res Function(_RemoteController) _then) = __$RemoteControllerCopyWithImpl;
@override @useResult
$Res call({
 String documentId, String? serialNumber, String rcType, String? currentPackageId, String status, Map<String, String> customFields, bool isDeleted
});




}
/// @nodoc
class __$RemoteControllerCopyWithImpl<$Res>
    implements _$RemoteControllerCopyWith<$Res> {
  __$RemoteControllerCopyWithImpl(this._self, this._then);

  final _RemoteController _self;
  final $Res Function(_RemoteController) _then;

/// Create a copy of RemoteController
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? documentId = null,Object? serialNumber = freezed,Object? rcType = null,Object? currentPackageId = freezed,Object? status = null,Object? customFields = null,Object? isDeleted = null,}) {
  return _then(_RemoteController(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,serialNumber: freezed == serialNumber ? _self.serialNumber : serialNumber // ignore: cast_nullable_to_non_nullable
as String?,rcType: null == rcType ? _self.rcType : rcType // ignore: cast_nullable_to_non_nullable
as String,currentPackageId: freezed == currentPackageId ? _self.currentPackageId : currentPackageId // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,customFields: null == customFields ? _self._customFields : customFields // ignore: cast_nullable_to_non_nullable
as Map<String, String>,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
