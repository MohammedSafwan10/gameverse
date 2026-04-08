import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/game_controller.dart';
import '../controllers/settings_controller.dart';
import '../bindings/game_binding.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import 'package:gameverse/theme/app_theme.dart';
import 'package:gameverse/widgets/premium_background.dart';

class ConnectFourModeScreen extends StatelessWidget {
  const ConnectFourModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Connect Four Theme Colors
    final primaryColor = Colors.blue.shade600;
    final secondaryColor = Colors.redAccent;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const PremiumBackground(),
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/games/connect_four.png',
                  fit: BoxFit.cover,
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.32),
                        const Color(0xFF0F172A).withValues(alpha: 0.88),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(context),
                  const SizedBox(height: 28),
                  Text(
                    'Choose how you want to play',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: const Duration(milliseconds: 500))
                      .slideY(begin: 0.15),
                  const SizedBox(height: 20),
                  _buildHeroCard(theme, primaryColor)
                      .animate()
                      .fadeIn(
                          delay: const Duration(milliseconds: 120),
                          duration: const Duration(milliseconds: 600))
                      .slideY(begin: 0.12),
                  const SizedBox(height: 20),
                  _buildModeCard(
                    icon: Icons.smart_toy_rounded,
                    title: 'Single Player',
                    subtitle: 'Play against AI',
                    mode: GameMode.vsAI,
                    accentColor: secondaryColor,
                  )
                      .animate()
                      .fadeIn(
                          delay: const Duration(milliseconds: 180),
                          duration: const Duration(milliseconds: 600))
                      .slideX(begin: 0.08),
                  const SizedBox(height: 16),
                  _buildModeCard(
                    icon: Icons.groups_2_rounded,
                    title: 'Two Players',
                    subtitle: 'Play with a friend',
                    mode: GameMode.pvp,
                    accentColor: primaryColor,
                  )
                      .animate()
                      .fadeIn(
                          delay: const Duration(milliseconds: 240),
                          duration: const Duration(milliseconds: 600))
                      .slideX(begin: 0.08),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: IconButton(
            onPressed: Get.back,
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 18),
          ),
        ),
        const Spacer(),
        _quickActionButton(
          icon: Icons.bar_chart_rounded,
          onTap: () => Get.to(() => const ConnectFourStatsScreen()),
        ),
        const SizedBox(width: 10),
        _quickActionButton(
          icon: Icons.settings_rounded,
          onTap: () {
            if (!Get.isRegistered<ConnectFourSettingsController>()) {
              Get.put(ConnectFourSettingsController(), permanent: true);
            }
            Get.to(() => ConnectFourSettingsScreen());
          },
        ),
      ],
    );
  }

  Widget _quickActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: AppTheme.glassmorphicDecoration(
            backgroundColor: Colors.white.withValues(alpha: 0.14),
            borderColor: Colors.white.withValues(alpha: 0.16),
            borderRadius: 999,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildHeroCard(ThemeData theme, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.amberAccent,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amberAccent.withValues(alpha: 0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'CONNECT FOUR',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 4,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required GameMode mode,
    required Color accentColor,
  }) {
    return Container(
      decoration: AppTheme.glassmorphicDecoration(
        backgroundColor: Colors.white,
        borderColor: Colors.white,
        borderRadius: 28,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _startGame(mode),
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: AppTheme.glassmorphicDecoration(
                    backgroundColor: accentColor.withValues(alpha: 0.16),
                    borderColor: accentColor.withValues(alpha: 0.24),
                    borderRadius: 20,
                  ),
                  child: Icon(
                    icon,
                    size: 30,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.72),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 42,
                  height: 42,
                  decoration: AppTheme.glassmorphicDecoration(
                    backgroundColor: Colors.white.withValues(alpha: 0.08),
                    borderColor: Colors.white.withValues(alpha: 0.1),
                    borderRadius: 999,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
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
