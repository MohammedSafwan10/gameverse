import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:developer' as dev;
import '../bindings/game_binding.dart';
import '../theme/game_theme.dart';
import '../controllers/settings_controller.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

class WhackAMoleModeSelectionScreen extends StatelessWidget {
  const WhackAMoleModeSelectionScreen({super.key});

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Game?'),
            content: const Text('Are you sure you want to exit Whack-A-Mole?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit', style: TextStyle(color: Colors.red)),
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
        body: Container(
          decoration: const BoxDecoration(
            gradient: WhackAMoleTheme.backgroundGradient,
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // App Bar
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white),
                        onPressed: () async {
                          final shouldPop =
                              await _showExitConfirmationDialog(context);
                          if (shouldPop) {
                            Get.back();
                          }
                        },
                      ),
                      Expanded(
                        child: Text(
                          'Select Mode',
                          style: WhackAMoleTheme.titleStyle.copyWith(
                            fontSize: MediaQuery.of(context).size.width < 360
                                ? 20
                                : 24,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      IconButton(
                        icon:
                            const Icon(Icons.help_outline, color: Colors.white),
                        onPressed: () => _showHowToPlay(context),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () =>
                            Get.to(() => const WhackAMoleSettingsScreen()),
                      ),
                    ],
                  ),
                ),

