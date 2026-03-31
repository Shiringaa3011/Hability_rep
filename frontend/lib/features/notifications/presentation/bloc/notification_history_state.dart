import '../../domain/entities/notification_history_item.dart';

class NotificationHistoryState {
  final bool loading;
  final List<NotificationHistoryItem> items;
  final String? error;

  const NotificationHistoryState({
    this.loading = false,
    this.items = const [],
    this.error,
  });

  int get unreadLast30Days {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    return items.where((e) => !e.read && !e.receivedAt.isBefore(cutoff)).length;
  }

  NotificationHistoryState copyWith({
    bool? loading,
    List<NotificationHistoryItem>? items,
    String? error,
    bool clearError = false,
  }) {
    return NotificationHistoryState(
      loading: loading ?? this.loading,
      items: items ?? this.items,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
