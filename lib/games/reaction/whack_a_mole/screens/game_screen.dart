import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math';
import '../controllers/game_controller.dart';
import '../widgets/mole_hole.dart';
import '../widgets/game_hud.dart';
import '../widgets/hit_effect.dart';
import '../widgets/combo_text.dart';

class WhackAMoleGameScreen extends GetView<WhackAMoleGameController> {
  const WhackAMoleGameScreen({super.key});

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Exit Game?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: const Text(
                'Are you sure you want to exit? Your progress will be lost.',
                style: TextStyle(color: Colors.black87),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Exit'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  Widget _buildGameBoard() {
    return Obx(() {
      final gameState = controller.gameState.value;
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: 9,
          itemBuilder: (context, index) {
            return MoleHole(
              moleType: gameState.moles[index],
              isActive: gameState.isActive[index],
              progress: gameState.moleProgress[index],
              onTap: () => controller.onMoleHit(index),
              onMiss: controller.onMoleMissed,
            );
          },
        ),
      );
    });
  }

  Widget _buildHitEffect() {
    return Obx(() {
      if (!controller.showHitEffect.value) return const SizedBox.shrink();
      final index = controller.hitEffectIndex.value;
      final moleType = controller.gameState.value.moles[index];
      return Positioned.fill(
        child: HitEffect(
          moleType: moleType,
          isActive: true,
          onComplete: controller.onHitEffectComplete,
        ),
      );
    });
  }

  Widget _buildComboText() {
    return Obx(() {
      if (!controller.showComboText.value) return const SizedBox.shrink();
      return Center(
        child: ComboText(
          combo: controller.scoreController.consecutiveHits.value,
          onComplete: controller.onComboTextComplete,
        ),
      );
    });
  }

  Widget _buildPauseOverlay() {
    return Obx(() {
      if (!controller.isPaused.value || !controller.isPlaying.value) {
        return const SizedBox.shrink();
      }
      return Container(
        color: Colors.black.withOpacity(0.4),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'PAUSED',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton(
                      onPressed: controller.resumeGame,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        'Resume',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 20),
                    FilledButton(
                      onPressed: controller.quitGame,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text(
                        'Quit',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn();
    });
  }

  Widget _buildGameArea() {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = min(constraints.maxWidth, constraints.maxHeight);
          return Center(
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildGameBoard(),
                  _buildHitEffect(),
                  _buildComboText(),
                  _buildPauseOverlay(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStartButton() {
    return Obx(() {
      if (controller.isPlaying.value) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: controller.startGame,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20),
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
            ),
            child: const Text('Start Game'),
          ),
        ),
      ).animate().fadeIn().scale();
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          if (controller.isPlaying.value) {
            controller.pauseGame();
          } else {
            final shouldPop = await _showExitConfirmationDialog(context);
            if (shouldPop && context.mounted) {
              controller.quitGame();
            }
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE),
        body: Stack(
          children: [
             // Decorative Background
            Positioned(
              left: -100,
              top: -50,
              child: Container(
                width: 300,
                height: 300,
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
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Obx(() => GameHUD(
                          score: controller.currentScore.value,
                          timeRemaining: controller.gameMode == 'classic'
                              ? controller.timeRemaining.value
                              : -1,
                          lives: controller.gameMode == 'survival'
                              ? controller.lives.value
                              : null,
                          onPause: controller.pauseGame,
                          onBackPressed: (context) async {
                            if (controller.isPlaying.value) {
                              controller.pauseGame();
                            }
                            final shouldPop =
                                await _showExitConfirmationDialog(context);
                            if (shouldPop) {
                              controller.quitGame();
                            }
                            return shouldPop;
                          },
                          gameMode: controller.gameMode,
                        )),
                  ),
                  const SizedBox(height: 16),
                  _buildGameArea(),
                  _buildStartButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
