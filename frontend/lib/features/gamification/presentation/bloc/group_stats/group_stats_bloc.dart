import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/user_stats.dart';
import '../../../domain/usecases/get_group_stats.dart';
import 'group_stats_event.dart';
import 'group_stats_state.dart';

class GroupStatsBloc extends Bloc<GroupStatsEvent, GroupStatsState> {
  GroupStatsBloc({required this.getGroupStats}) : super(const GroupStatsInitial()) {
    on<LoadGroupStats>(_onLoad);
    on<RefreshGroupStats>(_onRefresh);
    on<ChangeGroupStatsPeriod>(_onChangePeriod);
  }

  final GetGroupStats getGroupStats;

  Future<void> _onLoad(LoadGroupStats event, Emitter<GroupStatsState> emit) async {
    emit(const GroupStatsLoading());
    await _fetch(event.groupId, event.period, emit);
  }

  Future<void> _onRefresh(
    RefreshGroupStats event,
    Emitter<GroupStatsState> emit,
  ) async {
    await _fetch(event.groupId, event.period, emit);
  }

  Future<void> _onChangePeriod(
    ChangeGroupStatsPeriod event,
    Emitter<GroupStatsState> emit,
  ) async {
    emit(const GroupStatsLoading());
    await _fetch(event.groupId, event.period, emit);
  }

  Future<void> _fetch(
    String groupId,
    StatsPeriod period,
    Emitter<GroupStatsState> emit,
  ) async {
    final result = await getGroupStats(
      GetGroupStatsParams(groupId: groupId, period: period),
    );

    result.fold(
      (failure) => emit(GroupStatsError(failure.message)),
      (stats) => emit(GroupStatsLoaded(stats: stats)),
    );
  }
}
