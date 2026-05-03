// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'achievement_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AchievementModel {
  String get id;
  String get name;
  String get description;
  String get icon;
  String get type;
  @JsonKey(name: 'condition_value')
  int get conditionValue;
  @JsonKey(name: 'reward_points')
  int get rewardPoints;
  @JsonKey(name: 'is_earned')
  bool get isEarned;
  int get progress;
  @JsonKey(name: 'progress_percent')
  double get progressPercent;
  @JsonKey(name: 'earned_at')
  String? get earnedAt;

  /// Create a copy of AchievementModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AchievementModelCopyWith<AchievementModel> get copyWith =>
      _$AchievementModelCopyWithImpl<AchievementModel>(
          this as AchievementModel, _$identity);

  /// Serializes this AchievementModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AchievementModel &&
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

  @override
  String toString() {
    return 'AchievementModel(id: $id, name: $name, description: $description, icon: $icon, type: $type, conditionValue: $conditionValue, rewardPoints: $rewardPoints, isEarned: $isEarned, progress: $progress, progressPercent: $progressPercent, earnedAt: $earnedAt)';
  }
}

/// @nodoc
abstract mixin class $AchievementModelCopyWith<$Res> {
  factory $AchievementModelCopyWith(
          AchievementModel value, $Res Function(AchievementModel) _then) =
      _$AchievementModelCopyWithImpl;
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
class _$AchievementModelCopyWithImpl<$Res>
    implements $AchievementModelCopyWith<$Res> {
  _$AchievementModelCopyWithImpl(this._self, this._then);

  final AchievementModel _self;
  final $Res Function(AchievementModel) _then;

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
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _self.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      conditionValue: null == conditionValue
          ? _self.conditionValue
          : conditionValue // ignore: cast_nullable_to_non_nullable
              as int,
      rewardPoints: null == rewardPoints
          ? _self.rewardPoints
          : rewardPoints // ignore: cast_nullable_to_non_nullable
              as int,
      isEarned: null == isEarned
          ? _self.isEarned
          : isEarned // ignore: cast_nullable_to_non_nullable
              as bool,
      progress: null == progress
          ? _self.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as int,
      progressPercent: null == progressPercent
          ? _self.progressPercent
          : progressPercent // ignore: cast_nullable_to_non_nullable
              as double,
      earnedAt: freezed == earnedAt
          ? _self.earnedAt
          : earnedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [AchievementModel].
extension AchievementModelPatterns on AchievementModel {
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
    TResult Function(_AchievementModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AchievementModel() when $default != null:
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
    TResult Function(_AchievementModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AchievementModel():
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
    TResult? Function(_AchievementModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AchievementModel() when $default != null:
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
            String id,
            String name,
            String description,
            String icon,
            String type,
            @JsonKey(name: 'condition_value') int conditionValue,
            @JsonKey(name: 'reward_points') int rewardPoints,
            @JsonKey(name: 'is_earned') bool isEarned,
            int progress,
            @JsonKey(name: 'progress_percent') double progressPercent,
            @JsonKey(name: 'earned_at') String? earnedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AchievementModel() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.description,
            _that.icon,
            _that.type,
            _that.conditionValue,
            _that.rewardPoints,
            _that.isEarned,
            _that.progress,
            _that.progressPercent,
            _that.earnedAt);
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
            String id,
            String name,
            String description,
            String icon,
            String type,
            @JsonKey(name: 'condition_value') int conditionValue,
            @JsonKey(name: 'reward_points') int rewardPoints,
            @JsonKey(name: 'is_earned') bool isEarned,
            int progress,
            @JsonKey(name: 'progress_percent') double progressPercent,
            @JsonKey(name: 'earned_at') String? earnedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AchievementModel():
        return $default(
            _that.id,
            _that.name,
            _that.description,
            _that.icon,
            _that.type,
            _that.conditionValue,
            _that.rewardPoints,
            _that.isEarned,
            _that.progress,
            _that.progressPercent,
            _that.earnedAt);
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
            String id,
            String name,
            String description,
            String icon,
            String type,
            @JsonKey(name: 'condition_value') int conditionValue,
            @JsonKey(name: 'reward_points') int rewardPoints,
            @JsonKey(name: 'is_earned') bool isEarned,
            int progress,
            @JsonKey(name: 'progress_percent') double progressPercent,
            @JsonKey(name: 'earned_at') String? earnedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AchievementModel() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.description,
            _that.icon,
            _that.type,
            _that.conditionValue,
            _that.rewardPoints,
            _that.isEarned,
            _that.progress,
            _that.progressPercent,
            _that.earnedAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _AchievementModel extends AchievementModel {
  const _AchievementModel(
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
  factory _AchievementModel.fromJson(Map<String, dynamic> json) =>
      _$AchievementModelFromJson(json);

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

  /// Create a copy of AchievementModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AchievementModelCopyWith<_AchievementModel> get copyWith =>
      __$AchievementModelCopyWithImpl<_AchievementModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AchievementModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AchievementModel &&
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

  @override
  String toString() {
    return 'AchievementModel(id: $id, name: $name, description: $description, icon: $icon, type: $type, conditionValue: $conditionValue, rewardPoints: $rewardPoints, isEarned: $isEarned, progress: $progress, progressPercent: $progressPercent, earnedAt: $earnedAt)';
  }
}

/// @nodoc
abstract mixin class _$AchievementModelCopyWith<$Res>
    implements $AchievementModelCopyWith<$Res> {
  factory _$AchievementModelCopyWith(
          _AchievementModel value, $Res Function(_AchievementModel) _then) =
      __$AchievementModelCopyWithImpl;
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
class __$AchievementModelCopyWithImpl<$Res>
    implements _$AchievementModelCopyWith<$Res> {
  __$AchievementModelCopyWithImpl(this._self, this._then);

  final _AchievementModel _self;
  final $Res Function(_AchievementModel) _then;

  /// Create a copy of AchievementModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_AchievementModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      icon: null == icon
          ? _self.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      conditionValue: null == conditionValue
          ? _self.conditionValue
          : conditionValue // ignore: cast_nullable_to_non_nullable
              as int,
      rewardPoints: null == rewardPoints
          ? _self.rewardPoints
          : rewardPoints // ignore: cast_nullable_to_non_nullable
              as int,
      isEarned: null == isEarned
          ? _self.isEarned
          : isEarned // ignore: cast_nullable_to_non_nullable
              as bool,
      progress: null == progress
          ? _self.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as int,
      progressPercent: null == progressPercent
          ? _self.progressPercent
          : progressPercent // ignore: cast_nullable_to_non_nullable
              as double,
      earnedAt: freezed == earnedAt
          ? _self.earnedAt
          : earnedAt // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
