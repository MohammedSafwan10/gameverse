import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:developer' as dev;
import '../controllers/settings_controller.dart';
import '../controllers/game_controller.dart';
import '../bindings/game_binding.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

class BlockMergeModeSelectionScreen extends StatelessWidget {
  const BlockMergeModeSelectionScreen({super.key});

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.orange.shade800),
                const SizedBox(width: 8),
                const Text('Exit Game'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Are you sure you want to exit Block Merge?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You can always come back and play later!',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade800,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Exit',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    dev.log('Building BlockMergeModeSelectionScreen', name: 'BlockMerge');

    // Initialize services using the binding
    if (!Get.isRegistered<BlockMergeController>()) {
      dev.log('Initializing Block Merge dependencies', name: 'BlockMerge');
      BlockMergeBinding().dependencies();
    } else {
      dev.log('Block Merge dependencies already initialized',
          name: 'BlockMerge');
    }

    final settingsController = Get.find<BlockMergeSettingsController>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _showExitConfirmationDialog(context);
          if (shouldPop) {
            Get.back();
          }
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final shouldPop = await _showExitConfirmationDialog(context);
              if (shouldPop) {
                Get.back();
              }
            },
          ).animate().fadeIn(delay: 100.ms),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Get.to(() => const BlockMergeSettingsScreen()),
              tooltip: 'Game Settings',
            ).animate().fadeIn(delay: 100.ms),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange.shade200,
                Colors.orange.shade50,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(settingsController),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildModeCard(
                          title: 'Classic Mode',
                          description:
                              'Reach 2048 with no time pressure. Perfect for strategic play!',
                          icon: Icons.grid_4x4,
                          mode: BlockMergeMode.classic,
                          features: [
                            'Unlimited time',
                            'Reach 2048 to win',
                            'Keep playing after winning',
                            'Track your high score',
                          ],
                          settingsController: settingsController,
                        ),
                        const SizedBox(height: 16),
                        _buildModeCard(
                          title: 'Time Challenge',
                          description:
                              'Race against time! Reach the highest score before time runs out.',
                          icon: Icons.timer,
                          mode: BlockMergeMode.timeChallenge,
                          features: [
                            '3 minutes time limit',
                            'Score as high as possible',
                            'Quick thinking required',
                            'Perfect for speed runs',
                          ],
                          settingsController: settingsController,
                        ),
                        const SizedBox(height: 16),
                        _buildModeCard(
                          title: 'Zen Mode',
                          description:
                              'Relaxed mode with no game over. Practice and improve your strategy.',
                          icon: Icons.spa,
                          mode: BlockMergeMode.zen,
                          features: [
                            'No game over',
                            'Practice freely',
                            'Experiment with strategies',
                            'Perfect for beginners',
                          ],
                          settingsController: settingsController,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required String title,
    required String description,
    required IconData icon,
    required BlockMergeMode mode,
    required List<String> features,
    required BlockMergeSettingsController settingsController,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () {
          dev.log('Starting $title', name: 'BlockMerge');
          // Clear any existing game state before switching modes
          final controller = Get.find<BlockMergeController>();
          controller.clearGameState();
          settingsController.setGameMode(mode);
          // Start a new game immediately after mode change
          controller.newGame();
          Get.to(() => const BlockMergeGameScreen());
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.shade200.withValues(
                            red: Colors.orange.shade200.r.toDouble(),
                            green: Colors.orange.shade200.g.toDouble(),
                            blue: Colors.orange.shade200.b.toDouble(),
                            alpha: 0.5,
                          ),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(icon, color: Colors.orange.shade800, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: features
                    .map((feature) => _buildFeatureChip(feature))
                    .toList(),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      dev.log('Starting $title', name: 'BlockMerge');
                      settingsController.setGameMode(mode);
                      Get.to(() => const BlockMergeGameScreen());
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Play Now'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange.shade800,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2);
  }

  Widget _buildFeatureChip(String feature) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline,
              size: 16, color: Colors.orange.shade800),
          const SizedBox(width: 4),
          Text(
            feature,
            style: TextStyle(
              fontSize: 12,
              color: Colors.orange.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BlockMergeSettingsController settingsController) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            'Block Merge',
            style: Get.textTheme.headlineMedium?.copyWith(
              color: Colors.orange.shade800,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn().slideY(begin: -0.3, curve: Curves.easeOutBack),
          const SizedBox(height: 8),
          Text(
            'Choose Your Game Mode',
            style: TextStyle(
              fontSize: 16,
              color: Colors.orange.shade600,
              fontWeight: FontWeight.w500,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 16),
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatChip(
                    'Best Score',
                    settingsController.bestScore.value.toString(),
                    Icons.emoji_events,
                  ),
                  const SizedBox(width: 12),
                  _buildStatChip(
                    'Games Won',
                    settingsController.gamesWon.value.toString(),
                    Icons.workspace_premium,
                  ),
                  const SizedBox(width: 12),
                  _buildStatChip(
                    'Win Rate',
                    settingsController.getWinRate(),
                    Icons.analytics,
                  ),
                ],
              )).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              red: Colors.black.r.toDouble(),
              green: Colors.black.g.toDouble(),
              blue: Colors.black.b.toDouble(),
              alpha: 0.05,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.orange.shade800),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange.shade900,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
