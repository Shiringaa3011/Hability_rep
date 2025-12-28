// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'habit_stats_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

HabitStatsModel _$HabitStatsModelFromJson(Map<String, dynamic> json) {
  return _HabitStatsModel.fromJson(json);
}

/// @nodoc
mixin _$HabitStatsModel {
  @JsonKey(name: 'habit_id')
  String get habitId => throw _privateConstructorUsedError;
  @JsonKey(name: 'habit_name')
  String get habitName => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_completions')
  int get totalCompletions => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_streak')
  int get currentStreak => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_streak')
  int get maxStreak => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_points_earned')
  int get totalPointsEarned => throw _privateConstructorUsedError;
  @JsonKey(name: 'completion_rate')
  double get completionRate => throw _privateConstructorUsedError;

  /// Serializes this HabitStatsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of HabitStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HabitStatsModelCopyWith<HabitStatsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HabitStatsModelCopyWith<$Res> {
  factory $HabitStatsModelCopyWith(
          HabitStatsModel value, $Res Function(HabitStatsModel) then) =
      _$HabitStatsModelCopyWithImpl<$Res, HabitStatsModel>;
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
class _$HabitStatsModelCopyWithImpl<$Res, $Val extends HabitStatsModel>
    implements $HabitStatsModelCopyWith<$Res> {
  _$HabitStatsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      habitId: null == habitId
          ? _value.habitId
          : habitId // ignore: cast_nullable_to_non_nullable
              as String,
      habitName: null == habitName
          ? _value.habitName
          : habitName // ignore: cast_nullable_to_non_nullable
              as String,
      totalCompletions: null == totalCompletions
          ? _value.totalCompletions
          : totalCompletions // ignore: cast_nullable_to_non_nullable
              as int,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      maxStreak: null == maxStreak
          ? _value.maxStreak
          : maxStreak // ignore: cast_nullable_to_non_nullable
              as int,
      totalPointsEarned: null == totalPointsEarned
          ? _value.totalPointsEarned
          : totalPointsEarned // ignore: cast_nullable_to_non_nullable
              as int,
      completionRate: null == completionRate
          ? _value.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HabitStatsModelImplCopyWith<$Res>
    implements $HabitStatsModelCopyWith<$Res> {
  factory _$$HabitStatsModelImplCopyWith(_$HabitStatsModelImpl value,
          $Res Function(_$HabitStatsModelImpl) then) =
      __$$HabitStatsModelImplCopyWithImpl<$Res>;
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
class __$$HabitStatsModelImplCopyWithImpl<$Res>
    extends _$HabitStatsModelCopyWithImpl<$Res, _$HabitStatsModelImpl>
    implements _$$HabitStatsModelImplCopyWith<$Res> {
  __$$HabitStatsModelImplCopyWithImpl(
      _$HabitStatsModelImpl _value, $Res Function(_$HabitStatsModelImpl) _then)
      : super(_value, _then);

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
    return _then(_$HabitStatsModelImpl(
      habitId: null == habitId
          ? _value.habitId
          : habitId // ignore: cast_nullable_to_non_nullable
              as String,
      habitName: null == habitName
          ? _value.habitName
          : habitName // ignore: cast_nullable_to_non_nullable
              as String,
      totalCompletions: null == totalCompletions
          ? _value.totalCompletions
          : totalCompletions // ignore: cast_nullable_to_non_nullable
              as int,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      maxStreak: null == maxStreak
          ? _value.maxStreak
          : maxStreak // ignore: cast_nullable_to_non_nullable
              as int,
      totalPointsEarned: null == totalPointsEarned
          ? _value.totalPointsEarned
          : totalPointsEarned // ignore: cast_nullable_to_non_nullable
              as int,
      completionRate: null == completionRate
          ? _value.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$HabitStatsModelImpl extends _HabitStatsModel {
  const _$HabitStatsModelImpl(
      {@JsonKey(name: 'habit_id') required this.habitId,
      @JsonKey(name: 'habit_name') required this.habitName,
      @JsonKey(name: 'total_completions') required this.totalCompletions,
      @JsonKey(name: 'current_streak') required this.currentStreak,
      @JsonKey(name: 'max_streak') required this.maxStreak,
      @JsonKey(name: 'total_points_earned') required this.totalPointsEarned,
      @JsonKey(name: 'completion_rate') required this.completionRate})
      : super._();

  factory _$HabitStatsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$HabitStatsModelImplFromJson(json);

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

  @override
  String toString() {
    return 'HabitStatsModel(habitId: $habitId, habitName: $habitName, totalCompletions: $totalCompletions, currentStreak: $currentStreak, maxStreak: $maxStreak, totalPointsEarned: $totalPointsEarned, completionRate: $completionRate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HabitStatsModelImpl &&
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

  /// Create a copy of HabitStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HabitStatsModelImplCopyWith<_$HabitStatsModelImpl> get copyWith =>
      __$$HabitStatsModelImplCopyWithImpl<_$HabitStatsModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$HabitStatsModelImplToJson(
      this,
    );
  }
}

abstract class _HabitStatsModel extends HabitStatsModel {
  const factory _HabitStatsModel(
      {@JsonKey(name: 'habit_id') required final String habitId,
      @JsonKey(name: 'habit_name') required final String habitName,
      @JsonKey(name: 'total_completions') required final int totalCompletions,
      @JsonKey(name: 'current_streak') required final int currentStreak,
      @JsonKey(name: 'max_streak') required final int maxStreak,
      @JsonKey(name: 'total_points_earned')
      required final int totalPointsEarned,
      @JsonKey(name: 'completion_rate')
      required final double completionRate}) = _$HabitStatsModelImpl;
  const _HabitStatsModel._() : super._();

  factory _HabitStatsModel.fromJson(Map<String, dynamic> json) =
      _$HabitStatsModelImpl.fromJson;

  @override
  @JsonKey(name: 'habit_id')
  String get habitId;
  @override
  @JsonKey(name: 'habit_name')
  String get habitName;
  @override
  @JsonKey(name: 'total_completions')
  int get totalCompletions;
  @override
  @JsonKey(name: 'current_streak')
  int get currentStreak;
  @override
  @JsonKey(name: 'max_streak')
  int get maxStreak;
  @override
  @JsonKey(name: 'total_points_earned')
  int get totalPointsEarned;
  @override
  @JsonKey(name: 'completion_rate')
  double get completionRate;

  /// Create a copy of HabitStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HabitStatsModelImplCopyWith<_$HabitStatsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
