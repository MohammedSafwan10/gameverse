import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:developer' as developer;
import '../controllers/game_controller.dart';
import '../controllers/settings_controller.dart';
import '../utils/constants.dart';
import '../bindings/game_binding.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

class FlappyBirdModeSelectionScreen extends StatefulWidget {
  const FlappyBirdModeSelectionScreen({super.key});

  @override
  State<FlappyBirdModeSelectionScreen> createState() =>
      _FlappyBirdModeSelectionScreenState();
}

class _FlappyBirdModeSelectionScreenState
    extends State<FlappyBirdModeSelectionScreen> {
  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Game'),
        content: const Text('Are you sure you want to exit Flappy Bird?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  late FlappyBirdGameController gameController;

  @override
  void initState() {
    super.initState();
    // Initialize bindings if not already done
    FlappyBirdBinding().dependencies();
    gameController = Get.find<FlappyBirdGameController>();

    // Load stats immediately
    _refreshStats();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh stats when dependencies change (like returning to this screen)
    _refreshStats();
  }

  void _refreshStats() {
    // Force reload of stats from storage
    gameController.loadHighScore();
    developer.log('Refreshing stats on mode selection screen');
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<FlappyBirdSettingsController>();

    // Force a refresh of stats whenever the UI is rebuilt
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshStats();
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (!didPop) {
          final shouldPop = await _showExitConfirmationDialog(context);
          if (shouldPop) {
            Get.delete<FlappyBirdGameController>();
            Get.back();
          }
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF64B5F6),
                Color(0xFF1976D2),
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => Get.back(),
                          ),
                          const Expanded(
                            child: Text(
                              'Flappy Bird',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                            icon:
                                const Icon(Icons.settings, color: Colors.white),
                            onPressed: () =>
                                Get.to(() => const FlappyBirdSettingsScreen()),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Game Stats
                    Obx(() {
                      final stats = gameController.gameStats.value;
                      developer.log(
                          'Displaying stats: Games played: ${stats.gamesPlayed}, Total pipes: ${stats.totalPipesPassed}, Play time: ${stats.totalPlayTime.inSeconds}s');

                      return Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(
                            red: 0,
                            green: 0,
                            blue: 0,
                            alpha: 0.4,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(
                              red: 255,
                              green: 255,
                              blue: 255,
                              alpha: 0.5,
                            ),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Your Stats',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    final result = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Reset Statistics'),
                                        content: const Text(
                                            'Are you sure you want to reset all statistics? This cannot be undone.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('Reset'),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (result == true) {
                                      await gameController.resetStats();
                                      Get.snackbar(
                                        'Success',
                                        'Statistics have been reset',
                                        backgroundColor: Colors.green,
                                        colorText: Colors.white,
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.refresh,
                                      color: Colors.white70),
                                  tooltip: 'Reset Stats',
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            // Use Wrap instead of Row for better small screen handling
                            Wrap(
                              spacing: 10, // horizontal spacing
                              runSpacing: 10, // vertical spacing between rows
                              alignment: WrapAlignment.center,
                              children: [
                                _StatItem(
                                  icon: Icons.emoji_events,
                                  value: stats.highScore.toString(),
                                  label: 'High Score',
                                  color: Colors.amber,
                                  width: _getStatItemWidth(context),
                                ),
                                _StatItem(
                                  icon: Icons.sports_esports,
                                  value: stats.gamesPlayed.toString(),
                                  label: 'Games',
                                  color: Colors.green,
                                  width: _getStatItemWidth(context),
                                ),
                                _StatItem(
                                  icon: Icons.flight_takeoff,
                                  value: stats.totalPipesPassed.toString(),
                                  label: 'Pipes',
                                  color: Colors.blue,
                                  width: _getStatItemWidth(context),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            // Make play time more visible
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(
                                  red: 255,
                                  green: 255,
                                  blue: 255,
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Total Play Time: ${_formatDuration(stats.totalPlayTime)}',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black54,
                                            blurRadius: 2,
                                            offset: Offset(1, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 30),

                    // Difficulty Selection
                    const Text(
                      'Select Difficulty',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Obx(() => Column(
                          children: [
                            _DifficultyButton(
                              title: 'Easy',
                              subtitle: 'Perfect for beginners',
                              icon: Icons.sentiment_satisfied,
                              isSelected: settingsController.difficulty.value ==
                                  GameDifficulty.easy,
                              onTap: () => settingsController
                                  .setDifficulty(GameDifficulty.easy),
                            ),
                            const SizedBox(height: 12),
                            _DifficultyButton(
                              title: 'Normal',
                              subtitle: 'Classic challenge',
                              icon: Icons.sentiment_neutral,
                              isSelected: settingsController.difficulty.value ==
                                  GameDifficulty.normal,
                              onTap: () => settingsController
                                  .setDifficulty(GameDifficulty.normal),
                            ),
                            const SizedBox(height: 12),
                            _DifficultyButton(
                              title: 'Hard',
                              subtitle: 'For the brave ones',
                              icon: Icons.sentiment_very_dissatisfied,
                              isSelected: settingsController.difficulty.value ==
                                  GameDifficulty.hard,
                              onTap: () => settingsController
                                  .setDifficulty(GameDifficulty.hard),
                            ),
                          ],
                        )),

                    const SizedBox(height: 30),

                    // Play Button
                    ElevatedButton.icon(
                      onPressed: () {
                        gameController.initGame();
                        Get.to(
                          () => const FlappyBirdGameScreen(),
                          binding: FlappyBirdBinding(),
                          transition: Transition.fadeIn,
                        );
                      },
                      icon: const Icon(Icons.play_arrow, size: 28),
                      label: const Text('Play Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 16,
                        ),
                        textStyle: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  // Calculate adaptive width for stat items based on screen size
  double _getStatItemWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // On very small screens, make them full width minus padding
    if (screenWidth < 300) {
      return screenWidth - 80;
    }
    // On small screens, show 2 per row
    else if (screenWidth < 400) {
      return (screenWidth - 80) / 2;
    }
    // On larger screens, show 3 per row
    else {
      return (screenWidth - 100) / 3;
    }
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final double? width;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(
          red: color.r.toDouble(),
          green: color.g.toDouble(),
          blue: color.b.toDouble(),
          alpha: 0.25,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              red: 0,
              green: 0,
              blue: 0,
              alpha: 0.2,
            ),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 2,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 2,
                  offset: Offset(1, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _DifficultyButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? Colors.white.withValues(
              red: Colors.white.r.toDouble(),
              green: Colors.white.g.toDouble(),
              blue: Colors.white.b.toDouble(),
              alpha: 0.2,
            )
          : Colors.white.withValues(
              red: Colors.white.r.toDouble(),
              green: Colors.white.g.toDouble(),
              blue: Colors.white.b.toDouble(),
              alpha: 0.1,
            ),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 32,
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
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(
                          red: Colors.white.r.toDouble(),
                          green: Colors.white.g.toDouble(),
                          blue: Colors.white.b.toDouble(),
                          alpha: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
