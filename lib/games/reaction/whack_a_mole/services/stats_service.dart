import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class WhackAMoleStatsService extends GetxService {
  static const String _storageKey = 'whack_a_mole_stats';
  final _storage = GetStorage();

  // Stats observables
  final highScores = <String, int>{}.obs;
  final totalGames = 0.obs;
  final totalHits = 0.obs;
  final totalGoldenHits = 0.obs;
  final totalBombHits = 0.obs;
  final longestCombo = 0.obs;
  final totalPlayTime = Duration.zero.obs;

  @override
  void onInit() {
    super.onInit();
    _loadStats();
  }

  void updateStats({
    required String mode,
    required int score,
    required int combo,
    required int normalHits,
    required int goldenHits,
    required int bombHits,
    required Duration gameTime,
  }) {
    // Update high scores
    final currentHighScore = highScores[mode] ?? 0;
    if (score > currentHighScore) {
      highScores[mode] = score;
    }

    // Update total stats
    totalGames.value++;
    totalHits.value += normalHits;
    totalGoldenHits.value += goldenHits;
    totalBombHits.value += bombHits;
    if (combo > longestCombo.value) {
      longestCombo.value = combo;
    }
    totalPlayTime.value += gameTime;

    // Save to storage
    _saveStats();
  }

  Map<String, dynamic> _getStatsMap() {
    return {
      'highScores': highScores,
      'totalGames': totalGames.value,
      'totalHits': totalHits.value,
      'totalGoldenHits': totalGoldenHits.value,
      'totalBombHits': totalBombHits.value,
      'longestCombo': longestCombo.value,
      'totalPlayTime': totalPlayTime.value.inSeconds,
    };
  }

  void _loadStats() {
    try {
      final stats = _storage.read(_storageKey);
      if (stats != null) {
        highScores.value = Map<String, int>.from(stats['highScores'] ?? {});
        totalGames.value = stats['totalGames'] ?? 0;
        totalHits.value = stats['totalHits'] ?? 0;
        totalGoldenHits.value = stats['totalGoldenHits'] ?? 0;
        totalBombHits.value = stats['totalBombHits'] ?? 0;
        longestCombo.value = stats['longestCombo'] ?? 0;
        totalPlayTime.value = Duration(seconds: stats['totalPlayTime'] ?? 0);
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
    }
  }

  Future<void> _saveStats() async {
    try {
      await _storage.write(_storageKey, _getStatsMap());
    } catch (e) {
      debugPrint('Error saving stats: $e');
    }
  }

  Future<void> resetStats() async {
    highScores.clear();
    totalGames.value = 0;
    totalHits.value = 0;
    totalGoldenHits.value = 0;
    totalBombHits.value = 0;
    longestCombo.value = 0;
    totalPlayTime.value = Duration.zero;
    await _saveStats();
  }
}
