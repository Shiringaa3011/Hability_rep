// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_stats_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserStatsModel {
  @JsonKey(name: 'user_id')
  String get userId;
  String get period;
  @JsonKey(name: 'total_completions')
  int get totalCompletions;
  @JsonKey(name: 'completion_rate')
  double get completionRate;
  @JsonKey(name: 'current_streak')
  int get currentStreak;
  @JsonKey(name: 'max_streak')
  int get maxStreak;
  @JsonKey(name: 'total_points_earned')
  int get totalPointsEarned;
  @JsonKey(name: 'updated_at')
  String get updatedAt;
  @JsonKey(name: 'missed_count')
  int get missedCount;

  /// Create a copy of UserStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserStatsModelCopyWith<UserStatsModel> get copyWith =>
      _$UserStatsModelCopyWithImpl<UserStatsModel>(
          this as UserStatsModel, _$identity);

  /// Serializes this UserStatsModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UserStatsModel &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.totalCompletions, totalCompletions) ||
                other.totalCompletions == totalCompletions) &&
            (identical(other.completionRate, completionRate) ||
                other.completionRate == completionRate) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.maxStreak, maxStreak) ||
                other.maxStreak == maxStreak) &&
            (identical(other.totalPointsEarned, totalPointsEarned) ||
                other.totalPointsEarned == totalPointsEarned) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.missedCount, missedCount) ||
                other.missedCount == missedCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      period,
      totalCompletions,
      completionRate,
      currentStreak,
      maxStreak,
      totalPointsEarned,
      updatedAt,
      missedCount);

  @override
  String toString() {
    return 'UserStatsModel(userId: $userId, period: $period, totalCompletions: $totalCompletions, completionRate: $completionRate, currentStreak: $currentStreak, maxStreak: $maxStreak, totalPointsEarned: $totalPointsEarned, updatedAt: $updatedAt, missedCount: $missedCount)';
  }
}

/// @nodoc
abstract mixin class $UserStatsModelCopyWith<$Res> {
  factory $UserStatsModelCopyWith(
          UserStatsModel value, $Res Function(UserStatsModel) _then) =
      _$UserStatsModelCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: 'user_id') String userId,
      String period,
      @JsonKey(name: 'total_completions') int totalCompletions,
      @JsonKey(name: 'completion_rate') double completionRate,
      @JsonKey(name: 'current_streak') int currentStreak,
      @JsonKey(name: 'max_streak') int maxStreak,
      @JsonKey(name: 'total_points_earned') int totalPointsEarned,
      @JsonKey(name: 'updated_at') String updatedAt,
      @JsonKey(name: 'missed_count') int missedCount});
}

