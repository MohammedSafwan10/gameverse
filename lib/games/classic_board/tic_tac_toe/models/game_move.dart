import 'package:equatable/equatable.dart';
import 'player.dart';

class GameMove extends Equatable {
  final Player player;
  final int position;
  final DateTime timestamp;

  const GameMove({
    required this.player,
    required this.position,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [player, position, timestamp];
}
