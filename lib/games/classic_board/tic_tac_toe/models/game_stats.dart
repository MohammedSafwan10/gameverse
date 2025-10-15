import 'package:equatable/equatable.dart';
import 'game_difficulty.dart';
import 'achievement.dart';

class MultiplayerStats extends Equatable {
  final int gamesPlayed;
  final int player1Wins;
  final int player2Wins;
  final int draws;

  const MultiplayerStats({
    this.gamesPlayed = 0,
    this.player1Wins = 0,
    this.player2Wins = 0,
    this.draws = 0,
  });

  double get player1WinRate =>
      gamesPlayed > 0 ? player1Wins / gamesPlayed : 0.0;
  double get player2WinRate =>
      gamesPlayed > 0 ? player2Wins / gamesPlayed : 0.0;
  double get drawRate => gamesPlayed > 0 ? draws / gamesPlayed : 0.0;

  MultiplayerStats copyWith({
    int? gamesPlayed,
    int? player1Wins,
    int? player2Wins,
    int? draws,
  }) {
    return MultiplayerStats(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      player1Wins: player1Wins ?? this.player1Wins,
      player2Wins: player2Wins ?? this.player2Wins,
      draws: draws ?? this.draws,
    );
  }

  @override
  List<Object?> get props => [
        gamesPlayed,
        player1Wins,
        player2Wins,
        draws,
      ];
}

class DifficultyStats extends Equatable {
  final int gamesPlayed;
  final int gamesWon;
  final int gamesLost;
  final int gamesDrawn;
  final int currentStreak;
  final int bestStreak;

  const DifficultyStats({
    this.gamesPlayed = 0,
    this.gamesWon = 0,
    this.gamesLost = 0,
    this.gamesDrawn = 0,
    this.currentStreak = 0,
    this.bestStreak = 0,
  });

  double get winRate => gamesPlayed > 0 ? gamesWon / gamesPlayed : 0.0;

  DifficultyStats copyWith({
    int? gamesPlayed,
    int? gamesWon,
    int? gamesLost,
    int? gamesDrawn,
    int? currentStreak,
    int? bestStreak,
  }) {
    return DifficultyStats(
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      gamesWon: gamesWon ?? this.gamesWon,
      gamesLost: gamesLost ?? this.gamesLost,
      gamesDrawn: gamesDrawn ?? this.gamesDrawn,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
    );
  }

  @override
  List<Object?> get props => [
        gamesPlayed,
        gamesWon,
        gamesLost,
        gamesDrawn,
        currentStreak,
        bestStreak,
      ];
}

class GameStats extends Equatable {
  final Map<GameDifficulty, DifficultyStats> difficultyStats;
  final Set<Achievement> unlockedAchievements;
  final DateTime? lastPlayed;
  final Duration totalPlayTime;
  final MultiplayerStats multiplayerStats;

  const GameStats({
    this.difficultyStats = const {},
    this.unlockedAchievements = const {},
    this.lastPlayed,
    this.totalPlayTime = const Duration(),
    this.multiplayerStats = const MultiplayerStats(),
  });

  int get gamesPlayed =>
      difficultyStats.values.fold(0, (sum, stats) => sum + stats.gamesPlayed);

  int get gamesWon =>
      difficultyStats.values.fold(0, (sum, stats) => sum + stats.gamesWon);

  int get gamesLost =>
      difficultyStats.values.fold(0, (sum, stats) => sum + stats.gamesLost);

  int get gamesDrawn =>
      difficultyStats.values.fold(0, (sum, stats) => sum + stats.gamesDrawn);

  double get winRate => gamesPlayed > 0 ? gamesWon / gamesPlayed : 0.0;

  int get totalGamesPlayed => gamesPlayed + multiplayerStats.gamesPlayed;

  GameStats copyWith({
    Map<GameDifficulty, DifficultyStats>? difficultyStats,
    Set<Achievement>? unlockedAchievements,
    DateTime? lastPlayed,
    Duration? totalPlayTime,
    MultiplayerStats? multiplayerStats,
  }) {
    return GameStats(
      difficultyStats: difficultyStats ?? this.difficultyStats,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
      multiplayerStats: multiplayerStats ?? this.multiplayerStats,
    );
  }

  @override
  List<Object?> get props => [
        difficultyStats,
        unlockedAchievements,
        lastPlayed,
        totalPlayTime,
        multiplayerStats,
      ];
}
