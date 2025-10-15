import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/game_controller.dart';
import '../controllers/settings_controller.dart';
import '../widgets/block_tile.dart';
import 'settings_screen.dart';

class BlockMergeGameScreen extends StatefulWidget {
  const BlockMergeGameScreen({super.key});

  @override
  State<BlockMergeGameScreen> createState() => _BlockMergeGameScreenState();
}

class _BlockMergeGameScreenState extends State<BlockMergeGameScreen> {
  late final BlockMergeController controller;
  late final BlockMergeSettingsController settingsController;

  @override
  void initState() {
    super.initState();
    controller = Get.find<BlockMergeController>();
    settingsController = Get.find<BlockMergeSettingsController>();
    // Show tutorial after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted && settingsController.showTutorial.value) {
        _showTutorialDialog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final gridSize = screenWidth * 0.9;
    final tileSize = (gridSize - 32) / 4;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _showExitConfirmationDialog(context);
          if (shouldPop) {
            controller.exitGame();
          }
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final shouldPop = await _showExitConfirmationDialog(context);
              if (shouldPop) {
                controller.exitGame();
              }
            },
          ).animate().fadeIn(delay: 100.ms),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Get.to(() => const BlockMergeSettingsScreen()),
              tooltip: 'Game Settings',
            ).animate().fadeIn(delay: 100.ms),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange.shade200,
                Colors.orange.shade50,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildGameInfo(),
                const SizedBox(height: 24),
                Expanded(
                  child: Center(
                    child: _buildGameGrid(gridSize, tileSize),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Block Merge',
          style: Get.textTheme.headlineMedium?.copyWith(
            color: Colors.orange.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
        Obx(() => Tooltip(
              message: settingsController.gameMode.value ==
                      BlockMergeMode.classic
                  ? 'Classic Mode: Keep playing until no moves are left'
                  : settingsController.gameMode.value ==
                          BlockMergeMode.timeChallenge
                      ? 'Time Challenge: Race against the clock! Get the highest score before time runs out'
                      : 'Zen Mode: Relaxed gameplay with no game over. Practice and improve your strategy',
              child: Text(
                settingsController.gameMode.value == BlockMergeMode.classic
                    ? 'Classic Mode'
                    : settingsController.gameMode.value ==
                            BlockMergeMode.timeChallenge
                        ? 'Time Challenge'
                        : 'Zen Mode',
                style: TextStyle(
                  color: Colors.orange.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )),
      ],
    ).animate().fadeIn().slideY(begin: -0.3);
  }

  Widget _buildGameInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    child: Column(
                      children: [
                        Text(
                          'Score',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(() => Text(
                              controller.score.value.toString(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    child: Column(
                      children: [
                        Text(
                          'Best',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.orange.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Obx(() => Text(
                              controller.bestScore.value.toString(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
              if (settingsController.gameMode.value ==
                  BlockMergeMode.timeChallenge) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      child: Column(
                        children: [
                          Text(
                            'Time',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.orange.shade800,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(() => Text(
                                controller.timeRemaining.value.toString(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildControlButton(
              icon: Icons.refresh,
              label: 'Restart',
              onPressed: controller.newGame,
              tooltip: 'Start a new game',
            ),
            const SizedBox(width: 16),
            _buildControlButton(
              icon: Icons.undo,
              label: 'Undo',
              onPressed: controller.undo,
              tooltip: 'Undo last move',
            ),
            const SizedBox(width: 16),
            _buildControlButton(
              icon: Icons.help_outline,
              label: 'Help',
              onPressed: _showTutorialDialog,
              tooltip: 'How to play',
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: -0.2);
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.orange.shade800, size: 18),
        label: Text(
          label,
          style: TextStyle(
            color: Colors.orange.shade800,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          minimumSize: const Size(70, 36),
        ),
      ),
    );
  }

  Widget _buildGameGrid(double gridSize, double tileSize) {
    return Container(
      width: gridSize,
      height: gridSize,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.shade100.withValues(
          red: Colors.orange.shade800.r.toDouble(),
          green: Colors.orange.shade800.g.toDouble(),
          blue: Colors.orange.shade800.b.toDouble(),
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.shade200,
          width: 2,
        ),
      ),
      child: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dy > 0) {
            controller.moveDown();
          } else {
            controller.moveUp();
          }
        },
        onHorizontalDragEnd: (details) {
          if (details.velocity.pixelsPerSecond.dx > 0) {
            controller.moveRight();
          } else {
            controller.moveLeft();
          }
        },
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
          ),
          itemCount: 16,
          itemBuilder: (context, index) {
            final row = index ~/ 4;
            final col = index % 4;
            return Obx(() {
              final block = controller.grid.value[row][col];
              return BlockTile(
                block: block,
                size: tileSize,
              );
            });
          },
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.orange.shade800),
                const SizedBox(width: 8),
                const Text('Exit Game'),
              ],
            ),
            content: const Text(
                'Are you sure you want to exit? Progress will be lost.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.orange.shade800),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade800,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Exit'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showTutorialDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.lightbulb_outline, color: Colors.orange.shade800),
            const SizedBox(width: 8),
            const Text('How to Play'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTutorialStep(
              '1. Swipe Direction',
              'Swipe up, down, left, or right to move all tiles in that direction.',
              Icons.swipe,
            ),
            const SizedBox(height: 16),
            _buildTutorialStep(
              '2. Merge Tiles',
              'When two tiles with the same number touch, they merge into one tile with double the value!',
              Icons.merge_type,
            ),
            const SizedBox(height: 16),
            _buildTutorialStep(
              '3. Reach 2048',
              'Keep merging tiles to reach the 2048 tile and win the game!',
              Icons.emoji_events,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              settingsController.setShowTutorial(false);
              Navigator.of(context).pop();
            },
            child: Text(
              'Don\'t Show Again',
              style: TextStyle(color: Colors.orange.shade800),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade800,
              foregroundColor: Colors.white,
            ),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialStep(String title, String description, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.orange.shade600, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
