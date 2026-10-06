import 'package:get/get.dart';
import 'dart:developer' as dev;
import '../controllers/game_controller.dart';
import '../controllers/settings_controller.dart';

class BlockMergeBinding extends Bindings {
  @override
  void dependencies() {
    dev.log('Initializing Block Merge dependencies', name: 'BlockMerge');

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
    }

    dev.log('Block Merge dependencies initialized', name: 'BlockMerge');
  }
}
