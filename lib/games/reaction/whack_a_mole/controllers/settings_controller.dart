import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class WhackAMoleSettingsController extends GetxController {
  final _storage = GetStorage();
  static const _storageKey = 'whack_a_mole_settings';

  // Settings
  final _soundEnabled = true.obs;
  final _musicEnabled = true.obs;
  final _hapticEnabled = true.obs;
  final _difficulty = 'medium'.obs;

  // Stats
  final _highScore = 0.obs;
  final _gamesPlayed = 0.obs;
  final _bestCombo = 0.obs;

  // Getters for settings
  RxBool get isSoundEnabled => _soundEnabled;
  RxBool get isMusicEnabled => _musicEnabled;
  RxBool get isHapticEnabled => _hapticEnabled;
  RxString get difficulty => _difficulty;

  // Getters for stats
  int get highScore => _highScore.value;
  int get gamesPlayed => _gamesPlayed.value;
  int get bestCombo => _bestCombo.value;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    final settings = _storage.read(_storageKey);
    if (settings != null) {
      _soundEnabled.value = settings['soundEnabled'] ?? true;
      _musicEnabled.value = settings['musicEnabled'] ?? true;
      _hapticEnabled.value = settings['hapticEnabled'] ?? true;
      _difficulty.value = settings['difficulty'] ?? 'medium';
      _highScore.value = settings['highScore'] ?? 0;
      _gamesPlayed.value = settings['gamesPlayed'] ?? 0;
      _bestCombo.value = settings['bestCombo'] ?? 0;
    }
  }

  void _saveSettings() {
    _storage.write(_storageKey, {
      'soundEnabled': _soundEnabled.value,
      'musicEnabled': _musicEnabled.value,
      'hapticEnabled': _hapticEnabled.value,
      'difficulty': _difficulty.value,
      'highScore': _highScore.value,
      'gamesPlayed': _gamesPlayed.value,
      'bestCombo': _bestCombo.value,
    });
  }

  void setDifficulty(String value) {
    _difficulty.value = value;
    _saveSettings();
  }

  void toggleSound(bool value) {
    _soundEnabled.value = value;
    _saveSettings();
  }

  void toggleMusic(bool value) {
    _musicEnabled.value = value;
    _saveSettings();
  }

  void toggleHaptic(bool value) {
    _hapticEnabled.value = value;
    _saveSettings();
  }

  void updateStats({int? score, int? combo}) {
    if (score != null && score > _highScore.value) {
      _highScore.value = score;
    }
    if (combo != null && combo > _bestCombo.value) {
      _bestCombo.value = combo;
    }
    _gamesPlayed.value++;
    _saveSettings();
  }

  void resetStats() {
    _highScore.value = 0;
    _gamesPlayed.value = 0;
    _bestCombo.value = 0;
    _saveSettings();
  }

  Map<String, dynamic> getDifficultySettings() {
    switch (_difficulty.value) {
      case 'easy':
        return {
          'spawnInterval': 2000,
          'moleSpeed': 2000,
          'bombFrequency': 0.1,
          'goldenFrequency': 0.2,
        };
      case 'hard':
        return {
          'spawnInterval': 800,
          'moleSpeed': 1000,
          'bombFrequency': 0.3,
          'goldenFrequency': 0.1,
        };
      case 'medium':
      default:
        return {
          'spawnInterval': 1200,
          'moleSpeed': 1500,
          'bombFrequency': 0.2,
          'goldenFrequency': 0.15,
        };
    }
  }
}
