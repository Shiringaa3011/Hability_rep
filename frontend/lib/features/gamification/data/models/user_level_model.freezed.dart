// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_level_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserLevelModel {
  @JsonKey(name: 'user_id')
  String get userId;
  int get level;
  @JsonKey(name: 'total_points')
  int get totalPoints;
  @JsonKey(name: 'points_to_next_level')
  int get pointsToNextLevel;
  @JsonKey(name: 'progress_percent')
  double get progressPercent;

  /// Create a copy of UserLevelModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserLevelModelCopyWith<UserLevelModel> get copyWith =>
      _$UserLevelModelCopyWithImpl<UserLevelModel>(
          this as UserLevelModel, _$identity);

  /// Serializes this UserLevelModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UserLevelModel &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.totalPoints, totalPoints) ||
                other.totalPoints == totalPoints) &&
            (identical(other.pointsToNextLevel, pointsToNextLevel) ||
                other.pointsToNextLevel == pointsToNextLevel) &&
            (identical(other.progressPercent, progressPercent) ||
                other.progressPercent == progressPercent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, level, totalPoints,
      pointsToNextLevel, progressPercent);

  @override
  String toString() {
    return 'UserLevelModel(userId: $userId, level: $level, totalPoints: $totalPoints, pointsToNextLevel: $pointsToNextLevel, progressPercent: $progressPercent)';
  }
}

/// @nodoc
abstract mixin class $UserLevelModelCopyWith<$Res> {
  factory $UserLevelModelCopyWith(
          UserLevelModel value, $Res Function(UserLevelModel) _then) =
      _$UserLevelModelCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: 'user_id') String userId,
      int level,
      @JsonKey(name: 'total_points') int totalPoints,
      @JsonKey(name: 'points_to_next_level') int pointsToNextLevel,
      @JsonKey(name: 'progress_percent') double progressPercent});
}

