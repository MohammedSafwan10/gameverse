import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // Always use light theme
    Get.changeThemeMode(ThemeMode.light);
  }

  ThemeMode get themeMode => ThemeMode.light;
}
