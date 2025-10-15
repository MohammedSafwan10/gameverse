import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../controllers/stats_controller.dart';
import '../controllers/settings_controller.dart';
import '../services/sound_service.dart';

class ConnectFourBinding implements Bindings {
  final GameMode gameMode;

  const ConnectFourBinding({
    required this.gameMode,
  });

  @override
  void dependencies() {
    // Initialize services first
    if (!Get.isRegistered<SoundService>()) {
      Get.put(SoundService(), permanent: true);
    }

    // Initialize stats controller
    if (!Get.isRegistered<ConnectFourStatsController>()) {
      Get.put(ConnectFourStatsController(), permanent: true);
    }

    // Initialize settings controller - ALWAYS create as permanent
    if (!Get.isRegistered<ConnectFourSettingsController>()) {
      Get.put(ConnectFourSettingsController(), permanent: true);
    }

    // Get the settings controller
    final settingsController = Get.find<ConnectFourSettingsController>();

    // Set the initial game mode in settings
    settingsController.setGameMode(gameMode);

    // Initialize controller with game mode from settings
    Get.put(ConnectFourController());
  }
}
