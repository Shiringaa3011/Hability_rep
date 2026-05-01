import 'package:equatable/equatable.dart';

class GroupInviteEntity extends Equatable {
  final String id;
  final String groupId;
  final String groupName;
  final String fromUserId;
  final String fromUsername;
  final String toUserId;
  final String status;
  final DateTime createdAt;

  const GroupInviteEntity({
    required this.id,
    required this.groupId,
    required this.groupName,
    required this.fromUserId,
    required this.fromUsername,
    required this.toUserId,
    required this.status,
    required this.createdAt,
  });

  bool get isPending => status == 'pending';

  @override
  List<Object?> get props => [
    id, groupId, groupName, fromUserId, fromUsername,
    toUserId, status, createdAt
  ];
}