import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:gameverse/theme/app_theme.dart';
import 'package:gameverse/widgets/premium_background.dart';
import '../controllers/settings_controller.dart';
import '../models/game_difficulty.dart';
import '../models/game_mode.dart';
import '../services/navigation_service.dart';

class ModeSelectionScreen extends StatelessWidget {
  final _settingsController = Get.find<TicTacToeSettingsController>();
  final _navigationService = Get.find<TicTacToeNavigationService>();

  ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const PremiumBackground(),
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/games/tic_tac_toe.png',
                  fit: BoxFit.cover,
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.32),
                        const Color(0xFF0F172A).withValues(alpha: 0.88),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(context),
                  const SizedBox(height: 28),
                  Text(
                    'Choose how you want to play',
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ).animate().fadeIn(duration: const Duration(milliseconds: 500)).slideY(begin: 0.15),
                  const SizedBox(height: 20),
                  _buildHeroCard(theme)
                      .animate()
                      .fadeIn(delay: const Duration(milliseconds: 120), duration: const Duration(milliseconds: 600))
                      .slideY(begin: 0.12),
                  const SizedBox(height: 20),
                  _buildModeCard(
                    icon: Icons.smart_toy_rounded,
                    title: 'Single Player',
                    subtitle: 'Play against AI',
                    mode: GameMode.singlePlayer,
                    accentColor: AppTheme.primaryColor,
                  )
                      .animate()
                      .fadeIn(delay: const Duration(milliseconds: 180), duration: const Duration(milliseconds: 600))
                      .slideX(begin: 0.08),
                  const SizedBox(height: 16),
                  _buildModeCard(
                    icon: Icons.groups_2_rounded,
                    title: 'Two Players',
                    subtitle: 'Play with a friend',
                    mode: GameMode.multiPlayer,
                    accentColor: AppTheme.accentColor,
                  )
                      .animate()
                      .fadeIn(delay: const Duration(milliseconds: 240), duration: const Duration(milliseconds: 600))
                      .slideX(begin: 0.08),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
          ),
          child: IconButton(
            onPressed: Get.back,
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          ),
        ),
        const Spacer(),
        _quickActionButton(
          icon: Icons.bar_chart_rounded,
          onTap: _navigationService.toStats,
        ),
        const SizedBox(width: 10),
        _quickActionButton(
          icon: Icons.settings_rounded,
          onTap: _navigationService.toSettings,
        ),
      ],
    );
  }

  Widget _quickActionButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: AppTheme.glassmorphicDecoration(
            backgroundColor: Colors.white.withValues(alpha: 0.14),
            borderColor: Colors.white.withValues(alpha: 0.16),
            borderRadius: 999,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildHeroCard(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'TIC TAC TOE',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required GameMode mode,
    required Color accentColor,
  }) {
    return Container(
      decoration: AppTheme.glassmorphicDecoration(
        backgroundColor: Colors.white,
        borderColor: Colors.white,
        borderRadius: 28,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleModeSelection(mode),
          borderRadius: BorderRadius.circular(28),
          child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: AppTheme.glassmorphicDecoration(
                  backgroundColor: accentColor.withValues(alpha: 0.16),
                  borderColor: accentColor.withValues(alpha: 0.24),
                  borderRadius: 20,
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.72),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 42,
                height: 42,
                decoration: AppTheme.glassmorphicDecoration(
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  borderColor: Colors.white.withValues(alpha: 0.1),
                  borderRadius: 999,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  void _handleModeSelection(GameMode mode) {
    _settingsController.updateGameMode(mode);
    if (mode == GameMode.singlePlayer) {
      _showDifficultySheet();
      return;
    }
    Get.toNamed('/tic-tac-toe/game');
  }

  void _showDifficultySheet() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.72,
        decoration: AppTheme.glassmorphicDecoration(
          backgroundColor: const Color(0xFF0F172A).withValues(alpha: 0.9),
          borderColor: Colors.white.withValues(alpha: 0.15),
          borderRadius: 50,
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(50)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Header
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppTheme.glassmorphicDecoration(
                        backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.15),
                        borderColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                        borderRadius: 999,
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: AppTheme.primaryColor,
                        size: 32,
                      ),
                    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: 20),
                    const Text(
                      'AI DIFFICULTY',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 24,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'How smart should your opponent be?',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),
                
                // Difficulty List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    itemCount: GameDifficulty.values.length,
                    itemBuilder: (context, index) {
                      final difficulty = GameDifficulty.values[index];
                      final isSelected = _settingsController.settings.difficulty == difficulty;
                      final color = _getDifficultyColor(difficulty);
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              _settingsController.updateDifficulty(difficulty);
                              Get.back();
                              Get.toNamed('/tic-tac-toe/game');
                            },
                            borderRadius: BorderRadius.circular(28),
                            child: AnimatedContainer(
                              duration: 300.ms,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? color.withValues(alpha: 0.12)
                                    : Colors.white.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: isSelected 
                                      ? color.withValues(alpha: 0.5)
                                      : Colors.white.withValues(alpha: 0.08),
                                  width: isSelected ? 2 : 1,
                                ),
                                boxShadow: isSelected ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.1),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  )
                                ] : null,
                              ),
                              child: Row(
                                children: [
                                  // Diff Icon
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: AppTheme.glassmorphicDecoration(
                                      backgroundColor: isSelected
                                          ? color.withValues(alpha: 0.2)
                                          : Colors.white.withValues(alpha: 0.05),
                                      borderColor: isSelected
                                          ? color.withValues(alpha: 0.3)
                                          : Colors.white.withValues(alpha: 0.08),
                                      borderRadius: 20,
                                    ),
                                    child: Icon(
                                      _getDifficultyIcon(difficulty),
                                      color: isSelected ? color : Colors.white60,
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  
                                  // Text info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          difficulty.displayName,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _getDifficultyDescription(difficulty),
                                          style: TextStyle(
                                            color: Colors.white.withValues(alpha: 0.45),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Checkbox or Arrow
                                  if (isSelected)
                                    Icon(Icons.check_circle_rounded, color: color, size: 28)
                                        .animate().scale(duration: 400.ms, curve: Curves.easeOutBack)
                                  else
                                    Icon(
                                      Icons.arrow_forward_ios_rounded, 
                                      color: Colors.white.withValues(alpha: 0.15), 
                                      size: 16
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: (index * 100).ms, duration: 500.ms).slideX(begin: 0.1);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  Color _getDifficultyColor(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return Colors.greenAccent;
      case GameDifficulty.medium:
        return Colors.amberAccent;
      case GameDifficulty.hard:
        return Colors.orangeAccent;
      case GameDifficulty.impossible:
        return Colors.redAccent;
    }
  }

  IconData _getDifficultyIcon(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return Icons.sentiment_satisfied;
      case GameDifficulty.medium:
        return Icons.sentiment_neutral;
      case GameDifficulty.hard:
        return Icons.sentiment_dissatisfied;
      case GameDifficulty.impossible:
        return Icons.psychology;
    }
  }

  String _getDifficultyDescription(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return 'Perfect for beginners';
      case GameDifficulty.medium:
        return 'Balanced challenge';
      case GameDifficulty.hard:
        return 'For experienced players';
      case GameDifficulty.impossible:
        return 'Unbeatable AI';
    }
  }
}


