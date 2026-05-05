import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:habitly/core/design_system/widgets/ds_card.dart';
import 'package:habitly/features/groups/domain/entities/group_entity.dart';
import 'package:habitly/features/groups/presentation/bloc/groups_bloc.dart';
import 'package:habitly/features/groups/presentation/bloc/groups_event.dart';
import 'package:habitly/features/groups/presentation/bloc/groups_state.dart';
import 'package:habitly/features/groups/presentation/pages/groups_page.dart';
import 'package:habitly/features/groups/presentation/pages/create_group_page.dart';
import 'package:habitly/features/groups/presentation/pages/group_detail_page.dart';

import 'package:get_it/get_it.dart';
import 'package:habitly/features/groups/domain/repositories/group_repository.dart';
import 'package:habitly/features/groups/domain/usecases/create_group.dart';
import 'package:habitly/features/groups/domain/usecases/get_group_details.dart';
import 'package:habitly/features/groups/domain/usecases/leave_group.dart';
import 'package:habitly/features/groups/domain/usecases/remove_member.dart';
import 'package:habitly/features/groups/domain/usecases/send_reaction.dart';
import 'package:habitly/features/groups/presentation/bloc/group_detail_state.dart';

import '../bloc/group_detail_bloc_test.mocks.dart';
import 'groups_page_widget_test.mocks.dart';

