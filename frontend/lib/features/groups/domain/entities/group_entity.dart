import 'package:equatable/equatable.dart';

class GroupEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String createdBy;
  final DateTime createdAt;
  final bool isActive;
  final int habitsCount;

  const GroupEntity({
    required this.id,
    required this.name,
    this.description,
    required this.createdBy,
    required this.createdAt,
    this.isActive = true,
    this.habitsCount = 0,
  });

  @override
  List<Object?> get props => [
    id, name, description, createdBy, createdAt, isActive, habitsCount
  ];
}