import 'package:get/get.dart';
import '../models/game_settings.dart';
import '../models/game_mode.dart';
import '../models/game_difficulty.dart';
import '../controllers/stats_controller.dart';

class TicTacToeSettingsController extends GetxController {
  final Rx<GameSettings> _settings = const GameSettings().obs;
  late TicTacToeStatsController _statsController;

  @override
  void onInit() {
    super.onInit();
    _statsController = Get.find<TicTacToeStatsController>();
  }

  GameSettings get settings => _settings.value;

  void updateGameMode(GameMode mode) {
    _settings.value = settings.copyWith(gameMode: mode);
  }

  void updateDifficulty(GameDifficulty difficulty) {
    _settings.value = settings.copyWith(difficulty: difficulty);
  }

  void updateSettings(GameSettings newSettings) {
    _settings.value = newSettings;
  }

  void toggleSound() {
    _settings.value = settings.copyWith(soundEnabled: !settings.soundEnabled);
  }

  void toggleVibration() {
    _settings.value =
        settings.copyWith(vibrationEnabled: !settings.vibrationEnabled);
  }

  void toggleHints() {
    _settings.value = settings.copyWith(showHints: !settings.showHints);
  }

  void updateMoveDelay(Duration delay) {
    _settings.value = settings.copyWith(moveDelay: delay);
  }

  void toggleAutoRestart() {
    _settings.value = settings.copyWith(autoRestart: !settings.autoRestart);
  }

  void updateAiDelay(Duration delay) {
    _settings.value = settings.copyWith(aiDelay: delay);
  }

  void resetToDefaults() {
    _settings.value = const GameSettings();
  }

  Future<void> resetCurrentModeStats() async {
    if (settings.gameMode == GameMode.singlePlayer) {
      await _statsController.resetSinglePlayerStats();
    } else {
      await _statsController.resetMultiplayerStats();
    }
  }

  Future<void> resetAllStats() async {
    await _statsController.resetAllStats();
  }
}
