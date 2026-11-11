// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'http_request_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HttpRequestDraft {

 HttpMethod get method; String get url; List<KeyValue> get params; List<KeyValue> get headers; RequestAuth get auth; RequestBody get body;
/// Create a copy of HttpRequestDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HttpRequestDraftCopyWith<HttpRequestDraft> get copyWith => _$HttpRequestDraftCopyWithImpl<HttpRequestDraft>(this as HttpRequestDraft, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as HttpRequestDraft;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HttpRequestDraft&&(identical(other.method, _this.method) || other.method == _this.method)&&(identical(other.url, _this.url) || other.url == _this.url)&&const DeepCollectionEquality().equals(other.params, _this.params)&&const DeepCollectionEquality().equals(other.headers, _this.headers)&&(identical(other.auth, _this.auth) || other.auth == _this.auth)&&(identical(other.body, _this.body) || other.body == _this.body));
}


@override
int get hashCode {
  final _this = this as HttpRequestDraft;
  return Object.hash(runtimeType,_this.method,_this.url,const DeepCollectionEquality().hash(_this.params),const DeepCollectionEquality().hash(_this.headers),_this.auth,_this.body);
}

@override
String toString() {
  final _this = this as HttpRequestDraft;
  return 'HttpRequestDraft(method: ${_this.method}, url: ${_this.url}, params: ${_this.params}, headers: ${_this.headers}, auth: ${_this.auth}, body: ${_this.body})';
}


}

/// @nodoc
abstract mixin class $HttpRequestDraftCopyWith<$Res>  {
  factory $HttpRequestDraftCopyWith(HttpRequestDraft value, $Res Function(HttpRequestDraft) _then) = _$HttpRequestDraftCopyWithImpl;
@useResult
$Res call({
 HttpMethod method, String url, List<KeyValue> params, List<KeyValue> headers, RequestAuth auth, RequestBody body
});


$RequestAuthCopyWith<$Res> get auth;$RequestBodyCopyWith<$Res> get body;

}
/// @nodoc
class _$HttpRequestDraftCopyWithImpl<$Res>
    implements $HttpRequestDraftCopyWith<$Res> {
  _$HttpRequestDraftCopyWithImpl(this._self, this._then);

  final HttpRequestDraft _self;
  final $Res Function(HttpRequestDraft) _then;

/// Create a copy of HttpRequestDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? method = null,Object? url = null,Object? params = null,Object? headers = null,Object? auth = null,Object? body = null,}) {
  return _then(HttpRequestDraft(
method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as HttpMethod,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,params: null == params ? _self.params : params // ignore: cast_nullable_to_non_nullable
as List<KeyValue>,headers: null == headers ? _self.headers : headers // ignore: cast_nullable_to_non_nullable
as List<KeyValue>,auth: null == auth ? _self.auth : auth // ignore: cast_nullable_to_non_nullable
as RequestAuth,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as RequestBody,
  ));
}
/// Create a copy of HttpRequestDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RequestAuthCopyWith<$Res> get auth {
  
  return $RequestAuthCopyWith<$Res>(_self.auth, (value) {
    return _then(_self.copyWith(auth: value));
  });
}/// Create a copy of HttpRequestDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RequestBodyCopyWith<$Res> get body {
  
  return $RequestBodyCopyWith<$Res>(_self.body, (value) {
    return _then(_self.copyWith(body: value));
  });
}
}


/// Adds pattern-matching-related methods to [HttpRequestDraft].
extension HttpRequestDraftPatterns on HttpRequestDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HttpRequestDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HttpRequestDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HttpRequestDraft value)  $default,){
final _that = this;
switch (_that) {
case _HttpRequestDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HttpRequestDraft value)?  $default,){
final _that = this;
switch (_that) {
case _HttpRequestDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HttpMethod method,  String url,  List<KeyValue> params,  List<KeyValue> headers,  RequestAuth auth,  RequestBody body)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HttpRequestDraft() when $default != null:
return $default(_that.method,_that.url,_that.params,_that.headers,_that.auth,_that.body);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HttpMethod method,  String url,  List<KeyValue> params,  List<KeyValue> headers,  RequestAuth auth,  RequestBody body)  $default,) {final _that = this;
switch (_that) {
case _HttpRequestDraft():
return $default(_that.method,_that.url,_that.params,_that.headers,_that.auth,_that.body);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HttpMethod method,  String url,  List<KeyValue> params,  List<KeyValue> headers,  RequestAuth auth,  RequestBody body)?  $default,) {final _that = this;
switch (_that) {
case _HttpRequestDraft() when $default != null:
return $default(_that.method,_that.url,_that.params,_that.headers,_that.auth,_that.body);case _:
  return null;

}
}

}

