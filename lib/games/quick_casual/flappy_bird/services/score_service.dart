import 'package:get_storage/get_storage.dart';
import 'dart:developer' as developer;
import '../models/game_stats.dart';
import '../utils/constants.dart';

class ScoreService {
  final _storage = GetStorage();
  static const _statsKey = 'flappy_bird_stats';

  // In-memory cache to prevent data loss in case of errors
  GameStats? _lastSavedStats;

  Future<int> getHighScore() async {
    try {
      final highScore = _storage.read<int>(GameConstants.highScoreKey) ?? 0;
      developer.log('Retrieved high score: $highScore');
      return highScore;
    } catch (e) {
      developer.log('Error retrieving high score: $e');
      return 0;
    }
  }

  Future<void> saveHighScore(int score) async {
    try {
      developer.log('Saving high score: $score');
      await _storage.write(GameConstants.highScoreKey, score);
      await _storage.save(); // Force immediate save to disk
    } catch (e) {
      developer.log('Error saving high score: $e');
    }
  }

  Future<GameStats> getGameStats() async {
    try {
      developer.log('Retrieving game stats');
      final Map<String, dynamic>? statsMap =
          _storage.read<Map<String, dynamic>>(_statsKey);

      if (statsMap == null) {
        developer.log('No saved stats found, returning initial stats');
        return GameStats.initial();
      }

      // Ensure we have all required fields with defaults if missing
      final stats = GameStats(
        score: statsMap['score'] ?? 0,
        highScore: statsMap['highScore'] ?? 0,
        gamesPlayed: statsMap['gamesPlayed'] ?? 0,
        totalPlayTime: Duration(milliseconds: statsMap['totalPlayTimeMs'] ?? 0),
        totalPipesPassed: statsMap['totalPipesPassed'] ?? 0,
      );

      // Store in memory cache
      _lastSavedStats = stats;

      developer.log('Retrieved stats: HighScore=${stats.highScore}, '
          'Games=${stats.gamesPlayed}, '
          'Pipes=${stats.totalPipesPassed}, '
          'PlayTime=${stats.totalPlayTime.inSeconds}s');

      return stats;
    } catch (e) {
      developer.log('Error loading stats: $e');

      // Use cached stats if available
      if (_lastSavedStats != null) {
        developer.log('Returning cached stats instead');
        return _lastSavedStats!;
      }

      return GameStats.initial();
    }
  }

  Future<void> saveGameStats(GameStats stats) async {
    try {
      developer.log('Saving game stats - HighScore: ${stats.highScore}, '
          'Games: ${stats.gamesPlayed}, '
          'Pipes: ${stats.totalPipesPassed}, '
          'PlayTime: ${stats.totalPlayTime.inSeconds}s');

      // Ensure high score is consistent
      final currentHighScore = await getHighScore();
      final highScoreToSave = stats.highScore > currentHighScore
          ? stats.highScore
          : currentHighScore;

      if (highScoreToSave != stats.highScore) {
        developer.log('Adjusting highScore in stats to match stored highScore');
        stats = stats.copyWith(highScore: highScoreToSave);
      }

      // Validate stats are reasonable
      if (stats.gamesPlayed < 0 ||
          stats.totalPlayTime.inSeconds < 0 ||
          stats.totalPipesPassed < 0) {
        developer.log('Invalid stats detected, fixing before saving');
        stats = GameStats(
          score: stats.score,
          highScore: stats.highScore,
          gamesPlayed: stats.gamesPlayed < 0 ? 0 : stats.gamesPlayed,
          totalPlayTime: stats.totalPlayTime.inSeconds < 0
              ? Duration.zero
              : stats.totalPlayTime,
          totalPipesPassed:
              stats.totalPipesPassed < 0 ? 0 : stats.totalPipesPassed,
        );
      }

      // Save to storage
      final Map<String, dynamic> statsMap = {
        'score': stats.score,
        'highScore': highScoreToSave,
        'gamesPlayed': stats.gamesPlayed,
        'totalPlayTimeMs': stats.totalPlayTime.inMilliseconds,
        'totalPipesPassed': stats.totalPipesPassed,
      };

      await _storage.write(_statsKey, statsMap);

      // Force immediate write to disk
      await _storage.save();

      // Update memory cache
      _lastSavedStats = stats;

      // Also ensure the highScore key is updated for backward compatibility
      if (highScoreToSave > currentHighScore) {
        await saveHighScore(highScoreToSave);
      }

      developer.log('Game stats saved successfully');
    } catch (e) {
      developer.log('Error saving stats: $e');
    }
  }

  Future<void> clearCache() async {
    try {
      developer.log('Clearing score service cache');
      _lastSavedStats = null;
      await _storage.erase();
    } catch (e) {
      developer.log('Error clearing cache: $e');
    }
  }
}
