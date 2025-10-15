import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Get.theme.colorScheme.primary.withValues(
                red: Get.theme.colorScheme.primary.r.toDouble(),
                green: Get.theme.colorScheme.primary.g.toDouble(),
                blue: Get.theme.colorScheme.primary.b.toDouble(),
                alpha: 0.1,
              ),
              Get.theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
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
                        Icons.people,
                        Colors.blue,
                        () => _startGame(GameMode.pvp),
                      ),
                      const SizedBox(height: 24),
                      _buildModeButton(
                        'Player vs AI',
                        'Challenge our smart AI opponent',
                        Icons.smart_toy,
                        Colors.purple,
                        () => _startGame(GameMode.vsAI),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 16),
          Text(
            'Connect Four',
            style: Get.textTheme.headlineMedium?.copyWith(
              color: Get.theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              // Ensure the settings controller is initialized
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
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Get.theme.colorScheme.primary.withValues(
              red: Get.theme.colorScheme.primary.r.toDouble(),
              green: Get.theme.colorScheme.primary.g.toDouble(),
              blue: Get.theme.colorScheme.primary.b.toDouble(),
              alpha: 0.3,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(
                      red: color.r.toDouble(),
                      green: color.g.toDouble(),
                      blue: color.b.toDouble(),
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: color,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Get.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: Get.textTheme.bodyMedium?.copyWith(
                          color: Get.theme.colorScheme.onSurface.withValues(
                            red: Get.theme.colorScheme.onSurface.r.toDouble(),
                            green: Get.theme.colorScheme.onSurface.g.toDouble(),
                            blue: Get.theme.colorScheme.onSurface.b.toDouble(),
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Get.theme.colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startGame(GameMode mode) {
    // Ensure the settings controller is initialized
    if (!Get.isRegistered<ConnectFourSettingsController>()) {
      Get.put(ConnectFourSettingsController(), permanent: true);
    }

    // Update the settings controller with the selected mode
    final settingsController = Get.find<ConnectFourSettingsController>();
    settingsController.setGameMode(mode);

    Get.to(
      () => const ConnectFourGameScreen(),
      binding: ConnectFourBinding(gameMode: mode),
      transition: Transition.rightToLeft,
    )?.then((_) {
      // Clean up when returning from game
      Get.delete<ConnectFourController>();
    });
  }
}
