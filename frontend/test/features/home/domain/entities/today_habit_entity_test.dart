import 'package:flutter_test/flutter_test.dart';
import 'package:habitly/features/home/domain/entities/today_habit_entity.dart';

void main() {
  group('TodayHabitEntity', () {
    const testId = 'habit-123';
    const testTitle = 'Утренняя зарядка';
    const testDescription = 'Делать зарядку каждое утро';
    const testScheduledTimeLabel = '08:00';
    const testFrequencyLabel = 'Ежедневно';
    const testGroupId = 'group-456';
    const testGroupName = 'Семья';
    const testReminderTimeLabel = '07:55';
    const testDayOfWeek = 3;

    final fullHabit = TodayHabitEntity(
      id: testId,
      title: testTitle,
      description: testDescription,
      scheduledTimeLabel: testScheduledTimeLabel,
      frequencyLabel: testFrequencyLabel,
      completedToday: true,
      groupId: testGroupId,
      groupName: testGroupName,
      remindersEnabled: true,
      reminderTimeLabel: testReminderTimeLabel,
      dayOfWeek: testDayOfWeek,
    );

    group('constructor', () {
      test('should create entity with all parameters', () {
        expect(fullHabit.id, equals(testId));
        expect(fullHabit.title, equals(testTitle));
        expect(fullHabit.description, equals(testDescription));
        expect(fullHabit.scheduledTimeLabel, equals(testScheduledTimeLabel));
        expect(fullHabit.frequencyLabel, equals(testFrequencyLabel));
        expect(fullHabit.completedToday, isTrue);
        expect(fullHabit.groupId, equals(testGroupId));
        expect(fullHabit.groupName, equals(testGroupName));
        expect(fullHabit.remindersEnabled, isTrue);
        expect(fullHabit.reminderTimeLabel, equals(testReminderTimeLabel));
        expect(fullHabit.dayOfWeek, equals(testDayOfWeek));
      });

      test('should use default values when not provided', () {
        const minimalHabit = TodayHabitEntity(
          id: testId,
          title: testTitle,
        );

        expect(minimalHabit.id, equals(testId));
        expect(minimalHabit.title, equals(testTitle));
        expect(minimalHabit.description, isNull);
        expect(minimalHabit.scheduledTimeLabel, isNull);
        expect(minimalHabit.frequencyLabel, isNull);
        expect(minimalHabit.completedToday, isFalse);
        expect(minimalHabit.groupId, isNull);
        expect(minimalHabit.groupName, isNull);
        expect(minimalHabit.remindersEnabled, isFalse);
        expect(minimalHabit.reminderTimeLabel, isNull);
        expect(minimalHabit.dayOfWeek, isNull);
      });

      test('should allow description to be null', () {
        const habitWithoutDesc = TodayHabitEntity(
          id: testId,
          title: testTitle,
          description: null,
        );
        expect(habitWithoutDesc.description, isNull);
      });

      test('should allow dayOfWeek to be null for daily habits', () {
        const dailyHabit = TodayHabitEntity(
          id: testId,
          title: testTitle,
          dayOfWeek: null,
        );
        expect(dailyHabit.dayOfWeek, isNull);
      });
    });

    group('copyWith', () {
      test('should create copy with updated title', () {
        const newTitle = 'Вечерняя зарядка';
        final updated = fullHabit.copyWith(title: newTitle);
        expect(updated.title, equals(newTitle));
        expect(updated.id, equals(fullHabit.id));
        expect(updated.description, equals(fullHabit.description));
        expect(updated.scheduledTimeLabel, equals(fullHabit.scheduledTimeLabel));
        expect(updated.completedToday, equals(fullHabit.completedToday));
      });

      test('should create copy with updated completedToday', () {
        final updated = fullHabit.copyWith(completedToday: false);
        expect(updated.completedToday, isFalse);
        expect(updated.title, equals(fullHabit.title));
      });

      test('should create copy with updated description to null', () {
        final updated = fullHabit.copyWith(description: null);
        expect(updated.description, isNull);
      });

      test('should create copy with updated groupId and groupName', () {
        const newGroupId = 'group-789';
        const newGroupName = 'Друзья';
        final updated = fullHabit.copyWith(
          groupId: newGroupId,
          groupName: newGroupName,
        );
        expect(updated.groupId, equals(newGroupId));
        expect(updated.groupName, equals(newGroupName));
      });

      test('should create copy with updated remindersEnabled and reminderTimeLabel', () {
        const newReminderTime = '08:30';
        final updated = fullHabit.copyWith(
          remindersEnabled: false,
          reminderTimeLabel: newReminderTime,
        );
        expect(updated.remindersEnabled, isFalse);
        expect(updated.reminderTimeLabel, equals(newReminderTime));
      });

      test('should not change other fields when copying with no parameters', () {
        final updated = fullHabit.copyWith();
        expect(updated, equals(fullHabit));
      });
    });

    group('Equatable', () {
      test('should consider equal objects as equal', () {
        const habit1 = TodayHabitEntity(
          id: testId,
          title: testTitle,
          description: testDescription,
        );
        const habit2 = TodayHabitEntity(
          id: testId,
          title: testTitle,
          description: testDescription,
        );
        expect(habit1, equals(habit2));
      });

      test('should consider objects with different id as not equal', () {
        const habit1 = TodayHabitEntity(id: 'habit-1', title: testTitle);
        const habit2 = TodayHabitEntity(id: 'habit-2', title: testTitle);
        expect(habit1, isNot(equals(habit2)));
      });

      test('should consider objects with different title as not equal', () {
        const habit1 = TodayHabitEntity(id: testId, title: 'Привычка 1');
        const habit2 = TodayHabitEntity(id: testId, title: 'Привычка 2');
        expect(habit1, isNot(equals(habit2)));
      });

      test('should consider objects with different completedToday as not equal', () {
        const habit1 = TodayHabitEntity(
          id: testId,
          title: testTitle,
          completedToday: false,
        );
        const habit2 = TodayHabitEntity(
          id: testId,
          title: testTitle,
          completedToday: true,
        );
        expect(habit1, isNot(equals(habit2)));
      });

      test('should consider objects with different groupId as not equal', () {
        const habit1 = TodayHabitEntity(
          id: testId,
          title: testTitle,
          groupId: 'group-1',
        );
        const habit2 = TodayHabitEntity(
          id: testId,
          title: testTitle,
          groupId: 'group-2',
        );
        expect(habit1, isNot(equals(habit2)));
      });

      test('should consider null groupId and non-null groupId as not equal', () {
        const habit1 = TodayHabitEntity(id: testId, title: testTitle, groupId: null);
        const habit2 = TodayHabitEntity(id: testId, title: testTitle, groupId: 'group-1');
        expect(habit1, isNot(equals(habit2)));
      });

      test('should consider objects with different remindersEnabled as not equal', () {
        const habit1 = TodayHabitEntity(
          id: testId,
          title: testTitle,
          remindersEnabled: false,
        );
        const habit2 = TodayHabitEntity(
          id: testId,
          title: testTitle,
          remindersEnabled: true,
        );
        expect(habit1, isNot(equals(habit2)));
      });
    });

    group('props', () {
      test('should return all fields in correct order', () {
        const habit = TodayHabitEntity(
          id: testId,
          title: testTitle,
          description: testDescription,
          scheduledTimeLabel: testScheduledTimeLabel,
          frequencyLabel: testFrequencyLabel,
          completedToday: true,
          groupId: testGroupId,
          groupName: testGroupName,
          remindersEnabled: true,
          reminderTimeLabel: testReminderTimeLabel,
        );

        expect(
          habit.props,
          equals([
            testId,
            testTitle,
            testDescription,
            testScheduledTimeLabel,
            testFrequencyLabel,
            true,
            testGroupId,
            testGroupName,
            true,
            testReminderTimeLabel,
          ]),
        );
      });

      test('should include nulls for optional fields', () {
        const habit = TodayHabitEntity(
          id: testId,
          title: testTitle,
        );

        expect(habit.props, contains(isNull));
        expect(habit.props.length, equals(10));
      });
    });

    group('toString', () {
      test('should return string representation', () {
        const habit = TodayHabitEntity(
          id: testId,
          title: testTitle,
        );

        final str = habit.toString();
        expect(str, contains('TodayHabitEntity'));
        expect(str, contains(testId));
        expect(str, contains(testTitle));
      });
    });
  });
}