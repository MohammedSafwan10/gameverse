import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
              backgroundColor: Colors.grey[900],
              title: const Text(
                'Exit Game?',
                style: TextStyle(color: Colors.white),
              ),
              content: const Text(
                'Are you sure you want to exit? Your progress will be lost.',
                style: TextStyle(color: Colors.white70),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel',
                      style: TextStyle(color: Colors.white70)),
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                ),
                TextButton(
                  child: const Text('Exit',
                      style: TextStyle(color: Colors.redAccent)),
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
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
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
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
        color: Colors.black54,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'PAUSED',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: controller.resumeGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Resume',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: controller.quitGame,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
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
      );
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: controller.startGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text('Start Game'),
          ),
        ),
      );
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
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF1A237E),
                Color(0xFF0D47A1),
              ],
            ),
          ),
          child: SafeArea(
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
        ),
      ),
    );
  }
}
