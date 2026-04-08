import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../controllers/settings_controller.dart';
import '../utils/constants.dart';
import '../bindings/game_binding.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'package:gameverse/widgets/guarded_exit.dart';

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
    gameController.loadHighScore();
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.power_settings_new_rounded,
                      color: Colors.white70, size: 32),
                ),
                const SizedBox(height: 20),
                const Text(
                  'EXIT GAME',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to return to the main menu?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14,
                      height: 1.5),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('Cancel',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0F172A),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text('Exit',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return result ?? false;
  }

  Future<bool> _showWipeDataDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_forever_rounded,
                      color: Colors.redAccent, size: 32),
                ),
                const SizedBox(height: 20),
                const Text('WIPE DATA?',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1)),
                const SizedBox(height: 12),
                Text(
                  'All high scores and statistics will be permanently deleted. This cannot be undone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14,
                      height: 1.5),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16))),
                        child: Text('Cancel',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 0),
                        child: const Text('Delete',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<FlappyBirdSettingsController>();
    final isCompact = MediaQuery.of(context).size.width < 380;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool verySmallScreen = screenHeight < 700;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (!didPop) {
          final shouldPop = await _showExitConfirmationDialog(context);
          if (shouldPop) {
            if (!context.mounted) return;
            Get.delete<FlappyBirdGameController>();
            await popAfterConfirmation(context, confirmExit: () async => true);
          }
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A237E), // Navy Blue
                Color(0xFF0D47A1), // Deep Blue
                Color(0xFF01579B), // Lighter Deep Blue
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isCompact ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildGlassIconButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onPressed: () => popAfterConfirmation(
                            context,
                            confirmExit: () =>
                                _showExitConfirmationDialog(context),
                          ),
                        ),
                        _buildGlassIconButton(
                          icon: Icons.settings_rounded,
                          onPressed: () => Get.to(
                            () => const FlappyBirdSettingsScreen(),
                            transition: Transition.fadeIn,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flight_rounded,
                            color: Colors.white,
                            size: verySmallScreen ? 32 : 40),
                        SizedBox(height: verySmallScreen ? 4 : 8),
                        Text(
                          'FLAPPY BIRD',
                          style: TextStyle(
                            fontSize: verySmallScreen ? 28 : 32,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: verySmallScreen ? 16 : 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                              width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'STATISTICS',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 1,
                                    fontSize: 12,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final result =
                                        await _showWipeDataDialog(context);
                                    if (result == true) {
                                      await gameController.resetStats();
                                    }
                                  },
                                  child: Icon(Icons.refresh_rounded,
                                      color:
                                          Colors.white.withValues(alpha: 0.4),
                                      size: 18),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Obx(() {
                              final stats = gameController.gameStats.value;
                              return Row(
                                children: [
                                  Expanded(
                                    child: _buildStatItem(
                                        'BEST',
                                        stats.highScore.toString(),
                                        Colors.blueAccent),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _buildStatItem(
                                        'GAMES',
                                        stats.gamesPlayed.toString(),
                                        Colors.purpleAccent),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Spacer(flex: 1),

                  // Theme Selection
                  const Text(
                    'THEME',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white54,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: verySmallScreen ? 8 : 12),

                  Obx(() => Row(
                        children: [
                          Expanded(
                            child: _buildThemeCard(
                              title: 'CYBER',
                              subtitle: 'Neon grid',
                              icon: Icons.memory_rounded,
                              color: Colors.cyanAccent,
                              isSelected:
                                  settingsController.currentTheme.value ==
                                      FlappyBirdTheme.cyberpunk,
                              onTap: () => settingsController
                                  .setTheme(FlappyBirdTheme.cyberpunk),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildThemeCard(
                              title: 'CLASSIC',
                              subtitle: 'Daylight sky',
                              icon: Icons.wb_sunny_rounded,
                              color: Colors.amberAccent,
                              isSelected:
                                  settingsController.currentTheme.value ==
                                      FlappyBirdTheme.classic,
                              onTap: () => settingsController
                                  .setTheme(FlappyBirdTheme.classic),
                            ),
                          ),
                        ],
                      )),

                  const Spacer(flex: 1),

                  // Difficulty Selection
                  const Text(
                    'DIFFICULTY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white54,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: verySmallScreen ? 8 : 12),
                  Obx(() => Row(
                        children: [
                          Expanded(
                            child: _buildHorizontalDifficultyCard(
                              title: 'EASY',
                              icon: Icons.shield_rounded,
                              color: Colors.greenAccent,
                              isSelected: settingsController.difficulty.value ==
                                  GameDifficulty.easy,
                              onTap: () => settingsController
                                  .setDifficulty(GameDifficulty.easy),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildHorizontalDifficultyCard(
                              title: 'NORM',
                              icon: Icons.bolt_rounded,
                              color: Colors.orangeAccent,
                              isSelected: settingsController.difficulty.value ==
                                  GameDifficulty.normal,
                              onTap: () => settingsController
                                  .setDifficulty(GameDifficulty.normal),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildHorizontalDifficultyCard(
                              title: 'HARD',
                              icon: Icons.whatshot_rounded,
                              color: Colors.redAccent,
                              isSelected: settingsController.difficulty.value ==
                                  GameDifficulty.hard,
                              onTap: () => settingsController
                                  .setDifficulty(GameDifficulty.hard),
                            ),
                          ),
                        ],
                      )),
                  const Spacer(flex: 2),
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    height: verySmallScreen ? 56 : 64,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        gameController.initGame();
                        Get.to(
                          () => const FlappyBirdGameScreen(),
                          binding: FlappyBirdBinding(),
                          transition: Transition.cupertino,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow_rounded,
                              color: Color(0xFF0F172A)),
                          SizedBox(width: 12),
                          Text(
                            'PLAY NOW',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: Color(0xFF0F172A),
                            ),
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
      ),
    );
  }

  Widget _buildGlassIconButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              shadows: [Shadow(color: color, blurRadius: 10)],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 10)]
              : [],
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.white54, size: 24),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
                color: isSelected ? color : Colors.white54,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? Colors.white : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalDifficultyCard({
    required String title,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.white.withValues(alpha: 0.1),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withValues(alpha: 0.2), blurRadius: 10)]
              : [],
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.white54, size: 24),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
                color: isSelected ? color : Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
