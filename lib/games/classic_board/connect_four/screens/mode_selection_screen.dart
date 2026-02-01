import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/game_controller.dart';
import '../controllers/settings_controller.dart';
import '../bindings/game_binding.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

class ConnectFourModeScreen extends StatelessWidget {
  const ConnectFourModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: Stack(
        children: [
          // Decorative Background
          Positioned(
            right: -100,
            top: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader().animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
                const SizedBox(height: 40),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildModeButton(
                          'Player vs Player',
                          'Challenge your friend locally',
                          Icons.people_outline_rounded,
                          Colors.blue,
                          () => _startGame(GameMode.pvp),
                          0,
                        ),
                        const SizedBox(height: 24),
                        _buildModeButton(
                          'Player vs AI',
                          'Challenge our smart AI opponent',
                          Icons.smart_toy_outlined,
                          Colors.purple,
                          () => _startGame(GameMode.vsAI),
                          1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: Colors.black87,
            onPressed: () => Get.back(),
          ),
          Text(
            'Connect Four',
            style: Get.textTheme.headlineMedium?.copyWith(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            color: Colors.black87,
            tooltip: 'Settings',
            onPressed: () {
              if (!Get.isRegistered<ConnectFourSettingsController>()) {
                Get.put(ConnectFourSettingsController(), permanent: true);
              }
              Get.to(() => ConnectFourSettingsScreen());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
    int index,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          splashColor: color.withOpacity(0.1),
          highlightColor: color.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: color,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: color.withOpacity(0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: (200 * index).ms).fadeIn().slideX(begin: 0.2);
  }

  void _startGame(GameMode mode) {
    if (!Get.isRegistered<ConnectFourSettingsController>()) {
      Get.put(ConnectFourSettingsController(), permanent: true);
    }

    final settingsController = Get.find<ConnectFourSettingsController>();
    settingsController.setGameMode(mode);

    Get.to(
      () => const ConnectFourGameScreen(),
      binding: ConnectFourBinding(gameMode: mode),
      transition: Transition.rightToLeft,
    )?.then((_) {
      Get.delete<ConnectFourController>();
    });
  }
}
