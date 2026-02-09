import 'package:equatable/equatable.dart';
import 'card_model.dart';
import 'game_mode.dart';

/// Private sentinel type used to distinguish "not provided" from null in copyWith.
class _Sentinel {
  const _Sentinel();
}

const _sentinel = _Sentinel();

enum GameDifficulty { easy, medium, hard }

enum GameStatus { playing, paused, completed, timeUp }

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

  // Combo / streak tracking
  final int combo; // consecutive matches without a miss
  final int bestCombo; // best combo this game
  final int matchCount; // total matches found

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
    this.combo = 0,
    this.bestCombo = 0,
    this.matchCount = 0,
  });

  bool get isCompleted => cards.every((card) => card.isMatched);

  /// Grid dimensions: (columns, rows)
  (int, int) get gridDimensions {
    switch (difficulty) {
      case GameDifficulty.easy:
        return (4, 3); // 12 cards = 6 pairs
      case GameDifficulty.medium:
        return (4, 4); // 16 cards = 8 pairs
      case GameDifficulty.hard:
        return (5, 4); // 20 cards = 10 pairs
    }
  }

  int get columns => gridDimensions.$1;
  int get rows => gridDimensions.$2;
  int get totalPairs => (columns * rows) ~/ 2;

  int get remainingPairs =>
      totalPairs - (cards.where((card) => card.isMatched).length ~/ 2);

  /// Time limit for time-trial mode (seconds)
  int get timeLimit {
    switch (difficulty) {
      case GameDifficulty.easy:
        return 60;
      case GameDifficulty.medium:
        return 90;
      case GameDifficulty.hard:
        return 120;
    }
  }

  int get timeRemaining => (timeLimit - timeElapsed).clamp(0, timeLimit);

  /// Star rating (1-3) based on performance
  int get starRating {
    if (!isCompleted) return 0;
    final perfectMoves = totalPairs; // best case = 1 move per pair
    final ratio = perfectMoves / (moves == 0 ? 1 : moves);
    if (ratio >= 0.8) return 3;
    if (ratio >= 0.5) return 2;
    return 1;
  }

  MemoryMatchState copyWith({
    List<MemoryCard>? cards,
    MemoryMatchMode? mode,
    GameDifficulty? difficulty,
    GameStatus? status,
    int? moves,
    int? score,
    int? timeElapsed,
    DateTime? startTime,
    Object? firstCard = _sentinel,
    Object? secondCard = _sentinel,
    bool? isChecking,
    int? combo,
    int? bestCombo,
    int? matchCount,
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
      firstCard: identical(firstCard, _sentinel)
          ? this.firstCard
          : firstCard as MemoryCard?,
      secondCard: identical(secondCard, _sentinel)
          ? this.secondCard
          : secondCard as MemoryCard?,
      isChecking: isChecking ?? this.isChecking,
      combo: combo ?? this.combo,
      bestCombo: bestCombo ?? this.bestCombo,
      matchCount: matchCount ?? this.matchCount,
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
        combo,
        bestCombo,
        matchCount,
      ];
}
