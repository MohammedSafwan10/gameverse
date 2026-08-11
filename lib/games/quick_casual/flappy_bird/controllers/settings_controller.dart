import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

enum FlappyBirdTheme { cyberpunk, classic }

class FlappyBirdSettingsController extends GetxController {
  final soundEnabled = true.obs;
  final musicEnabled = true.obs;
  final vibrationEnabled = true.obs;
  final currentTheme = FlappyBirdTheme.classic.obs;

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
        orElse: () => FlappyBirdTheme.classic,
      );
    }
  }

  void setTheme(FlappyBirdTheme newTheme) {
    currentTheme.value = newTheme;
    _storage.write('flappy_bird_theme', newTheme.toString());
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
