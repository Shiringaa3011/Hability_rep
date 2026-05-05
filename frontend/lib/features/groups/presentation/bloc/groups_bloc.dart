import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/exceptions.dart';
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
      if (state.groups.isEmpty) {
        emit(state.copyWith(isLoading: true, clearError: true));
      }

      try {
        final groups = await _getUserGroups(event.userId);
        final online = await _isOnline();
        emit(state.copyWith(
          groups: groups,
          isLoading: false,
          isOffline: !online,
          clearError: true,
        ));
      } on DioException catch (e) {
        emit(state.copyWith(
          isLoading: false,
          isOffline: true,
          error: state.groups.isEmpty ? fromDioException(e).message : null,
        ));
      } catch (e) {
        emit(state.copyWith(
          isLoading: false,
          error: state.groups.isEmpty ? 'Что-то пошло не так' : null,
        ));
      }
    });

    on<RefreshGroups>((event, emit) async {
      add(LoadUserGroups(event.userId));
    });
  }

  Future<bool> _isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }
}