import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:developer' as dev;
import '../controllers/game_controller.dart';
import '../bindings/chess_binding.dart';
import '../services/storage_service.dart';
import '../services/sound_service.dart';
import 'settings_screen.dart';
import 'game_screen.dart';
import '../widgets/game_options_dialog.dart';
import 'package:gameverse/theme/app_theme.dart';
import 'package:gameverse/widgets/premium_background.dart';

class ChessModeSelectionScreen extends StatelessWidget {
  const ChessModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    dev.log('Building ChessModeSelectionScreen', name: 'Chess');

    // Initialize services using the binding
    ChessBinding().dependencies();
    dev.log('Chess dependencies initialized', name: 'Chess');

    final theme = Theme.of(context);
    final primaryColor = const Color(0xFFF4B860); // Warm gold for Chess
    final secondaryColor = const Color(0xFF7CC6D9); // Soft teal accent

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
                  'assets/images/games/chess.png',
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
                    'Choose your strategy',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.15),
                  const SizedBox(height: 20),
                  _buildHeroCard(theme, primaryColor)
                      .animate()
                      .fadeIn(delay: 120.ms, duration: 600.ms)
                      .slideY(begin: 0.12),
                  const SizedBox(height: 20),
                  _buildModeCard(
                    context,
                    icon: Icons.psychology_rounded,
                    title: 'Play vs AI',
                    subtitle: 'Test your skills against the engine',
                    mode: ChessGameMode.ai,
                    accentColor: primaryColor,
                  )
                      .animate()
                      .fadeIn(delay: 180.ms, duration: 600.ms)
                      .slideX(begin: 0.08),
                  const SizedBox(height: 16),
                  _buildModeCard(
                    context,
                    icon: Icons.groups_2_rounded,
                    title: 'Two Players',
                    subtitle: 'Classic local match with a friend',
                    mode: ChessGameMode.local,
                    accentColor: secondaryColor,
                  )
                      .animate()
                      .fadeIn(delay: 240.ms, duration: 600.ms)
                      .slideX(begin: 0.08),
                  const SizedBox(height: 32),
                  _buildStatsOverview(context)
                      .animate()
                      .fadeIn(delay: 350.ms, duration: 600.ms)
                      .slideY(begin: 0.1),
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
          icon: Icons.settings_rounded,
          onTap: _openSettings,
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
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'CHESS',
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

  Widget _buildModeCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required ChessGameMode mode,
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

  Widget _buildStatsOverview(BuildContext context) {
    final theme = Theme.of(context);
    final storage = Get.find<ChessStorageService>();
    final primaryColor = const Color(0xFFF4B860);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassmorphicDecoration(
        backgroundColor: Colors.white.withValues(alpha: 0.05),
        borderColor: Colors.white.withValues(alpha: 0.1),
        borderRadius: 32,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.bar_chart_rounded,
                    size: 20, color: primaryColor),
              ),
              const SizedBox(width: 12),
              Text(
                'STATISTICS',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCompactStat(
                      'PLAYED', storage.gamesPlayed.toString(), primaryColor),
                  _buildCompactStat(
                      'WON', storage.gamesWon.toString(), Colors.greenAccent),
                  _buildCompactStat(
                      'LOST', storage.gamesLost.toString(), Colors.redAccent),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildCompactStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: color,
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  void _openSettings() {
    final soundService = Get.find<ChessSoundService>();
    soundService.playMenuSelectionSound();
    Get.to(() => const ChessSettingsScreen(),
        transition: Transition.rightToLeft);
  }

  Future<void> _startGame(ChessGameMode mode) async {
    final controller = Get.find<ChessGameController>();
    final soundService = Get.find<ChessSoundService>();

    final result = await Get.dialog<Map<String, dynamic>>(
      GameOptionsDialog(mode: mode),
      barrierDismissible: false,
    );

    if (result != null) {
      controller.timerEnabled.value = result['timerEnabled'] ?? false;
      controller.timePerPlayer.value = result['timePerPlayer'] ?? 10;
      controller.storageService
          .updateTimerEnabled(controller.timerEnabled.value);
      controller.storageService
          .updateTimePerPlayer(controller.timePerPlayer.value);
      if (mode == ChessGameMode.ai) {
        final difficulty = result['difficulty'] ?? 2;
        controller.aiDifficulty.value = difficulty;
        controller.aiService.setDifficulty(difficulty);
        controller.storageService.updateAiDifficulty(difficulty);
      }

      controller.startNewGame(mode);
      soundService.playGameStartSound();

      Get.to(
        () => const ChessGameScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );
    }
  }
}
