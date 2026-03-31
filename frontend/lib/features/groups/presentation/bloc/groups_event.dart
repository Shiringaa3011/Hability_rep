abstract class GroupsEvent {}

class LoadUserGroups extends GroupsEvent {
  final String userId;
  LoadUserGroups(this.userId);
}

class RefreshGroups extends GroupsEvent {
  final String userId;
  RefreshGroups(this.userId);
}