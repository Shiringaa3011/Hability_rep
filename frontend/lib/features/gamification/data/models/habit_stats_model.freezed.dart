// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit_stats_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HabitStatsModel {
  @JsonKey(name: 'habit_id')
  String get habitId;
  @JsonKey(name: 'habit_name')
  String get habitName;
  @JsonKey(name: 'total_completions')
  int get totalCompletions;
  @JsonKey(name: 'current_streak')
  int get currentStreak;
  @JsonKey(name: 'max_streak')
  int get maxStreak;
  @JsonKey(name: 'total_points_earned')
  int get totalPointsEarned;
  @JsonKey(name: 'completion_rate')
  double get completionRate;

  /// Create a copy of HabitStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $HabitStatsModelCopyWith<HabitStatsModel> get copyWith =>
      _$HabitStatsModelCopyWithImpl<HabitStatsModel>(
          this as HabitStatsModel, _$identity);

  /// Serializes this HabitStatsModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is HabitStatsModel &&
            (identical(other.habitId, habitId) || other.habitId == habitId) &&
            (identical(other.habitName, habitName) ||
                other.habitName == habitName) &&
            (identical(other.totalCompletions, totalCompletions) ||
                other.totalCompletions == totalCompletions) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.maxStreak, maxStreak) ||
                other.maxStreak == maxStreak) &&
            (identical(other.totalPointsEarned, totalPointsEarned) ||
                other.totalPointsEarned == totalPointsEarned) &&
            (identical(other.completionRate, completionRate) ||
                other.completionRate == completionRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      habitId,
      habitName,
      totalCompletions,
      currentStreak,
      maxStreak,
      totalPointsEarned,
      completionRate);

  @override
  String toString() {
    return 'HabitStatsModel(habitId: $habitId, habitName: $habitName, totalCompletions: $totalCompletions, currentStreak: $currentStreak, maxStreak: $maxStreak, totalPointsEarned: $totalPointsEarned, completionRate: $completionRate)';
  }
}

/// @nodoc
abstract mixin class $HabitStatsModelCopyWith<$Res> {
  factory $HabitStatsModelCopyWith(
          HabitStatsModel value, $Res Function(HabitStatsModel) _then) =
      _$HabitStatsModelCopyWithImpl;
  @useResult
  $Res call(
      {@JsonKey(name: 'habit_id') String habitId,
      @JsonKey(name: 'habit_name') String habitName,
      @JsonKey(name: 'total_completions') int totalCompletions,
      @JsonKey(name: 'current_streak') int currentStreak,
      @JsonKey(name: 'max_streak') int maxStreak,
      @JsonKey(name: 'total_points_earned') int totalPointsEarned,
      @JsonKey(name: 'completion_rate') double completionRate});
}

