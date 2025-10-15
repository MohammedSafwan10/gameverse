import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:math' as math;
import '../models/board.dart';
import 'game_controller.dart';

class ConnectFourStatsController extends GetxController {
  final _storage = GetStorage();
  final _logger = Logger();
  static const _statsKey = 'connect_four_stats';

  // Observable stats for single player mode
  final playerWins = 0.obs;
  final aiWins = 0.obs;
  final draws = 0.obs;
  final gamesPlayed = 0.obs;

  // Observable stats for multiplayer mode
  final player1Wins = 0.obs;
  final player2Wins = 0.obs;
  final multiplayerDraws = 0.obs;
  final multiplayerGamesPlayed = 0.obs;

  // Stats by difficulty
  final easyWins = 0.obs;
  final mediumWins = 0.obs;
  final hardWins = 0.obs;

  // Streaks
  final currentStreak = 0.obs;
  final bestStreak = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadStats();
  }

  void _loadStats() {
    try {
      final stats = _storage.read(_statsKey);
      if (stats != null) {
        playerWins.value = stats['playerWins'] ?? 0;
        aiWins.value = stats['aiWins'] ?? 0;
        draws.value = stats['draws'] ?? 0;
        gamesPlayed.value = stats['gamesPlayed'] ?? 0;

        player1Wins.value = stats['player1Wins'] ?? 0;
        player2Wins.value = stats['player2Wins'] ?? 0;
        multiplayerDraws.value = stats['multiplayerDraws'] ?? 0;
        multiplayerGamesPlayed.value = stats['multiplayerGamesPlayed'] ?? 0;

        easyWins.value = stats['easyWins'] ?? 0;
        mediumWins.value = stats['mediumWins'] ?? 0;
        hardWins.value = stats['hardWins'] ?? 0;

        currentStreak.value = stats['currentStreak'] ?? 0;
        bestStreak.value = stats['bestStreak'] ?? 0;

        _logger.i('Connect Four stats loaded successfully');
      }
    } catch (e) {
      _logger.e('Failed to load Connect Four stats: $e');
    }
  }

  void _saveStats() {
    try {
      final stats = {
        'playerWins': playerWins.value,
        'aiWins': aiWins.value,
        'draws': draws.value,
        'gamesPlayed': gamesPlayed.value,
        'player1Wins': player1Wins.value,
        'player2Wins': player2Wins.value,
        'multiplayerDraws': multiplayerDraws.value,
        'multiplayerGamesPlayed': multiplayerGamesPlayed.value,
        'easyWins': easyWins.value,
        'mediumWins': mediumWins.value,
        'hardWins': hardWins.value,
        'currentStreak': currentStreak.value,
        'bestStreak': bestStreak.value,
      };

      _storage.write(_statsKey, stats);
      _logger.i('Connect Four stats saved successfully');
    } catch (e) {
      _logger.e('Failed to save Connect Four stats: $e');
    }
  }

  void updateGameStats({
    required GameMode gameMode,
    required GameStatus result,
    AIDifficulty? difficulty,
    required Duration gameDuration,
  }) {
    if (gameMode == GameMode.vsAI) {
      _updateSinglePlayerStats(result, difficulty!, gameDuration);
    } else {
      _updateMultiplayerStats(result, gameDuration);
    }
  }

  void _updateSinglePlayerStats(
    GameStatus result,
    AIDifficulty difficulty,
    Duration gameDuration,
  ) {
    gamesPlayed.value++;

    if (result == GameStatus.player1Won) {
      playerWins.value++;
      currentStreak.value++;
      bestStreak.value = math.max(bestStreak.value, currentStreak.value);

      // Update wins by difficulty
      switch (difficulty) {
        case AIDifficulty.easy:
          easyWins.value++;
          break;
        case AIDifficulty.medium:
          mediumWins.value++;
          break;
        case AIDifficulty.hard:
          hardWins.value++;
          break;
      }
    } else if (result == GameStatus.player2Won) {
      aiWins.value++;
      currentStreak.value = 0;
    } else if (result == GameStatus.draw) {
      draws.value++;
      // Draw doesn't reset streak
    }

    _logger.i(
        'Single player stats updated: P:${playerWins.value} AI:${aiWins.value} D:${draws.value}');
    _saveStats();
  }

  void _updateMultiplayerStats(
    GameStatus result,
    Duration gameDuration,
  ) {
    multiplayerGamesPlayed.value++;

    if (result == GameStatus.player1Won) {
      player1Wins.value++;
    } else if (result == GameStatus.player2Won) {
      player2Wins.value++;
    } else if (result == GameStatus.draw) {
      multiplayerDraws.value++;
    }

    _logger.i(
        'Multiplayer stats updated: P1:${player1Wins.value} P2:${player2Wins.value} D:${multiplayerDraws.value}');
    _saveStats();
  }

  void resetSinglePlayerStats() {
    playerWins.value = 0;
    aiWins.value = 0;
    draws.value = 0;
    gamesPlayed.value = 0;
    easyWins.value = 0;
    mediumWins.value = 0;
    hardWins.value = 0;
    currentStreak.value = 0;
    bestStreak.value = 0;
    _saveStats();
    _logger.i('Single player stats reset');
  }

  void resetMultiplayerStats() {
    player1Wins.value = 0;
    player2Wins.value = 0;
    multiplayerDraws.value = 0;
    multiplayerGamesPlayed.value = 0;
    _saveStats();
    _logger.i('Multiplayer stats reset');
  }

  void resetAllStats() {
    resetSinglePlayerStats();
    resetMultiplayerStats();
    _logger.i('All stats reset');
  }
}
