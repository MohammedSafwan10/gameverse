import 'dart:math' show max;
import 'package:get_storage/get_storage.dart';
import '../models/game_state.dart';
import '../services/word_service.dart';

class HangmanStorageService {
  final _storage = GetStorage('hangman');
  static const _highScoresKey = 'high_scores';
  static const _dailyChallengeKey = 'daily_challenge';
  static const _statsKey = 'stats';

  Future<void> init() async {
    await GetStorage.init('hangman');
  }

  // High Scores
  List<int> getHighScores() {
    return (_storage.read(_highScoresKey) as List<dynamic>?)
            ?.map((e) => e as int)
            .toList() ??
        [];
  }

  Future<void> addHighScore(int score) async {
    final scores = getHighScores()..add(score);
    scores.sort((a, b) => b.compareTo(a)); // Sort in descending order
    if (scores.length > 10) scores.length = 10; // Keep only top 10
    await _storage.write(_highScoresKey, scores);
  }

  // Daily Challenge
  Map<String, dynamic>? getDailyChallengeProgress() {
    return _storage.read(_dailyChallengeKey) as Map<String, dynamic>?;
  }

  Future<void> saveDailyChallengeProgress(DateTime date, int score) async {
    final dateStr = '${date.year}-${date.month}-${date.day}';
    await _storage.write(_dailyChallengeKey, {
      'lastPlayed': dateStr,
      'score': score,
    });
  }

  bool canPlayDailyChallenge() {
    final progress = getDailyChallengeProgress();
    if (progress == null) return true;

    final lastPlayed = DateTime.parse(progress['lastPlayed'] as String);
    final today = DateTime.now();
    return lastPlayed.year != today.year ||
        lastPlayed.month != today.month ||
        lastPlayed.day != today.day;
  }

  // Statistics
  Map<String, int> getStats() {
    return (_storage.read(_statsKey) as Map<dynamic, dynamic>?)?.map(
            (key, value) => MapEntry(key.toString(), value as int)) ??
        {
          'gamesPlayed': 0,
          'gamesWon': 0,
          'currentStreak': 0,
          'bestStreak': 0,
          'hintsUsed': 0,
          'totalScore': 0,
        };
  }

  Future<void> updateStats(HangmanGameState state) async {
    final stats = getStats();
    stats['gamesPlayed'] = (stats['gamesPlayed'] ?? 0) + 1;

    if (state.status == HangmanGameStatus.won) {
      stats['gamesWon'] = (stats['gamesWon'] ?? 0) + 1;
      stats['currentStreak'] = (stats['currentStreak'] ?? 0) + 1;
      stats['bestStreak'] = max(
        stats['bestStreak'] ?? 0,
        stats['currentStreak'] ?? 0,
      );
      stats['totalScore'] =
          (stats['totalScore'] ?? 0) + WordService.calculateScore(state).toInt();
    } else {
      stats['currentStreak'] = 0;
    }

    stats['hintsUsed'] =
        (stats['hintsUsed'] ?? 0) + (3 - state.hintsRemaining);

    await _storage.write(_statsKey, stats);
  }
} 