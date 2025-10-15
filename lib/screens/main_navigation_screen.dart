import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/navigation_controller.dart';
import '../controllers/home_controller.dart';
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
      body: Obx(
        () => _screens[Get.find<NavigationController>().selectedIndex.value],
      ),
      bottomNavigationBar: Obx(
        () => NavigationBar(
          selectedIndex: Get.find<NavigationController>().selectedIndex.value,
          onDestinationSelected: Get.find<NavigationController>().changePage,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
