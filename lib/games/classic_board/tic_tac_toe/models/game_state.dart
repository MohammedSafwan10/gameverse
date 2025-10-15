import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'player.dart';
import 'game_move.dart';
import 'game_settings.dart';

part 'game_state.g.dart';

enum GameStatus {
  playing,
  draw,
  won,
}

@JsonSerializable()
class TicTacToeState extends Equatable {
  final List<Player> board;
  final Player currentPlayer;
  final Player? winner;
  final GameStatus status;
  final List<int> winningLine;
  final GameMove? lastMove;
  final GameSettings settings;

  const TicTacToeState({
    required this.board,
    required this.currentPlayer,
    this.winner,
    required this.status,
    this.winningLine = const [],
    this.lastMove,
    required this.settings,
  });

  factory TicTacToeState.initial() {
    return TicTacToeState(
      board: List.filled(9, Player.none),
      currentPlayer: Player.x,
      status: GameStatus.playing,
      settings: GameSettings.initial(),
    );
  }

  bool get isGameOver => status != GameStatus.playing;

  TicTacToeState copyWith({
    List<Player>? board,
    Player? currentPlayer,
    Player? winner,
    GameStatus? status,
    List<int>? winningLine,
    GameMove? lastMove,
    GameSettings? settings,
  }) {
    return TicTacToeState(
      board: board ?? this.board,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      winner: winner ?? this.winner,
      status: status ?? this.status,
      winningLine: winningLine ?? this.winningLine,
      lastMove: lastMove ?? this.lastMove,
      settings: settings ?? this.settings,
    );
  }

  factory TicTacToeState.fromJson(Map<String, dynamic> json) => _$TicTacToeStateFromJson(json);
  Map<String, dynamic> toJson() => _$TicTacToeStateToJson(this);

  @override
  List<Object?> get props => [
        board,
        currentPlayer,
        winner,
        status,
        winningLine,
        lastMove,
        settings,
      ];
}
