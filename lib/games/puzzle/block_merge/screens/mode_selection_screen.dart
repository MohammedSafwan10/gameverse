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

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<BlockMergeController>()) {
      BlockMergeBinding().dependencies();
    }

    final settingsController = Get.find<BlockMergeSettingsController>();

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
            onPressed: () => Get.to(() => const BlockMergeSettingsScreen()),
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
                  color: Colors.orange.withOpacity(0.05),
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
                  color: Colors.amber.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(settingsController).animate().fadeIn().slideY(begin: -0.2),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _buildModeCard(
                        title: 'Classic Mode',
                        description:
                            'Reach 2048 with no time pressure. Perfect for strategic play!',
                        icon: Icons.grid_view_rounded,
                        mode: BlockMergeMode.classic,
                        features: ['Unlimited time', 'Reach 2048 to win'],
                        settingsController: settingsController,
                        index: 0,
                      ),
                      const SizedBox(height: 16),
                      _buildModeCard(
                        title: 'Time Challenge',
                        description:
                            'Race against time! Reach the highest score before time runs out.',
                        icon: Icons.timer_rounded,
                        mode: BlockMergeMode.timeChallenge,
                        features: ['3 minutes limit', 'High score challenge'],
                        settingsController: settingsController,
                        index: 1,
                      ),
                      const SizedBox(height: 16),
                      _buildModeCard(
                        title: 'Zen Mode',
                        description:
                            'Relaxed mode with no game over. Practice and improve your strategy.',
                        icon: Icons.spa_rounded,
                        mode: BlockMergeMode.zen,
                        features: ['No game over', 'Practice mode'],
                        settingsController: settingsController,
                        index: 2,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BlockMergeSettingsController settingsController) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Text(
            'Block Merge',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose your challenge',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          Obx(() => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatChip(
                  'Best Score',
                  settingsController.bestScore.value.toString(),
                  Icons.emoji_events_rounded,
                  Colors.amber,
                ),
                _buildStatChip(
                  'Games Won',
                  settingsController.gamesWon.value.toString(),
                  Icons.workspace_premium_rounded,
                  Colors.purple,
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, IconData icon, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
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
        ),
      ],
    );
  }

  Widget _buildModeCard({
    required String title,
    required String description,
    required IconData icon,
    required BlockMergeMode mode,
    required List<String> features,
    required BlockMergeSettingsController settingsController,
    required int index,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () {
            final controller = Get.find<BlockMergeController>();
            controller.clearGameState();
            settingsController.setGameMode(mode);
            controller.newGame();
            Get.to(() => const BlockMergeGameScreen());
          },
          borderRadius: BorderRadius.circular(24),
          splashColor: Colors.orange.withOpacity(0.1),
          highlightColor: Colors.orange.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, color: Colors.orange, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
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
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: (200 * index).ms).fadeIn().slideX(begin: 0.2);
  }

  Widget _buildFeatureChip(String feature) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Text(
        feature,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.orange,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
