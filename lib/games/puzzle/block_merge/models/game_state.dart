import 'package:equatable/equatable.dart';
import 'block.dart';

enum Direction { up, down, left, right }

enum GameStatus { initial, playing, paused, won, gameOver }

class BlockMergeGameState extends Equatable {
  final GameStatus status;
  final int moves;
  final Duration playTime;
  final int highestTile;
  final int currentScore;
  final bool canUndo;
  final List<List<Block?>> previousGrid;
  final int previousScore;

  const BlockMergeGameState({
    required this.status,
    required this.moves,
    required this.playTime,
    required this.highestTile,
    required this.currentScore,
    required this.canUndo,
    required this.previousGrid,
    required this.previousScore,
  });

  factory BlockMergeGameState.initial() {
    return BlockMergeGameState(
      status: GameStatus.initial,
      moves: 0,
      playTime: Duration.zero,
      highestTile: 0,
      currentScore: 0,
      canUndo: false,
      previousGrid: List.generate(4, (_) => List.generate(4, (_) => null)),
      previousScore: 0,
    );
  }

  BlockMergeGameState copyWith({
    GameStatus? status,
    int? moves,
    Duration? playTime,
    int? highestTile,
    int? currentScore,
    bool? canUndo,
    List<List<Block?>>? previousGrid,
    int? previousScore,
  }) {
    return BlockMergeGameState(
      status: status ?? this.status,
      moves: moves ?? this.moves,
      playTime: playTime ?? this.playTime,
      highestTile: highestTile ?? this.highestTile,
      currentScore: currentScore ?? this.currentScore,
      canUndo: canUndo ?? this.canUndo,
      previousGrid: previousGrid ?? this.previousGrid,
      previousScore: previousScore ?? this.previousScore,
    );
  }

  List<Position> getEmptyPositions() {
    List<Position> emptyPositions = [];
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (previousGrid[i][j] == null) {
          emptyPositions.add(Position(j, i));
        }
      }
    }
    return emptyPositions;
  }

  @override
  List<Object?> get props => [
        status,
        moves,
        playTime,
        highestTile,
        currentScore,
        canUndo,
        previousGrid,
        previousScore,
      ];
}
