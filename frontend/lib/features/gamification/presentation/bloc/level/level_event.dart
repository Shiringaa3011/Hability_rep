import 'package:equatable/equatable.dart';

abstract class LevelEvent extends Equatable {
  const LevelEvent();

  @override
  List<Object?> get props => [];
}

class LoadLevel extends LevelEvent {
  const LoadLevel(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}

class RefreshLevel extends LevelEvent {
  const RefreshLevel(this.userId);

  final String userId;

  @override
  List<Object?> get props => [userId];
}
