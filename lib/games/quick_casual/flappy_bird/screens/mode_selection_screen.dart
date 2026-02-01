import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
  late FlappyBirdGameController gameController;

  @override
  void initState() {
    super.initState();
    FlappyBirdBinding().dependencies();
    gameController = Get.find<FlappyBirdGameController>();
    _refreshStats();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshStats();
  }

  void _refreshStats() {
    gameController.loadHighScore();
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<FlappyBirdSettingsController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshStats();
    });

    return Scaffold(
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
            Positioned(
              left: -50,
              bottom: 50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
                        onPressed: () => Get.back(),
                      ),
                      const Text(
                        'Flappy Bird',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings_outlined, color: Colors.black87),
                        onPressed: () => Get.to(() => const FlappyBirdSettingsScreen()),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: -0.2),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Game Stats
                        Obx(() {
                          final stats = gameController.gameStats.value;
                          return Container(
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Your Stats',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        // Reset stats logic
                                      },
                                      icon: const Icon(Icons.refresh_rounded, color: Colors.grey),
                                      tooltip: 'Reset Stats',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _StatItem(
                                      icon: Icons.emoji_events_rounded,
                                      value: stats.highScore.toString(),
                                      label: 'Best',
                                      color: Colors.amber,
                                    ),
                                    _StatItem(
                                      icon: Icons.sports_esports_rounded,
                                      value: stats.gamesPlayed.toString(),
                                      label: 'Games',
                                      color: Colors.blue,
                                    ),
                                    _StatItem(
                                      icon: Icons.flight_takeoff_rounded,
                                      value: stats.totalPipesPassed.toString(),
                                      label: 'Pipes',
                                      color: Colors.green,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                        const SizedBox(height: 32),

                        // Difficulty Selection
                        const Text(
                          'Select Difficulty',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ).animate().fadeIn(delay: 300.ms),
                        const SizedBox(height: 16),
                        Obx(() => Column(
                              children: [
                                _DifficultyButton(
                                  title: 'Easy',
                                  subtitle: 'Perfect for beginners',
                                  icon: Icons.sentiment_satisfied_rounded,
                                  isSelected: settingsController.difficulty.value ==
                                      GameDifficulty.easy,
                                  onTap: () => settingsController
                                      .setDifficulty(GameDifficulty.easy),
                                  color: Colors.green,
                                ),
                                const SizedBox(height: 12),
                                _DifficultyButton(
                                  title: 'Normal',
                                  subtitle: 'Classic challenge',
                                  icon: Icons.sentiment_neutral_rounded,
                                  isSelected: settingsController.difficulty.value ==
                                      GameDifficulty.normal,
                                  onTap: () => settingsController
                                      .setDifficulty(GameDifficulty.normal),
                                  color: Colors.orange,
                                ),
                                const SizedBox(height: 12),
                                _DifficultyButton(
                                  title: 'Hard',
                                  subtitle: 'For the brave ones',
                                  icon: Icons.sentiment_very_dissatisfied_rounded,
                                  isSelected: settingsController.difficulty.value ==
                                      GameDifficulty.hard,
                                  onTap: () => settingsController
                                      .setDifficulty(GameDifficulty.hard),
                                  color: Colors.red,
                                ),
                              ],
                            )).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                        const SizedBox(height: 32),

                        // Play Button
                        FilledButton.icon(
                          onPressed: () {
                            gameController.initGame();
                            Get.to(
                              () => const FlappyBirdGameScreen(),
                              binding: FlappyBirdBinding(),
                              transition: Transition.fadeIn,
                            );
                          },
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Play Now'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ).animate().fadeIn(delay: 500.ms).scale(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _DifficultyButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : Colors.black87,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? color.withOpacity(0.8) : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