                // Stats Section
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      red: Colors.white.r.toDouble(),
                      green: Colors.white.g.toDouble(),
                      blue: Colors.white.b.toDouble(),
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(
                        red: Colors.white.r.toDouble(),
                        green: Colors.white.g.toDouble(),
                        blue: Colors.white.b.toDouble(),
                        alpha: 0.2,
                      ),
                      width: 1,
                    ),
                  ),
                  child: Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatItem(
                            'High Score',
                            '${settingsController.highScore}',
                            Icons.emoji_events,
                            Colors.amber,
                          ),
                          _buildStatItem(
                            'Games Played',
                            '${settingsController.gamesPlayed}',
                            Icons.sports_esports,
                            Colors.blue,
                          ),
                          _buildStatItem(
                            'Best Combo',
                            '${settingsController.bestCombo}',
                            Icons.flash_on,
                            Colors.orange,
                          ),
                        ],
                      )),
                ).animate().fadeIn().slideY(begin: -0.2),

                // Mode Selection Grid
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Adjust grid based on available space
                      final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                      final childAspectRatio =
                          constraints.maxWidth > 600 ? 1.3 : 1.1;
                      final padding = constraints.maxWidth > 600
                          ? 24.0
                          : (constraints.maxWidth > 360 ? 16.0 : 12.0);
                      final spacing = constraints.maxWidth > 600
                          ? 24.0
                          : (constraints.maxWidth > 360 ? 16.0 : 12.0);

                      return GridView.count(
                        crossAxisCount: crossAxisCount,
                        padding: EdgeInsets.all(padding),
                        mainAxisSpacing: spacing,
                        crossAxisSpacing: spacing,
                        childAspectRatio: childAspectRatio,
                        children: [
                          _buildModeCard(
                            'Classic',
                            'Score points in 60 seconds!',
                            Icons.timer,
                            Colors.blue,
                            () => _startGame('classic'),
                            constraints,
                            0,
                          ),
                          _buildModeCard(
                            'Survival',
                            'Play until you run out of lives!',
                            Icons.favorite,
                            Colors.red,
                            () => _startGame('survival'),
                            constraints,
                            1,
                          ),
                          _buildModeCard(
                            'Challenge',
                            'Daily challenges with unique rules!',
                            Icons.star,
                            Colors.amber,
                            () => _startGame('challenge'),
                            constraints,
                            2,
                          ),
                          _buildModeCard(
                            'Practice',
                            'Practice without time limits!',
                            Icons.school,
                            Colors.green,
                            () => _startGame('practice'),
                            constraints,
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
        ),
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(
              red: Colors.white.r.toDouble(),
              green: Colors.white.g.toDouble(),
              blue: Colors.white.b.toDouble(),
              alpha: 0.7,
            ),
            fontSize: 12,
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
    BoxConstraints constraints,
    int index,
  ) {
    final isSmallScreen = constraints.maxWidth < 360;
    final isMediumScreen = constraints.maxWidth < 600;
    final cardPadding = isSmallScreen ? 8.0 : (isMediumScreen ? 12.0 : 16.0);

    String tooltipMessage = switch (title.toLowerCase()) {
      'classic' =>
        'Score as many points as possible in 60 seconds! Watch out for bombs and catch golden moles for bonus points.',
      'survival' =>
        'Play until you run out of lives! The game gets harder over time, but golden moles can restore lives.',
      'challenge' =>
        'Complete special objectives in 30 seconds! Each challenge has unique rules and targets.',
      'practice' =>
        'Learn the game mechanics at your own pace. No time limit, perfect for beginners!',
      _ => description,
    };

    Widget card = Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Tooltip(
        message: tooltipMessage,
        textStyle: const TextStyle(
          color: Colors.white,
          fontSize: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
        waitDuration: const Duration(milliseconds: 500),
        showDuration: const Duration(seconds: 3),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(
                    red: color.r.toDouble(),
                    green: color.g.toDouble(),
                    blue: color.b.toDouble(),
                    alpha: 0.7,
                  ),
                  color.withValues(
                    red: color.r.toDouble(),
                    green: color.g.toDouble(),
                    blue: color.b.toDouble(),
                    alpha: 0.9,
                  ),
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(cardPadding),
              child: LayoutBuilder(
                builder: (context, cardConstraints) {
                  final availableHeight = cardConstraints.maxHeight;
                  final iconSize =
                      isSmallScreen ? 32.0 : (isMediumScreen ? 40.0 : 48.0);
                  final titleSize =
                      isSmallScreen ? 14.0 : (isMediumScreen ? 16.0 : 20.0);
                  final descSize = isSmallScreen ? 10.0 : 12.0;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: iconSize,
                        color: Colors.white,
                      ),
                      SizedBox(height: availableHeight * 0.05),
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: availableHeight * 0.03),
                      Flexible(
                        child: Text(
                          description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: descSize,
                            color: Colors.white.withValues(
                              red: Colors.white.r.toDouble(),
                              green: Colors.white.g.toDouble(),
                              blue: Colors.white.b.toDouble(),
                              alpha: 0.9,
                            ),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    // Add animations
    return card
        .animate()
        .fadeIn(delay: (100 * index).ms)
        .slideX(
          begin: index.isEven ? -0.1 : 0.1,
          duration: 400.ms,
          curve: Curves.easeOutQuad,
        )
        .scale(
          begin: const Offset(0.8, 0.8),
          duration: 400.ms,
          curve: Curves.easeOutQuad,
        );
  }

  void _startGame(String mode) {
    dev.log('Starting WhackAMole game with mode: $mode', name: 'WhackAMole');
    Get.to(
      () => const WhackAMoleGameScreen(),
      arguments: mode,
      transition: Transition.zoom,
      duration: const Duration(milliseconds: 500),
    );
  }

  void _showHowToPlay(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Colors.blue),
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
                Icons.track_changes,
              ),
              const Divider(),
              _buildHowToPlaySection(
                'Mole Types',
                '• Regular Mole: 10 points\n'
                    '• Golden Mole: 30 points\n'
                    '• Bomb: Reduces score/lives',
                Icons.catching_pokemon,
              ),
              const Divider(),
              _buildHowToPlaySection(
                'Combo System',
                'Hit moles consecutively to build up your combo multiplier for higher scores!',
                Icons.flash_on,
              ),
              const Divider(),
              _buildHowToPlaySection(
                'Game Modes',
                '• Classic: 60 seconds to score\n'
                    '• Survival: Play until you lose all lives\n'
                    '• Challenge: 30 seconds with special rules\n'
                    '• Practice: No time limit, perfect for learning',
                Icons.games,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildHowToPlaySection(String title, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
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
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
