import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/game_stats.dart';
import '../models/game_difficulty.dart';
import '../models/achievement.dart';

class StorageService extends GetxService {
  static const String _statsKey = 'tic_tac_toe_stats';
  final GetStorage _storage;

  StorageService() : _storage = GetStorage();

  Future<StorageService> init() async {
    await GetStorage.init();
    return this;
  }

  Future<GameStats> loadStats() async {
    try {
      final data = _storage.read(_statsKey);
      if (data == null) return const GameStats();

      final Map<String, dynamic> json = jsonDecode(data);
      final Map<GameDifficulty, DifficultyStats> difficultyStats = {};
      
      if (json['difficultyStats'] != null) {
        (json['difficultyStats'] as Map<String, dynamic>).forEach((key, value) {
          final difficulty = GameDifficulty.values.firstWhere(
            (d) => d.toString() == key,
            orElse: () => GameDifficulty.medium,
          );
          difficultyStats[difficulty] = DifficultyStats(
            gamesPlayed: value['gamesPlayed'] ?? 0,
            gamesWon: value['gamesWon'] ?? 0,
            gamesLost: value['gamesLost'] ?? 0,
            gamesDrawn: value['gamesDrawn'] ?? 0,
            currentStreak: value['currentStreak'] ?? 0,
            bestStreak: value['bestStreak'] ?? 0,
          );
        });
      }

      final Set<Achievement> achievements = {};
      if (json['achievements'] != null) {
        for (final name in json['achievements']) {
          try {
            achievements.add(Achievement.values.firstWhere(
              (a) => a.toString() == name,
            ));
          } catch (_) {}
        }
      }

      return GameStats(
        difficultyStats: difficultyStats,
        unlockedAchievements: achievements,
        lastPlayed: json['lastPlayed'] != null 
            ? DateTime.parse(json['lastPlayed'])
            : null,
        totalPlayTime: Duration(milliseconds: json['totalPlayTime'] ?? 0),
      );
    } catch (e) {
      return const GameStats();
    }
  }

  Future<void> saveStats(GameStats stats) async {
    final Map<String, dynamic> difficultyStats = {};
    stats.difficultyStats.forEach((difficulty, stats) {
      difficultyStats[difficulty.toString()] = {
        'gamesPlayed': stats.gamesPlayed,
        'gamesWon': stats.gamesWon,
        'gamesLost': stats.gamesLost,
        'gamesDrawn': stats.gamesDrawn,
        'currentStreak': stats.currentStreak,
        'bestStreak': stats.bestStreak,
      };
    });

    final data = {
      'difficultyStats': difficultyStats,
      'achievements': stats.unlockedAchievements
          .map((a) => a.toString())
          .toList(),
      'lastPlayed': stats.lastPlayed?.toIso8601String(),
      'totalPlayTime': stats.totalPlayTime.inMilliseconds,
    };

    await _storage.write(_statsKey, jsonEncode(data));
  }

  Future<void> resetStats() async {
    await _storage.remove(_statsKey);
  }
}
