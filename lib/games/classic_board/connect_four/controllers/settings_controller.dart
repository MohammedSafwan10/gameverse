import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';
import 'game_controller.dart';

/// Controller for Connect Four game settings
class ConnectFourSettingsController extends GetxController {
  // Storage keys
  static const String _gameModeKey = 'connect_four_game_mode';
  static const String _difficultyKey = 'connect_four_difficulty';
  static const String _soundEnabledKey = 'connect_four_sound_enabled';
  static const String _vibrationEnabledKey = 'connect_four_vibration_enabled';
  static const String _autoRestartKey = 'connect_four_auto_restart';

  // Observable settings
  final gameMode = GameMode.vsAI.obs;
  final difficulty = AIDifficulty.medium.obs;
  final isSoundEnabled = true.obs;
  final isVibrationEnabled = true.obs;
  final isAutoRestartEnabled = false.obs;

  // Storage and logging
  final _storage = GetStorage();
  final _logger = Logger();

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    _logger.i('Connect Four settings controller initialized');
  }

  /// Load all settings from persistent storage
  void _loadSettings() {
    // Game mode (PvP or vs AI)
    final savedGameMode = _storage.read(_gameModeKey);
    if (savedGameMode != null) {
      gameMode.value = GameMode.values[savedGameMode];
    }

    // AI difficulty
    final savedDifficulty = _storage.read(_difficultyKey);
    if (savedDifficulty != null) {
      difficulty.value = AIDifficulty.values[savedDifficulty];
    }

    // Sound settings
    final savedSoundEnabled = _storage.read(_soundEnabledKey);
    if (savedSoundEnabled != null) {
      isSoundEnabled.value = savedSoundEnabled;
    }

    // Vibration settings
    final savedVibrationEnabled = _storage.read(_vibrationEnabledKey);
    if (savedVibrationEnabled != null) {
      isVibrationEnabled.value = savedVibrationEnabled;
    }

    // Auto restart settings
    final savedAutoRestart = _storage.read(_autoRestartKey);
    if (savedAutoRestart != null) {
      isAutoRestartEnabled.value = savedAutoRestart;
    }

    _logger.d('Loaded settings: '
        'gameMode=${gameMode.value}, '
        'difficulty=${difficulty.value}, '
        'sound=${isSoundEnabled.value}, '
        'vibration=${isVibrationEnabled.value}, '
        'autoRestart=${isAutoRestartEnabled.value}');
  }

  /// Set the game mode (PvP or vs AI)
  void setGameMode(GameMode mode) {
    gameMode.value = mode;
    _storage.write(_gameModeKey, mode.index);
    _logger.i('Game mode set to: $mode');
  }

  /// Set the AI difficulty level
  void setDifficulty(AIDifficulty newDifficulty) {
    difficulty.value = newDifficulty;
    _storage.write(_difficultyKey, newDifficulty.index);
    _logger.i('AI difficulty set to: $newDifficulty');
  }

  /// Toggle sound effects
  void toggleSound() {
    isSoundEnabled.value = !isSoundEnabled.value;
    _storage.write(_soundEnabledKey, isSoundEnabled.value);
    _logger.i('Sound ${isSoundEnabled.value ? 'enabled' : 'disabled'}');
  }

  /// Toggle vibration feedback
  void toggleVibration() {
    isVibrationEnabled.value = !isVibrationEnabled.value;
    _storage.write(_vibrationEnabledKey, isVibrationEnabled.value);
    _logger.i('Vibration ${isVibrationEnabled.value ? 'enabled' : 'disabled'}');
  }

  /// Toggle auto restart after game ends
  void toggleAutoRestart() {
    isAutoRestartEnabled.value = !isAutoRestartEnabled.value;
    _storage.write(_autoRestartKey, isAutoRestartEnabled.value);
    _logger.i(
        'Auto restart ${isAutoRestartEnabled.value ? 'enabled' : 'disabled'}');
  }

  /// Reset all settings to default values
  void resetToDefaults() {
    _logger.i('Resetting settings to defaults');

    gameMode.value = GameMode.vsAI;
    difficulty.value = AIDifficulty.medium;
    isSoundEnabled.value = true;
    isVibrationEnabled.value = true;
    isAutoRestartEnabled.value = false;

    // Update storage
    _storage.write(_gameModeKey, gameMode.value.index);
    _storage.write(_difficultyKey, difficulty.value.index);
    _storage.write(_soundEnabledKey, isSoundEnabled.value);
    _storage.write(_vibrationEnabledKey, isVibrationEnabled.value);
    _storage.write(_autoRestartKey, isAutoRestartEnabled.value);
  }
}
