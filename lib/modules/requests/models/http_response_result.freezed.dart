// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'http_response_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HttpResponseResult {

 int get statusCode; Map<String, List<String>> get headers; String get body; Duration get duration; int get sizeBytes; String? get reason;/// Indented JSON, set when the body is valid JSON.
 String? get prettyBody;
/// Create a copy of HttpResponseResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HttpResponseResultCopyWith<HttpResponseResult> get copyWith => _$HttpResponseResultCopyWithImpl<HttpResponseResult>(this as HttpResponseResult, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HttpResponseResult;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HttpResponseResult&&(identical(other.statusCode, _this.statusCode) || other.statusCode == _this.statusCode)&&const DeepCollectionEquality().equals(other.headers, _this.headers)&&(identical(other.body, _this.body) || other.body == _this.body)&&(identical(other.duration, _this.duration) || other.duration == _this.duration)&&(identical(other.sizeBytes, _this.sizeBytes) || other.sizeBytes == _this.sizeBytes)&&(identical(other.reason, _this.reason) || other.reason == _this.reason)&&(identical(other.prettyBody, _this.prettyBody) || other.prettyBody == _this.prettyBody));
}


@override
int get hashCode {
  final _this = this as HttpResponseResult;
  return Object.hash(runtimeType,_this.statusCode,const DeepCollectionEquality().hash(_this.headers),_this.body,_this.duration,_this.sizeBytes,_this.reason,_this.prettyBody);
}

@override
String toString() {
  final _this = this as HttpResponseResult;
  return 'HttpResponseResult(statusCode: ${_this.statusCode}, headers: ${_this.headers}, body: ${_this.body}, duration: ${_this.duration}, sizeBytes: ${_this.sizeBytes}, reason: ${_this.reason}, prettyBody: ${_this.prettyBody})';
}


}

/// @nodoc
abstract mixin class $HttpResponseResultCopyWith<$Res>  {
  factory $HttpResponseResultCopyWith(HttpResponseResult value, $Res Function(HttpResponseResult) _then) = _$HttpResponseResultCopyWithImpl;
@useResult
$Res call({
 int statusCode, Map<String, List<String>> headers, String body, Duration duration, int sizeBytes, String? reason, String? prettyBody
});




}
/// @nodoc
class _$HttpResponseResultCopyWithImpl<$Res>
    implements $HttpResponseResultCopyWith<$Res> {
  _$HttpResponseResultCopyWithImpl(this._self, this._then);

  final HttpResponseResult _self;
  final $Res Function(HttpResponseResult) _then;

/// Create a copy of HttpResponseResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? statusCode = null,Object? headers = null,Object? body = null,Object? duration = null,Object? sizeBytes = null,Object? reason = freezed,Object? prettyBody = freezed,}) {
  return _then(HttpResponseResult(
statusCode: null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,headers: null == headers ? _self.headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,prettyBody: freezed == prettyBody ? _self.prettyBody : prettyBody // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [HttpResponseResult].
extension HttpResponseResultPatterns on HttpResponseResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HttpResponseResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HttpResponseResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HttpResponseResult value)  $default,){
final _that = this;
switch (_that) {
case _HttpResponseResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HttpResponseResult value)?  $default,){
final _that = this;
switch (_that) {
case _HttpResponseResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int statusCode,  Map<String, List<String>> headers,  String body,  Duration duration,  int sizeBytes,  String? reason,  String? prettyBody)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HttpResponseResult() when $default != null:
return $default(_that.statusCode,_that.headers,_that.body,_that.duration,_that.sizeBytes,_that.reason,_that.prettyBody);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int statusCode,  Map<String, List<String>> headers,  String body,  Duration duration,  int sizeBytes,  String? reason,  String? prettyBody)  $default,) {final _that = this;
switch (_that) {
case _HttpResponseResult():
return $default(_that.statusCode,_that.headers,_that.body,_that.duration,_that.sizeBytes,_that.reason,_that.prettyBody);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int statusCode,  Map<String, List<String>> headers,  String body,  Duration duration,  int sizeBytes,  String? reason,  String? prettyBody)?  $default,) {final _that = this;
switch (_that) {
case _HttpResponseResult() when $default != null:
return $default(_that.statusCode,_that.headers,_that.body,_that.duration,_that.sizeBytes,_that.reason,_that.prettyBody);case _:
  return null;

}
}

}

/// @nodoc


class _HttpResponseResult implements HttpResponseResult {
  const _HttpResponseResult({required this.statusCode, required  Map<String, List<String>> headers, required this.body, required this.duration, required this.sizeBytes, this.reason, this.prettyBody}): _headers = headers;
  

@override final  int statusCode;
 final  Map<String, List<String>> _headers;
@override Map<String, List<String>> get headers {
  if (_headers is EqualUnmodifiableMapView) return _headers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_headers);
}

@override final  String body;
@override final  Duration duration;
@override final  int sizeBytes;
@override final  String? reason;
/// Indented JSON, set when the body is valid JSON.
@override final  String? prettyBody;

/// Create a copy of HttpResponseResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HttpResponseResultCopyWith<_HttpResponseResult> get copyWith => __$HttpResponseResultCopyWithImpl<_HttpResponseResult>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HttpResponseResult&&(identical(other.statusCode, statusCode) || other.statusCode == statusCode)&&const DeepCollectionEquality().equals(other.headers, _headers)&&(identical(other.body, body) || other.body == body)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.sizeBytes, sizeBytes) || other.sizeBytes == sizeBytes)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.prettyBody, prettyBody) || other.prettyBody == prettyBody));
}


@override
int get hashCode {
    return Object.hash(runtimeType,statusCode,const DeepCollectionEquality().hash(_headers),body,duration,sizeBytes,reason,prettyBody);
}

@override
String toString() {
    return 'HttpResponseResult(statusCode: $statusCode, headers: $headers, body: $body, duration: $duration, sizeBytes: $sizeBytes, reason: $reason, prettyBody: $prettyBody)';
}


}

/// @nodoc
abstract mixin class _$HttpResponseResultCopyWith<$Res> implements $HttpResponseResultCopyWith<$Res> {
  factory _$HttpResponseResultCopyWith(_HttpResponseResult value, $Res Function(_HttpResponseResult) _then) = __$HttpResponseResultCopyWithImpl;
@override @useResult
$Res call({
 int statusCode, Map<String, List<String>> headers, String body, Duration duration, int sizeBytes, String? reason, String? prettyBody
});




}
/// @nodoc
class __$HttpResponseResultCopyWithImpl<$Res>
    implements _$HttpResponseResultCopyWith<$Res> {
  __$HttpResponseResultCopyWithImpl(this._self, this._then);

  final _HttpResponseResult _self;
  final $Res Function(_HttpResponseResult) _then;

/// Create a copy of HttpResponseResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? statusCode = null,Object? headers = null,Object? body = null,Object? duration = null,Object? sizeBytes = null,Object? reason = freezed,Object? prettyBody = freezed,}) {
  return _then(_HttpResponseResult(
statusCode: null == statusCode ? _self.statusCode : statusCode // ignore: cast_nullable_to_non_nullable
as int,headers: null == headers ? _self._headers : headers // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,sizeBytes: null == sizeBytes ? _self.sizeBytes : sizeBytes // ignore: cast_nullable_to_non_nullable
as int,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,prettyBody: freezed == prettyBody ? _self.prettyBody : prettyBody // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
