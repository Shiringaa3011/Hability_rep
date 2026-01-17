// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_stats_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserStatsModel _$UserStatsModelFromJson(Map<String, dynamic> json) {
  return _UserStatsModel.fromJson(json);
}

/// @nodoc
mixin _$UserStatsModel {
  @JsonKey(name: 'user_id')
  String get userId => throw _privateConstructorUsedError;
  String get period => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_completions')
  int get totalCompletions => throw _privateConstructorUsedError;
  @JsonKey(name: 'completion_rate')
  double get completionRate => throw _privateConstructorUsedError;
  @JsonKey(name: 'current_streak')
  int get currentStreak => throw _privateConstructorUsedError;
  @JsonKey(name: 'max_streak')
  int get maxStreak => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_points_earned')
  int get totalPointsEarned => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this UserStatsModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserStatsModelCopyWith<UserStatsModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserStatsModelCopyWith<$Res> {
  factory $UserStatsModelCopyWith(
          UserStatsModel value, $Res Function(UserStatsModel) then) =
      _$UserStatsModelCopyWithImpl<$Res, UserStatsModel>;
  @useResult
  $Res call(
      {@JsonKey(name: 'user_id') String userId,
      String period,
      @JsonKey(name: 'total_completions') int totalCompletions,
      @JsonKey(name: 'completion_rate') double completionRate,
      @JsonKey(name: 'current_streak') int currentStreak,
      @JsonKey(name: 'max_streak') int maxStreak,
      @JsonKey(name: 'total_points_earned') int totalPointsEarned,
      @JsonKey(name: 'updated_at') String updatedAt});
}

/// @nodoc
class _$UserStatsModelCopyWithImpl<$Res, $Val extends UserStatsModel>
    implements $UserStatsModelCopyWith<$Res> {
  _$UserStatsModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as String,
      totalCompletions: null == totalCompletions
          ? _value.totalCompletions
          : totalCompletions // ignore: cast_nullable_to_non_nullable
              as int,
      completionRate: null == completionRate
          ? _value.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double,
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
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserStatsModelImplCopyWith<$Res>
    implements $UserStatsModelCopyWith<$Res> {
  factory _$$UserStatsModelImplCopyWith(_$UserStatsModelImpl value,
          $Res Function(_$UserStatsModelImpl) then) =
      __$$UserStatsModelImplCopyWithImpl<$Res>;
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
      @JsonKey(name: 'updated_at') String updatedAt});
}

/// @nodoc
class __$$UserStatsModelImplCopyWithImpl<$Res>
    extends _$UserStatsModelCopyWithImpl<$Res, _$UserStatsModelImpl>
    implements _$$UserStatsModelImplCopyWith<$Res> {
  __$$UserStatsModelImplCopyWithImpl(
      _$UserStatsModelImpl _value, $Res Function(_$UserStatsModelImpl) _then)
      : super(_value, _then);

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
  }) {
    return _then(_$UserStatsModelImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      period: null == period
          ? _value.period
          : period // ignore: cast_nullable_to_non_nullable
              as String,
      totalCompletions: null == totalCompletions
          ? _value.totalCompletions
          : totalCompletions // ignore: cast_nullable_to_non_nullable
              as int,
      completionRate: null == completionRate
          ? _value.completionRate
          : completionRate // ignore: cast_nullable_to_non_nullable
              as double,
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
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserStatsModelImpl extends _UserStatsModel {
  const _$UserStatsModelImpl(
      {@JsonKey(name: 'user_id') required this.userId,
      required this.period,
      @JsonKey(name: 'total_completions') required this.totalCompletions,
      @JsonKey(name: 'completion_rate') required this.completionRate,
      @JsonKey(name: 'current_streak') required this.currentStreak,
      @JsonKey(name: 'max_streak') required this.maxStreak,
      @JsonKey(name: 'total_points_earned') required this.totalPointsEarned,
      @JsonKey(name: 'updated_at') required this.updatedAt})
      : super._();

  factory _$UserStatsModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserStatsModelImplFromJson(json);

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
  String toString() {
    return 'UserStatsModel(userId: $userId, period: $period, totalCompletions: $totalCompletions, completionRate: $completionRate, currentStreak: $currentStreak, maxStreak: $maxStreak, totalPointsEarned: $totalPointsEarned, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserStatsModelImpl &&
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
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, userId, period, totalCompletions,
      completionRate, currentStreak, maxStreak, totalPointsEarned, updatedAt);

  /// Create a copy of UserStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserStatsModelImplCopyWith<_$UserStatsModelImpl> get copyWith =>
      __$$UserStatsModelImplCopyWithImpl<_$UserStatsModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserStatsModelImplToJson(
      this,
    );
  }
}

abstract class _UserStatsModel extends UserStatsModel {
  const factory _UserStatsModel(
      {@JsonKey(name: 'user_id') required final String userId,
      required final String period,
      @JsonKey(name: 'total_completions') required final int totalCompletions,
      @JsonKey(name: 'completion_rate') required final double completionRate,
      @JsonKey(name: 'current_streak') required final int currentStreak,
      @JsonKey(name: 'max_streak') required final int maxStreak,
      @JsonKey(name: 'total_points_earned')
      required final int totalPointsEarned,
      @JsonKey(name: 'updated_at')
      required final String updatedAt}) = _$UserStatsModelImpl;
  const _UserStatsModel._() : super._();

  factory _UserStatsModel.fromJson(Map<String, dynamic> json) =
      _$UserStatsModelImpl.fromJson;

  @override
  @JsonKey(name: 'user_id')
  String get userId;
  @override
  String get period;
  @override
  @JsonKey(name: 'total_completions')
  int get totalCompletions;
  @override
  @JsonKey(name: 'completion_rate')
  double get completionRate;
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
  @JsonKey(name: 'updated_at')
  String get updatedAt;

  /// Create a copy of UserStatsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserStatsModelImplCopyWith<_$UserStatsModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
