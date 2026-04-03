import 'package:equatable/equatable.dart';

class GroupMemberEntity extends Equatable {
  final String id;
  final String userId;
  final String username;
  final int points; 
  final int reactions;
  final DateTime joinedAt;

  const GroupMemberEntity({
    required this.id,
    required this.userId,
    required this.username,
    this.points = 0,
    this.reactions = 0,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [id, userId, username, points, reactions, joinedAt];
}