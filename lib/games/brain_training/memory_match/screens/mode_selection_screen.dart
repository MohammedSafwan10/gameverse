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
    MemoryMatchBinding.initDependencies();
  }

  @override
  Widget build(BuildContext context) {
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
                  color: Colors.purple.withOpacity(0.05),
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
                  color: Colors.pink.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

          SafeArea(
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
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Get.back(),
            color: Colors.black87,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Memory Match',
                style: Get.textTheme.headlineMedium?.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ).animate().fadeIn().slideX(),
              Text(
                'Select your game mode',
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 14,
                ),
              ).animate().fadeIn(delay: 200.ms).slideX(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeGrid() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: mode.color.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () => _showDifficultyDialog(mode),
          borderRadius: BorderRadius.circular(24),
          splashColor: mode.color.withOpacity(0.1),
          highlightColor: mode.color.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: mode.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    mode.icon,
                    size: 32,
                    color: mode.color,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        mode.displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mode.description,
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
                  color: mode.color.withOpacity(0.5),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: (200 * mode.index).ms).fadeIn().slideX();
  }

  void _showDifficultyDialog(MemoryMatchMode mode) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Difficulty',
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                mode.displayName,
                style: TextStyle(
                  color: mode.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              ...GameDifficulty.values.map((difficulty) {
                String gridSize;
                IconData icon;

                switch (difficulty) {
                  case GameDifficulty.easy:
                    gridSize = '4x4';
                    icon = Icons.sentiment_satisfied_rounded;
                  case GameDifficulty.medium:
                    gridSize = '6x6';
                    icon = Icons.sentiment_neutral_rounded;
                  case GameDifficulty.hard:
                    gridSize = '8x8';
                    icon = Icons.sentiment_very_satisfied_rounded;
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Icon(icon, color: mode.color),
                            const SizedBox(width: 16),
                            Text(
                              difficulty.name.capitalize!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: mode.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                gridSize,
                                style: TextStyle(
                                  color: mode.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpButton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: TextButton.icon(
        onPressed: () => _showHelpDialog(),
        icon: const Icon(Icons.help_outline_rounded),
        label: const Text('How to Play'),
        style: TextButton.styleFrom(
          foregroundColor: Colors.purple,
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  void _showHelpDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.help_outline_rounded, size: 48, color: Colors.purple),
              const SizedBox(height: 16),
              const Text(
                'How to Play',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tap cards to flip them and find matching pairs. Remember their positions!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => Get.back(),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: const Text('Got it!'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
