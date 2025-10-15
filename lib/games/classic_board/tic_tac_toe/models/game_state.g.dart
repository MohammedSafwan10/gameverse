// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TicTacToeState _$TicTacToeStateFromJson(Map<String, dynamic> json) =>
    TicTacToeState(
      board: (json['board'] as List<dynamic>)
          .map((e) => $enumDecode(_$PlayerEnumMap, e))
          .toList(),
      currentPlayer: $enumDecode(_$PlayerEnumMap, json['currentPlayer']),
      winner: $enumDecodeNullable(_$PlayerEnumMap, json['winner']),
      status: $enumDecode(_$GameStatusEnumMap, json['status']),
      winningLine: (json['winningLine'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      lastMove: json['lastMove'] == null
          ? null
          : GameMove.fromJson(json['lastMove'] as Map<String, dynamic>),
      settings: GameSettings.fromJson(json['settings'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TicTacToeStateToJson(TicTacToeState instance) =>
    <String, dynamic>{
      'board': instance.board.map((e) => _$PlayerEnumMap[e]!).toList(),
      'currentPlayer': _$PlayerEnumMap[instance.currentPlayer]!,
      'winner': _$PlayerEnumMap[instance.winner],
      'status': _$GameStatusEnumMap[instance.status]!,
      'winningLine': instance.winningLine,
      'lastMove': instance.lastMove,
      'settings': instance.settings,
    };

const _$PlayerEnumMap = {
  Player.x: 'x',
  Player.o: 'o',
  Player.none: 'none',
};

const _$GameStatusEnumMap = {
  GameStatus.playing: 'playing',
  GameStatus.draw: 'draw',
  GameStatus.won: 'won',
};
