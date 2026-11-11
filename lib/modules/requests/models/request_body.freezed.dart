// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_body.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RequestBody {

 BodyType get type; String get text; List<KeyValue> get fields;
/// Create a copy of RequestBody
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestBodyCopyWith<RequestBody> get copyWith => _$RequestBodyCopyWithImpl<RequestBody>(this as RequestBody, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RequestBody;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestBody&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.text, _this.text) || other.text == _this.text)&&const DeepCollectionEquality().equals(other.fields, _this.fields));
}


@override
int get hashCode {
  final _this = this as RequestBody;
  return Object.hash(runtimeType,_this.type,_this.text,const DeepCollectionEquality().hash(_this.fields));
}

@override
String toString() {
  final _this = this as RequestBody;
  return 'RequestBody(type: ${_this.type}, text: ${_this.text}, fields: ${_this.fields})';
}


}

/// @nodoc
abstract mixin class $RequestBodyCopyWith<$Res>  {
  factory $RequestBodyCopyWith(RequestBody value, $Res Function(RequestBody) _then) = _$RequestBodyCopyWithImpl;
@useResult
$Res call({
 BodyType type, String text, List<KeyValue> fields
});




}
/// @nodoc
class _$RequestBodyCopyWithImpl<$Res>
    implements $RequestBodyCopyWith<$Res> {
  _$RequestBodyCopyWithImpl(this._self, this._then);

  final RequestBody _self;
  final $Res Function(RequestBody) _then;

/// Create a copy of RequestBody
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? text = null,Object? fields = null,}) {
  return _then(RequestBody(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as BodyType,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,fields: null == fields ? _self.fields : fields // ignore: cast_nullable_to_non_nullable
as List<KeyValue>,
  ));
}

}


/// Adds pattern-matching-related methods to [RequestBody].
extension RequestBodyPatterns on RequestBody {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestBody value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestBody() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestBody value)  $default,){
final _that = this;
switch (_that) {
case _RequestBody():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestBody value)?  $default,){
final _that = this;
switch (_that) {
case _RequestBody() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( BodyType type,  String text,  List<KeyValue> fields)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequestBody() when $default != null:
return $default(_that.type,_that.text,_that.fields);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( BodyType type,  String text,  List<KeyValue> fields)  $default,) {final _that = this;
switch (_that) {
case _RequestBody():
return $default(_that.type,_that.text,_that.fields);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( BodyType type,  String text,  List<KeyValue> fields)?  $default,) {final _that = this;
switch (_that) {
case _RequestBody() when $default != null:
return $default(_that.type,_that.text,_that.fields);case _:
  return null;

}
}

}

/// @nodoc


class _RequestBody implements RequestBody {
  const _RequestBody({this.type = BodyType.none, this.text = '',  List<KeyValue> fields = const []}): _fields = fields;
  

@override@JsonKey() final  BodyType type;
@override@JsonKey() final  String text;
 final  List<KeyValue> _fields;
@override@JsonKey() List<KeyValue> get fields {
  if (_fields is EqualUnmodifiableListView) return _fields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fields);
}


/// Create a copy of RequestBody
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestBodyCopyWith<_RequestBody> get copyWith => __$RequestBodyCopyWithImpl<_RequestBody>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestBody&&(identical(other.type, type) || other.type == type)&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other.fields, _fields));
}


@override
int get hashCode {
    return Object.hash(runtimeType,type,text,const DeepCollectionEquality().hash(_fields));
}

@override
String toString() {
    return 'RequestBody(type: $type, text: $text, fields: $fields)';
}


}

/// @nodoc
abstract mixin class _$RequestBodyCopyWith<$Res> implements $RequestBodyCopyWith<$Res> {
  factory _$RequestBodyCopyWith(_RequestBody value, $Res Function(_RequestBody) _then) = __$RequestBodyCopyWithImpl;
@override @useResult
$Res call({
 BodyType type, String text, List<KeyValue> fields
});




}
/// @nodoc
class __$RequestBodyCopyWithImpl<$Res>
    implements _$RequestBodyCopyWith<$Res> {
  __$RequestBodyCopyWithImpl(this._self, this._then);

  final _RequestBody _self;
  final $Res Function(_RequestBody) _then;

/// Create a copy of RequestBody
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? text = null,Object? fields = null,}) {
  return _then(_RequestBody(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as BodyType,text: null == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String,fields: null == fields ? _self._fields : fields // ignore: cast_nullable_to_non_nullable
as List<KeyValue>,
  ));
}


}

// dart format on
