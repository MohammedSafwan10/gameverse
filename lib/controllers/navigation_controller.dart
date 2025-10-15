import 'package:get/get.dart';

class NavigationController extends GetxController {
  final selectedIndex = 0.obs;

  void changePage(int index) {
    if (index >= 0 && index <= 1) {
      // Only allow indices 0 and 1
      selectedIndex.value = index;
    }
  }
}
