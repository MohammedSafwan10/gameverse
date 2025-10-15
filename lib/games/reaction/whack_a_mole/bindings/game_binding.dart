import 'package:get/get.dart';
import 'dart:developer' as dev;
import '../controllers/game_controller.dart';
import '../controllers/score_controller.dart';
import '../controllers/settings_controller.dart';
import '../services/audio_service.dart';
import '../services/stats_service.dart';

class WhackAMoleBinding extends Bindings {
  @override
  void dependencies() {
    dev.log('Initializing Whack-A-Mole dependencies', name: 'WhackAMole');

    // Initialize services first (permanent)
    if (!Get.isRegistered<WhackAMoleAudioService>()) {
      dev.log('Initializing audio service', name: 'WhackAMole');
      Get.put(WhackAMoleAudioService(), permanent: true);
    }

    if (!Get.isRegistered<WhackAMoleStatsService>()) {
      dev.log('Initializing stats service', name: 'WhackAMole');
      Get.put(WhackAMoleStatsService(), permanent: true);
    }

    // Initialize controllers
    if (!Get.isRegistered<WhackAMoleSettingsController>()) {
      dev.log('Initializing settings controller', name: 'WhackAMole');
      Get.put(WhackAMoleSettingsController(), permanent: true);
    }

    if (!Get.isRegistered<WhackAMoleScoreController>()) {
      dev.log('Initializing score controller', name: 'WhackAMole');
      Get.put(WhackAMoleScoreController());
    }

    // Initialize game controller last since it depends on other controllers
    if (!Get.isRegistered<WhackAMoleGameController>()) {
      dev.log('Initializing game controller', name: 'WhackAMole');
      Get.put(WhackAMoleGameController());
    } else {
      dev.log('Game controller already initialized', name: 'WhackAMole');
      // Reset game state if controller exists
      final controller = Get.find<WhackAMoleGameController>();
      controller.resetGame();
    }

    dev.log('Whack-A-Mole dependencies initialized', name: 'WhackAMole');
  }
}
