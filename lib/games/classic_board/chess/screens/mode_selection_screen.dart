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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              dev.log('Navigating to settings screen', name: 'Chess');
              _openSettings();
            },
          ).animate()
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withValues(
                red: theme.colorScheme.primary.r.toDouble(),
                green: theme.colorScheme.primary.g.toDouble(),
                blue: theme.colorScheme.primary.b.toDouble(),
                alpha: 0.1,
              ),
              theme.colorScheme.surfaceContainerHighest,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Chess',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ).animate().fadeIn().slideY(
                        begin: -0.3,
                        curve: Curves.easeOutBack,
                      ),
                  const SizedBox(height: 48),

                  // Game Modes Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.sports_esports,
                                  color: theme.colorScheme.primary),
                              const SizedBox(width: 8),
                              const Text(
                                'Game Modes',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          _buildModeButton(
                            'Play vs AI',
                            Icons.computer,
                            'Challenge the computer at chess',
                            () => _startGame(ChessGameMode.ai),
                            theme,
                          ).animate().fadeIn(delay: 200.ms).slideX(
                                begin: -0.3,
                                curve: Curves.easeOutBack,
                              ),
                          const SizedBox(height: 16),
                          _buildModeButton(
                            'Two Players',
                            Icons.people,
                            'Play against a friend locally',
                            () => _startGame(ChessGameMode.local),
                            theme,
                          ).animate().fadeIn(delay: 400.ms).slideX(
                                begin: 0.3,
                                curve: Curves.easeOutBack,
                              ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Statistics Card
                  Obx(() {
                    dev.log('Rebuilding statistics section', name: 'Chess');
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.bar_chart,
                                    color: theme.colorScheme.primary),
                                const SizedBox(width: 8),
                                const Text(
                                  'Statistics',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStatItem(
                                  'Played',
                                  Get.find<ChessStorageService>()
                                      .gamesPlayed
                                      .toString(),
                                  Icons.sports_esports,
                                  theme.colorScheme.primary,
                                ),
                                _buildStatItem(
                                  'Won',
                                  Get.find<ChessStorageService>()
                                      .gamesWon
                                      .toString(),
                                  Icons.emoji_events,
                                  Colors.green,
                                ),
                                _buildStatItem(
                                  'Lost',
                                  Get.find<ChessStorageService>()
                                      .gamesLost
                                      .toString(),
                                  Icons.close,
                                  Colors.red,
                                ),
                                _buildStatItem(
                                  'Draw',
                                  Get.find<ChessStorageService>()
                                      .gamesDraw
                                      .toString(),
                                  Icons.balance,
                                  Colors.orange,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms).slideY(
                          begin: 0.3,
                          curve: Curves.easeOutBack,
                        );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(
    String text,
    IconData icon,
    String description,
    VoidCallback onPressed,
    ThemeData theme,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(
                  red: theme.colorScheme.primary.r.toDouble(),
                  green: theme.colorScheme.primary.g.toDouble(),
                  blue: theme.colorScheme.primary.b.toDouble(),
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withValues(
                        red: theme.colorScheme.onSurface.r.toDouble(),
                        green: theme.colorScheme.onSurface.g.toDouble(),
                        blue: theme.colorScheme.onSurface.b.toDouble(),
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(
                red: theme.colorScheme.onSurface.r.toDouble(),
                green: theme.colorScheme.onSurface.g.toDouble(),
                blue: theme.colorScheme.onSurface.b.toDouble(),
                alpha: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  void _openSettings() {
    dev.log('Opening settings screen', name: 'Chess');
    final soundService = Get.find<ChessSoundService>();
    soundService.playMenuSelectionSound();
    Get.to(
      () => const ChessSettingsScreen(),
      transition: Transition.rightToLeft,
    );
  }

  Future<void> _startGame(ChessGameMode mode) async {
    dev.log('Starting game with mode: $mode', name: 'Chess');
    final controller = Get.find<ChessGameController>();
    final soundService = Get.find<ChessSoundService>();

    // Show game options dialog
    final result = await Get.dialog<Map<String, dynamic>>(
      GameOptionsDialog(mode: mode),
      barrierDismissible: false,
    );

    if (result != null) {
      dev.log('Game options selected: $result', name: 'Chess');
      // Configure game settings
      controller.timerEnabled.value = result['timerEnabled'] ?? false;
      controller.timePerPlayer.value = result['timePerPlayer'] ?? 10;
      if (mode == ChessGameMode.ai) {
        controller.aiService.setDifficulty(result['difficulty'] ?? 2);
      }

      // Start new game
      controller.startNewGame(mode);
      soundService.playGameStartSound();

      // Navigate to game screen
      Get.to(
        () => const ChessGameScreen(),
        transition: Transition.fadeIn,
        duration: const Duration(milliseconds: 500),
      );
    }
  }
}
