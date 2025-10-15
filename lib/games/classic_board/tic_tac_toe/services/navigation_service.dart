import 'package:get/get.dart';

class TicTacToeNavigationService extends GetxService {
  static TicTacToeNavigationService get to => Get.find<TicTacToeNavigationService>();

  void toModeSelection() {
    Get.toNamed('/tic-tac-toe');
  }

  void toGame() {
    Get.toNamed('/tic-tac-toe/game');
  }

  void back() {
    Get.back();
  }

  void toSettings() {
    Get.toNamed('/tic-tac-toe/settings');
  }

  void toStats() {
    Get.toNamed('/tic-tac-toe/stats');
  }
}
