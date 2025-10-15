import 'package:get/get.dart';
import 'dart:developer' as dev;
import '../controllers/game_controller.dart';
import '../services/storage_service.dart';
import '../services/sound_service.dart';
import '../services/ai_service.dart';

class ChessBinding extends Bindings {
  @override
  void dependencies() {
    dev.log('Initializing chess dependencies', name: 'Chess');

    // Initialize services first
    if (!Get.isRegistered<ChessStorageService>()) {
      dev.log('Initializing storage service', name: 'Chess');
      Get.put(ChessStorageService(), permanent: true);
    }

    if (!Get.isRegistered<ChessSoundService>()) {
      dev.log('Initializing sound service', name: 'Chess');
      Get.put(ChessSoundService(), permanent: true);
    }

    if (!Get.isRegistered<ChessAIService>()) {
      dev.log('Initializing AI service', name: 'Chess');
      Get.put(ChessAIService(), permanent: true);
    }

    // Initialize controller with dependencies
    if (!Get.isRegistered<ChessGameController>()) {
      dev.log('Initializing game controller', name: 'Chess');
      Get.put(ChessGameController(
        Get.find<ChessStorageService>(),
        Get.find<ChessSoundService>(),
      ));
    } else {
      dev.log('Game controller already initialized', name: 'Chess');
    }

    dev.log('Chess dependencies initialized', name: 'Chess');
  }
}