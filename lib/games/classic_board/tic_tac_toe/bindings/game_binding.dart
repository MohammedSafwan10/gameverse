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
    // Services
    Get.lazyPut(() => StorageService(), fenix: true);
    Get.lazyPut(() => AIService(), fenix: true);
    Get.lazyPut(() => TicTacToeNavigationService(), fenix: true);

    // Controllers - order matters: stats before settings, settings before game
    Get.lazyPut(
      () => TicTacToeStatsController(Get.find<StorageService>()),
      fenix: true,
    );
    Get.lazyPut(() => TicTacToeSettingsController(), fenix: true);
    Get.lazyPut(
      () => TicTacToeGameController(
        Get.find<TicTacToeNavigationService>(),
        Get.find<AIService>(),
      ),
      fenix: true,
    );
  }
}
