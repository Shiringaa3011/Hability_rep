import 'package:equatable/equatable.dart';

class TimelinePoint extends Equatable {
  const TimelinePoint({required this.date, required this.points});

  final DateTime date;
  final int points;

  @override
  List<Object?> get props => [date, points];

  @override
  String toString() => 'TimelinePoint(date: $date, points: $points)';
}
