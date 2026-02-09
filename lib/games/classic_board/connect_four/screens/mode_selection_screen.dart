import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/game_controller.dart';
import '../controllers/settings_controller.dart';
import '../bindings/game_binding.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'package:gameverse/widgets/premium_background.dart';

class ConnectFourModeScreen extends StatelessWidget {
  const ConnectFourModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              if (!Get.isRegistered<ConnectFourSettingsController>()) {
                Get.put(ConnectFourSettingsController(), permanent: true);
              }
              Get.to(() => ConnectFourSettingsScreen());
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          const PremiumBackground(),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Header with Icon
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.blur_on_rounded,
                        size: 80,
                        color: theme.colorScheme.primary,
                      ),
                    )
                        .animate()
                        .scale(duration: 600.ms, curve: Curves.easeOutBack),

                    const SizedBox(height: 24),
                    Text(
                      'CONNECT FOUR',
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: theme.colorScheme.onSurface,
                      ),
                    ).animate().fadeIn().slideY(begin: 0.2),

                    const SizedBox(height: 8),
                    Text(
                      'STRATEGY & TACTICS',
                      style: theme.textTheme.labelLarge?.copyWith(
                        letterSpacing: 4,
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 48),

                    // Mode Selection
                    _buildModeCard(
                      context,
                      title: 'Player vs Player',
                      description: 'Challenge a friend sitting next to you',
                      icon: Icons.people_outline_rounded,
                      color: Colors.blue,
                      onTap: () => _startGame(GameMode.pvp),
                    ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),

                    const SizedBox(height: 16),

                    _buildModeCard(
                      context,
                      title: 'Player vs AI',
                      description: 'Test your skills against our smart bot',
                      icon: Icons.smart_toy_outlined,
                      color: Colors.purple,
                      onTap: () => _startGame(GameMode.vsAI),
                    ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.2),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 32),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 16, color: theme.colorScheme.outline),
              ],
            ),
          ),
        ),
      ),
    );
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
