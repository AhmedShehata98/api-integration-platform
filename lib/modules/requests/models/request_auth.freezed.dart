// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_auth.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RequestAuth {





@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestAuth);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'RequestAuth()';
}


}

/// @nodoc
class $RequestAuthCopyWith<$Res>  {
$RequestAuthCopyWith(RequestAuth _, $Res Function(RequestAuth) __);
}


/// Adds pattern-matching-related methods to [RequestAuth].
extension RequestAuthPatterns on RequestAuth {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( NoAuth value)?  none,TResult Function( BearerAuth value)?  bearer,TResult Function( BasicAuth value)?  basic,TResult Function( ApiKeyAuth value)?  apiKey,required TResult orElse(),}){
final _that = this;
switch (_that) {
case NoAuth() when none != null:
return none(_that);case BearerAuth() when bearer != null:
return bearer(_that);case BasicAuth() when basic != null:
return basic(_that);case ApiKeyAuth() when apiKey != null:
return apiKey(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( NoAuth value)  none,required TResult Function( BearerAuth value)  bearer,required TResult Function( BasicAuth value)  basic,required TResult Function( ApiKeyAuth value)  apiKey,}){
final _that = this;
switch (_that) {
case NoAuth():
return none(_that);case BearerAuth():
return bearer(_that);case BasicAuth():
return basic(_that);case ApiKeyAuth():
return apiKey(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( NoAuth value)?  none,TResult? Function( BearerAuth value)?  bearer,TResult? Function( BasicAuth value)?  basic,TResult? Function( ApiKeyAuth value)?  apiKey,}){
final _that = this;
switch (_that) {
case NoAuth() when none != null:
return none(_that);case BearerAuth() when bearer != null:
return bearer(_that);case BasicAuth() when basic != null:
return basic(_that);case ApiKeyAuth() when apiKey != null:
return apiKey(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  none,TResult Function( String token)?  bearer,TResult Function( String username,  String password)?  basic,TResult Function( String name,  String value,  ApiKeyLocation location)?  apiKey,required TResult orElse(),}) {final _that = this;
switch (_that) {
case NoAuth() when none != null:
return none();case BearerAuth() when bearer != null:
return bearer(_that.token);case BasicAuth() when basic != null:
return basic(_that.username,_that.password);case ApiKeyAuth() when apiKey != null:
return apiKey(_that.name,_that.value,_that.location);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  none,required TResult Function( String token)  bearer,required TResult Function( String username,  String password)  basic,required TResult Function( String name,  String value,  ApiKeyLocation location)  apiKey,}) {final _that = this;
switch (_that) {
case NoAuth():
return none();case BearerAuth():
return bearer(_that.token);case BasicAuth():
return basic(_that.username,_that.password);case ApiKeyAuth():
return apiKey(_that.name,_that.value,_that.location);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  none,TResult? Function( String token)?  bearer,TResult? Function( String username,  String password)?  basic,TResult? Function( String name,  String value,  ApiKeyLocation location)?  apiKey,}) {final _that = this;
switch (_that) {
case NoAuth() when none != null:
return none();case BearerAuth() when bearer != null:
return bearer(_that.token);case BasicAuth() when basic != null:
return basic(_that.username,_that.password);case ApiKeyAuth() when apiKey != null:
return apiKey(_that.name,_that.value,_that.location);case _:
  return null;

}
}

}

/// @nodoc


class NoAuth implements RequestAuth {
  const NoAuth();
  






@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is NoAuth);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
    return 'RequestAuth.none()';
}


}




/// @nodoc


class BearerAuth implements RequestAuth {
  const BearerAuth({this.token = ''});
  

@JsonKey() final  String token;

/// Create a copy of RequestAuth
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BearerAuthCopyWith<BearerAuth> get copyWith => _$BearerAuthCopyWithImpl<BearerAuth>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is BearerAuth&&(identical(other.token, token) || other.token == token));
}


@override
int get hashCode {
    return Object.hash(runtimeType,token);
}

