import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../controllers/game_controller.dart';
import '../controllers/stats_controller.dart';
import '../controllers/settings_controller.dart';
import '../models/board.dart';
import '../widgets/board_widget.dart';
import '../services/sound_service.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class ConnectFourGameScreen extends StatelessWidget {
  const ConnectFourGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ConnectFourController>();
    final screenHeight = MediaQuery.of(context).size.height;
    final boardSize =
        MediaQuery.of(context).size.width - 32; // Full width minus margins
    final topPadding =
        (screenHeight - boardSize - 160) / 2; // 160 for header and status

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _showExitConfirmationDialog(context);
          if (shouldPop) {
            Get.back(result: true);
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FE), // AppTheme clean background
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: Colors.black87,
            onPressed: () =>
                _showExitConfirmationDialog(context).then((result) {
              if (result) Get.back();
            }),
          ),
          title: Obx(() {
            final text = _getGameStatusText(controller);
            final isWinning =
                controller.board.value.status == GameStatus.player1Won ||
                    controller.board.value.status == GameStatus.player2Won;
            return Text(
              text,
              style: TextStyle(
                color: isWinning ? Get.theme.colorScheme.primary : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            );
          }),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              color: Colors.black87,
              tooltip: 'Settings',
              onPressed: () {
                if (!Get.isRegistered<ConnectFourSettingsController>()) {
                  Get.put(ConnectFourSettingsController(), permanent: true);
                }
                Get.to(() => ConnectFourSettingsScreen());
              },
            ),
            IconButton(
              icon: const Icon(Icons.bar_chart_rounded),
              color: Colors.black87,
              tooltip: 'Statistics',
              onPressed: () => Get.to(() => const ConnectFourStatsScreen()),
            ),
          ],
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
             // Decorative Background
             Positioned(
              right: -100,
              top: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -80,
              bottom: 100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  _buildControls(context, controller).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
                  SizedBox(height: topPadding.clamp(20, 40)),
                  _buildGameBoard(controller).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                  const Spacer(),
                  _buildGameStatus(controller).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(
      BuildContext context, ConnectFourController controller) {
    final soundService = Get.find<SoundService>();
    final settingsController = Get.find<ConnectFourSettingsController>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(() => IconButton(
                    icon: Icon(
                      soundService.isEnabled.value
                          ? Icons.volume_up_rounded
                          : Icons.volume_off_rounded,
                      color: soundService.isEnabled.value
                          ? Get.theme.colorScheme.primary
                          : Colors.grey,
                    ),
                    onPressed: () {
                      soundService.toggleSound();
                      settingsController.toggleSound();
                    },
                    tooltip: 'Sound',
                  )),
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                color: Colors.black87,
                tooltip: 'Restart Game',
                onPressed: () =>
                    _showRestartConfirmationDialog(context, controller),
              ),
            ],
          ),
        ),
        Obx(() {
          if (controller.gameMode.value == GameMode.vsAI) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'AI Difficulty:',
                      style: Get.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: AIDifficulty.values
                          .map((difficulty) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: _buildDifficultyChip(
                                  difficulty,
                                  controller.aiDifficulty.value == difficulty,
                                  () {
                                    controller.setAIDifficulty(difficulty);
                                    settingsController.setDifficulty(difficulty);
                                  },
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildDifficultyChip(
      AIDifficulty difficulty, bool isSelected, VoidCallback onTap) {
    final colors = {
      AIDifficulty.easy: Colors.green,
      AIDifficulty.medium: Colors.orange,
      AIDifficulty.hard: Colors.red,
    };
    final color = colors[difficulty]!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
            border: Border.all(
              color: isSelected ? color : Colors.grey.withOpacity(0.3),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            difficulty.name.capitalize!,
            style: TextStyle(
              color: isSelected ? color : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameBoard(ConnectFourController controller) {
    return Obx(() {
      final isWinning =
          controller.board.value.status == GameStatus.player1Won ||
              controller.board.value.status == GameStatus.player2Won;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: AspectRatio(
          aspectRatio: 7 / 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Add padding inside the board container
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: BoardWidget(controller: controller),
                ),

                if (isWinning)
                  Container(
                    color: Colors.black.withOpacity(0.1),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // You might want to replace Lottie if not available or verify asset
                          // Using a scale animation for text instead
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            decoration: BoxDecoration(
                              color: Get.theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Get.theme.colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              _getWinnerText(controller),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ).animate().scale(curve: Curves.elasticOut),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildGameStatus(ConnectFourController controller) {
    final statsController = Get.find<ConnectFourStatsController>();

    return Obx(() => Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPlayerIndicator(
                "Player 1",
                CellState.player1,
                controller.currentPlayer.value == CellState.player1,
                Colors.red, // Classic Connect 4 Red
                controller,
                controller.gameMode.value == GameMode.vsAI
                    ? statsController.playerWins.value
                    : statsController.player1Wins.value,
              ),
              Container(
                height: 40,
                width: 1,
                color: Colors.grey.withOpacity(0.2),
              ),
              _buildPlayerIndicator(
                controller.gameMode.value == GameMode.vsAI ? "AI" : "Player 2",
                CellState.player2,
                controller.currentPlayer.value == CellState.player2,
                Colors.yellow[700]!, // Classic Connect 4 Yellow
                controller,
                controller.gameMode.value == GameMode.vsAI
                    ? statsController.aiWins.value
                    : statsController.player2Wins.value,
              ),
            ],
          ),
        ));
  }

  Widget _buildPlayerIndicator(
    String name,
    CellState player,
    bool isCurrentPlayer,
    Color color,
    ConnectFourController controller,
    int wins,
  ) {
    final isWinner = (player == CellState.player1 &&
            controller.board.value.status == GameStatus.player1Won) ||
        (player == CellState.player2 &&
            controller.board.value.status == GameStatus.player2Won);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isCurrentPlayer ? color.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentPlayer ? color : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontWeight: isCurrentPlayer ? FontWeight.bold : FontWeight.normal,
              color: Colors.black87,
            ),
          ),
          Text(
            'Wins: $wins',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          if (isWinner)
             Text(
              'WINNER',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ).animate().fadeIn(),
        ],
      ),
    );
  }

  String _getGameStatusText(ConnectFourController controller) {
    switch (controller.board.value.status) {
      case GameStatus.playing:
        if (controller.isAIThinking.value) {
          return "AI is thinking...";
        }
        return "Connect Four";
      case GameStatus.draw:
        return "It's a Draw!";
      case GameStatus.player1Won:
      case GameStatus.player2Won:
        return "Game Over!";
    }
  }

  String _getWinnerText(ConnectFourController controller) {
    switch (controller.board.value.status) {
      case GameStatus.player1Won:
        return "Player 1 Wins! 🎉";
      case GameStatus.player2Won:
        return controller.gameMode.value == GameMode.vsAI
            ? "AI Wins! 🤖"
            : "Player 2 Wins! 🎉";
      default:
        return "";
    }
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            title: const Text('Exit Game?'),
            content: const Text(
                'Are you sure you want to exit? Progress will be lost.'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('CANCEL'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Get.theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('EXIT'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _showRestartConfirmationDialog(
      BuildContext context, ConnectFourController controller) async {
    final shouldRestart = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Restart Game?'),
        content: const Text(
            'Are you sure you want to restart? Current game will be lost.'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('RESTART'),
          ),
        ],
      ),
    );

    if (shouldRestart == true) {
      controller.resetGame();
    }
  }
}
