import 'package:get/get.dart';
import 'dart:math' as math;
import '../models/game_stats.dart';
import '../models/game_difficulty.dart';
import '../models/achievement.dart';
import '../models/game_mode.dart';
import '../services/storage_service.dart';

class TicTacToeStatsController extends GetxController {
  final StorageService _storage;
  final Rx<GameStats> _stats = const GameStats(
    difficultyStats: {},
    unlockedAchievements: {},
    multiplayerStats: MultiplayerStats(),
  ).obs;

  TicTacToeStatsController(this._storage) {
    _loadStats();
  }

  GameStats get stats => _stats.value;

  int get playerWins => stats.difficultyStats.values.fold(
        0,
        (sum, stats) => sum + stats.gamesWon,
      );

  int get aiWins => stats.difficultyStats.values.fold(
        0,
        (sum, stats) => sum + stats.gamesLost,
      );

  int get player1Wins => stats.multiplayerStats.player1Wins;

  int get player2Wins => stats.multiplayerStats.player2Wins;

  int get multiplayerDraws => stats.multiplayerStats.draws;

  int getWinsForDifficulty(GameDifficulty difficulty) {
    return stats.difficultyStats[difficulty]?.gamesWon ?? 0;
  }

  int getLossesForDifficulty(GameDifficulty difficulty) {
    return stats.difficultyStats[difficulty]?.gamesLost ?? 0;
  }

  int getDrawsForDifficulty(GameDifficulty difficulty) {
    return stats.difficultyStats[difficulty]?.gamesDrawn ?? 0;
  }

  Future<void> _loadStats() async {
    try {
    final loadedStats = await _storage.loadStats();
        _stats.value = loadedStats;
      } catch (e) {
      _stats.value = const GameStats(
        difficultyStats: {},
        unlockedAchievements: {},
        multiplayerStats: MultiplayerStats(),
      );
    }
  }

  Future<void> updateGameStats({
    required GameMode gameMode,
    GameDifficulty? difficulty,
    required bool isWin,
    required bool isDraw,
    required Duration gameDuration,
    int? winningPlayer,
  }) async {
    try {
      if (gameMode == GameMode.singlePlayer && difficulty != null) {
        await _updateSinglePlayerStats(
          difficulty: difficulty,
          isWin: isWin,
          isDraw: isDraw,
          gameDuration: gameDuration,
        );
      } else if (gameMode == GameMode.multiPlayer) {
        await _updateMultiplayerStats(
          winningPlayer: winningPlayer,
          isDraw: isDraw,
          gameDuration: gameDuration,
        );
      }
    } catch (_) {}
  }

  Future<void> _updateSinglePlayerStats({
    required GameDifficulty difficulty,
    required bool isWin,
    required bool isDraw,
    required Duration gameDuration,
  }) async {
    final currentDifficultyStats =
        stats.difficultyStats[difficulty] ?? const DifficultyStats();

    final newDifficultyStats = currentDifficultyStats.copyWith(
      gamesPlayed: currentDifficultyStats.gamesPlayed + 1,
      gamesWon: currentDifficultyStats.gamesWon + (isWin ? 1 : 0),
      gamesLost: currentDifficultyStats.gamesLost + (!isWin && !isDraw ? 1 : 0),
      gamesDrawn: currentDifficultyStats.gamesDrawn + (isDraw ? 1 : 0),
      currentStreak: isWin
          ? currentDifficultyStats.currentStreak + 1
          : isDraw
              ? currentDifficultyStats.currentStreak
              : 0,
      bestStreak: isWin
          ? math.max(
              currentDifficultyStats.bestStreak,
              currentDifficultyStats.currentStreak + 1,
            )
          : currentDifficultyStats.bestStreak,
    );

    final newDifficultyStatsMap = Map<GameDifficulty, DifficultyStats>.from(
      stats.difficultyStats,
    )..addAll({difficulty: newDifficultyStats});

    final unlockedAchievements = _checkAchievements(
      stats.unlockedAchievements,
      newDifficultyStats,
      difficulty,
    );

    _stats.value = stats.copyWith(
      difficultyStats: newDifficultyStatsMap,
      unlockedAchievements: unlockedAchievements,
      lastPlayed: DateTime.now(),
      totalPlayTime: stats.totalPlayTime + gameDuration,
    );

    await _storage.saveStats(_stats.value);
  }

  Future<void> _updateMultiplayerStats({
    required int? winningPlayer,
    required bool isDraw,
    required Duration gameDuration,
  }) async {
    final currentMultiplayerStats = stats.multiplayerStats;

    final newMultiplayerStats = currentMultiplayerStats.copyWith(
      gamesPlayed: currentMultiplayerStats.gamesPlayed + 1,
      player1Wins:
          currentMultiplayerStats.player1Wins + (winningPlayer == 1 ? 1 : 0),
      player2Wins:
          currentMultiplayerStats.player2Wins + (winningPlayer == 2 ? 1 : 0),
      draws: currentMultiplayerStats.draws + (isDraw ? 1 : 0),
    );

    _stats.value = stats.copyWith(
      multiplayerStats: newMultiplayerStats,
      lastPlayed: DateTime.now(),
      totalPlayTime: stats.totalPlayTime + gameDuration,
    );

    await _storage.saveStats(_stats.value);
  }

  Set<Achievement> _checkAchievements(
    Set<Achievement> current,
    DifficultyStats stats,
    GameDifficulty difficulty,
  ) {
    final newAchievements = Set<Achievement>.from(current);

    if (stats.gamesWon > 0) {
      newAchievements.add(Achievement.firstWin);
    }

    if (stats.gamesWon >= 10) {
      newAchievements.add(Achievement.tenWins);
    }

    if (stats.currentStreak >= 3) {
      newAchievements.add(Achievement.threeInARow);
    }

    if (difficulty == GameDifficulty.impossible && stats.gamesWon > 0) {
      newAchievements.add(Achievement.impossibleWin);
    }

    return newAchievements;
  }

  Future<void> resetAllStats() async {
    try {
      _stats.value = const GameStats(
        difficultyStats: {},
        unlockedAchievements: {},
        multiplayerStats: MultiplayerStats(),
      );
      await _storage.saveStats(_stats.value);
      } catch (_) {}
  }

  Future<void> resetSinglePlayerStats() async {
    try {
      _stats.value = stats.copyWith(
        difficultyStats: {},
      );
      await _storage.saveStats(_stats.value);
    } catch (_) {}
  }

  Future<void> resetMultiplayerStats() async {
    try {
      _stats.value = stats.copyWith(
        multiplayerStats: const MultiplayerStats(),
      );
      await _storage.saveStats(_stats.value);
    } catch (_) {}
  }
}
