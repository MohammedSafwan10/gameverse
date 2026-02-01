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
        backgroundColor: const Color(0xFFF8F9FE),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: Colors.black87,
            onPressed: () async {
              final shouldPop = await _showExitConfirmationDialog(context);
              if (shouldPop) {
                controller.exitGame();
              }
            },
          ).animate().fadeIn(delay: 100.ms),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              color: Colors.black87,
              onPressed: () => Get.to(() => const BlockMergeSettingsScreen()),
              tooltip: 'Game Settings',
            ).animate().fadeIn(delay: 100.ms),
          ],
        ),
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
                  color: Colors.orange.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  _buildHeader().animate().fadeIn().slideY(begin: -0.2),
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
          ],
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
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        Obx(() => Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
                settingsController.gameMode.value == BlockMergeMode.classic
                    ? 'Classic Mode'
                    : settingsController.gameMode.value ==
                            BlockMergeMode.timeChallenge
                        ? 'Time Challenge'
                        : 'Zen Mode',
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
        )),
      ],
    );
  }

  Widget _buildGameInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildScoreCard(
                  'Score',
                  controller.score.value.toString(),
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildScoreCard(
                  'Best',
                  controller.bestScore.value.toString(),
                  Colors.amber,
                ),
              ),
              if (settingsController.gameMode.value ==
                  BlockMergeMode.timeChallenge) ...[
                const SizedBox(width: 16),
                Expanded(
                  child: _buildScoreCard(
                    'Time',
                    controller.timeRemaining.value.toString(),
                    Colors.red,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildControlButton(
              icon: Icons.refresh_rounded,
              label: 'Restart',
              onPressed: controller.newGame,
              tooltip: 'Start a new game',
            ),
            const SizedBox(width: 16),
            _buildControlButton(
              icon: Icons.undo_rounded,
              label: 'Undo',
              onPressed: controller.undo,
              tooltip: 'Undo last move',
            ),
            const SizedBox(width: 16),
            _buildControlButton(
              icon: Icons.help_outline_rounded,
              label: 'Help',
              onPressed: _showTutorialDialog,
              tooltip: 'How to play',
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2);
  }

  Widget _buildScoreCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Obx(() => Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          )),
        ],
      ),
    );
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
        icon: Icon(icon, color: Colors.white, size: 20),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
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
        color: const Color(0xFFBBADA0),
        borderRadius: BorderRadius.circular(16),
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
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
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
    ).animate().scale(curve: Curves.elasticOut, duration: 800.ms);
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Exit Game?'),
            content: const Text(
                'Are you sure you want to exit? Progress will be lost.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('CANCEL'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('EXIT'),
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.lightbulb_outline_rounded, color: Colors.orange),
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
              Icons.swipe_rounded,
            ),
            const SizedBox(height: 16),
            _buildTutorialStep(
              '2. Merge Tiles',
              'When two tiles with the same number touch, they merge into one!',
              Icons.merge_type_rounded,
            ),
            const SizedBox(height: 16),
            _buildTutorialStep(
              '3. Reach 2048',
              'Keep merging tiles to reach the 2048 tile and win the game!',
              Icons.emoji_events_rounded,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              settingsController.setShowTutorial(false);
              Navigator.of(context).pop();
            },
            child: const Text('Don\'t Show Again'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialStep(String title, String description, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.orange, size: 20),
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
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
