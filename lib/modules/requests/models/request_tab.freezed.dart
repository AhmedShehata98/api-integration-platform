// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'request_tab.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RequestTab {

 String get id; String get name; HttpRequestDraft get draft;/// What is stored in the database; null while the tab was never saved.
 HttpRequestDraft? get savedDraft; String? get savedRequestId;/// Collection the request is saved in, or the one a new request is meant for.
 String? get collectionId; SendState get sendState;
/// Create a copy of RequestTab
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestTabCopyWith<RequestTab> get copyWith => _$RequestTabCopyWithImpl<RequestTab>(this as RequestTab, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RequestTab;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestTab&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.draft, _this.draft) || other.draft == _this.draft)&&(identical(other.savedDraft, _this.savedDraft) || other.savedDraft == _this.savedDraft)&&(identical(other.savedRequestId, _this.savedRequestId) || other.savedRequestId == _this.savedRequestId)&&(identical(other.collectionId, _this.collectionId) || other.collectionId == _this.collectionId)&&(identical(other.sendState, _this.sendState) || other.sendState == _this.sendState));
}


@override
int get hashCode {
  final _this = this as RequestTab;
  return Object.hash(runtimeType,_this.id,_this.name,_this.draft,_this.savedDraft,_this.savedRequestId,_this.collectionId,_this.sendState);
}

@override
String toString() {
  final _this = this as RequestTab;
  return 'RequestTab(id: ${_this.id}, name: ${_this.name}, draft: ${_this.draft}, savedDraft: ${_this.savedDraft}, savedRequestId: ${_this.savedRequestId}, collectionId: ${_this.collectionId}, sendState: ${_this.sendState})';
}


}

/// @nodoc
abstract mixin class $RequestTabCopyWith<$Res>  {
  factory $RequestTabCopyWith(RequestTab value, $Res Function(RequestTab) _then) = _$RequestTabCopyWithImpl;
@useResult
$Res call({
 String id, String name, HttpRequestDraft draft, HttpRequestDraft? savedDraft, String? savedRequestId, String? collectionId, SendState sendState
});


$HttpRequestDraftCopyWith<$Res> get draft;$HttpRequestDraftCopyWith<$Res>? get savedDraft;

}
/// @nodoc
class _$RequestTabCopyWithImpl<$Res>
    implements $RequestTabCopyWith<$Res> {
  _$RequestTabCopyWithImpl(this._self, this._then);

  final RequestTab _self;
  final $Res Function(RequestTab) _then;

/// Create a copy of RequestTab
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? draft = null,Object? savedDraft = freezed,Object? savedRequestId = freezed,Object? collectionId = freezed,Object? sendState = null,}) {
  return _then(RequestTab(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as HttpRequestDraft,savedDraft: freezed == savedDraft ? _self.savedDraft : savedDraft // ignore: cast_nullable_to_non_nullable
as HttpRequestDraft?,savedRequestId: freezed == savedRequestId ? _self.savedRequestId : savedRequestId // ignore: cast_nullable_to_non_nullable
as String?,collectionId: freezed == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String?,sendState: null == sendState ? _self.sendState : sendState // ignore: cast_nullable_to_non_nullable
as SendState,
  ));
}
/// Create a copy of RequestTab
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HttpRequestDraftCopyWith<$Res> get draft {
  
  return $HttpRequestDraftCopyWith<$Res>(_self.draft, (value) {
    return _then(_self.copyWith(draft: value));
  });
}/// Create a copy of RequestTab
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HttpRequestDraftCopyWith<$Res>? get savedDraft {
    if (_self.savedDraft == null) {
    return null;
  }

  return $HttpRequestDraftCopyWith<$Res>(_self.savedDraft!, (value) {
    return _then(_self.copyWith(savedDraft: value));
  });
}
}


/// Adds pattern-matching-related methods to [RequestTab].
extension RequestTabPatterns on RequestTab {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestTab value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestTab() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestTab value)  $default,){
final _that = this;
switch (_that) {
case _RequestTab():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestTab value)?  $default,){
final _that = this;
switch (_that) {
case _RequestTab() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  HttpRequestDraft draft,  HttpRequestDraft? savedDraft,  String? savedRequestId,  String? collectionId,  SendState sendState)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequestTab() when $default != null:
return $default(_that.id,_that.name,_that.draft,_that.savedDraft,_that.savedRequestId,_that.collectionId,_that.sendState);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  HttpRequestDraft draft,  HttpRequestDraft? savedDraft,  String? savedRequestId,  String? collectionId,  SendState sendState)  $default,) {final _that = this;
switch (_that) {
case _RequestTab():
return $default(_that.id,_that.name,_that.draft,_that.savedDraft,_that.savedRequestId,_that.collectionId,_that.sendState);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  HttpRequestDraft draft,  HttpRequestDraft? savedDraft,  String? savedRequestId,  String? collectionId,  SendState sendState)?  $default,) {final _that = this;
switch (_that) {
case _RequestTab() when $default != null:
return $default(_that.id,_that.name,_that.draft,_that.savedDraft,_that.savedRequestId,_that.collectionId,_that.sendState);case _:
  return null;

}
}

}

