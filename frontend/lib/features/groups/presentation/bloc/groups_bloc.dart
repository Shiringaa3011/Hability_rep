import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_user_groups.dart';
import 'groups_event.dart';
import 'groups_state.dart';

class GroupsBloc extends Bloc<GroupsEvent, GroupsState> {
  final GetUserGroups _getUserGroups;
  final String currentUserId;

  GroupsBloc({
    required GetUserGroups getUserGroups,
    required this.currentUserId,
  })  : _getUserGroups = getUserGroups,
        super(GroupsState()) {
    on<LoadUserGroups>((event, emit) async {
      emit(state.copyWith(isLoading: true, clearError: true));
      try {
        final groups = await _getUserGroups(event.userId);
        emit(state.copyWith(groups: groups, isLoading: false, clearError: true));
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString()));
      }
    });
    
    on<RefreshGroups>((event, emit) async {
      add(LoadUserGroups(event.userId));
    });
  }
}