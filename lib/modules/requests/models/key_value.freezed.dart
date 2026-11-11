// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'key_value.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$KeyValue {

 String get key; String get value; bool get enabled;
/// Create a copy of KeyValue
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KeyValueCopyWith<KeyValue> get copyWith => _$KeyValueCopyWithImpl<KeyValue>(this as KeyValue, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as KeyValue;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KeyValue&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled));
}


@override
int get hashCode {
  final _this = this as KeyValue;
  return Object.hash(runtimeType,_this.key,_this.value,_this.enabled);
}

@override
String toString() {
  final _this = this as KeyValue;
  return 'KeyValue(key: ${_this.key}, value: ${_this.value}, enabled: ${_this.enabled})';
}


}

/// @nodoc
abstract mixin class $KeyValueCopyWith<$Res>  {
  factory $KeyValueCopyWith(KeyValue value, $Res Function(KeyValue) _then) = _$KeyValueCopyWithImpl;
@useResult
$Res call({
 String key, String value, bool enabled
});




}
/// @nodoc
class _$KeyValueCopyWithImpl<$Res>
    implements $KeyValueCopyWith<$Res> {
  _$KeyValueCopyWithImpl(this._self, this._then);

  final KeyValue _self;
  final $Res Function(KeyValue) _then;

/// Create a copy of KeyValue
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? value = null,Object? enabled = null,}) {
  return _then(KeyValue(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [KeyValue].
extension KeyValuePatterns on KeyValue {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KeyValue value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KeyValue() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KeyValue value)  $default,){
final _that = this;
switch (_that) {
case _KeyValue():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KeyValue value)?  $default,){
final _that = this;
switch (_that) {
case _KeyValue() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String value,  bool enabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KeyValue() when $default != null:
return $default(_that.key,_that.value,_that.enabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String value,  bool enabled)  $default,) {final _that = this;
switch (_that) {
case _KeyValue():
return $default(_that.key,_that.value,_that.enabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String value,  bool enabled)?  $default,) {final _that = this;
switch (_that) {
case _KeyValue() when $default != null:
return $default(_that.key,_that.value,_that.enabled);case _:
  return null;

}
}

}

/// @nodoc


class _KeyValue implements KeyValue {
  const _KeyValue({this.key = '', this.value = '', this.enabled = true});
  

@override@JsonKey() final  String key;
@override@JsonKey() final  String value;
@override@JsonKey() final  bool enabled;

/// Create a copy of KeyValue
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KeyValueCopyWith<_KeyValue> get copyWith => __$KeyValueCopyWithImpl<_KeyValue>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _KeyValue&&(identical(other.key, key) || other.key == key)&&(identical(other.value, value) || other.value == value)&&(identical(other.enabled, enabled) || other.enabled == enabled));
}


@override
int get hashCode {
    return Object.hash(runtimeType,key,value,enabled);
}

@override
String toString() {
    return 'KeyValue(key: $key, value: $value, enabled: $enabled)';
}


}

/// @nodoc
abstract mixin class _$KeyValueCopyWith<$Res> implements $KeyValueCopyWith<$Res> {
  factory _$KeyValueCopyWith(_KeyValue value, $Res Function(_KeyValue) _then) = __$KeyValueCopyWithImpl;
@override @useResult
$Res call({
 String key, String value, bool enabled
});




}
/// @nodoc
class __$KeyValueCopyWithImpl<$Res>
    implements _$KeyValueCopyWith<$Res> {
  __$KeyValueCopyWithImpl(this._self, this._then);

  final _KeyValue _self;
  final $Res Function(_KeyValue) _then;

/// Create a copy of KeyValue
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? value = null,Object? enabled = null,}) {
  return _then(_KeyValue(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
