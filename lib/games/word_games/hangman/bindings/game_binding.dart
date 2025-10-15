import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../services/storage_service.dart';
import '../services/sound_service.dart';

class HangmanBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize services
    Get.lazyPut(() => HangmanStorageService());
    Get.lazyPut(() => HangmanSoundService());

    // Initialize controllers
    Get.lazyPut(() => HangmanGameController(
          Get.find<HangmanStorageService>(),
          Get.find<HangmanSoundService>(),
        ));
  }
} 