// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'achievement_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AchievementModel _$AchievementModelFromJson(Map<String, dynamic> json) {
  return _AchievementModel.fromJson(json);
}

/// @nodoc
mixin _$AchievementModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  @JsonKey(name: 'condition_value')
  int get conditionValue => throw _privateConstructorUsedError;
  @JsonKey(name: 'reward_points')
  int get rewardPoints => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_earned')
  bool get isEarned => throw _privateConstructorUsedError;
  int get progress => throw _privateConstructorUsedError;
  @JsonKey(name: 'progress_percent')
  double get progressPercent => throw _privateConstructorUsedError;
  @JsonKey(name: 'earned_at')
  String? get earnedAt => throw _privateConstructorUsedError;

  /// Serializes this AchievementModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AchievementModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AchievementModelCopyWith<AchievementModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AchievementModelCopyWith<$Res> {
  factory $AchievementModelCopyWith(
          AchievementModel value, $Res Function(AchievementModel) then) =
      _$AchievementModelCopyWithImpl<$Res, AchievementModel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String icon,
      String type,
      @JsonKey(name: 'condition_value') int conditionValue,
      @JsonKey(name: 'reward_points') int rewardPoints,
      @JsonKey(name: 'is_earned') bool isEarned,
      int progress,
      @JsonKey(name: 'progress_percent') double progressPercent,
      @JsonKey(name: 'earned_at') String? earnedAt});
}

/// @nodoc
class _$AchievementModelCopyWithImpl<$Res, $Val extends AchievementModel>
    implements $AchievementModelCopyWith<$Res> {
  _$AchievementModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AchievementModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? icon = null,
    Object? type = null,
    Object? conditionValue = null,
    Object? rewardPoints = null,
    Object? isEarned = null,
    Object? progress = null,
    Object? progressPercent = null,
    Object? earnedAt = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      conditionValue: null == conditionValue
          ? _value.conditionValue
          : conditionValue // ignore: cast_nullable_to_non_nullable
              as int,
      rewardPoints: null == rewardPoints
          ? _value.rewardPoints
          : rewardPoints // ignore: cast_nullable_to_non_nullable
              as int,
      isEarned: null == isEarned
          ? _value.isEarned
          : isEarned // ignore: cast_nullable_to_non_nullable
              as bool,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as int,
      progressPercent: null == progressPercent
          ? _value.progressPercent
          : progressPercent // ignore: cast_nullable_to_non_nullable
              as double,
      earnedAt: freezed == earnedAt
          ? _value.earnedAt
          : earnedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AchievementModelImplCopyWith<$Res>
    implements $AchievementModelCopyWith<$Res> {
  factory _$$AchievementModelImplCopyWith(_$AchievementModelImpl value,
          $Res Function(_$AchievementModelImpl) then) =
      __$$AchievementModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      String icon,
      String type,
      @JsonKey(name: 'condition_value') int conditionValue,
      @JsonKey(name: 'reward_points') int rewardPoints,
      @JsonKey(name: 'is_earned') bool isEarned,
      int progress,
      @JsonKey(name: 'progress_percent') double progressPercent,
      @JsonKey(name: 'earned_at') String? earnedAt});
}