/// @nodoc
class _$UserLevelModelCopyWithImpl<$Res>
    implements $UserLevelModelCopyWith<$Res> {
  _$UserLevelModelCopyWithImpl(this._self, this._then);

  final UserLevelModel _self;
  final $Res Function(UserLevelModel) _then;

  /// Create a copy of UserLevelModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? level = null,
    Object? totalPoints = null,
    Object? pointsToNextLevel = null,
    Object? progressPercent = null,
  }) {
    return _then(_self.copyWith(
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      level: null == level
          ? _self.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      totalPoints: null == totalPoints
          ? _self.totalPoints
          : totalPoints // ignore: cast_nullable_to_non_nullable
              as int,
      pointsToNextLevel: null == pointsToNextLevel
          ? _self.pointsToNextLevel
          : pointsToNextLevel // ignore: cast_nullable_to_non_nullable
              as int,
      progressPercent: null == progressPercent
          ? _self.progressPercent
          : progressPercent // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// Adds pattern-matching-related methods to [UserLevelModel].
extension UserLevelModelPatterns on UserLevelModel {
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

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_UserLevelModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UserLevelModel() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_UserLevelModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserLevelModel():
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_UserLevelModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserLevelModel() when $default != null:
        return $default(_that);
      case _:
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

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            @JsonKey(name: 'user_id') String userId,
            int level,
            @JsonKey(name: 'total_points') int totalPoints,
            @JsonKey(name: 'points_to_next_level') int pointsToNextLevel,
            @JsonKey(name: 'progress_percent') double progressPercent)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UserLevelModel() when $default != null:
        return $default(_that.userId, _that.level, _that.totalPoints,
            _that.pointsToNextLevel, _that.progressPercent);
      case _:
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

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            @JsonKey(name: 'user_id') String userId,
            int level,
            @JsonKey(name: 'total_points') int totalPoints,
            @JsonKey(name: 'points_to_next_level') int pointsToNextLevel,
            @JsonKey(name: 'progress_percent') double progressPercent)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserLevelModel():
        return $default(_that.userId, _that.level, _that.totalPoints,
            _that.pointsToNextLevel, _that.progressPercent);
      case _:
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

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            @JsonKey(name: 'user_id') String userId,
            int level,
            @JsonKey(name: 'total_points') int totalPoints,
            @JsonKey(name: 'points_to_next_level') int pointsToNextLevel,
            @JsonKey(name: 'progress_percent') double progressPercent)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserLevelModel() when $default != null:
        return $default(_that.userId, _that.level, _that.totalPoints,
            _that.pointsToNextLevel, _that.progressPercent);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _UserLevelModel extends UserLevelModel {
  const _UserLevelModel(
      {@JsonKey(name: 'user_id') required this.userId,
      required this.level,
      @JsonKey(name: 'total_points') required this.totalPoints,
      @JsonKey(name: 'points_to_next_level') required this.pointsToNextLevel,
      @JsonKey(name: 'progress_percent') required this.progressPercent})
      : super._();
  factory _UserLevelModel.fromJson(Map<String, dynamic> json) =>
      _$UserLevelModelFromJson(json);

  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final int level;
  @override
  @JsonKey(name: 'total_points')
  final int totalPoints;
  @override
  @JsonKey(name: 'points_to_next_level')
  final int pointsToNextLevel;
  @override
  @JsonKey(name: 'progress_percent')
  final double progressPercent;

  /// Create a copy of UserLevelModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UserLevelModelCopyWith<_UserLevelModel> get copyWith =>
      __$UserLevelModelCopyWithImpl<_UserLevelModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$UserLevelModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UserLevelModel &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.level, level) || other.level == level) &&
            (identical(other.totalPoints, totalPoints) ||
                other.totalPoints == totalPoints) &&
            (identical(other.pointsToNextLevel, pointsToNextLevel) ||
                other.pointsToNextLevel == pointsToNextLevel) &&
            (identical(other.progressPercent, progressPercent) ||
                other.progressPercent == progressPercent));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, level, totalPoints,
      pointsToNextLevel, progressPercent);

  @override
  String toString() {
    return 'UserLevelModel(userId: $userId, level: $level, totalPoints: $totalPoints, pointsToNextLevel: $pointsToNextLevel, progressPercent: $progressPercent)';
  }
}

/// @nodoc
abstract mixin class _$UserLevelModelCopyWith<$Res>
    implements $UserLevelModelCopyWith<$Res> {
  factory _$UserLevelModelCopyWith(
          _UserLevelModel value, $Res Function(_UserLevelModel) _then) =
      __$UserLevelModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'user_id') String userId,
      int level,
      @JsonKey(name: 'total_points') int totalPoints,
      @JsonKey(name: 'points_to_next_level') int pointsToNextLevel,
      @JsonKey(name: 'progress_percent') double progressPercent});
}

/// @nodoc
class __$UserLevelModelCopyWithImpl<$Res>
    implements _$UserLevelModelCopyWith<$Res> {
  __$UserLevelModelCopyWithImpl(this._self, this._then);

  final _UserLevelModel _self;
  final $Res Function(_UserLevelModel) _then;

  /// Create a copy of UserLevelModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? userId = null,
    Object? level = null,
    Object? totalPoints = null,
    Object? pointsToNextLevel = null,
    Object? progressPercent = null,
  }) {
    return _then(_UserLevelModel(
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      level: null == level
          ? _self.level
          : level // ignore: cast_nullable_to_non_nullable
              as int,
      totalPoints: null == totalPoints
          ? _self.totalPoints
          : totalPoints // ignore: cast_nullable_to_non_nullable
              as int,
      pointsToNextLevel: null == pointsToNextLevel
          ? _self.pointsToNextLevel
          : pointsToNextLevel // ignore: cast_nullable_to_non_nullable
              as int,
      progressPercent: null == progressPercent
          ? _self.progressPercent
          : progressPercent // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

// dart format on
