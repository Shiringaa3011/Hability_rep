import 'package:intl/intl.dart';

String formatDate(DateTime date) {
  return DateFormat('dd.MM.yyyy').format(date);
}

String formatDateTime(DateTime date) {
  return DateFormat('dd.MM.yyyy HH:mm').format(date);
}

String formatRelativeTime(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays > 0) {
    return '${difference.inDays} ${difference.inDays == 1 ? 'день' : 'дней'} назад';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} ${difference.inHours == 1 ? 'час' : 'часов'} назад';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} минут назад';
  } else {
    return 'Только что';
  }
}

bool isToday(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year && date.month == now.month && date.day == now.day;
}

bool isYesterday(DateTime date) {
  final yesterday = DateTime.now().subtract(const Duration(days: 1));
  return date.year == yesterday.year &&
      date.month == yesterday.month &&
      date.day == yesterday.day;
}