/// @nodoc
class _$HabitStatsModelCopyWithImpl<$Res>
    implements $HabitStatsModelCopyWith<$Res> {
  _$HabitStatsModelCopyWithImpl(this._self, this._then);

  final HabitStatsModel _self;
  final $Res Function(HabitStatsModel) _then;

  /// Create a copy of HabitStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? habitId = null,
    Object? habitName = null,
    Object? totalCompletions = null,
    Object? currentStreak = null,
    Object? maxStreak = null,
    Object? totalPointsEarned = null,
    Object? completionRate = null,
  }) {
    return _then(_self.copyWith(
      habitId: null == habitId
          ? _self.habitId
          : habitId // ignore: cast_nullable_to_non_nullable
              as String,
      habitName: null == habitName
          ? _self.habitName
          : habitName // ignore: cast_nullable_to_non_nullable
              as String,
      totalCompletions: null == totalCompletions
          ? _self.totalCompletions
          : totalCompletions // ignore: cast_nullable_to_non_nullable
              as int,
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
      completionRate: null == completionRate
          ? _self.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// Adds pattern-matching-related methods to [HabitStatsModel].
extension HabitStatsModelPatterns on HabitStatsModel {
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
    TResult Function(_HabitStatsModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HabitStatsModel() when $default != null:
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
    TResult Function(_HabitStatsModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HabitStatsModel():
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
    TResult? Function(_HabitStatsModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HabitStatsModel() when $default != null:
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
            @JsonKey(name: 'habit_id') String habitId,
            @JsonKey(name: 'habit_name') String habitName,
            @JsonKey(name: 'total_completions') int totalCompletions,
            @JsonKey(name: 'current_streak') int currentStreak,
            @JsonKey(name: 'max_streak') int maxStreak,
            @JsonKey(name: 'total_points_earned') int totalPointsEarned,
            @JsonKey(name: 'completion_rate') double completionRate)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _HabitStatsModel() when $default != null:
        return $default(
            _that.habitId,
            _that.habitName,
            _that.totalCompletions,
            _that.currentStreak,
            _that.maxStreak,
            _that.totalPointsEarned,
            _that.completionRate);
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
            @JsonKey(name: 'habit_id') String habitId,
            @JsonKey(name: 'habit_name') String habitName,
            @JsonKey(name: 'total_completions') int totalCompletions,
            @JsonKey(name: 'current_streak') int currentStreak,
            @JsonKey(name: 'max_streak') int maxStreak,
            @JsonKey(name: 'total_points_earned') int totalPointsEarned,
            @JsonKey(name: 'completion_rate') double completionRate)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HabitStatsModel():
        return $default(
            _that.habitId,
            _that.habitName,
            _that.totalCompletions,
            _that.currentStreak,
            _that.maxStreak,
            _that.totalPointsEarned,
            _that.completionRate);
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
            @JsonKey(name: 'habit_id') String habitId,
            @JsonKey(name: 'habit_name') String habitName,
            @JsonKey(name: 'total_completions') int totalCompletions,
            @JsonKey(name: 'current_streak') int currentStreak,
            @JsonKey(name: 'max_streak') int maxStreak,
            @JsonKey(name: 'total_points_earned') int totalPointsEarned,
            @JsonKey(name: 'completion_rate') double completionRate)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _HabitStatsModel() when $default != null:
        return $default(
            _that.habitId,
            _that.habitName,
            _that.totalCompletions,
            _that.currentStreak,
            _that.maxStreak,
            _that.totalPointsEarned,
            _that.completionRate);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _HabitStatsModel extends HabitStatsModel {
  const _HabitStatsModel(
      {@JsonKey(name: 'habit_id') required this.habitId,
      @JsonKey(name: 'habit_name') required this.habitName,
      @JsonKey(name: 'total_completions') required this.totalCompletions,
      @JsonKey(name: 'current_streak') required this.currentStreak,
      @JsonKey(name: 'max_streak') required this.maxStreak,
      @JsonKey(name: 'total_points_earned') required this.totalPointsEarned,
      @JsonKey(name: 'completion_rate') required this.completionRate})
      : super._();
  factory _HabitStatsModel.fromJson(Map<String, dynamic> json) =>
      _$HabitStatsModelFromJson(json);

  @override
  @JsonKey(name: 'habit_id')
  final String habitId;
  @override
  @JsonKey(name: 'habit_name')
  final String habitName;
  @override
  @JsonKey(name: 'total_completions')
  final int totalCompletions;
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
  @JsonKey(name: 'completion_rate')
  final double completionRate;

  /// Create a copy of HabitStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$HabitStatsModelCopyWith<_HabitStatsModel> get copyWith =>
      __$HabitStatsModelCopyWithImpl<_HabitStatsModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$HabitStatsModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _HabitStatsModel &&
            (identical(other.habitId, habitId) || other.habitId == habitId) &&
            (identical(other.habitName, habitName) ||
                other.habitName == habitName) &&
            (identical(other.totalCompletions, totalCompletions) ||
                other.totalCompletions == totalCompletions) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.maxStreak, maxStreak) ||
                other.maxStreak == maxStreak) &&
            (identical(other.totalPointsEarned, totalPointsEarned) ||
                other.totalPointsEarned == totalPointsEarned) &&
            (identical(other.completionRate, completionRate) ||
                other.completionRate == completionRate));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      habitId,
      habitName,
      totalCompletions,
      currentStreak,
      maxStreak,
      totalPointsEarned,
      completionRate);

  @override
  String toString() {
    return 'HabitStatsModel(habitId: $habitId, habitName: $habitName, totalCompletions: $totalCompletions, currentStreak: $currentStreak, maxStreak: $maxStreak, totalPointsEarned: $totalPointsEarned, completionRate: $completionRate)';
  }
}

/// @nodoc
abstract mixin class _$HabitStatsModelCopyWith<$Res>
    implements $HabitStatsModelCopyWith<$Res> {
  factory _$HabitStatsModelCopyWith(
          _HabitStatsModel value, $Res Function(_HabitStatsModel) _then) =
      __$HabitStatsModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'habit_id') String habitId,
      @JsonKey(name: 'habit_name') String habitName,
      @JsonKey(name: 'total_completions') int totalCompletions,
      @JsonKey(name: 'current_streak') int currentStreak,
      @JsonKey(name: 'max_streak') int maxStreak,
      @JsonKey(name: 'total_points_earned') int totalPointsEarned,
      @JsonKey(name: 'completion_rate') double completionRate});
}

/// @nodoc
class __$HabitStatsModelCopyWithImpl<$Res>
    implements _$HabitStatsModelCopyWith<$Res> {
  __$HabitStatsModelCopyWithImpl(this._self, this._then);

  final _HabitStatsModel _self;
  final $Res Function(_HabitStatsModel) _then;

  /// Create a copy of HabitStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? habitId = null,
    Object? habitName = null,
    Object? totalCompletions = null,
    Object? currentStreak = null,
    Object? maxStreak = null,
    Object? totalPointsEarned = null,
    Object? completionRate = null,
  }) {
    return _then(_HabitStatsModel(
      habitId: null == habitId
          ? _self.habitId
          : habitId // ignore: cast_nullable_to_non_nullable
              as String,
      habitName: null == habitName
          ? _self.habitName
          : habitName // ignore: cast_nullable_to_non_nullable
              as String,
      totalCompletions: null == totalCompletions
          ? _self.totalCompletions
          : totalCompletions // ignore: cast_nullable_to_non_nullable
              as int,
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
      completionRate: null == completionRate
          ? _self.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

// dart format on
