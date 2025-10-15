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
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
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
                color: isWinning ? Get.theme.colorScheme.primary : null,
                fontWeight: FontWeight.bold,
              ),
            );
          }),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'Settings',
              onPressed: () {
                // Ensure the settings controller is initialized
                if (!Get.isRegistered<ConnectFourSettingsController>()) {
                  Get.put(ConnectFourSettingsController(), permanent: true);
                }
                Get.to(() => ConnectFourSettingsScreen());
              },
            ),
            IconButton(
              icon: const Icon(Icons.bar_chart),
              tooltip: 'Statistics',
              onPressed: () => Get.to(() => const ConnectFourStatsScreen()),
            ),
          ],
        ),
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Get.theme.colorScheme.primary.withValues(
                  red: Get.theme.colorScheme.primary.r.toDouble(),
                  green: Get.theme.colorScheme.primary.g.toDouble(),
                  blue: Get.theme.colorScheme.primary.b.toDouble(),
                  alpha: 0.2,
                ),
                Get.theme.colorScheme.surface,
                Get.theme.colorScheme.secondary.withValues(
                  red: Get.theme.colorScheme.secondary.r.toDouble(),
                  green: Get.theme.colorScheme.secondary.g.toDouble(),
                  blue: Get.theme.colorScheme.secondary.b.toDouble(),
                  alpha: 0.1,
                ),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildControls(context, controller),
                SizedBox(height: topPadding.clamp(20, 40)),
                _buildGameBoard(controller),
                const Spacer(),
                _buildGameStatus(controller),
                const SizedBox(height: 20),
              ],
            ),
          ),
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
                          ? Icons.volume_up
                          : Icons.volume_off,
                      color: soundService.isEnabled.value
                          ? Get.theme.colorScheme.primary
                          : null,
                    ),
                    onPressed: () {
                      soundService.toggleSound();
                      settingsController.toggleSound();
                    },
                    tooltip: 'Sound',
                  )),
              IconButton(
                icon: const Icon(Icons.refresh),
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
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Get.theme.colorScheme.surface.withValues(
                  red: Get.theme.colorScheme.surface.r.toDouble(),
                  green: Get.theme.colorScheme.surface.g.toDouble(),
                  blue: Get.theme.colorScheme.surface.b.toDouble(),
                  alpha: 0.9,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Get.theme.colorScheme.primary.withValues(
                      red: Get.theme.colorScheme.primary.r.toDouble(),
                      green: Get.theme.colorScheme.primary.g.toDouble(),
                      blue: Get.theme.colorScheme.primary.b.toDouble(),
                      alpha: 0.1,
                    ),
                    blurRadius: 4,
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
                      style: Get.textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: AIDifficulty.values
                          .map((difficulty) => Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: _buildDifficultyChip(
                                  difficulty,
                                  controller.aiDifficulty.value == difficulty,
                                  () {
                                    // Update both controller and settings
                                    controller.setAIDifficulty(difficulty);
                                    settingsController
                                        .setDifficulty(difficulty);
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
    final icons = {
      AIDifficulty.easy: Icons.sentiment_satisfied,
      AIDifficulty.medium: Icons.sentiment_neutral,
      AIDifficulty.hard: Icons.sentiment_very_dissatisfied,
    };
    final color = colors[difficulty]!;
    final icon = icons[difficulty]!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(
                    red: color.r.toDouble(),
                    green: color.g.toDouble(),
                    blue: color.b.toDouble(),
                    alpha: 0.1,
                  )
                : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? color
                  : Get.theme.colorScheme.onSurface.withValues(
                      red: Get.theme.colorScheme.onSurface.r.toDouble(),
                      green: Get.theme.colorScheme.onSurface.g.toDouble(),
                      blue: Get.theme.colorScheme.onSurface.b.toDouble(),
                      alpha: 0.3,
                    ),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? color
                    : Get.theme.colorScheme.onSurface.withValues(
                        red: Get.theme.colorScheme.onSurface.r.toDouble(),
                        green: Get.theme.colorScheme.onSurface.g.toDouble(),
                        blue: Get.theme.colorScheme.onSurface.b.toDouble(),
                        alpha: 0.7,
                      ),
              ),
              const SizedBox(width: 4),
              Text(
                difficulty.name.capitalize!,
                style: Get.textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? color
                      : Get.theme.colorScheme.onSurface.withValues(
                          red: Get.theme.colorScheme.onSurface.r.toDouble(),
                          green: Get.theme.colorScheme.onSurface.g.toDouble(),
                          blue: Get.theme.colorScheme.onSurface.b.toDouble(),
                          alpha: 0.7,
                        ),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(
          target: isSelected ? 1 : 0,
        )
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          duration: const Duration(milliseconds: 200),
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
          color: Get.theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Get.theme.colorScheme.primary.withValues(
                red: Get.theme.colorScheme.primary.r.toDouble(),
                green: Get.theme.colorScheme.primary.g.toDouble(),
                blue: Get.theme.colorScheme.primary.b.toDouble(),
                alpha: 0.2,
              ),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AspectRatio(
          aspectRatio: 7 / 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                BoardWidget(controller: controller),
                if (isWinning)
                  Container(
                    color: Colors.black.withValues(
                      red: 0.0,
                      green: 0.0,
                      blue: 0.0,
                      alpha: 0.1,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Lottie.network(
                            'https://assets2.lottiefiles.com/packages/lf20_obhph3sh.json',
                            width: 150,
                            height: 150,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: Get.theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Get.theme.colorScheme.primary.withValues(
                                    red: Get.theme.colorScheme.primary.r
                                        .toDouble(),
                                    green: Get.theme.colorScheme.primary.g
                                        .toDouble(),
                                    blue: Get.theme.colorScheme.primary.b
                                        .toDouble(),
                                    alpha: 0.3,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              _getWinnerText(controller),
                              style: Get.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(),
              ],
            ),
          ),
        ),
      )
          .animate(
            target: isWinning ? 1 : 0,
          )
          .shimmer(
            duration: const Duration(milliseconds: 2000),
            color: Get.theme.colorScheme.primary.withValues(
              red: Get.theme.colorScheme.primary.r.toDouble(),
              green: Get.theme.colorScheme.primary.g.toDouble(),
              blue: Get.theme.colorScheme.primary.b.toDouble(),
              alpha: 0.3,
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
            color: Get.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Get.theme.colorScheme.primary.withValues(
                  red: Get.theme.colorScheme.primary.r.toDouble(),
                  green: Get.theme.colorScheme.primary.g.toDouble(),
                  blue: Get.theme.colorScheme.primary.b.toDouble(),
                  alpha: 0.1,
                ),
                blurRadius: 8,
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
                Colors.red,
                controller,
                controller.gameMode.value == GameMode.vsAI
                    ? statsController.playerWins.value
                    : statsController.player1Wins.value,
              ),
              Container(
                height: 40,
                width: 2,
                color: Get.theme.colorScheme.primary.withValues(
                  red: Get.theme.colorScheme.primary.r.toDouble(),
                  green: Get.theme.colorScheme.primary.g.toDouble(),
                  blue: Get.theme.colorScheme.primary.b.toDouble(),
                  alpha: 0.1,
                ),
              ),
              _buildPlayerIndicator(
                controller.gameMode.value == GameMode.vsAI ? "AI" : "Player 2",
                CellState.player2,
                controller.currentPlayer.value == CellState.player2,
                Colors.yellow,
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

    // Show active indicator only when game is still in progress
    final showActiveIndicator = isCurrentPlayer && !controller.isGameOver;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: showActiveIndicator
            ? Border.all(color: Get.theme.colorScheme.primary, width: 2)
            : null,
        boxShadow: [
          if (isWinner)
            BoxShadow(
              color: color.withValues(
                red: color.r.toDouble(),
                green: color.g.toDouble(),
                blue: color.b.toDouble(),
                alpha: 0.3,
              ),
              blurRadius: 8,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(
                    red: color.r.toDouble(),
                    green: color.g.toDouble(),
                    blue: color.b.toDouble(),
                    alpha: 0.3,
                  ),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight:
                      showActiveIndicator ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              Row(
                children: [
                  Text(
                    'Wins: $wins',
                    style: Get.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (isWinner)
                    Text(
                      ' Winner! 🎉',
                      style: Get.textTheme.bodySmall?.copyWith(
                        color: Get.theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    )
        .animate(
          target: showActiveIndicator ? 1 : 0,
        )
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          duration: const Duration(milliseconds: 200),
        )
        .animate(
          target: isWinner ? 1 : 0,
        )
        .shimmer(
          duration: const Duration(milliseconds: 1000),
          color: color.withValues(
            red: color.r.toDouble(),
            green: color.g.toDouble(),
            blue: color.b.toDouble(),
            alpha: 0.5,
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
            title: const Text('Exit Game?'),
            content: const Text(
                'Are you sure you want to exit the game? Any progress will not be saved.'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
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
        title: const Text('Restart Game?'),
        content: const Text(
            'Are you sure you want to restart the game? The current game will be lost.'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
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