/// @nodoc
class __$$AchievementModelImplCopyWithImpl<$Res>
    extends _$AchievementModelCopyWithImpl<$Res, _$AchievementModelImpl>
    implements _$$AchievementModelImplCopyWith<$Res> {
  __$$AchievementModelImplCopyWithImpl(_$AchievementModelImpl _value,
      $Res Function(_$AchievementModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of AchievementModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? icon = null,
    Object? type = null,
    Object? conditionValue = null,
    Object? rewardPoints = null,
    Object? isEarned = null,
    Object? progress = null,
    Object? progressPercent = null,
    Object? earnedAt = freezed,
  }) {
    return _then(_$AchievementModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      conditionValue: null == conditionValue
          ? _value.conditionValue
          : conditionValue // ignore: cast_nullable_to_non_nullable
              as int,
      rewardPoints: null == rewardPoints
          ? _value.rewardPoints
          : rewardPoints // ignore: cast_nullable_to_non_nullable
              as int,
      isEarned: null == isEarned
          ? _value.isEarned
          : isEarned // ignore: cast_nullable_to_non_nullable
              as bool,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as int,
      progressPercent: null == progressPercent
          ? _value.progressPercent
          : progressPercent // ignore: cast_nullable_to_non_nullable
              as double,
      earnedAt: freezed == earnedAt
          ? _value.earnedAt
          : earnedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AchievementModelImpl extends _AchievementModel {
  const _$AchievementModelImpl(
      {required this.id,
      required this.name,
      required this.description,
      required this.icon,
      required this.type,
      @JsonKey(name: 'condition_value') required this.conditionValue,
      @JsonKey(name: 'reward_points') required this.rewardPoints,
      @JsonKey(name: 'is_earned') required this.isEarned,
      required this.progress,
      @JsonKey(name: 'progress_percent') required this.progressPercent,
      @JsonKey(name: 'earned_at') this.earnedAt})
      : super._();

  factory _$AchievementModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AchievementModelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  final String icon;
  @override
  final String type;
  @override
  @JsonKey(name: 'condition_value')
  final int conditionValue;
  @override
  @JsonKey(name: 'reward_points')
  final int rewardPoints;
  @override
  @JsonKey(name: 'is_earned')
  final bool isEarned;
  @override
  final int progress;
  @override
  @JsonKey(name: 'progress_percent')
  final double progressPercent;
  @override
  @JsonKey(name: 'earned_at')
  final String? earnedAt;

  @override
  String toString() {
    return 'AchievementModel(id: $id, name: $name, description: $description, icon: $icon, type: $type, conditionValue: $conditionValue, rewardPoints: $rewardPoints, isEarned: $isEarned, progress: $progress, progressPercent: $progressPercent, earnedAt: $earnedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AchievementModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.conditionValue, conditionValue) ||
                other.conditionValue == conditionValue) &&
            (identical(other.rewardPoints, rewardPoints) ||
                other.rewardPoints == rewardPoints) &&
            (identical(other.isEarned, isEarned) ||
                other.isEarned == isEarned) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.progressPercent, progressPercent) ||
                other.progressPercent == progressPercent) &&
            (identical(other.earnedAt, earnedAt) ||
                other.earnedAt == earnedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      description,
      icon,
      type,
      conditionValue,
      rewardPoints,
      isEarned,
      progress,
      progressPercent,
      earnedAt);

  /// Create a copy of AchievementModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AchievementModelImplCopyWith<_$AchievementModelImpl> get copyWith =>
      __$$AchievementModelImplCopyWithImpl<_$AchievementModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AchievementModelImplToJson(
      this,
    );
  }
}

abstract class _AchievementModel extends AchievementModel {
  const factory _AchievementModel(
      {required final String id,
      required final String name,
      required final String description,
      required final String icon,
      required final String type,
      @JsonKey(name: 'condition_value') required final int conditionValue,
      @JsonKey(name: 'reward_points') required final int rewardPoints,
      @JsonKey(name: 'is_earned') required final bool isEarned,
      required final int progress,
      @JsonKey(name: 'progress_percent') required final double progressPercent,
      @JsonKey(name: 'earned_at')
      final String? earnedAt}) = _$AchievementModelImpl;
  const _AchievementModel._() : super._();

  factory _AchievementModel.fromJson(Map<String, dynamic> json) =
      _$AchievementModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  String get icon;
  @override
  String get type;
  @override
  @JsonKey(name: 'condition_value')
  int get conditionValue;
  @override
  @JsonKey(name: 'reward_points')
  int get rewardPoints;
  @override
  @JsonKey(name: 'is_earned')
  bool get isEarned;
  @override
  int get progress;
  @override
  @JsonKey(name: 'progress_percent')
  double get progressPercent;
  @override
  @JsonKey(name: 'earned_at')
  String? get earnedAt;

  /// Create a copy of AchievementModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AchievementModelImplCopyWith<_$AchievementModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
