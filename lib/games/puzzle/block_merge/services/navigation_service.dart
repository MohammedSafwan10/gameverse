import 'package:get/get.dart';
import '../screens/game_screen.dart';
import '../screens/mode_selection_screen.dart';

class BlockMergeNavigationService extends GetxService {
  void toGame() {
    Get.to(() => const BlockMergeGameScreen());
  }

  void toModeSelection() {
    Get.to(() => const BlockMergeModeSelectionScreen());
  }

  void back() {
    Get.back();
  }
}
