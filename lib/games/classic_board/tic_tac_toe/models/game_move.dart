import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'player.dart';

part 'game_move.g.dart';

@JsonSerializable()
class GameMove extends Equatable {
  final Player player;
  final int position;
  final DateTime timestamp;

  const GameMove({
    required this.player,
    required this.position,
    required this.timestamp,
  });

  factory GameMove.fromJson(Map<String, dynamic> json) => _$GameMoveFromJson(json);
  Map<String, dynamic> toJson() => _$GameMoveToJson(this);

  @override
  List<Object?> get props => [player, position, timestamp];
}