/// @nodoc


class _HttpRequestDraft implements HttpRequestDraft {
  const _HttpRequestDraft({this.method = HttpMethod.get, this.url = '',  List<KeyValue> params = const [],  List<KeyValue> headers = const [], this.auth = const RequestAuth.none(), this.body = const RequestBody()}): _params = params,_headers = headers;
  

@override@JsonKey() final  HttpMethod method;
@override@JsonKey() final  String url;
 final  List<KeyValue> _params;
@override@JsonKey() List<KeyValue> get params {
  if (_params is EqualUnmodifiableListView) return _params;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_params);
}

 final  List<KeyValue> _headers;
@override@JsonKey() List<KeyValue> get headers {
  if (_headers is EqualUnmodifiableListView) return _headers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_headers);
}

@override@JsonKey() final  RequestAuth auth;
@override@JsonKey() final  RequestBody body;

/// Create a copy of HttpRequestDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HttpRequestDraftCopyWith<_HttpRequestDraft> get copyWith => __$HttpRequestDraftCopyWithImpl<_HttpRequestDraft>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _HttpRequestDraft&&(identical(other.method, method) || other.method == method)&&(identical(other.url, url) || other.url == url)&&const DeepCollectionEquality().equals(other.params, _params)&&const DeepCollectionEquality().equals(other.headers, _headers)&&(identical(other.auth, auth) || other.auth == auth)&&(identical(other.body, body) || other.body == body));
}


@override
int get hashCode {
    return Object.hash(runtimeType,method,url,const DeepCollectionEquality().hash(_params),const DeepCollectionEquality().hash(_headers),auth,body);
}

@override
String toString() {
    return 'HttpRequestDraft(method: $method, url: $url, params: $params, headers: $headers, auth: $auth, body: $body)';
}


}

/// @nodoc
abstract mixin class _$HttpRequestDraftCopyWith<$Res> implements $HttpRequestDraftCopyWith<$Res> {
  factory _$HttpRequestDraftCopyWith(_HttpRequestDraft value, $Res Function(_HttpRequestDraft) _then) = __$HttpRequestDraftCopyWithImpl;
@override @useResult
$Res call({
 HttpMethod method, String url, List<KeyValue> params, List<KeyValue> headers, RequestAuth auth, RequestBody body
});


@override $RequestAuthCopyWith<$Res> get auth;@override $RequestBodyCopyWith<$Res> get body;

}
/// @nodoc
class __$HttpRequestDraftCopyWithImpl<$Res>
    implements _$HttpRequestDraftCopyWith<$Res> {
  __$HttpRequestDraftCopyWithImpl(this._self, this._then);

  final _HttpRequestDraft _self;
  final $Res Function(_HttpRequestDraft) _then;

/// Create a copy of HttpRequestDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? method = null,Object? url = null,Object? params = null,Object? headers = null,Object? auth = null,Object? body = null,}) {
  return _then(_HttpRequestDraft(
method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as HttpMethod,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,params: null == params ? _self._params : params // ignore: cast_nullable_to_non_nullable
as List<KeyValue>,headers: null == headers ? _self._headers : headers // ignore: cast_nullable_to_non_nullable
as List<KeyValue>,auth: null == auth ? _self.auth : auth // ignore: cast_nullable_to_non_nullable
as RequestAuth,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as RequestBody,
  ));
}

/// Create a copy of HttpRequestDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RequestAuthCopyWith<$Res> get auth {
  
  return $RequestAuthCopyWith<$Res>(_self.auth, (value) {
    return _then(_self.copyWith(auth: value));
  });
}/// Create a copy of HttpRequestDraft
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RequestBodyCopyWith<$Res> get body {
  
  return $RequestBodyCopyWith<$Res>(_self.body, (value) {
    return _then(_self.copyWith(body: value));
  });
}
}

// dart format on
