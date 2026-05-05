import 'package:flutter_test/flutter_test.dart';
import 'package:habitly/features/groups/domain/entities/group_entity.dart';

void main() {
  group('GroupEntity', () {
    const testId = 'group-123';
    const testName = 'Семья';
    const testDescription = 'Наши семейные привычки';
    const testCreatedBy = 'user-456';
    final testCreatedAt = DateTime(2026, 1, 15);
    const testIsActive = true;
    const testHabitsCount = 5;

    final fullGroup = GroupEntity(
      id: testId,
      name: testName,
      description: testDescription,
      createdBy: testCreatedBy,
      createdAt: testCreatedAt,
      isActive: testIsActive,
      habitsCount: testHabitsCount,
    );

    group('конструктор', () {
      test('should create entity with all parameters', () {
        expect(fullGroup.id, equals(testId));
        expect(fullGroup.name, equals(testName));
        expect(fullGroup.description, equals(testDescription));
        expect(fullGroup.createdBy, equals(testCreatedBy));
        expect(fullGroup.createdAt, equals(testCreatedAt));
        expect(fullGroup.isActive, equals(testIsActive));
        expect(fullGroup.habitsCount, equals(testHabitsCount));
      });

      test('should use default values when not provided', () {
        final minimalGroup = GroupEntity(
          id: testId,
          name: testName,
          createdBy: testCreatedBy,
          createdAt: testCreatedAt,
        );

        expect(minimalGroup.id, equals(testId));
        expect(minimalGroup.name, equals(testName));
        expect(minimalGroup.description, isNull);
        expect(minimalGroup.createdBy, equals(testCreatedBy));
        expect(minimalGroup.createdAt, equals(testCreatedAt));
        expect(minimalGroup.isActive, isTrue);
        expect(minimalGroup.habitsCount, equals(0));
      });

      test('should allow description to be null', () {
        final groupWithoutDesc = GroupEntity(
          id: testId,
          name: testName,
          createdBy: testCreatedBy,
          createdAt: testCreatedAt,
          description: null,
        );

        expect(groupWithoutDesc.description, isNull);
      });

      test('should allow isActive to be false', () {
        final inactiveGroup = GroupEntity(
          id: testId,
          name: testName,
          createdBy: testCreatedBy,
          createdAt: testCreatedAt,
          isActive: false,
        );

        expect(inactiveGroup.isActive, isFalse);
      });
    });

    group('Equatable', () {
      test('should consider equal objects as equal', () {
        final group1 = GroupEntity(
          id: testId,
          name: testName,
          createdBy: testCreatedBy,
          createdAt: testCreatedAt,
        );
        final group2 = GroupEntity(
          id: testId,
          name: testName,
          createdBy: testCreatedBy,
          createdAt: testCreatedAt,
        );

        expect(group1, equals(group2));
      });

      test('should consider objects with different id as not equal', () {
        final group1 = GroupEntity(
          id: 'group-1',
          name: testName,
          createdBy: testCreatedBy,
          createdAt: testCreatedAt,
        );
        final group2 = GroupEntity(
          id: 'group-2',
          name: testName,
          createdBy: testCreatedBy,
          createdAt: testCreatedAt,
        );

        expect(group1, isNot(equals(group2)));
      });

      test('should consider objects with different name as not equal', () {
        final group1 = GroupEntity(
          id: testId,
          name: 'Семья',
          createdBy: testCreatedBy,
          createdAt: testCreatedAt,
        );
        final group2 = GroupEntity(
          id: testId,
          name: 'Друзья',
          createdBy: testCreatedBy,
          createdAt: testCreatedAt,
        );

        expect(group1, isNot(equals(group2)));
      });

      test('should consider objects with different description as not equal', () {
        final group1 = GroupEntity(
          id: testId,
          name: testName,
          description: 'Описание',
          createdBy: testCreatedBy,
          createdAt: testCreatedAt,
        );
        final group2 = GroupEntity(
          id: testId,
          name: testName,
          description: 'Другое описание',
          createdBy: testCreatedBy,
          createdAt: testCreatedAt,
        );

        expect(group1, isNot(equals(group2)));
      });

      test('should consider null description and non-null description as not equal', () {
        final group1 = GroupEntity(
          id: testId,
          name: testName,
          description: null,
          createdBy: testCreatedBy,
          createdAt: testCreatedAt,
        );
        final group2 = GroupEntity(
          id: testId,
          name: testName,
          description: 'Описание',
          createdBy: testCreatedBy,
          createdAt: testCreatedAt,
        );

        expect(group1, isNot(equals(group2)));
      });

      test('should consider objects with different createdBy as not equal', () {
        final group1 = GroupEntity(
          id: testId,
          name: testName,
          createdBy: 'user-1',
          createdAt: testCreatedAt,
        );
        final group2 = GroupEntity(
          id: testId,
          name: testName,
          createdBy: 'user-2',
          createdAt: testCreatedAt,
        );

        expect(group1, isNot(equals(group2)));
      });

      test('should consider objects with different createdAt as not equal', () {
        final group1 = GroupEntity(
          id: testId,
          name: testName,
          createdBy: testCreatedBy,
          createdAt: DateTime(2026, 1, 1),
        );
        final group2 = GroupEntity(
          id: testId,
          name: testName,
          createdBy: testCreatedBy,
          createdAt: DateTime(2026, 2, 1),
        );

        expect(group1, isNot(equals(group2)));
      });

      test('should consider objects with different isActive as not equal', () {
        final group1 = GroupEntity(
          id: testId,
          name: testName,
          createdBy: testCreatedBy,
          createdAt: testCreatedAt,
          isActive: true,
        );
        final group2 = GroupEntity(
          id: testId,
          name: testName,
          createdBy: testCreatedBy,
          createdAt: testCreatedAt,
          isActive: false,
        );

        expect(group1, isNot(equals(group2)));
      });

      test('should consider objects with different habitsCount as not equal', () {
        final group1 = GroupEntity(
          id: testId,
          name: testName,
          createdBy: testCreatedBy,
          createdAt: testCreatedAt,
          habitsCount: 5,
        );
        final group2 = GroupEntity(
          id: testId,
          name: testName,
          createdBy: testCreatedBy,
          createdAt: testCreatedAt,
          habitsCount: 10,
        );

        expect(group1, isNot(equals(group2)));
      });
    });

    group('props', () {
      test('should return all fields in correct order', () {
        final group = GroupEntity(
          id: testId,
          name: testName,
          description: testDescription,
          createdBy: testCreatedBy,
          createdAt: testCreatedAt,
          isActive: testIsActive,
          habitsCount: testHabitsCount,
        );

        expect(
          group.props,
          equals([
            testId,
            testName,
            testDescription,
            testCreatedBy,
            testCreatedAt,
            testIsActive,
            testHabitsCount,
          ]),
        );
      });

      test('props should include null for description when null', () {
        final group = GroupEntity(
          id: testId,
          name: testName,
          createdBy: testCreatedBy,
          createdAt: testCreatedAt,
        );

        expect(group.props, contains(isNull));
        expect(group.props.length, equals(7));
      });
    });

    group('toString', () {
      test('should return string representation', () {
        final group = GroupEntity(
          id: testId,
          name: testName,
          createdBy: testCreatedBy,
          createdAt: testCreatedAt,
        );

        final str = group.toString();
        expect(str, contains('GroupEntity'));
        expect(str, contains(testId));
        expect(str, contains(testName));
      });
    });
  });
}