/// @nodoc


class _RequestTab extends RequestTab {
  const _RequestTab({required this.id, required this.name, required this.draft, this.savedDraft, this.savedRequestId, this.collectionId, this.sendState = const SendIdle()}): super._();
  

@override final  String id;
@override final  String name;
@override final  HttpRequestDraft draft;
/// What is stored in the database; null while the tab was never saved.
@override final  HttpRequestDraft? savedDraft;
@override final  String? savedRequestId;
/// Collection the request is saved in, or the one a new request is meant for.
@override final  String? collectionId;
@override@JsonKey() final  SendState sendState;

/// Create a copy of RequestTab
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestTabCopyWith<_RequestTab> get copyWith => __$RequestTabCopyWithImpl<_RequestTab>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestTab&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.draft, draft) || other.draft == draft)&&(identical(other.savedDraft, savedDraft) || other.savedDraft == savedDraft)&&(identical(other.savedRequestId, savedRequestId) || other.savedRequestId == savedRequestId)&&(identical(other.collectionId, collectionId) || other.collectionId == collectionId)&&(identical(other.sendState, sendState) || other.sendState == sendState));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,draft,savedDraft,savedRequestId,collectionId,sendState);
}

@override
String toString() {
    return 'RequestTab(id: $id, name: $name, draft: $draft, savedDraft: $savedDraft, savedRequestId: $savedRequestId, collectionId: $collectionId, sendState: $sendState)';
}


}

/// @nodoc
abstract mixin class _$RequestTabCopyWith<$Res> implements $RequestTabCopyWith<$Res> {
  factory _$RequestTabCopyWith(_RequestTab value, $Res Function(_RequestTab) _then) = __$RequestTabCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, HttpRequestDraft draft, HttpRequestDraft? savedDraft, String? savedRequestId, String? collectionId, SendState sendState
});


@override $HttpRequestDraftCopyWith<$Res> get draft;@override $HttpRequestDraftCopyWith<$Res>? get savedDraft;

}
/// @nodoc
class __$RequestTabCopyWithImpl<$Res>
    implements _$RequestTabCopyWith<$Res> {
  __$RequestTabCopyWithImpl(this._self, this._then);

  final _RequestTab _self;
  final $Res Function(_RequestTab) _then;

/// Create a copy of RequestTab
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? draft = null,Object? savedDraft = freezed,Object? savedRequestId = freezed,Object? collectionId = freezed,Object? sendState = null,}) {
  return _then(_RequestTab(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,draft: null == draft ? _self.draft : draft // ignore: cast_nullable_to_non_nullable
as HttpRequestDraft,savedDraft: freezed == savedDraft ? _self.savedDraft : savedDraft // ignore: cast_nullable_to_non_nullable
as HttpRequestDraft?,savedRequestId: freezed == savedRequestId ? _self.savedRequestId : savedRequestId // ignore: cast_nullable_to_non_nullable
as String?,collectionId: freezed == collectionId ? _self.collectionId : collectionId // ignore: cast_nullable_to_non_nullable
as String?,sendState: null == sendState ? _self.sendState : sendState // ignore: cast_nullable_to_non_nullable
as SendState,
  ));
}

/// Create a copy of RequestTab
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HttpRequestDraftCopyWith<$Res> get draft {
  
  return $HttpRequestDraftCopyWith<$Res>(_self.draft, (value) {
    return _then(_self.copyWith(draft: value));
  });
}/// Create a copy of RequestTab
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HttpRequestDraftCopyWith<$Res>? get savedDraft {
    if (_self.savedDraft == null) {
    return null;
  }

  return $HttpRequestDraftCopyWith<$Res>(_self.savedDraft!, (value) {
    return _then(_self.copyWith(savedDraft: value));
  });
}
}

