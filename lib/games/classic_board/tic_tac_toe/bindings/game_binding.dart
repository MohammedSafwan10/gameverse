import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../controllers/settings_controller.dart';
import '../controllers/stats_controller.dart';
import '../services/ai_service.dart';
import '../services/storage_service.dart';
import '../services/navigation_service.dart';

class TicTacToeBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize services
    Get.put(StorageService());
    Get.put(AIService());
    Get.put(TicTacToeNavigationService());

    // Initialize controllers - Note: order matters!
    // Stats controller must be initialized before settings controller
    // since settings controller depends on stats controller
    Get.put(TicTacToeStatsController(Get.find<StorageService>()));
    Get.put(TicTacToeSettingsController());
    Get.put(
      TicTacToeGameController(
        Get.find<TicTacToeNavigationService>(),
        Get.find<AIService>(),
      ),
    );
  }
}
