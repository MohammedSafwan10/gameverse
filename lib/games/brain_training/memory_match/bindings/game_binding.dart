import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../controllers/game_controller.dart';
import '../services/sound_service.dart';

class MemoryMatchBinding implements Bindings {
  static final _logger = Logger();

  @override
  void dependencies() {
    initDependencies();
  }

  static void initDependencies() {
    try {
      // Initialize services first
      if (!Get.isRegistered<SoundService>()) {
        Get.put<SoundService>(SoundService(), permanent: true);
      }

      // Then initialize controllers
      if (!Get.isRegistered<MemoryMatchGameController>()) {
        Get.put<MemoryMatchGameController>(MemoryMatchGameController());
      }
    } catch (e, stackTrace) {
      _logger.e(
        'Error initializing Memory Match dependencies',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }
}