/// @nodoc
mixin _$RequestTabsState {

 List<RequestTab> get tabs; String? get activeId;
/// Create a copy of RequestTabsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RequestTabsStateCopyWith<RequestTabsState> get copyWith => _$RequestTabsStateCopyWithImpl<RequestTabsState>(this as RequestTabsState, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as RequestTabsState;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestTabsState&&const DeepCollectionEquality().equals(other.tabs, _this.tabs)&&(identical(other.activeId, _this.activeId) || other.activeId == _this.activeId));
}


@override
int get hashCode {
  final _this = this as RequestTabsState;
  return Object.hash(runtimeType,const DeepCollectionEquality().hash(_this.tabs),_this.activeId);
}

@override
String toString() {
  final _this = this as RequestTabsState;
  return 'RequestTabsState(tabs: ${_this.tabs}, activeId: ${_this.activeId})';
}


}

/// @nodoc
abstract mixin class $RequestTabsStateCopyWith<$Res>  {
  factory $RequestTabsStateCopyWith(RequestTabsState value, $Res Function(RequestTabsState) _then) = _$RequestTabsStateCopyWithImpl;
@useResult
$Res call({
 List<RequestTab> tabs, String? activeId
});




}
/// @nodoc
class _$RequestTabsStateCopyWithImpl<$Res>
    implements $RequestTabsStateCopyWith<$Res> {
  _$RequestTabsStateCopyWithImpl(this._self, this._then);

  final RequestTabsState _self;
  final $Res Function(RequestTabsState) _then;

/// Create a copy of RequestTabsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tabs = null,Object? activeId = freezed,}) {
  return _then(RequestTabsState(
tabs: null == tabs ? _self.tabs : tabs // ignore: cast_nullable_to_non_nullable
as List<RequestTab>,activeId: freezed == activeId ? _self.activeId : activeId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RequestTabsState].
extension RequestTabsStatePatterns on RequestTabsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RequestTabsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RequestTabsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RequestTabsState value)  $default,){
final _that = this;
switch (_that) {
case _RequestTabsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RequestTabsState value)?  $default,){
final _that = this;
switch (_that) {
case _RequestTabsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<RequestTab> tabs,  String? activeId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RequestTabsState() when $default != null:
return $default(_that.tabs,_that.activeId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<RequestTab> tabs,  String? activeId)  $default,) {final _that = this;
switch (_that) {
case _RequestTabsState():
return $default(_that.tabs,_that.activeId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<RequestTab> tabs,  String? activeId)?  $default,) {final _that = this;
switch (_that) {
case _RequestTabsState() when $default != null:
return $default(_that.tabs,_that.activeId);case _:
  return null;

}
}

}

/// @nodoc


class _RequestTabsState extends RequestTabsState {
  const _RequestTabsState({ List<RequestTab> tabs = const [], this.activeId}): _tabs = tabs,super._();
  

 final  List<RequestTab> _tabs;
@override@JsonKey() List<RequestTab> get tabs {
  if (_tabs is EqualUnmodifiableListView) return _tabs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tabs);
}

@override final  String? activeId;

/// Create a copy of RequestTabsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RequestTabsStateCopyWith<_RequestTabsState> get copyWith => __$RequestTabsStateCopyWithImpl<_RequestTabsState>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _RequestTabsState&&const DeepCollectionEquality().equals(other.tabs, _tabs)&&(identical(other.activeId, activeId) || other.activeId == activeId));
}


@override
int get hashCode {
    return Object.hash(runtimeType,const DeepCollectionEquality().hash(_tabs),activeId);
}

@override
String toString() {
    return 'RequestTabsState(tabs: $tabs, activeId: $activeId)';
}


}

/// @nodoc
abstract mixin class _$RequestTabsStateCopyWith<$Res> implements $RequestTabsStateCopyWith<$Res> {
  factory _$RequestTabsStateCopyWith(_RequestTabsState value, $Res Function(_RequestTabsState) _then) = __$RequestTabsStateCopyWithImpl;
@override @useResult
$Res call({
 List<RequestTab> tabs, String? activeId
});




}
/// @nodoc
class __$RequestTabsStateCopyWithImpl<$Res>
    implements _$RequestTabsStateCopyWith<$Res> {
  __$RequestTabsStateCopyWithImpl(this._self, this._then);

  final _RequestTabsState _self;
  final $Res Function(_RequestTabsState) _then;

/// Create a copy of RequestTabsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tabs = null,Object? activeId = freezed,}) {
  return _then(_RequestTabsState(
tabs: null == tabs ? _self._tabs : tabs // ignore: cast_nullable_to_non_nullable
as List<RequestTab>,activeId: freezed == activeId ? _self.activeId : activeId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
