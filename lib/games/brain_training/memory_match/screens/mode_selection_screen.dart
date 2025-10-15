import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/game_mode.dart';
import '../models/game_state.dart';
import '../bindings/game_binding.dart';
import 'game_screen.dart';

class MemoryMatchModeSelectionScreen extends StatefulWidget {
  const MemoryMatchModeSelectionScreen({super.key});

  @override
  State<MemoryMatchModeSelectionScreen> createState() =>
      _MemoryMatchModeSelectionScreenState();
}

class _MemoryMatchModeSelectionScreenState
    extends State<MemoryMatchModeSelectionScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize dependencies once when the screen is created
    MemoryMatchBinding.initDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade100,
              Colors.purple.shade400,
            ],
            stops: const [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildModeGrid(),
              ),
              _buildHelpButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    red: 0.0,
                    green: 0.0,
                    blue: 0.0,
                    alpha: 0.1,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
              color: Colors.purple,
              iconSize: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Memory Match',
                  style: Get.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn().slideX(),
                const SizedBox(height: 4),
                Text(
                  'Select your game mode',
                  style: Get.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(
                      red: 1.0,
                      green: 1.0,
                      blue: 1.0,
                      alpha: 0.8,
                    ),
                  ),
                ).animate().fadeIn().slideX(delay: 200.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeGrid() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: MemoryMatchMode.values.length,
      itemBuilder: (context, index) {
        final mode = MemoryMatchMode.values[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildModeCard(mode),
        );
      },
    );
  }

  Widget _buildModeCard(MemoryMatchMode mode) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: mode.color.withValues(
              red: mode.color.r.toDouble(),
              green: mode.color.g.toDouble(),
              blue: mode.color.b.toDouble(),
              alpha: 0.3,
            ),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDifficultyDialog(mode),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: mode.color.withValues(
                      red: mode.color.r.toDouble(),
                      green: mode.color.g.toDouble(),
                      blue: mode.color.b.toDouble(),
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    mode.icon,
                    size: 24,
                    color: mode.color,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        mode.displayName,
                        style: Get.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mode.description,
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: mode.color,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (200 * mode.index).ms).slideX();
  }

  void _showDifficultyDialog(MemoryMatchMode mode) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: mode.color.withValues(
                  red: mode.color.r.toDouble(),
                  green: mode.color.g.toDouble(),
                  blue: mode.color.b.toDouble(),
                  alpha: 0.2,
                ),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: mode.color.withValues(
                          red: mode.color.r.toDouble(),
                          green: mode.color.g.toDouble(),
                          blue: mode.color.b.toDouble(),
                          alpha: 0.1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        mode.icon,
                        color: mode.color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Difficulty',
                            style: Get.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            mode.displayName,
                            style: Get.textTheme.bodyMedium?.copyWith(
                              color: mode.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ).animate().fadeIn().slideY(begin: 0.3),
                const SizedBox(height: 24),
                ...GameDifficulty.values.map((difficulty) {
                  String gridSize;
                  String description;
                  IconData icon;

                  switch (difficulty) {
                    case GameDifficulty.easy:
                      gridSize = '4x4';
                      description = 'Perfect for beginners';
                      icon = Icons.sentiment_satisfied;
                    case GameDifficulty.medium:
                      gridSize = '6x6';
                      description = 'For experienced players';
                      icon = Icons.sentiment_neutral;
                    case GameDifficulty.hard:
                      gridSize = '8x8';
                      description = 'Ultimate challenge';
                      icon = Icons.sentiment_very_satisfied;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Get.back();
                          Get.to(
                            () => MemoryMatchGameScreen(
                              mode: mode,
                              difficulty: difficulty,
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: mode.color.withValues(
                                red: mode.color.r.toDouble(),
                                green: mode.color.g.toDouble(),
                                blue: mode.color.b.toDouble(),
                                alpha: 0.2,
                              ),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: mode.color.withValues(
                                        red: mode.color.r.toDouble(),
                                        green: mode.color.g.toDouble(),
                                        blue: mode.color.b.toDouble(),
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  icon,
                                  color: mode.color,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      difficulty.name.toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      description,
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: mode.color.withValues(
                                    red: mode.color.r.toDouble(),
                                    green: mode.color.g.toDouble(),
                                    blue: mode.color.b.toDouble(),
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  gridSize,
                                  style: TextStyle(
                                    color: mode.color,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: (200 * difficulty.index).ms)
                      .slideX();
                }),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildHelpButton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextButton.icon(
        onPressed: () => _showHelpDialog(),
        icon: const Icon(Icons.help_outline, color: Colors.white),
        label: const Text(
          'How to Play',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          backgroundColor: Colors.purple.withValues(
            red: Colors.purple.r.toDouble(),
            green: Colors.purple.g.toDouble(),
            blue: Colors.purple.b.toDouble(),
            alpha: 0.4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  void _showHelpDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withValues(
                  red: Colors.purple.r.toDouble(),
                  green: Colors.purple.g.toDouble(),
                  blue: Colors.purple.b.toDouble(),
                  alpha: 0.2,
                ),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(
                        red: Colors.purple.r.toDouble(),
                        green: Colors.purple.g.toDouble(),
                        blue: Colors.purple.b.toDouble(),
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.help_outline,
                      color: Colors.purple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'How to Play',
                      style: Get.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn().slideY(begin: 0.3),
              const SizedBox(height: 24),
              _buildHelpItem(
                icon: Icons.touch_app,
                title: 'Flip Cards',
                description:
                    'Tap on cards to flip them and find matching pairs.',
              ),
              _buildHelpItem(
                icon: Icons.compare,
                title: 'Find Matches',
                description:
                    'Remember card positions to match pairs more efficiently.',
              ),
              _buildHelpItem(
                icon: Icons.speed,
                title: 'Game Modes',
                description:
                    'Classic - Play at your own pace\nTime Trial - Race against the clock\nChallenge - Progressive difficulty levels',
              ),
              _buildHelpItem(
                icon: Icons.grid_3x3,
                title: 'Difficulty Levels',
                description:
                    'Easy - 4x4 grid\nMedium - 6x6 grid\nHard - 8x8 grid',
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Got it!'),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(
                red: Colors.purple.r.toDouble(),
                green: Colors.purple.g.toDouble(),
                blue: Colors.purple.b.toDouble(),
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.purple,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 100.ms).slideX();
  }
}
