import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/repositories/group_repository.dart';
import '../../domain/usecases/get_group_details.dart';
import '../../domain/usecases/leave_group.dart';
import '../../domain/usecases/remove_member.dart';
import '../../domain/usecases/send_reaction.dart';
import 'group_detail_event.dart';
import 'group_detail_state.dart';

class GroupDetailBloc extends Bloc<GroupDetailEvent, GroupDetailState> {
  final GetGroupDetails _getGroupDetails;
  final LeaveGroup _leaveGroup;
  final RemoveMember _removeMember;
  final SendReaction _sendReaction;
  final GroupRepository _repository;

  GroupDetailBloc({
    required String groupId,
    required String currentUserId,
    required GetGroupDetails getGroupDetails,
    required LeaveGroup leaveGroup,
    required RemoveMember removeMember,
    required SendReaction sendReaction,
    required GroupRepository repository,
  })  : _getGroupDetails = getGroupDetails,
        _leaveGroup = leaveGroup,
        _removeMember = removeMember,
        _sendReaction = sendReaction,
        _repository = repository,
        super(GroupDetailState(groupId: groupId, currentUserId: currentUserId)) {
    on<LoadGroupDetail>(_onLoad);
    on<LeaveGroupPressed>(_onLeave);
    on<RemoveMemberPressed>(_onRemoveMember);
    on<SendReactionToLeader>(_onReaction);
    on<DeleteGroupPressed>(_onDelete);
  }

  Future<void> _onDelete(
    DeleteGroupPressed event,
    Emitter<GroupDetailState> emit,
  ) async {
    if (!state.isOwner) return;
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _repository.deleteGroup(state.groupId, state.currentUserId);
      emit(
        state.copyWith(
          isLoading: false,
          successMessage: 'Группа удалена',
          clearMessage: false,
        ),
      );
    } on DioException catch (e) {
      emit(state.copyWith(isLoading: false, error: fromDioException(e).message));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Что-то пошло не так'));
    }
  }

  Future<void> _onLoad(
    LoadGroupDetail event,
    Emitter<GroupDetailState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true, clearMessage: true));
    try {
      final detail = await _getGroupDetails(event.groupId, event.currentUserId);
      emit(
        state.copyWith(
          isLoading: false,
          detail: detail,
          clearError: true,
        ),
      );
    } on DioException catch (e) {
      emit(state.copyWith(isLoading: false, error: fromDioException(e).message));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Что-то пошло не так'));
    }
  }

  Future<void> _onLeave(
    LeaveGroupPressed event,
    Emitter<GroupDetailState> emit,
  ) async {
    if (!state.canLeave) {
      emit(state.copyWith(error: 'Создатель не может выйти из группы'));
      return;
    }
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _leaveGroup(state.groupId, state.currentUserId);
      emit(
        state.copyWith(
          isLoading: false,
          successMessage: 'Вы вышли из группы',
          clearMessage: false,
        ),
      );
    } on DioException catch (e) {
      emit(state.copyWith(isLoading: false, error: fromDioException(e).message));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Что-то пошло не так'));
    }
  }

  Future<void> _onRemoveMember(
    RemoveMemberPressed event,
    Emitter<GroupDetailState> emit,
  ) async {
    if (!state.isOwner) return;
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _removeMember(state.groupId, event.memberId);
      final detail = await _getGroupDetails(state.groupId, state.currentUserId);
      emit(state.copyWith(isLoading: false, detail: detail, clearError: true));
    } on DioException catch (e) {
      emit(state.copyWith(isLoading: false, error: fromDioException(e).message));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Что-то пошло не так'));
    }
  }

  Future<void> _onReaction(
    SendReactionToLeader event,
    Emitter<GroupDetailState> emit,
  ) async {
    final leader = state.leader;
    if (leader == null) return;
    if (leader.userId == state.currentUserId) return;
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      await _sendReaction(
        groupId: state.groupId,
        fromUserId: state.currentUserId,
        toUserId: leader.userId,
      );
      final detail = await _getGroupDetails(state.groupId, state.currentUserId);
      emit(
        state.copyWith(
          isLoading: false,
          detail: detail,
          successMessage: 'Реакция отправлена',
          clearMessage: false,
        ),
      );
    } on DioException catch (e) {
      emit(state.copyWith(isLoading: false, error: fromDioException(e).message));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Что-то пошло не так'));
    }
  }
}
