abstract class GroupDetailEvent {}

class LoadGroupDetail extends GroupDetailEvent {
  final String groupId;
  final String currentUserId;

  LoadGroupDetail({required this.groupId, required this.currentUserId});
}

class LeaveGroupPressed extends GroupDetailEvent {}

class RemoveMemberPressed extends GroupDetailEvent {
  final String memberId;

  RemoveMemberPressed(this.memberId);
}

class SendReactionToLeader extends GroupDetailEvent {}