@GenerateMocks([GroupsBloc, CreateGroup])
void main() {
  late MockGroupsBloc mockGroupsBloc;
  late MockGetGroupDetails mockGetGroupDetails;
  late MockLeaveGroup mockLeaveGroup;
  late MockRemoveMember mockRemoveMember;
  late MockSendReaction mockSendReaction;
  late MockGroupRepository mockGroupRepository;
  late MockCreateGroup mockCreateGroup;

  const testUserId = 'user-123';

  final testGroups = [
    GroupEntity(
      id: 'group-1',
      name: 'Семья',
      description: 'Наши семейные привычки',
      createdBy: testUserId,
      createdAt: DateTime(2026, 1, 1),
      isActive: true,
      habitsCount: 3,
    ),
    GroupEntity(
      id: 'group-2',
      name: 'Друзья',
      description: null,
      createdBy: 'user-456',
      createdAt: DateTime(2026, 1, 15),
      isActive: true,
      habitsCount: 1,
    ),
  ];

  final initialState = GroupsState(
    groups: [],
    isLoading: false,
    error: null,
  );

  final loadingState = GroupsState(
    groups: [],
    isLoading: true,
    error: null,
  );

  final loadedState = GroupsState(
    groups: testGroups,
    isLoading: false,
    error: null,
  );

  final errorState = GroupsState(
    groups: [],
    isLoading: false,
    error: 'Ошибка загрузки',
  );

  setUp(() async {
    mockGroupsBloc = MockGroupsBloc();
    mockGetGroupDetails = MockGetGroupDetails();
    mockLeaveGroup = MockLeaveGroup();
    mockRemoveMember = MockRemoveMember();
    mockSendReaction = MockSendReaction();
    mockGroupRepository = MockGroupRepository();
    mockCreateGroup = MockCreateGroup();

    final groupDetail = GroupDetail(
      group: testGroups.first,
      members: const [],
      groupAchievements: const [],
    );
    when(mockGetGroupDetails(any, any)).thenAnswer((_) async => groupDetail);
    when(mockCreateGroup(
      creatorUserId: anyNamed('creatorUserId'),
      name: anyNamed('name'),
      description: anyNamed('description'),
    )).thenAnswer((_) async => testGroups.first);

    await GetIt.instance.reset();
    GetIt.instance.registerLazySingleton<GetGroupDetails>(() => mockGetGroupDetails);
    GetIt.instance.registerLazySingleton<LeaveGroup>(() => mockLeaveGroup);
    GetIt.instance.registerLazySingleton<RemoveMember>(() => mockRemoveMember);
    GetIt.instance.registerLazySingleton<SendReaction>(() => mockSendReaction);
    GetIt.instance.registerLazySingleton<GroupRepository>(() => mockGroupRepository);
    GetIt.instance.registerLazySingleton<CreateGroup>(() => mockCreateGroup);
  });

  tearDown(() async {
    await GetIt.instance.reset();
  });

  void stubBlocState(GroupsState state) {
    when(mockGroupsBloc.state).thenReturn(state);
    when(mockGroupsBloc.stream).thenAnswer((_) => Stream.value(state));
  }

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: GroupsPage(userId: testUserId, groupsBloc: mockGroupsBloc),
    );
  }

  group('GroupsPage', () {
    testWidgets('shows loading indicator when loading', (tester) async {
      stubBlocState(loadingState);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Группы'), findsNothing);
    });

    testWidgets('shows error widget when error and empty groups', (tester) async {
      stubBlocState(errorState);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Не удалось загрузить группы'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.text('Группы'), findsNothing);
    });

    testWidgets('shows groups list when loaded', (tester) async {
      stubBlocState(loadedState);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Группы'), findsOneWidget);
      expect(find.text('2 группы'), findsOneWidget);
      expect(find.text('Семья'), findsOneWidget);
      expect(find.text('Наши семейные привычки'), findsOneWidget);
      expect(find.text('Друзья'), findsOneWidget);
    });

    testWidgets('shows empty state when no groups', (tester) async {
      final emptyState = GroupsState(
        groups: [],
        isLoading: false,
        error: null,
      );
      stubBlocState(emptyState);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Группы'), findsOneWidget);
      expect(find.text('Нет групп — создайте первую'), findsOneWidget);
      expect(find.text('Пока вы не состоите в группах'), findsOneWidget);
      expect(find.text('Семья'), findsNothing);
    });

    testWidgets('shows 1 group plural', (tester) async {
      stubBlocState(GroupsState(
        groups: testGroups.take(1).toList(),
        isLoading: false,
        error: null,
      ));
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text('1 группа'), findsOneWidget);
    });

    testWidgets('shows 2 groups plural', (tester) async {
      stubBlocState(loadedState);
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text('2 группы'), findsOneWidget);
    });

    testWidgets('shows 3 groups plural', (tester) async {
      stubBlocState(GroupsState(
        groups: [...testGroups, testGroups[0]],
        isLoading: false,
        error: null,
      ));
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text('3 группы'), findsOneWidget);
    });

    testWidgets('shows 5 groups plural', (tester) async {
      stubBlocState(GroupsState(
        groups: [...testGroups, ...testGroups, testGroups[0]],
        isLoading: false,
        error: null,
      ));
      await tester.pumpWidget(createWidgetUnderTest());
      expect(find.text('5 групп'), findsOneWidget);
    });
  });

  group('GroupTile', () {
    testWidgets('displays group name and description', (tester) async {
      stubBlocState(loadedState);

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Семья'), findsOneWidget);
      expect(find.text('Наши семейные привычки'), findsOneWidget);
      expect(find.text('Друзья'), findsOneWidget);
    });

    testWidgets('displays only name when description is null', (tester) async {
      stubBlocState(loadedState);

      await tester.pumpWidget(createWidgetUnderTest());

      final groupTile = find.widgetWithText(DSCard, 'Друзья');
      expect(groupTile, findsOneWidget);
    });

    testWidgets('navigates to GroupDetailPage on tap', (tester) async {
      stubBlocState(loadedState);

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Семья'));
      await tester.pumpAndSettle();

      expect(find.byType(GroupDetailPage), findsOneWidget);
    });
  });

  group('FloatingActionButton', () {
    testWidgets('opens CreateGroupPage when tapped', (tester) async {
      stubBlocState(loadedState);

      await tester.pumpWidget(createWidgetUnderTest());

      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);

      await tester.tap(fab);
      await tester.pumpAndSettle();

      expect(find.byType(CreateGroupPage), findsOneWidget);
    });
  });

  group('RefreshIndicator', () {
    testWidgets('calls RefreshGroups on pull to refresh', (tester) async {
      stubBlocState(loadedState);

      await tester.pumpWidget(createWidgetUnderTest());

      final refreshIndicator = find.byType(RefreshIndicator);
      expect(refreshIndicator, findsOneWidget);

      final refreshIndicatorWidget = tester.widget<RefreshIndicator>(refreshIndicator);
      await refreshIndicatorWidget.onRefresh!();

      verify(mockGroupsBloc.add(any)).called(1);
    });
  });

  group('Retry button in error state', () {
    testWidgets('calls RefreshGroups when retry tapped', (tester) async {
      stubBlocState(errorState);

      await tester.pumpWidget(createWidgetUnderTest());

      final retryButton = find.byIcon(Icons.refresh);
      expect(retryButton, findsOneWidget);

      await tester.tap(retryButton);
      await tester.pump();

      verify(mockGroupsBloc.add(any)).called(1);
    });
  });
}
