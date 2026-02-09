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
  static const _bgDark = Color(0xFF0F0F1A);
  static const _surfaceDark = Color(0xFF1A1A2E);
  static const _surfaceLight = Color(0xFF22223A);

  @override
  void initState() {
    super.initState();
    MemoryMatchBinding.initDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              const Color(0xFFA29BFE).withValues(alpha: 0.15),
              _bgDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(child: _buildModeList()),
              _buildHelpButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: _surfaceDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFA29BFE).withValues(alpha: 0.2),
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
              color: const Color(0xFFA29BFE),
              iconSize: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Memory Match',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ).animate().fadeIn().slideX(),
                const SizedBox(height: 2),
                Text(
                  'Select your game mode',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 14,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideX(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: MemoryMatchMode.values.length,
      itemBuilder: (context, index) {
        final mode = MemoryMatchMode.values[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _buildModeCard(mode),
        );
      },
    );
  }

  Widget _buildModeCard(MemoryMatchMode mode) {
    return Container(
      decoration: BoxDecoration(
        color: _surfaceDark,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: mode.color.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(
            color: mode.color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDifficultyDialog(mode),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: mode.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(mode.icon, size: 24, color: mode.color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mode.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        mode.description,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: mode.color.withValues(alpha: 0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (150 * mode.index).ms).slideX();
  }

  void _showDifficultyDialog(MemoryMatchMode mode) {
    Get.dialog(
      Dialog(
        backgroundColor: _surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
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
                      color: mode.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(mode.icon, color: mode.color, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Difficulty',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          mode.displayName,
                          style: TextStyle(
                            color: mode.color,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ...GameDifficulty.values.map((difficulty) {
                final (gridLabel, desc, icon) = switch (difficulty) {
                  GameDifficulty.easy => (
                      '4×3',
                      '6 pairs · Perfect for beginners',
                      Icons.sentiment_satisfied,
                    ),
                  GameDifficulty.medium => (
                      '4×4',
                      '8 pairs · For experienced players',
                      Icons.sentiment_neutral,
                    ),
                  GameDifficulty.hard => (
                      '5×4',
                      '10 pairs · Ultimate challenge',
                      Icons.sentiment_very_satisfied,
                    ),
                };

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
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
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _surfaceLight,
                          border: Border.all(
                            color: mode.color.withValues(alpha: 0.15),
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: mode.color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(icon, color: mode.color, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    difficulty.name.toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    desc,
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.45),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: mode.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                gridLabel,
                                style: TextStyle(
                                  color: mode.color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: (150 * difficulty.index).ms).slideX();
              }),
            ],
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
        onPressed: _showHelpDialog,
        icon: Icon(Icons.help_outline,
            color: Colors.white.withValues(alpha: 0.7)),
        label: Text(
          'How to Play',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontWeight: FontWeight.w600,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          backgroundColor: _surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  void _showHelpDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: _surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA29BFE).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.help_outline,
                      color: Color(0xFFA29BFE),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    'How to Play',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _helpItem(Icons.touch_app, 'Flip Cards',
                  'Tap on cards to flip them and reveal emojis.'),
              _helpItem(Icons.compare, 'Find Matches',
                  'Remember positions and match identical pairs.'),
              _helpItem(Icons.local_fire_department, 'Build Combos',
                  'Match consecutively for score multipliers!'),
              _helpItem(Icons.speed, 'Game Modes',
                  'Classic · Time Trial · Challenge'),
              _helpItem(Icons.grid_3x3, 'Grid Sizes',
                  'Easy 4×3 · Medium 4×4 · Hard 5×4'),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA29BFE),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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

  Widget _helpItem(IconData icon, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFFA29BFE).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFFA29BFE), size: 18),
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
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
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
