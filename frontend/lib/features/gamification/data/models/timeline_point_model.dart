import '../../domain/entities/timeline_point.dart';

class TimelinePointModel {
  const TimelinePointModel({required this.date, required this.points});

  final String date;
  final int points;

  factory TimelinePointModel.fromJson(Map<String, dynamic> json) {
    return TimelinePointModel(
      date: json['date'] as String,
      points: json['points'] as int,
    );
  }

  TimelinePoint toEntity() {
    return TimelinePoint(date: DateTime.parse(date), points: points);
  }
}
