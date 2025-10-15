import 'package:get/get.dart';
import 'dart:developer' as dev;
import '../controllers/game_controller.dart';
import '../controllers/settings_controller.dart';
import '../services/storage_service.dart';

class BlockMergeBinding extends Bindings {
  @override
  void dependencies() {
    dev.log('Initializing Block Merge dependencies', name: 'BlockMerge');

    // Initialize services first
    if (!Get.isRegistered<BlockMergeStorageService>()) {
      dev.log('Initializing storage service', name: 'BlockMerge');
      Get.put(BlockMergeStorageService(), permanent: true);
    }

    // Initialize controllers
    if (!Get.isRegistered<BlockMergeSettingsController>()) {
      dev.log('Initializing settings controller', name: 'BlockMerge');
      Get.put(BlockMergeSettingsController(), permanent: true);
    }

    if (!Get.isRegistered<BlockMergeController>()) {
      dev.log('Initializing game controller', name: 'BlockMerge');
      Get.put(BlockMergeController(
        Get.find<BlockMergeSettingsController>(),
      ));
    } else {
      dev.log('Game controller already initialized', name: 'BlockMerge');
      // Reset game state if controller exists
      final controller = Get.find<BlockMergeController>();
      controller.newGame();
    }

    dev.log('Block Merge dependencies initialized', name: 'BlockMerge');
  }
}
