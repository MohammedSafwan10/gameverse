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
    ChessBinding().dependencies();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: Colors.black87,
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            color: Colors.black87,
            onPressed: () {
              _openSettings();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
           // Decorative Background
            Positioned(
              right: -100,
              top: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -50,
              bottom: 50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'Chess',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: -1,
                      ),
                    ).animate().fadeIn().slideX(begin: -0.2),
                    const Text(
                      'Master the classic game of strategy',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                    const SizedBox(height: 48),

                    // Game Modes
                    const Text(
                      'Game Modes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 16),

                    _buildModeButton(
                      'Play vs AI',
                      Icons.computer_rounded,
                      'Challenge the computer at chess',
                      () => _startGame(ChessGameMode.ai),
                      Colors.indigo,
                      0,
                    ),
                    const SizedBox(height: 16),
                    _buildModeButton(
                      'Two Players',
                      Icons.people_rounded,
                      'Play against a friend locally',
                      () => _startGame(ChessGameMode.local),
                      Colors.teal,
                      1,
                    ),

                    const SizedBox(height: 48),

                    // Statistics
                    Row(
                      children: [
                        Icon(Icons.bar_chart_rounded, color: Colors.indigo),
                        const SizedBox(width: 8),
                        const Text(
                          'Statistics',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 600.ms),
                    const SizedBox(height: 16),

                    Obx(() {
                      return Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatItem(
                              'Played',
                              Get.find<ChessStorageService>()
                                  .gamesPlayed
                                  .toString(),
                              Icons.sports_esports,
                              Colors.indigo,
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
                      );
                    }).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(
    String text,
    IconData icon,
    String description,
    VoidCallback onPressed,
    Color color,
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
          onTap: onPressed,
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
                  child: Icon(icon, size: 28, color: color),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
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
    ).animate(delay: (400 + (index * 100)).ms).fadeIn().slideX(begin: 0.2);
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _openSettings() {
    final soundService = Get.find<ChessSoundService>();
    soundService.playMenuSelectionSound();
    Get.to(
      () => const ChessSettingsScreen(),
      transition: Transition.rightToLeft,
    );
  }

  Future<void> _startGame(ChessGameMode mode) async {
    final controller = Get.find<ChessGameController>();
    final soundService = Get.find<ChessSoundService>();

    // Show game options dialog
    final result = await Get.dialog<Map<String, dynamic>>(
      GameOptionsDialog(mode: mode),
      barrierDismissible: false,
    );

    if (result != null) {
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
