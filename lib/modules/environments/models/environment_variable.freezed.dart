// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'environment_variable.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EnvironmentVariable {

 String get key; String get value; bool get secret; bool get enabled;
/// Create a copy of EnvironmentVariable
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EnvironmentVariableCopyWith<EnvironmentVariable> get copyWith => _$EnvironmentVariableCopyWithImpl<EnvironmentVariable>(this as EnvironmentVariable, _$identity);

  /// Serializes this EnvironmentVariable to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as EnvironmentVariable;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EnvironmentVariable&&(identical(other.key, _this.key) || other.key == _this.key)&&(identical(other.value, _this.value) || other.value == _this.value)&&(identical(other.secret, _this.secret) || other.secret == _this.secret)&&(identical(other.enabled, _this.enabled) || other.enabled == _this.enabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as EnvironmentVariable;
  return Object.hash(runtimeType,_this.key,_this.value,_this.secret,_this.enabled);
}

@override
String toString() {
  final _this = this as EnvironmentVariable;
  return 'EnvironmentVariable(key: ${_this.key}, value: ${_this.value}, secret: ${_this.secret}, enabled: ${_this.enabled})';
}


}

/// @nodoc
abstract mixin class $EnvironmentVariableCopyWith<$Res>  {
  factory $EnvironmentVariableCopyWith(EnvironmentVariable value, $Res Function(EnvironmentVariable) _then) = _$EnvironmentVariableCopyWithImpl;
@useResult
$Res call({
 String key, String value, bool secret, bool enabled
});




}
/// @nodoc
class _$EnvironmentVariableCopyWithImpl<$Res>
    implements $EnvironmentVariableCopyWith<$Res> {
  _$EnvironmentVariableCopyWithImpl(this._self, this._then);

  final EnvironmentVariable _self;
  final $Res Function(EnvironmentVariable) _then;

/// Create a copy of EnvironmentVariable
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? value = null,Object? secret = null,Object? enabled = null,}) {
  return _then(EnvironmentVariable(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,secret: null == secret ? _self.secret : secret // ignore: cast_nullable_to_non_nullable
as bool,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [EnvironmentVariable].
extension EnvironmentVariablePatterns on EnvironmentVariable {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EnvironmentVariable value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EnvironmentVariable() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EnvironmentVariable value)  $default,){
final _that = this;
switch (_that) {
case _EnvironmentVariable():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EnvironmentVariable value)?  $default,){
final _that = this;
switch (_that) {
case _EnvironmentVariable() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String value,  bool secret,  bool enabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EnvironmentVariable() when $default != null:
return $default(_that.key,_that.value,_that.secret,_that.enabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String value,  bool secret,  bool enabled)  $default,) {final _that = this;
switch (_that) {
case _EnvironmentVariable():
return $default(_that.key,_that.value,_that.secret,_that.enabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String value,  bool secret,  bool enabled)?  $default,) {final _that = this;
switch (_that) {
case _EnvironmentVariable() when $default != null:
return $default(_that.key,_that.value,_that.secret,_that.enabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EnvironmentVariable implements EnvironmentVariable {
  const _EnvironmentVariable({this.key = '', this.value = '', this.secret = false, this.enabled = true});
  factory _EnvironmentVariable.fromJson(Map<String, dynamic> json) => _$EnvironmentVariableFromJson(json);

@override@JsonKey() final  String key;
@override@JsonKey() final  String value;
@override@JsonKey() final  bool secret;
@override@JsonKey() final  bool enabled;

/// Create a copy of EnvironmentVariable
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EnvironmentVariableCopyWith<_EnvironmentVariable> get copyWith => __$EnvironmentVariableCopyWithImpl<_EnvironmentVariable>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EnvironmentVariableToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _EnvironmentVariable&&(identical(other.key, key) || other.key == key)&&(identical(other.value, value) || other.value == value)&&(identical(other.secret, secret) || other.secret == secret)&&(identical(other.enabled, enabled) || other.enabled == enabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,key,value,secret,enabled);
}

@override
String toString() {
    return 'EnvironmentVariable(key: $key, value: $value, secret: $secret, enabled: $enabled)';
}


}

/// @nodoc
abstract mixin class _$EnvironmentVariableCopyWith<$Res> implements $EnvironmentVariableCopyWith<$Res> {
  factory _$EnvironmentVariableCopyWith(_EnvironmentVariable value, $Res Function(_EnvironmentVariable) _then) = __$EnvironmentVariableCopyWithImpl;
@override @useResult
$Res call({
 String key, String value, bool secret, bool enabled
});




}
/// @nodoc
class __$EnvironmentVariableCopyWithImpl<$Res>
    implements _$EnvironmentVariableCopyWith<$Res> {
  __$EnvironmentVariableCopyWithImpl(this._self, this._then);

  final _EnvironmentVariable _self;
  final $Res Function(_EnvironmentVariable) _then;

/// Create a copy of EnvironmentVariable
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? value = null,Object? secret = null,Object? enabled = null,}) {
  return _then(_EnvironmentVariable(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,secret: null == secret ? _self.secret : secret // ignore: cast_nullable_to_non_nullable
as bool,enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
