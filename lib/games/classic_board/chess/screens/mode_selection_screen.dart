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
              dev.log('Navigating to settings screen', name: 'Chess');
              _openSettings();
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
                        Icons.grid_view_rounded,
                        size: 80,
                        color: theme.colorScheme.primary,
                      ),
                    )
                        .animate()
                        .scale(duration: 600.ms, curve: Curves.easeOutBack),

                    const SizedBox(height: 24),
                    Text(
                      'CHESS',
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        color: theme.colorScheme.onSurface,
                      ),
                    ).animate().fadeIn().slideY(begin: 0.2),

                    const SizedBox(height: 8),
                    Text(
                      'THE ULTIMATE STRATEGY GAME',
                      style: theme.textTheme.labelLarge?.copyWith(
                        letterSpacing: 2,
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(delay: 200.ms),

                    const SizedBox(height: 48),

                    // Mode Selection
                    _buildModeCard(
                      context,
                      title: 'Play vs AI',
                      description: 'Test your skills against the engine',
                      icon: Icons.psychology_outlined,
                      color: theme.colorScheme.primary,
                      onTap: () => _startGame(ChessGameMode.ai),
                    ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2),

                    const SizedBox(height: 16),

                    _buildModeCard(
                      context,
                      title: 'Two Players',
                      description: 'Classic local match with a friend',
                      icon: Icons.people_outline_rounded,
                      color: theme.colorScheme.secondary,
                      onTap: () => _startGame(ChessGameMode.local),
                    ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.2),

                    const SizedBox(height: 40),

                    // Quick Stats
                    _buildStatsOverview(context),
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

  Widget _buildStatsOverview(BuildContext context) {
    final theme = Theme.of(context);
    return Obx(() {
      final storage = Get.find<ChessStorageService>();
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.05)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.bar_chart_rounded,
                    size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'STATISTICS',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCompactStat('PLAYED', storage.gamesPlayed.toString(),
                    theme.colorScheme.primary),
                _buildCompactStat(
                    'WON', storage.gamesWon.toString(), Colors.green),
                _buildCompactStat(
                    'LOST', storage.gamesLost.toString(), Colors.red),
              ],
            ),
          ],
        ),
      );
    }).animate().fadeIn(delay: 700.ms);
  }

  Widget _buildCompactStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
              fontSize: 24, fontWeight: FontWeight.w900, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
              fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
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
      if (mode == ChessGameMode.ai) {
        controller.aiService.setDifficulty(result['difficulty'] ?? 2);
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
