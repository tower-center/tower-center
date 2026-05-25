// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'accessory_def.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AccessoryDef {

/// 配件 ID (UUID)
 String get documentId;/// 配件名稱 (如 Mavic 3 充電管家)
 String get name;/// 所屬出廠機型 (對應 AircraftModel.name)
 String get aircraftModelName;/// 是否啟用
 bool get isActive;/// 建立時間
 DateTime get createdAt;
/// Create a copy of AccessoryDef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccessoryDefCopyWith<AccessoryDef> get copyWith => _$AccessoryDefCopyWithImpl<AccessoryDef>(this as AccessoryDef, _$identity);

  /// Serializes this AccessoryDef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccessoryDef&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.name, name) || other.name == name)&&(identical(other.aircraftModelName, aircraftModelName) || other.aircraftModelName == aircraftModelName)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentId,name,aircraftModelName,isActive,createdAt);

@override
String toString() {
  return 'AccessoryDef(documentId: $documentId, name: $name, aircraftModelName: $aircraftModelName, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AccessoryDefCopyWith<$Res>  {
  factory $AccessoryDefCopyWith(AccessoryDef value, $Res Function(AccessoryDef) _then) = _$AccessoryDefCopyWithImpl;
@useResult
$Res call({
 String documentId, String name, String aircraftModelName, bool isActive, DateTime createdAt
});




}
/// @nodoc
class _$AccessoryDefCopyWithImpl<$Res>
    implements $AccessoryDefCopyWith<$Res> {
  _$AccessoryDefCopyWithImpl(this._self, this._then);

  final AccessoryDef _self;
  final $Res Function(AccessoryDef) _then;

/// Create a copy of AccessoryDef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? documentId = null,Object? name = null,Object? aircraftModelName = null,Object? isActive = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,aircraftModelName: null == aircraftModelName ? _self.aircraftModelName : aircraftModelName // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [AccessoryDef].
extension AccessoryDefPatterns on AccessoryDef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccessoryDef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccessoryDef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccessoryDef value)  $default,){
final _that = this;
switch (_that) {
case _AccessoryDef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccessoryDef value)?  $default,){
final _that = this;
switch (_that) {
case _AccessoryDef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String documentId,  String name,  String aircraftModelName,  bool isActive,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccessoryDef() when $default != null:
return $default(_that.documentId,_that.name,_that.aircraftModelName,_that.isActive,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String documentId,  String name,  String aircraftModelName,  bool isActive,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _AccessoryDef():
return $default(_that.documentId,_that.name,_that.aircraftModelName,_that.isActive,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String documentId,  String name,  String aircraftModelName,  bool isActive,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AccessoryDef() when $default != null:
return $default(_that.documentId,_that.name,_that.aircraftModelName,_that.isActive,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AccessoryDef implements AccessoryDef {
  const _AccessoryDef({required this.documentId, required this.name, required this.aircraftModelName, this.isActive = true, required this.createdAt});
  factory _AccessoryDef.fromJson(Map<String, dynamic> json) => _$AccessoryDefFromJson(json);

/// 配件 ID (UUID)
@override final  String documentId;
/// 配件名稱 (如 Mavic 3 充電管家)
@override final  String name;
/// 所屬出廠機型 (對應 AircraftModel.name)
@override final  String aircraftModelName;
/// 是否啟用
@override@JsonKey() final  bool isActive;
/// 建立時間
@override final  DateTime createdAt;

/// Create a copy of AccessoryDef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccessoryDefCopyWith<_AccessoryDef> get copyWith => __$AccessoryDefCopyWithImpl<_AccessoryDef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AccessoryDefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccessoryDef&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.name, name) || other.name == name)&&(identical(other.aircraftModelName, aircraftModelName) || other.aircraftModelName == aircraftModelName)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentId,name,aircraftModelName,isActive,createdAt);

@override
String toString() {
  return 'AccessoryDef(documentId: $documentId, name: $name, aircraftModelName: $aircraftModelName, isActive: $isActive, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AccessoryDefCopyWith<$Res> implements $AccessoryDefCopyWith<$Res> {
  factory _$AccessoryDefCopyWith(_AccessoryDef value, $Res Function(_AccessoryDef) _then) = __$AccessoryDefCopyWithImpl;
@override @useResult
$Res call({
 String documentId, String name, String aircraftModelName, bool isActive, DateTime createdAt
});




}
/// @nodoc
class __$AccessoryDefCopyWithImpl<$Res>
    implements _$AccessoryDefCopyWith<$Res> {
  __$AccessoryDefCopyWithImpl(this._self, this._then);

  final _AccessoryDef _self;
  final $Res Function(_AccessoryDef) _then;

/// Create a copy of AccessoryDef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? documentId = null,Object? name = null,Object? aircraftModelName = null,Object? isActive = null,Object? createdAt = null,}) {
  return _then(_AccessoryDef(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,aircraftModelName: null == aircraftModelName ? _self.aircraftModelName : aircraftModelName // ignore: cast_nullable_to_non_nullable
as String,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
