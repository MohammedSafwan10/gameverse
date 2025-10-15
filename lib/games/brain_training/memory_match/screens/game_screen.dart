import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
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

      // Initialize game after frame is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _logger.i(
            'Initializing game with mode: ${widget.mode}, difficulty: ${widget.difficulty}');
        controller.initGame(widget.mode, widget.difficulty);
      });
    } catch (e, stackTrace) {
      _logger.e(
          'Error during initialization\nError: $e\nStack trace: $stackTrace');
      rethrow; // Rethrow to let the error handler deal with it
    }
  }

  @override
  void dispose() {
    _logger.i('Disposing MemoryMatchGameScreen');
    // Ensure we cleanup the game state before disposing
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
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Container(
                  color: Colors.grey[50],
                  child: _buildGameBoard(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmation() async {
    return await Get.dialog<bool>(
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Exit Game?',
                    style: Get.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
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
                          // Cleanup before exiting
                          controller.cleanupGame();
                          Get.back(result: true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.mode.color,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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

      // Check screen size to adjust layout
      final screenWidth = MediaQuery.of(context).size.width;
      final isSmallScreen = screenWidth < 360;

      return Padding(
        padding: EdgeInsets.fromLTRB(
            isSmallScreen ? 8 : 16,
            isSmallScreen ? 4 : 8,
            isSmallScreen ? 8 : 16,
            isSmallScreen ? 4 : 8),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: widget.mode.color.withValues(
                          red: widget.mode.color.r.toDouble(),
                          green: widget.mode.color.g.toDouble(),
                          blue: widget.mode.color.b.toDouble(),
                          alpha: 0.2,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Get.back(),
                    color: widget.mode.color,
                    iconSize: isSmallScreen ? 18 : 20,
                    padding: isSmallScreen
                        ? const EdgeInsets.all(8)
                        : const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.mode.displayName,
                        style: Get.textTheme.titleMedium?.copyWith(
                          color: widget.mode.color,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 16 : null,
                        ),
                      ),
                      Text(
                        '${gameState.remainingPairs} pairs remaining',
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: Colors.black54,
                          fontSize: isSmallScreen ? 10 : null,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: widget.mode.color.withValues(
                          red: widget.mode.color.r.toDouble(),
                          green: widget.mode.color.g.toDouble(),
                          blue: widget.mode.color.b.toDouble(),
                          alpha: 0.2,
                        ),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      soundService.isMuted ? Icons.volume_off : Icons.volume_up,
                      size: 20,
                    ),
                    onPressed: soundService.toggleMute,
                    color: widget.mode.color,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: widget.mode.color.withValues(
                      red: widget.mode.color.r.toDouble(),
                      green: widget.mode.color.g.toDouble(),
                      blue: widget.mode.color.b.toDouble(),
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer,
                        color: widget.mode.color,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${gameState.timeElapsed}s',
                        style: TextStyle(
                          color: widget.mode.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: widget.mode.color.withValues(
                      red: widget.mode.color.r.toDouble(),
                      green: widget.mode.color.g.toDouble(),
                      blue: widget.mode.color.b.toDouble(),
                      alpha: 0.1,
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat(
                    icon: Icons.star,
                    value: gameState.score.toString(),
                    label: 'Score',
                  ),
                  _buildStat(
                    icon: Icons.swap_horiz,
                    value: gameState.moves.toString(),
                    label: 'Moves',
                  ),
                  _buildStat(
                    icon: Icons.grid_view,
                    value: '${gameState.gridSize}x${gameState.gridSize}',
                    label: 'Grid',
                  ),
                ],
              ),
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
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: widget.mode.color.withValues(
              red: widget.mode.color.r.toDouble(),
              green: widget.mode.color.g.toDouble(),
              blue: widget.mode.color.b.toDouble(),
              alpha: 0.1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: widget.mode.color,
            size: 20,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Get.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(
          label,
          style: Get.textTheme.bodySmall?.copyWith(
            color: Colors.black54,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildGameBoard() {
    return Obx(() {
      final gameState = controller.state;
      if (gameState == null) {
        _logger.d('Game state is null, showing loading indicator');
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      _logger.d('Building game board with grid size: ${gameState.gridSize}');
      final gridSize = gameState.gridSize;

      // Calculate spacing based on grid size and screen size
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      final isSmallScreen = screenWidth < 360 || screenHeight < 600;
      final gridSpacing = isSmallScreen
          ? (gridSize <= 4 ? 4.0 : 2.0)
          : (gridSize <= 4 ? 8.0 : 4.0);

      return Container(
        margin: EdgeInsets.all(isSmallScreen ? 8 : 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                red: 0.0,
                green: 0.0,
                blue: 0.0,
                alpha: 0.05,
              ),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate available space considering device size
              final availableWidth =
                  constraints.maxWidth - (gridSize + 1) * gridSpacing;
              final availableHeight =
                  constraints.maxHeight - (gridSize + 1) * gridSpacing;

              // Calculate maximum possible card size based on available space
              final maxCardSize = min(
                availableWidth / gridSize,
                availableHeight / gridSize,
              );

              // Adjust card size based on grid size and screen size
              double cardSize;
              if (isSmallScreen) {
                // Smaller cards on small screens
                cardSize = maxCardSize * 0.95;
              } else if (gridSize <= 4) {
                cardSize = maxCardSize;
              } else if (gridSize == 6) {
                cardSize = maxCardSize * 0.95;
              } else {
                // For 8x8 grid
                cardSize = maxCardSize * 0.9;
              }

              // Ensure we never create overflow by limiting size
              cardSize = min(cardSize, (screenWidth - 40) / gridSize);

              // Calculate total grid size based on card size
              final totalWidth =
                  cardSize * gridSize + (gridSize + 1) * gridSpacing;
              final totalHeight =
                  cardSize * gridSize + (gridSize + 1) * gridSpacing;

              _logger.t('Card size calculated: $cardSize');

              return Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Container(
                      width: totalWidth,
                      height: totalHeight,
                      padding: EdgeInsets.all(gridSpacing),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
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
                                onTap: () {
                                  _logger.t('Card tapped: $index');
                                  controller.flipCard(index);
                                },
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
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    });
  }
}
