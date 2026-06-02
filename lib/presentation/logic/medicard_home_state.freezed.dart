// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'medicard_home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MedicardHomeState {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MedicardHomeState);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MedicardHomeState()';
}


}

/// @nodoc
class $MedicardHomeStateCopyWith<$Res>  {
$MedicardHomeStateCopyWith(MedicardHomeState _, $Res Function(MedicardHomeState) __);
}


/// Adds pattern-matching-related methods to [MedicardHomeState].
extension MedicardHomeStatePatterns on MedicardHomeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Initial value)?  initial,TResult Function( Loading value)?  loading,TResult Function( Success value)?  success,TResult Function( Failed value)?  failed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial(_that);case Loading() when loading != null:
return loading(_that);case Success() when success != null:
return success(_that);case Failed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Initial value)  initial,required TResult Function( Loading value)  loading,required TResult Function( Success value)  success,required TResult Function( Failed value)  failed,}){
final _that = this;
switch (_that) {
case Initial():
return initial(_that);case Loading():
return loading(_that);case Success():
return success(_that);case Failed():
return failed(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Initial value)?  initial,TResult? Function( Loading value)?  loading,TResult? Function( Success value)?  success,TResult? Function( Failed value)?  failed,}){
final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial(_that);case Loading() when loading != null:
return loading(_that);case Success() when success != null:
return success(_that);case Failed() when failed != null:
return failed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initial,TResult Function()?  loading,TResult Function( CardHomeInfoResponseModel homeInfo,  CardPersonalInfoResponseModel? personalInfo,  TopProvidersSliderResponse? sliderInfo)?  success,TResult Function( String error)?  failed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial();case Loading() when loading != null:
return loading();case Success() when success != null:
return success(_that.homeInfo,_that.personalInfo,_that.sliderInfo);case Failed() when failed != null:
return failed(_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initial,required TResult Function()  loading,required TResult Function( CardHomeInfoResponseModel homeInfo,  CardPersonalInfoResponseModel? personalInfo,  TopProvidersSliderResponse? sliderInfo)  success,required TResult Function( String error)  failed,}) {final _that = this;
switch (_that) {
case Initial():
return initial();case Loading():
return loading();case Success():
return success(_that.homeInfo,_that.personalInfo,_that.sliderInfo);case Failed():
return failed(_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initial,TResult? Function()?  loading,TResult? Function( CardHomeInfoResponseModel homeInfo,  CardPersonalInfoResponseModel? personalInfo,  TopProvidersSliderResponse? sliderInfo)?  success,TResult? Function( String error)?  failed,}) {final _that = this;
switch (_that) {
case Initial() when initial != null:
return initial();case Loading() when loading != null:
return loading();case Success() when success != null:
return success(_that.homeInfo,_that.personalInfo,_that.sliderInfo);case Failed() when failed != null:
return failed(_that.error);case _:
  return null;

}
}

}

/// @nodoc


class Initial implements MedicardHomeState {
  const Initial();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Initial);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MedicardHomeState.initial()';
}


}




/// @nodoc


class Loading implements MedicardHomeState {
  const Loading();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Loading);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'MedicardHomeState.loading()';
}


}




/// @nodoc


class Success implements MedicardHomeState {
  const Success({required this.homeInfo, this.personalInfo, this.sliderInfo});
  

 final  CardHomeInfoResponseModel homeInfo;
 final  CardPersonalInfoResponseModel? personalInfo;
 final  TopProvidersSliderResponse? sliderInfo;

/// Create a copy of MedicardHomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SuccessCopyWith<Success> get copyWith => _$SuccessCopyWithImpl<Success>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Success&&(identical(other.homeInfo, homeInfo) || other.homeInfo == homeInfo)&&(identical(other.personalInfo, personalInfo) || other.personalInfo == personalInfo)&&(identical(other.sliderInfo, sliderInfo) || other.sliderInfo == sliderInfo));
}


@override
int get hashCode => Object.hash(runtimeType,homeInfo,personalInfo,sliderInfo);

@override
String toString() {
  return 'MedicardHomeState.success(homeInfo: $homeInfo, personalInfo: $personalInfo, sliderInfo: $sliderInfo)';
}


}

/// @nodoc
abstract mixin class $SuccessCopyWith<$Res> implements $MedicardHomeStateCopyWith<$Res> {
  factory $SuccessCopyWith(Success value, $Res Function(Success) _then) = _$SuccessCopyWithImpl;
@useResult
$Res call({
 CardHomeInfoResponseModel homeInfo, CardPersonalInfoResponseModel? personalInfo, TopProvidersSliderResponse? sliderInfo
});




}
/// @nodoc
class _$SuccessCopyWithImpl<$Res>
    implements $SuccessCopyWith<$Res> {
  _$SuccessCopyWithImpl(this._self, this._then);

  final Success _self;
  final $Res Function(Success) _then;

/// Create a copy of MedicardHomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? homeInfo = null,Object? personalInfo = freezed,Object? sliderInfo = freezed,}) {
  return _then(Success(
homeInfo: null == homeInfo ? _self.homeInfo : homeInfo // ignore: cast_nullable_to_non_nullable
as CardHomeInfoResponseModel,personalInfo: freezed == personalInfo ? _self.personalInfo : personalInfo // ignore: cast_nullable_to_non_nullable
as CardPersonalInfoResponseModel?,sliderInfo: freezed == sliderInfo ? _self.sliderInfo : sliderInfo // ignore: cast_nullable_to_non_nullable
as TopProvidersSliderResponse?,
  ));
}


}

/// @nodoc


class Failed implements MedicardHomeState {
  const Failed({required this.error});
  

 final  String error;

/// Create a copy of MedicardHomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FailedCopyWith<Failed> get copyWith => _$FailedCopyWithImpl<Failed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Failed&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,error);

@override
String toString() {
  return 'MedicardHomeState.failed(error: $error)';
}


}

/// @nodoc
abstract mixin class $FailedCopyWith<$Res> implements $MedicardHomeStateCopyWith<$Res> {
  factory $FailedCopyWith(Failed value, $Res Function(Failed) _then) = _$FailedCopyWithImpl;
@useResult
$Res call({
 String error
});




}
/// @nodoc
class _$FailedCopyWithImpl<$Res>
    implements $FailedCopyWith<$Res> {
  _$FailedCopyWithImpl(this._self, this._then);

  final Failed _self;
  final $Res Function(Failed) _then;

/// Create a copy of MedicardHomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? error = null,}) {
  return _then(Failed(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
