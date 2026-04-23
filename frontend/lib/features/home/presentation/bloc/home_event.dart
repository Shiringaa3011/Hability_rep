abstract class HomeEvent {}

class HomeLoadRequested extends HomeEvent {
  final String userId;

  HomeLoadRequested(this.userId);
}

class HomeDateSelected extends HomeEvent {
  final DateTime day;

  HomeDateSelected(this.day);
}

class HomeGroupFilterSelected extends HomeEvent {
  final String? groupId;

  HomeGroupFilterSelected(this.groupId);
}

class HomeHabitToggled extends HomeEvent {
  final String habitId;
  final bool completed;

  HomeHabitToggled({required this.habitId, required this.completed});
}
