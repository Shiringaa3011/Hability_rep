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
  });

  TodayHabitEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? scheduledTimeLabel,
    String? frequencyLabel,
    bool? completedToday,
    String? groupId,
    String? groupName,
    bool? remindersEnabled,
    String? reminderTimeLabel,
  }) {
    return TodayHabitEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      scheduledTimeLabel: scheduledTimeLabel ?? this.scheduledTimeLabel,
      frequencyLabel: frequencyLabel ?? this.frequencyLabel,
      completedToday: completedToday ?? this.completedToday,
      groupId: groupId ?? this.groupId,
      groupName: groupName ?? this.groupName,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      reminderTimeLabel: reminderTimeLabel ?? this.reminderTimeLabel,
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
