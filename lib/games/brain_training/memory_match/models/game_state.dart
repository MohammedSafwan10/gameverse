import 'package:equatable/equatable.dart';
import 'card_model.dart';
import 'game_mode.dart';

enum GameDifficulty { easy, medium, hard }
enum GameStatus { playing, paused, completed }

class MemoryMatchState extends Equatable {
  final List<MemoryCard> cards;
  final MemoryMatchMode mode;
  final GameDifficulty difficulty;
  final GameStatus status;
  final int moves;
  final int score;
  final int timeElapsed;
  final DateTime startTime;
  final MemoryCard? firstCard;
  final MemoryCard? secondCard;
  final bool isChecking;

  const MemoryMatchState({
    required this.cards,
    required this.mode,
    required this.difficulty,
    this.status = GameStatus.playing,
    this.moves = 0,
    this.score = 0,
    this.timeElapsed = 0,
    required this.startTime,
    this.firstCard,
    this.secondCard,
    this.isChecking = false,
  });

  bool get isCompleted => cards.every((card) => card.isMatched);
  
  int get gridSize {
    switch (difficulty) {
      case GameDifficulty.easy:
        return 4; // 4x4 grid
      case GameDifficulty.medium:
        return 6; // 6x6 grid
      case GameDifficulty.hard:
        return 8; // 8x8 grid
    }
  }

  int get totalPairs => (gridSize * gridSize) ~/ 2;

  int get remainingPairs => totalPairs - (cards.where((card) => card.isMatched).length ~/ 2);

  MemoryMatchState copyWith({
    List<MemoryCard>? cards,
    MemoryMatchMode? mode,
    GameDifficulty? difficulty,
    GameStatus? status,
    int? moves,
    int? score,
    int? timeElapsed,
    DateTime? startTime,
    MemoryCard? firstCard,
    MemoryCard? secondCard,
    bool? isChecking,
  }) {
    return MemoryMatchState(
      cards: cards ?? this.cards,
      mode: mode ?? this.mode,
      difficulty: difficulty ?? this.difficulty,
      status: status ?? this.status,
      moves: moves ?? this.moves,
      score: score ?? this.score,
      timeElapsed: timeElapsed ?? this.timeElapsed,
      startTime: startTime ?? this.startTime,
      firstCard: firstCard,
      secondCard: secondCard,
      isChecking: isChecking ?? this.isChecking,
    );
  }

  @override
  List<Object?> get props => [
        cards,
        mode,
        difficulty,
        status,
        moves,
        score,
        timeElapsed,
        startTime,
        firstCard,
        secondCard,
        isChecking,
      ];
} 