// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_move.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameMove _$GameMoveFromJson(Map<String, dynamic> json) => GameMove(
      player: $enumDecode(_$PlayerEnumMap, json['player']),
      position: (json['position'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$GameMoveToJson(GameMove instance) => <String, dynamic>{
      'player': _$PlayerEnumMap[instance.player]!,
      'position': instance.position,
      'timestamp': instance.timestamp.toIso8601String(),
    };

const _$PlayerEnumMap = {
  Player.x: 'x',
  Player.o: 'o',
  Player.none: 'none',
};
