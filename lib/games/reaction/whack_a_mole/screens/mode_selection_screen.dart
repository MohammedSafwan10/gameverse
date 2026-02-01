import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:developer' as dev;
import '../bindings/game_binding.dart';
import '../controllers/settings_controller.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

class WhackAMoleModeSelectionScreen extends StatelessWidget {
  const WhackAMoleModeSelectionScreen({super.key});

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Exit Game?'),
            content: const Text('Are you sure you want to exit Whack-A-Mole?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Exit'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    dev.log('Building WhackAMoleModeSelectionScreen', name: 'WhackAMole');

    // Initialize services and controllers
    WhackAMoleBinding().dependencies();
    dev.log('WhackAMole dependencies initialized', name: 'WhackAMole');

    final settingsController = Get.find<WhackAMoleSettingsController>();

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
        backgroundColor: const Color(0xFFF8F9FE),
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
                  color: Colors.blue.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.black87),
                          onPressed: () async {
                            final shouldPop =
                                await _showExitConfirmationDialog(context);
                            if (shouldPop) {
                              Get.back();
                            }
                          },
                        ),
                        Text(
                          'Whack-A-Mole',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.help_outline_rounded, color: Colors.black87),
                              onPressed: () => _showHowToPlay(context),
                            ),
                            IconButton(
                              icon: const Icon(Icons.settings_outlined, color: Colors.black87),
                              onPressed: () =>
                                  Get.to(() => const WhackAMoleSettingsScreen()),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Stats Section
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    padding: const EdgeInsets.all(20),
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
                    child: Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatItem(
                              'High Score',
                              '${settingsController.highScore}',
                              Icons.emoji_events_rounded,
                              Colors.amber,
                            ),
                            _buildStatItem(
                              'Games',
                              '${settingsController.gamesPlayed}',
                              Icons.sports_esports_rounded,
                              Colors.blue,
                            ),
                            _buildStatItem(
                              'Best Combo',
                              '${settingsController.bestCombo}',
                              Icons.flash_on_rounded,
                              Colors.orange,
                            ),
                          ],
                        )),
                  ).animate().fadeIn().slideY(begin: -0.2),

                  const SizedBox(height: 20),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'Select Mode',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ).animate().fadeIn(delay: 200.ms),
                  ),

                  const SizedBox(height: 16),

                  // Mode Selection Grid
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                        final childAspectRatio = constraints.maxWidth > 600 ? 1.3 : 0.85;

                        return GridView.count(
                          crossAxisCount: crossAxisCount,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: childAspectRatio,
                          children: [
                            _buildModeCard(
                              'Classic',
                              'Score points in 60 seconds!',
                              Icons.timer_rounded,
                              Colors.blue,
                              () => _startGame('classic'),
                              0,
                            ),
                            _buildModeCard(
                              'Survival',
                              'Play until you run out of lives!',
                              Icons.favorite_rounded,
                              Colors.red,
                              () => _startGame('survival'),
                              1,
                            ),
                            _buildModeCard(
                              'Challenge',
                              'Daily challenges with unique rules!',
                              Icons.star_rounded,
                              Colors.amber,
                              () => _startGame('challenge'),
                              2,
                            ),
                            _buildModeCard(
                              'Practice',
                              'Practice without time limits!',
                              Icons.school_rounded,
                              Colors.green,
                              () => _startGame('practice'),
                              3,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildModeCard(
    String title,
    String description,
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
            blurRadius: 10,
            offset: const Offset(0, 4),
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
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: color,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: (100 * index).ms).fadeIn().scale(curve: Curves.easeOutBack);
  }

  void _startGame(String mode) {
    dev.log('Starting WhackAMole game with mode: $mode', name: 'WhackAMole');
    Get.to(
      () => const WhackAMoleGameScreen(),
      arguments: mode,
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 500),
    );
  }

  void _showHowToPlay(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.help_outline_rounded, color: Colors.blue),
            SizedBox(width: 8),
            Text('How to Play'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHowToPlaySection(
                'Game Objective',
                'Whack as many moles as possible to score points! But be careful of the bombs.',
                Icons.track_changes_rounded,
              ),
              const SizedBox(height: 16),
              _buildHowToPlaySection(
                'Mole Types',
                '• Regular Mole: 10 points\n'
                    '• Golden Mole: 30 points\n'
                    '• Bomb: Reduces score/lives',
                Icons.catching_pokemon_rounded,
              ),
              const SizedBox(height: 16),
              _buildHowToPlaySection(
                'Combo System',
                'Hit moles consecutively to build up your combo multiplier for higher scores!',
                Icons.flash_on_rounded,
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToPlaySection(String title, String content, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(fontSize: 14, color: Colors.grey[700]),
        ),
      ],
    );
  }
}
