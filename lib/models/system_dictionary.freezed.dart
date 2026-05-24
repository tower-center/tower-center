// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'system_dictionary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SystemDictionary {

/// 文件 ID (如隨機產生的 UUID)
 String get documentId;/// 字典類別 (例如 'tactical_name' 戰術編號, 'project_status' 專案狀態)
 String get category;/// 前台顯示的文字標籤 (例如 '雷霆-01')
 String get label;/// 後台或系統內部儲存的值 (例如 'thunder-01')
 String get value;/// 建立時間 (用於排序，保證最新建立在選單最前面)
 DateTime get createdAt;/// 排序權重 (可選手動排序)
 int get sortOrder;/// 是否啟用
 bool get isActive;
/// Create a copy of SystemDictionary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SystemDictionaryCopyWith<SystemDictionary> get copyWith => _$SystemDictionaryCopyWithImpl<SystemDictionary>(this as SystemDictionary, _$identity);

  /// Serializes this SystemDictionary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SystemDictionary&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.category, category) || other.category == category)&&(identical(other.label, label) || other.label == label)&&(identical(other.value, value) || other.value == value)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentId,category,label,value,createdAt,sortOrder,isActive);

@override
String toString() {
  return 'SystemDictionary(documentId: $documentId, category: $category, label: $label, value: $value, createdAt: $createdAt, sortOrder: $sortOrder, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class $SystemDictionaryCopyWith<$Res>  {
  factory $SystemDictionaryCopyWith(SystemDictionary value, $Res Function(SystemDictionary) _then) = _$SystemDictionaryCopyWithImpl;
@useResult
$Res call({
 String documentId, String category, String label, String value, DateTime createdAt, int sortOrder, bool isActive
});




}
/// @nodoc
class _$SystemDictionaryCopyWithImpl<$Res>
    implements $SystemDictionaryCopyWith<$Res> {
  _$SystemDictionaryCopyWithImpl(this._self, this._then);

  final SystemDictionary _self;
  final $Res Function(SystemDictionary) _then;

/// Create a copy of SystemDictionary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? documentId = null,Object? category = null,Object? label = null,Object? value = null,Object? createdAt = null,Object? sortOrder = null,Object? isActive = null,}) {
  return _then(_self.copyWith(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SystemDictionary].
extension SystemDictionaryPatterns on SystemDictionary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SystemDictionary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SystemDictionary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SystemDictionary value)  $default,){
final _that = this;
switch (_that) {
case _SystemDictionary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SystemDictionary value)?  $default,){
final _that = this;
switch (_that) {
case _SystemDictionary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String documentId,  String category,  String label,  String value,  DateTime createdAt,  int sortOrder,  bool isActive)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SystemDictionary() when $default != null:
return $default(_that.documentId,_that.category,_that.label,_that.value,_that.createdAt,_that.sortOrder,_that.isActive);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String documentId,  String category,  String label,  String value,  DateTime createdAt,  int sortOrder,  bool isActive)  $default,) {final _that = this;
switch (_that) {
case _SystemDictionary():
return $default(_that.documentId,_that.category,_that.label,_that.value,_that.createdAt,_that.sortOrder,_that.isActive);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String documentId,  String category,  String label,  String value,  DateTime createdAt,  int sortOrder,  bool isActive)?  $default,) {final _that = this;
switch (_that) {
case _SystemDictionary() when $default != null:
return $default(_that.documentId,_that.category,_that.label,_that.value,_that.createdAt,_that.sortOrder,_that.isActive);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SystemDictionary implements SystemDictionary {
  const _SystemDictionary({required this.documentId, required this.category, required this.label, required this.value, required this.createdAt, this.sortOrder = 0, this.isActive = true});
  factory _SystemDictionary.fromJson(Map<String, dynamic> json) => _$SystemDictionaryFromJson(json);

/// 文件 ID (如隨機產生的 UUID)
@override final  String documentId;
/// 字典類別 (例如 'tactical_name' 戰術編號, 'project_status' 專案狀態)
@override final  String category;
/// 前台顯示的文字標籤 (例如 '雷霆-01')
@override final  String label;
/// 後台或系統內部儲存的值 (例如 'thunder-01')
@override final  String value;
/// 建立時間 (用於排序，保證最新建立在選單最前面)
@override final  DateTime createdAt;
/// 排序權重 (可選手動排序)
@override@JsonKey() final  int sortOrder;
/// 是否啟用
@override@JsonKey() final  bool isActive;

/// Create a copy of SystemDictionary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SystemDictionaryCopyWith<_SystemDictionary> get copyWith => __$SystemDictionaryCopyWithImpl<_SystemDictionary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SystemDictionaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SystemDictionary&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.category, category) || other.category == category)&&(identical(other.label, label) || other.label == label)&&(identical(other.value, value) || other.value == value)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.sortOrder, sortOrder) || other.sortOrder == sortOrder)&&(identical(other.isActive, isActive) || other.isActive == isActive));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,documentId,category,label,value,createdAt,sortOrder,isActive);

@override
String toString() {
  return 'SystemDictionary(documentId: $documentId, category: $category, label: $label, value: $value, createdAt: $createdAt, sortOrder: $sortOrder, isActive: $isActive)';
}


}

/// @nodoc
abstract mixin class _$SystemDictionaryCopyWith<$Res> implements $SystemDictionaryCopyWith<$Res> {
  factory _$SystemDictionaryCopyWith(_SystemDictionary value, $Res Function(_SystemDictionary) _then) = __$SystemDictionaryCopyWithImpl;
@override @useResult
$Res call({
 String documentId, String category, String label, String value, DateTime createdAt, int sortOrder, bool isActive
});




}
/// @nodoc
class __$SystemDictionaryCopyWithImpl<$Res>
    implements _$SystemDictionaryCopyWith<$Res> {
  __$SystemDictionaryCopyWithImpl(this._self, this._then);

  final _SystemDictionary _self;
  final $Res Function(_SystemDictionary) _then;

/// Create a copy of SystemDictionary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? documentId = null,Object? category = null,Object? label = null,Object? value = null,Object? createdAt = null,Object? sortOrder = null,Object? isActive = null,}) {
  return _then(_SystemDictionary(
documentId: null == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,sortOrder: null == sortOrder ? _self.sortOrder : sortOrder // ignore: cast_nullable_to_non_nullable
as int,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
