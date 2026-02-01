import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import '../controllers/home_controller.dart';
import '../widgets/modern_bottom_nav_bar.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  MainNavigationScreen({super.key}) {
    // Initialize controllers
    Get.put(HomeController());
    Get.put(NavigationController());
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Important for floating nav bar
      body: Obx(
        () => _screens[Get.find<NavigationController>().selectedIndex.value],
      ),
      bottomNavigationBar: Obx(
        () => ModernBottomNavBar(
          selectedIndex: Get.find<NavigationController>().selectedIndex.value,
          onItemSelected: Get.find<NavigationController>().changePage,
        ),
      ),
    );
  }
}
