// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prepared_request.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PreparedRequest {

 String get method; Uri get url; Map<String, String> get headers; String? get body; Map<String, String>? get multipartFields;
/// Create a copy of PreparedRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PreparedRequestCopyWith<PreparedRequest> get copyWith => _$PreparedRequestCopyWithImpl<PreparedRequest>(this as PreparedRequest, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PreparedRequest;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PreparedRequest&&(identical(other.method, _this.method) || other.method == _this.method)&&(identical(other.url, _this.url) || other.url == _this.url)&&const DeepCollectionEquality().equals(other.headers, _this.headers)&&(identical(other.body, _this.body) || other.body == _this.body)&&const DeepCollectionEquality().equals(other.multipartFields, _this.multipartFields));
}


@override
int get hashCode {
  final _this = this as PreparedRequest;
  return Object.hash(runtimeType,_this.method,_this.url,const DeepCollectionEquality().hash(_this.headers),_this.body,const DeepCollectionEquality().hash(_this.multipartFields));
}

@override
String toString() {
  final _this = this as PreparedRequest;
  return 'PreparedRequest(method: ${_this.method}, url: ${_this.url}, headers: ${_this.headers}, body: ${_this.body}, multipartFields: ${_this.multipartFields})';
}


}

/// @nodoc
abstract mixin class $PreparedRequestCopyWith<$Res>  {
  factory $PreparedRequestCopyWith(PreparedRequest value, $Res Function(PreparedRequest) _then) = _$PreparedRequestCopyWithImpl;
@useResult
$Res call({
 String method, Uri url, Map<String, String> headers, String? body, Map<String, String>? multipartFields
});




}
/// @nodoc
class _$PreparedRequestCopyWithImpl<$Res>
    implements $PreparedRequestCopyWith<$Res> {
  _$PreparedRequestCopyWithImpl(this._self, this._then);

  final PreparedRequest _self;
  final $Res Function(PreparedRequest) _then;

/// Create a copy of PreparedRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? method = null,Object? url = null,Object? headers = null,Object? body = freezed,Object? multipartFields = freezed,}) {
  return _then(PreparedRequest(
method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as Uri,headers: null == headers ? _self.headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,multipartFields: freezed == multipartFields ? _self.multipartFields : multipartFields // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [PreparedRequest].
extension PreparedRequestPatterns on PreparedRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PreparedRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PreparedRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PreparedRequest value)  $default,){
final _that = this;
switch (_that) {
case _PreparedRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PreparedRequest value)?  $default,){
final _that = this;
switch (_that) {
case _PreparedRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String method,  Uri url,  Map<String, String> headers,  String? body,  Map<String, String>? multipartFields)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PreparedRequest() when $default != null:
return $default(_that.method,_that.url,_that.headers,_that.body,_that.multipartFields);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String method,  Uri url,  Map<String, String> headers,  String? body,  Map<String, String>? multipartFields)  $default,) {final _that = this;
switch (_that) {
case _PreparedRequest():
return $default(_that.method,_that.url,_that.headers,_that.body,_that.multipartFields);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String method,  Uri url,  Map<String, String> headers,  String? body,  Map<String, String>? multipartFields)?  $default,) {final _that = this;
switch (_that) {
case _PreparedRequest() when $default != null:
return $default(_that.method,_that.url,_that.headers,_that.body,_that.multipartFields);case _:
  return null;

}
}

}

/// @nodoc


class _PreparedRequest implements PreparedRequest {
  const _PreparedRequest({required this.method, required this.url,  Map<String, String> headers = const {}, this.body,  Map<String, String>? multipartFields}): _headers = headers,_multipartFields = multipartFields;
  

@override final  String method;
@override final  Uri url;
 final  Map<String, String> _headers;
@override@JsonKey() Map<String, String> get headers {
  if (_headers is EqualUnmodifiableMapView) return _headers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_headers);
}

@override final  String? body;
 final  Map<String, String>? _multipartFields;
@override Map<String, String>? get multipartFields {
  final value = _multipartFields;
  if (value == null) return null;
  if (_multipartFields is EqualUnmodifiableMapView) return _multipartFields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of PreparedRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PreparedRequestCopyWith<_PreparedRequest> get copyWith => __$PreparedRequestCopyWithImpl<_PreparedRequest>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PreparedRequest&&(identical(other.method, method) || other.method == method)&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other.headers, _headers)&&(identical(other.body, body) || other.body == body)&&const DeepCollectionEquality().equals(other.multipartFields, _multipartFields));
}


@override
int get hashCode {
    return Object.hash(runtimeType,method,url,const DeepCollectionEquality().hash(_headers),body,const DeepCollectionEquality().hash(_multipartFields));
}

@override
String toString() {
    return 'PreparedRequest(method: $method, url: $url, headers: $headers, body: $body, multipartFields: $multipartFields)';
}


}

/// @nodoc
abstract mixin class _$PreparedRequestCopyWith<$Res> implements $PreparedRequestCopyWith<$Res> {
  factory _$PreparedRequestCopyWith(_PreparedRequest value, $Res Function(_PreparedRequest) _then) = __$PreparedRequestCopyWithImpl;
@override @useResult
$Res call({
 String method, Uri url, Map<String, String> headers, String? body, Map<String, String>? multipartFields
});




}
/// @nodoc
class __$PreparedRequestCopyWithImpl<$Res>
    implements _$PreparedRequestCopyWith<$Res> {
  __$PreparedRequestCopyWithImpl(this._self, this._then);

  final _PreparedRequest _self;
  final $Res Function(_PreparedRequest) _then;

/// Create a copy of PreparedRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? method = null,Object? url = null,Object? headers = null,Object? body = freezed,Object? multipartFields = freezed,}) {
  return _then(_PreparedRequest(
method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as Uri,headers: null == headers ? _self._headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, String>,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,multipartFields: freezed == multipartFields ? _self._multipartFields : multipartFields // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,
  ));
}


}

// dart format on
