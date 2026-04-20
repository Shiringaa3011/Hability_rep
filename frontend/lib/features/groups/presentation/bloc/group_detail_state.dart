import '../../domain/entities/group_member_entity.dart';
import '../../domain/repositories/group_repository.dart';

class GroupDetailState {
  final String groupId;
  final String currentUserId;
  final bool isLoading;
  final GroupDetail? detail;
  final String? error;
  final String? successMessage;

  const GroupDetailState({
    required this.groupId,
    required this.currentUserId,
    this.isLoading = false,
    this.detail,
    this.error,
    this.successMessage,
  });

  bool get isOwner {
    final d = detail;
    if (d == null) return false;
    return d.group.createdBy == currentUserId;
  }

  bool get canLeave {
    final d = detail;
    if (d == null) return false;
    return d.group.createdBy != currentUserId;
  }

  GroupMemberEntity? get leader {
    final m = detail?.members ?? const <GroupMemberEntity>[];
    if (m.isEmpty) return null;
    return m.first;
  }

  GroupDetailState copyWith({
    bool? isLoading,
    GroupDetail? detail,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearMessage = false,
  }) {
    return GroupDetailState(
      groupId: groupId,
      currentUserId: currentUserId,
      isLoading: isLoading ?? this.isLoading,
      detail: detail ?? this.detail,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearMessage ? null : (successMessage ?? this.successMessage),
    );
  }
}
