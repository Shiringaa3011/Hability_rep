import 'package:equatable/equatable.dart';

class TodayHabitEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? scheduledTimeLabel;
  final String? frequencyLabel;
  final bool completedToday;
  final String? groupId;
  final String? groupName;
  final bool remindersEnabled;
  final String? reminderTimeLabel;
  final int? dayOfWeek;

  const TodayHabitEntity({
    required this.id,
    required this.title,
    this.description,
    this.scheduledTimeLabel,
    this.frequencyLabel,
    this.completedToday = false,
    this.groupId,
    this.groupName,
    this.remindersEnabled = false,
    this.reminderTimeLabel,
    this.dayOfWeek,
  });

  static const _unset = Object();

  TodayHabitEntity copyWith({
    String? id,
    String? title,
    Object? description = _unset,
    Object? scheduledTimeLabel = _unset,
    Object? frequencyLabel = _unset,
    bool? completedToday,
    Object? groupId = _unset,
    Object? groupName = _unset,
    bool? remindersEnabled,
    Object? reminderTimeLabel = _unset,
    Object? dayOfWeek = _unset,
  }) {
    return TodayHabitEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description == _unset ? this.description : description as String?,
      scheduledTimeLabel: scheduledTimeLabel == _unset
          ? this.scheduledTimeLabel
          : scheduledTimeLabel as String?,
      frequencyLabel: frequencyLabel == _unset
          ? this.frequencyLabel
          : frequencyLabel as String?,
      completedToday: completedToday ?? this.completedToday,
      groupId: groupId == _unset ? this.groupId : groupId as String?,
      groupName: groupName == _unset ? this.groupName : groupName as String?,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      reminderTimeLabel: reminderTimeLabel == _unset
          ? this.reminderTimeLabel
          : reminderTimeLabel as String?,
      dayOfWeek: dayOfWeek == _unset ? this.dayOfWeek : dayOfWeek as int?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        scheduledTimeLabel,
        frequencyLabel,
        completedToday,
        groupId,
        groupName,
        remindersEnabled,
        reminderTimeLabel,
      ];
}
