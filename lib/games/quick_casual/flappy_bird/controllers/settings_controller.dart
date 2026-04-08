import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../utils/constants.dart';

enum FlappyBirdTheme { cyberpunk, classic }

class FlappyBirdSettingsController extends GetxController {
  final difficulty = GameDifficulty.normal.obs;
  final soundEnabled = true.obs;
  final musicEnabled = true.obs;
  final vibrationEnabled = true.obs;
  final currentTheme = FlappyBirdTheme.cyberpunk.obs;

  final _storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    final savedTheme = _storage.read<String>('flappy_bird_theme');
    if (savedTheme != null) {
      currentTheme.value = FlappyBirdTheme.values.firstWhere(
        (e) => e.toString() == savedTheme,
        orElse: () => FlappyBirdTheme.cyberpunk,
      );
    }
  }

  void setTheme(FlappyBirdTheme newTheme) {
    currentTheme.value = newTheme;
    _storage.write('flappy_bird_theme', newTheme.toString());
  }

  double get gravity {
    switch (difficulty.value) {
      case GameDifficulty.easy:
        return GameConstants.easyGravity;
      case GameDifficulty.normal:
        return GameConstants.normalGravity;
      case GameDifficulty.hard:
        return GameConstants.hardGravity;
    }
  }

  double get pipeSpeed {
    switch (difficulty.value) {
      case GameDifficulty.easy:
        return GameConstants.easyPipeSpeed;
      case GameDifficulty.normal:
        return GameConstants.normalPipeSpeed;
      case GameDifficulty.hard:
        return GameConstants.hardPipeSpeed;
    }
  }

  double get pipeGap {
    switch (difficulty.value) {
      case GameDifficulty.easy:
        return GameConstants.easyPipeGap;
      case GameDifficulty.normal:
        return GameConstants.normalPipeGap;
      case GameDifficulty.hard:
        return GameConstants.hardPipeGap;
    }
  }

  void setDifficulty(GameDifficulty newDifficulty) {
    difficulty.value = newDifficulty;
  }

  void toggleSound() {
    soundEnabled.value = !soundEnabled.value;
  }

  void toggleMusic() {
    musicEnabled.value = !musicEnabled.value;
  }

  void toggleVibration() {
    vibrationEnabled.value = !vibrationEnabled.value;
  }
}
