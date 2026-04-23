import 'package:equatable/equatable.dart';

class NotificationHistoryItem extends Equatable {
  final String id;
  final String title;
  final String body;
  final DateTime receivedAt;
  final bool read;

  const NotificationHistoryItem({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    required this.read,
  });

  NotificationHistoryItem copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? receivedAt,
    bool? read,
  }) {
    return NotificationHistoryItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      receivedAt: receivedAt ?? this.receivedAt,
      read: read ?? this.read,
    );
  }

  @override
  List<Object?> get props => [id, title, body, receivedAt, read];
}