@override
String toString() {
    return 'RequestAuth.bearer(token: $token)';
}


}

/// @nodoc
abstract mixin class $BearerAuthCopyWith<$Res> implements $RequestAuthCopyWith<$Res> {
  factory $BearerAuthCopyWith(BearerAuth value, $Res Function(BearerAuth) _then) = _$BearerAuthCopyWithImpl;
@useResult
$Res call({
 String token
});




}
/// @nodoc
class _$BearerAuthCopyWithImpl<$Res>
    implements $BearerAuthCopyWith<$Res> {
  _$BearerAuthCopyWithImpl(this._self, this._then);

  final BearerAuth _self;
  final $Res Function(BearerAuth) _then;

/// Create a copy of RequestAuth
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? token = null,}) {
  return _then(BearerAuth(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class BasicAuth implements RequestAuth {
  const BasicAuth({this.username = '', this.password = ''});
  

@JsonKey() final  String username;
@JsonKey() final  String password;

/// Create a copy of RequestAuth
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BasicAuthCopyWith<BasicAuth> get copyWith => _$BasicAuthCopyWithImpl<BasicAuth>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is BasicAuth&&(identical(other.username, username) || other.username == username)&&(identical(other.password, password) || other.password == password));
}


@override
int get hashCode {
    return Object.hash(runtimeType,username,password);
}

@override
String toString() {
    return 'RequestAuth.basic(username: $username, password: $password)';
}


}

/// @nodoc
abstract mixin class $BasicAuthCopyWith<$Res> implements $RequestAuthCopyWith<$Res> {
  factory $BasicAuthCopyWith(BasicAuth value, $Res Function(BasicAuth) _then) = _$BasicAuthCopyWithImpl;
@useResult
$Res call({
 String username, String password
});




}
/// @nodoc
class _$BasicAuthCopyWithImpl<$Res>
    implements $BasicAuthCopyWith<$Res> {
  _$BasicAuthCopyWithImpl(this._self, this._then);

  final BasicAuth _self;
  final $Res Function(BasicAuth) _then;

/// Create a copy of RequestAuth
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? username = null,Object? password = null,}) {
  return _then(BasicAuth(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ApiKeyAuth implements RequestAuth {
  const ApiKeyAuth({this.name = '', this.value = '', this.location = ApiKeyLocation.header});
  

@JsonKey() final  String name;
@JsonKey() final  String value;
@JsonKey() final  ApiKeyLocation location;

/// Create a copy of RequestAuth
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiKeyAuthCopyWith<ApiKeyAuth> get copyWith => _$ApiKeyAuthCopyWithImpl<ApiKeyAuth>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiKeyAuth&&(identical(other.name, name) || other.name == name)&&(identical(other.value, value) || other.value == value)&&(identical(other.location, location) || other.location == location));
}


@override
int get hashCode {
    return Object.hash(runtimeType,name,value,location);
}

@override
String toString() {
    return 'RequestAuth.apiKey(name: $name, value: $value, location: $location)';
}


}

/// @nodoc
abstract mixin class $ApiKeyAuthCopyWith<$Res> implements $RequestAuthCopyWith<$Res> {
  factory $ApiKeyAuthCopyWith(ApiKeyAuth value, $Res Function(ApiKeyAuth) _then) = _$ApiKeyAuthCopyWithImpl;
@useResult
$Res call({
 String name, String value, ApiKeyLocation location
});




}
/// @nodoc
class _$ApiKeyAuthCopyWithImpl<$Res>
    implements $ApiKeyAuthCopyWith<$Res> {
  _$ApiKeyAuthCopyWithImpl(this._self, this._then);

  final ApiKeyAuth _self;
  final $Res Function(ApiKeyAuth) _then;

/// Create a copy of RequestAuth
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? name = null,Object? value = null,Object? location = null,}) {
  return _then(ApiKeyAuth(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as ApiKeyLocation,
  ));
}


}

// dart format on
