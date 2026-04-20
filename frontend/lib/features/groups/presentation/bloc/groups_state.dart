import '../../domain/entities/group_entity.dart';

class GroupsState {
  final List<GroupEntity> groups;
  final bool isLoading;
  final String? error;

  GroupsState({this.groups = const [], this.isLoading = false, this.error});

  GroupsState copyWith({
    List<GroupEntity>? groups,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return GroupsState(
      groups: groups ?? this.groups,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}