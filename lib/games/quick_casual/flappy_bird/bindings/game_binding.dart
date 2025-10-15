import 'package:get/get.dart';
import 'dart:developer' as dev;
import '../controllers/game_controller.dart';
import '../controllers/settings_controller.dart';
import '../services/score_service.dart';

class FlappyBirdBinding extends Bindings {
  @override
  void dependencies() {
    dev.log('Initializing Flappy Bird dependencies', name: 'FlappyBird');

    // Initialize services first
    if (!Get.isRegistered<ScoreService>()) {
      dev.log('Initializing score service', name: 'FlappyBird');
      Get.put(ScoreService(), permanent: true);
    }

    // Initialize controllers
    if (!Get.isRegistered<FlappyBirdSettingsController>()) {
      dev.log('Initializing settings controller', name: 'FlappyBird');
      Get.put(FlappyBirdSettingsController(), permanent: true);
    }

    if (!Get.isRegistered<FlappyBirdGameController>()) {
      dev.log('Initializing game controller', name: 'FlappyBird');
      Get.put(FlappyBirdGameController(
        scoreService: Get.find<ScoreService>(),
      ));
    } else {
      dev.log('Game controller already initialized', name: 'FlappyBird');
      // Reset game state if controller exists
      final controller = Get.find<FlappyBirdGameController>();
      controller.initGame();
    }

    dev.log('Flappy Bird dependencies initialized', name: 'FlappyBird');
  }
} 