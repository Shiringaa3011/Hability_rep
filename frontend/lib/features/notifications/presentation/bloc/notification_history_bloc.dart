import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/bootstrap_notification_pipeline.dart';
import '../../domain/usecases/get_notification_history.dart';
import '../../domain/usecases/mark_notification_read.dart';
import 'notification_history_event.dart';
import 'notification_history_state.dart';

class NotificationHistoryBloc
    extends Bloc<NotificationHistoryEvent, NotificationHistoryState> {
  final GetNotificationHistory _getHistory;
  final MarkNotificationRead _markRead;
  final BootstrapNotificationPipeline _bootstrapPipeline;
  final String userId;

  NotificationHistoryBloc({
    required this.userId,
    required BootstrapNotificationPipeline bootstrapPipeline,
    required GetNotificationHistory getHistory,
    required MarkNotificationRead markRead,
  })  : _getHistory = getHistory,
        _markRead = markRead,
        _bootstrapPipeline = bootstrapPipeline,
        super(const NotificationHistoryState()) {
    on<NotificationHistoryLoad>(_onLoad);
    on<NotificationHistoryMarkRead>(_onMark);
  }

  Future<void> _onLoad(
    NotificationHistoryLoad event,
    Emitter<NotificationHistoryState> emit,
  ) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      //await _bootstrapPipeline(event.userId);
      final list = await _getHistory(event.userId);
      emit(state.copyWith(loading: false, items: list, clearError: true));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onMark(
    NotificationHistoryMarkRead event,
    Emitter<NotificationHistoryState> emit,
  ) async {
    try {
      await _markRead(event.id);
      final list = await _getHistory(userId);
      emit(state.copyWith(items: list, clearError: true));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
