import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'dart:math' as math;
import '../models/game_stats.dart';
import '../models/game_difficulty.dart';
import '../models/achievement.dart';
import '../models/game_mode.dart';
import '../services/storage_service.dart';

class TicTacToeStatsController extends GetxController {
  final StorageService _storage;
  final _logger = Logger();
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

  Future<void> _loadStats() async {
    try {
      final loadedStats = await _storage.loadStats();
      _stats.value = loadedStats;
      _logger.i(
          'Stats loaded - Player wins: $playerWins, AI wins: $aiWins, Multiplayer: P1[$player1Wins] P2[$player2Wins]');
    } catch (e) {
      _logger.e('Failed to load stats: $e');
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
    } catch (e) {
      _logger.e('Failed to update stats: $e');
    }
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
    _logger.i(
        'Single player stats updated - Player wins: $playerWins, AI wins: $aiWins');
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
    _logger.i(
        'Multiplayer stats updated - P1: $player1Wins, P2: $player2Wins, Draws: $multiplayerDraws');
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
      _logger.i('All stats reset successfully');
    } catch (e) {
      _logger.e('Failed to reset stats: $e');
    }
  }

  Future<void> resetSinglePlayerStats() async {
    try {
      _stats.value = stats.copyWith(
        difficultyStats: {},
      );
      await _storage.saveStats(_stats.value);
      _logger.i('Single player stats reset successfully');
    } catch (e) {
      _logger.e('Failed to reset single player stats: $e');
    }
  }

  Future<void> resetMultiplayerStats() async {
    try {
      _stats.value = stats.copyWith(
        multiplayerStats: const MultiplayerStats(),
      );
      await _storage.saveStats(_stats.value);
      _logger.i('Multiplayer stats reset successfully');
    } catch (e) {
      _logger.e('Failed to reset multiplayer stats: $e');
    }
  }
}
