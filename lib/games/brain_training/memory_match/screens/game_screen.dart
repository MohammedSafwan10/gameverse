import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/game_controller.dart';
import '../models/game_mode.dart';
import '../models/game_state.dart';
import '../widgets/flip_card.dart';
import '../services/sound_service.dart';

class MemoryMatchGameScreen extends StatefulWidget {
  final MemoryMatchMode mode;
  final GameDifficulty difficulty;

  const MemoryMatchGameScreen({
    super.key,
    required this.mode,
    required this.difficulty,
  });

  @override
  State<MemoryMatchGameScreen> createState() => _MemoryMatchGameScreenState();
}

class _MemoryMatchGameScreenState extends State<MemoryMatchGameScreen> {
  late final MemoryMatchGameController controller;
  late final SoundService soundService;
  final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );

  @override
  void initState() {
    super.initState();
    _logger.i('Initializing MemoryMatchGameScreen');
    try {
      controller = Get.find<MemoryMatchGameController>();
      soundService = Get.find<SoundService>();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _logger.i(
            'Initializing game with mode: ${widget.mode}, difficulty: ${widget.difficulty}');
        controller.initGame(widget.mode, widget.difficulty);
      });
    } catch (e, stackTrace) {
      _logger.e(
          'Error during initialization\nError: $e\nStack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  void dispose() {
    _logger.i('Disposing MemoryMatchGameScreen');
    if (Get.isRegistered<MemoryMatchGameController>()) {
      controller.cleanupGame();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, dynamic result) async {
        if (!didPop) {
          _logger.d('Back button pressed, showing exit confirmation');
          controller.pauseGame();
          final shouldPop = await _showExitConfirmation();
          if (shouldPop) {
            _logger.i('User confirmed exit');
            Get.back();
          } else {
            _logger.d('User cancelled exit');
            controller.resumeGame();
          }
        }
      },
      child: Scaffold(
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
                  color: widget.mode.color.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  _buildHeader().animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
                  Expanded(
                    child: _buildGameBoard(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmation() async {
    return await Get.dialog<bool>(
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Exit Game?',
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Are you sure you want to exit?\nYour progress will be lost.',
                    textAlign: TextAlign.center,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(result: false),
                        child: Text(
                          'Continue',
                          style: TextStyle(color: widget.mode.color),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          controller.cleanupGame();
                          Get.back(result: true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.mode.color,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Exit'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;
  }

  Widget _buildHeader() {
    return Obx(() {
      final gameState = controller.state;
      if (gameState == null) {
        return const SizedBox.shrink();
      }

      final screenWidth = MediaQuery.of(context).size.width;
      final isSmallScreen = screenWidth < 360;

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Get.back(),
                  color: Colors.black87,
                  iconSize: 20,
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          widget.mode.displayName,
                          style: Get.textTheme.titleMedium?.copyWith(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          '${gameState.remainingPairs} pairs left',
                          style: Get.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    soundService.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                    size: 24,
                  ),
                  onPressed: soundService.toggleMute,
                  color: Colors.black87,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat(
                  icon: Icons.star_rounded,
                  value: gameState.score.toString(),
                  label: 'Score',
                  color: Colors.amber,
                ),
                _buildStat(
                  icon: Icons.timer_rounded,
                  value: '${gameState.timeElapsed}s',
                  label: 'Time',
                  color: Colors.blue,
                ),
                _buildStat(
                  icon: Icons.grid_view_rounded,
                  value: gameState.moves.toString(),
                  label: 'Moves',
                  color: Colors.purple,
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStat({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard() {
    return Obx(() {
      final gameState = controller.state;
      if (gameState == null) {
        return const Center(child: CircularProgressIndicator());
      }

      final gridSize = gameState.gridSize;
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      final isSmallScreen = screenWidth < 360 || screenHeight < 600;
      final gridSpacing = 12.0;

      return Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth - (gridSize + 1) * gridSpacing;
            final availableHeight = constraints.maxHeight - (gridSize + 1) * gridSpacing;
            final maxCardSize = min(
              availableWidth / gridSize,
              availableHeight / gridSize,
            );

            final cardSize = min(maxCardSize * 0.9, 100.0); // Cap max size
            final totalWidth = cardSize * gridSize + (gridSize - 1) * gridSpacing;
            final totalHeight = cardSize * gridSize + (gridSize - 1) * gridSpacing;

            return SizedBox(
              width: totalWidth + 24, // Add padding
              height: totalHeight + 24,
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                physics: const BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridSize,
                  crossAxisSpacing: gridSpacing,
                  mainAxisSpacing: gridSpacing,
                ),
                itemCount: gameState.cards.length,
                itemBuilder: (context, index) {
                  final card = gameState.cards[index];
                  return Hero(
                    tag: 'card_${card.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => controller.flipCard(index),
                        borderRadius: BorderRadius.circular(16),
                        child: FlipCard(
                          card: card,
                          mode: widget.mode,
                          onFlipComplete: (bool isFrontSide) {
                            if (isFrontSide && card.isMatched) {
                              controller.showMatchAnimation(index);
                            }
                          },
                        ),
                      ),
                    ),
                  ).animate().scale(delay: (50 * index).ms, duration: 400.ms, curve: Curves.easeOutBack);
                },
              ),
            );
          },
        ),
      );
    });
  }
}