/// @nodoc
class _$UserStatsModelCopyWithImpl<$Res>
    implements $UserStatsModelCopyWith<$Res> {
  _$UserStatsModelCopyWithImpl(this._self, this._then);

  final UserStatsModel _self;
  final $Res Function(UserStatsModel) _then;

  /// Create a copy of UserStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? period = null,
    Object? totalCompletions = null,
    Object? completionRate = null,
    Object? currentStreak = null,
    Object? maxStreak = null,
    Object? totalPointsEarned = null,
    Object? updatedAt = null,
    Object? missedCount = null,
  }) {
    return _then(_self.copyWith(
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      period: null == period
          ? _self.period
          : period // ignore: cast_nullable_to_non_nullable
              as String,
      totalCompletions: null == totalCompletions
          ? _self.totalCompletions
          : totalCompletions // ignore: cast_nullable_to_non_nullable
              as int,
      completionRate: null == completionRate
          ? _self.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double,
      currentStreak: null == currentStreak
          ? _self.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      maxStreak: null == maxStreak
          ? _self.maxStreak
          : maxStreak // ignore: cast_nullable_to_non_nullable
              as int,
      totalPointsEarned: null == totalPointsEarned
          ? _self.totalPointsEarned
          : totalPointsEarned // ignore: cast_nullable_to_non_nullable
              as int,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
      missedCount: null == missedCount
          ? _self.missedCount
          : missedCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// Adds pattern-matching-related methods to [UserStatsModel].
extension UserStatsModelPatterns on UserStatsModel {
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
    TResult Function(_UserStatsModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UserStatsModel() when $default != null:
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
    TResult Function(_UserStatsModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserStatsModel():
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
    TResult? Function(_UserStatsModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserStatsModel() when $default != null:
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
            String period,
            @JsonKey(name: 'total_completions') int totalCompletions,
            @JsonKey(name: 'completion_rate') double completionRate,
            @JsonKey(name: 'current_streak') int currentStreak,
            @JsonKey(name: 'max_streak') int maxStreak,
            @JsonKey(name: 'total_points_earned') int totalPointsEarned,
            @JsonKey(name: 'updated_at') String updatedAt,
            @JsonKey(name: 'missed_count') int missedCount)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UserStatsModel() when $default != null:
        return $default(
            _that.userId,
            _that.period,
            _that.totalCompletions,
            _that.completionRate,
            _that.currentStreak,
            _that.maxStreak,
            _that.totalPointsEarned,
            _that.updatedAt,
            _that.missedCount);
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
            String period,
            @JsonKey(name: 'total_completions') int totalCompletions,
            @JsonKey(name: 'completion_rate') double completionRate,
            @JsonKey(name: 'current_streak') int currentStreak,
            @JsonKey(name: 'max_streak') int maxStreak,
            @JsonKey(name: 'total_points_earned') int totalPointsEarned,
            @JsonKey(name: 'updated_at') String updatedAt,
            @JsonKey(name: 'missed_count') int missedCount)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserStatsModel():
        return $default(
            _that.userId,
            _that.period,
            _that.totalCompletions,
            _that.completionRate,
            _that.currentStreak,
            _that.maxStreak,
            _that.totalPointsEarned,
            _that.updatedAt,
            _that.missedCount);
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
            String period,
            @JsonKey(name: 'total_completions') int totalCompletions,
            @JsonKey(name: 'completion_rate') double completionRate,
            @JsonKey(name: 'current_streak') int currentStreak,
            @JsonKey(name: 'max_streak') int maxStreak,
            @JsonKey(name: 'total_points_earned') int totalPointsEarned,
            @JsonKey(name: 'updated_at') String updatedAt,
            @JsonKey(name: 'missed_count') int missedCount)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserStatsModel() when $default != null:
        return $default(
            _that.userId,
            _that.period,
            _that.totalCompletions,
            _that.completionRate,
            _that.currentStreak,
            _that.maxStreak,
            _that.totalPointsEarned,
            _that.updatedAt,
            _that.missedCount);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _UserStatsModel extends UserStatsModel {
  const _UserStatsModel(
      {@JsonKey(name: 'user_id') required this.userId,
      required this.period,
      @JsonKey(name: 'total_completions') required this.totalCompletions,
      @JsonKey(name: 'completion_rate') required this.completionRate,
      @JsonKey(name: 'current_streak') required this.currentStreak,
      @JsonKey(name: 'max_streak') required this.maxStreak,
      @JsonKey(name: 'total_points_earned') required this.totalPointsEarned,
      @JsonKey(name: 'updated_at') required this.updatedAt,
      @JsonKey(name: 'missed_count') this.missedCount = 0})
      : super._();
  factory _UserStatsModel.fromJson(Map<String, dynamic> json) =>
      _$UserStatsModelFromJson(json);

  @override
  @JsonKey(name: 'user_id')
  final String userId;
  @override
  final String period;
  @override
  @JsonKey(name: 'total_completions')
  final int totalCompletions;
  @override
  @JsonKey(name: 'completion_rate')
  final double completionRate;
  @override
  @JsonKey(name: 'current_streak')
  final int currentStreak;
  @override
  @JsonKey(name: 'max_streak')
  final int maxStreak;
  @override
  @JsonKey(name: 'total_points_earned')
  final int totalPointsEarned;
  @override
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  @override
  @JsonKey(name: 'missed_count')
  final int missedCount;

  /// Create a copy of UserStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UserStatsModelCopyWith<_UserStatsModel> get copyWith =>
      __$UserStatsModelCopyWithImpl<_UserStatsModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$UserStatsModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UserStatsModel &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.period, period) || other.period == period) &&
            (identical(other.totalCompletions, totalCompletions) ||
                other.totalCompletions == totalCompletions) &&
            (identical(other.completionRate, completionRate) ||
                other.completionRate == completionRate) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.maxStreak, maxStreak) ||
                other.maxStreak == maxStreak) &&
            (identical(other.totalPointsEarned, totalPointsEarned) ||
                other.totalPointsEarned == totalPointsEarned) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.missedCount, missedCount) ||
                other.missedCount == missedCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      period,
      totalCompletions,
      completionRate,
      currentStreak,
      maxStreak,
      totalPointsEarned,
      updatedAt,
      missedCount);

  @override
  String toString() {
    return 'UserStatsModel(userId: $userId, period: $period, totalCompletions: $totalCompletions, completionRate: $completionRate, currentStreak: $currentStreak, maxStreak: $maxStreak, totalPointsEarned: $totalPointsEarned, updatedAt: $updatedAt, missedCount: $missedCount)';
  }
}

/// @nodoc
abstract mixin class _$UserStatsModelCopyWith<$Res>
    implements $UserStatsModelCopyWith<$Res> {
  factory _$UserStatsModelCopyWith(
          _UserStatsModel value, $Res Function(_UserStatsModel) _then) =
      __$UserStatsModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'user_id') String userId,
      String period,
      @JsonKey(name: 'total_completions') int totalCompletions,
      @JsonKey(name: 'completion_rate') double completionRate,
      @JsonKey(name: 'current_streak') int currentStreak,
      @JsonKey(name: 'max_streak') int maxStreak,
      @JsonKey(name: 'total_points_earned') int totalPointsEarned,
      @JsonKey(name: 'updated_at') String updatedAt,
      @JsonKey(name: 'missed_count') int missedCount});
}

/// @nodoc
class __$UserStatsModelCopyWithImpl<$Res>
    implements _$UserStatsModelCopyWith<$Res> {
  __$UserStatsModelCopyWithImpl(this._self, this._then);

  final _UserStatsModel _self;
  final $Res Function(_UserStatsModel) _then;

  /// Create a copy of UserStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? userId = null,
    Object? period = null,
    Object? totalCompletions = null,
    Object? completionRate = null,
    Object? currentStreak = null,
    Object? maxStreak = null,
    Object? totalPointsEarned = null,
    Object? updatedAt = null,
    Object? missedCount = null,
  }) {
    return _then(_UserStatsModel(
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      period: null == period
          ? _self.period
          : period // ignore: cast_nullable_to_non_nullable
              as String,
      totalCompletions: null == totalCompletions
          ? _self.totalCompletions
          : totalCompletions // ignore: cast_nullable_to_non_nullable
              as int,
      completionRate: null == completionRate
          ? _self.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double,
      currentStreak: null == currentStreak
          ? _self.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      maxStreak: null == maxStreak
          ? _self.maxStreak
          : maxStreak // ignore: cast_nullable_to_non_nullable
              as int,
      totalPointsEarned: null == totalPointsEarned
          ? _self.totalPointsEarned
          : totalPointsEarned // ignore: cast_nullable_to_non_nullable
              as int,
      updatedAt: null == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
      missedCount: null == missedCount
          ? _self.missedCount
          : missedCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

// dart format on
