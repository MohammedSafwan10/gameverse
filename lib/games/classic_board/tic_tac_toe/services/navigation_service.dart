import 'package:get/get.dart';
import 'package:flutter/widgets.dart';

class TicTacToeNavigationService extends GetxService {
  static TicTacToeNavigationService get to =>
      Get.find<TicTacToeNavigationService>();

  void toModeSelection() {
    Get.toNamed('/tic-tac-toe');
  }

  void toGame() {
    Get.toNamed('/tic-tac-toe/game');
  }

  void back() {
    Get.back();
  }

  void backWithContext(BuildContext context, {Object? result}) {
    Navigator.of(context).pop(result);
  }

  void toSettings() {
    Get.toNamed('/tic-tac-toe/settings');
  }

  void toStats() {
    Get.toNamed('/tic-tac-toe/stats');
  }
}
