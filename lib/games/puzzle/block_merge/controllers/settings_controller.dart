import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

enum BlockMergeMode { classic, timeChallenge, zen }

class BlockMergeSettingsController extends GetxController {
  final _storage = GetStorage();

  // Game state
  final RxInt bestScore = 0.obs;
  final RxInt gamesPlayed = 0.obs;
  final RxInt gamesWon = 0.obs;
  final RxInt highestTile = 0.obs;

  // Settings
  final RxBool soundEnabled = true.obs;
  final RxBool vibrationEnabled = true.obs;
  final RxBool showTutorial = true.obs;
  final Rx<BlockMergeMode> gameMode = BlockMergeMode.classic.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    try {
      bestScore.value = _storage.read('block_merge_best_score') ?? 0;
      gamesPlayed.value = _storage.read('block_merge_games_played') ?? 0;
      gamesWon.value = _storage.read('block_merge_games_won') ?? 0;
      highestTile.value = _storage.read('block_merge_highest_tile') ?? 0;

      soundEnabled.value = _storage.read('block_merge_sound_enabled') ?? true;
      vibrationEnabled.value =
          _storage.read('block_merge_vibration_enabled') ?? true;
      showTutorial.value = _storage.read('block_merge_show_tutorial') ?? true;

      final savedMode = _storage.read('block_merge_game_mode');
      if (savedMode != null) {
        gameMode.value = BlockMergeMode.values.firstWhere(
          (mode) => mode.toString() == savedMode,
          orElse: () => BlockMergeMode.classic,
        );
      }
    } catch (e) {
      // If loading fails, use defaults
      _resetToDefaults();
    }
  }

  void _resetToDefaults() {
    bestScore.value = 0;
    gamesPlayed.value = 0;
    gamesWon.value = 0;
    highestTile.value = 0;
    soundEnabled.value = true;
    vibrationEnabled.value = true;
    showTutorial.value = true;
    gameMode.value = BlockMergeMode.classic;
  }

  void updateBestScore(int score) {
    if (score > bestScore.value) {
      bestScore.value = score;
      _storage.write('block_merge_best_score', score);
    }
  }

  void incrementGamesPlayed() {
    gamesPlayed.value++;
    _storage.write('block_merge_games_played', gamesPlayed.value);
  }

  void incrementWins() {
    gamesWon.value++;
    _storage.write('block_merge_games_won', gamesWon.value);
  }

  void updateHighestTile(int value) {
    if (value > highestTile.value) {
      highestTile.value = value;
      _storage.write('block_merge_highest_tile', value);
    }
  }

  void setSoundEnabled(bool enabled) {
    soundEnabled.value = enabled;
    _storage.write('block_merge_sound_enabled', enabled);
  }

  void setVibrationEnabled(bool enabled) {
    vibrationEnabled.value = enabled;
    _storage.write('block_merge_vibration_enabled', enabled);
  }

  void setShowTutorial(bool show) {
    showTutorial.value = show;
    _storage.write('block_merge_show_tutorial', show);
  }

  void setGameMode(BlockMergeMode mode) {
    gameMode.value = mode;
    _storage.write('block_merge_game_mode', mode.toString());
  }

  String getWinRate() {
    if (gamesPlayed.value == 0) return '0%';
    final rate = (gamesWon.value / gamesPlayed.value * 100).toStringAsFixed(1);
    return '$rate%';
  }

  void resetStatistics() {
    bestScore.value = 0;
    gamesPlayed.value = 0;
    gamesWon.value = 0;
    highestTile.value = 0;
    _storage.write('block_merge_best_score', 0);
    _storage.write('block_merge_games_played', 0);
    _storage.write('block_merge_games_won', 0);
    _storage.write('block_merge_highest_tile', 0);
  }

  @override
  void onClose() {
    // Ensure all settings are saved before controller is closed
    _storage.write('block_merge_best_score', bestScore.value);
    _storage.write('block_merge_games_played', gamesPlayed.value);
    _storage.write('block_merge_games_won', gamesWon.value);
    _storage.write('block_merge_highest_tile', highestTile.value);
    _storage.write('block_merge_sound_enabled', soundEnabled.value);
    _storage.write('block_merge_vibration_enabled', vibrationEnabled.value);
    _storage.write('block_merge_show_tutorial', showTutorial.value);
    _storage.write('block_merge_game_mode', gameMode.value.toString());
    super.onClose();
  }
}
