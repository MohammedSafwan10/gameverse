import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../controllers/game_controller.dart';
import '../controllers/stats_controller.dart';
import '../controllers/settings_controller.dart';
import '../models/board.dart';
import '../widgets/board_widget.dart';
import 'package:gameverse/widgets/premium_background.dart';
import 'package:gameverse/widgets/guarded_exit.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';

class ConnectFourGameScreen extends StatelessWidget {
  const ConnectFourGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ConnectFourController>();
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await popAfterConfirmation(
            context,
            confirmExit: () => _showExitConfirmationDialog(context),
            result: true,
          );
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => popAfterConfirmation(
              context,
              confirmExit: () => _showExitConfirmationDialog(context),
            ),
          ),
          title: Obx(() {
            final isWinning =
                controller.board.value.status != GameStatus.playing;
            return Text(
              isWinning ? "Game Over" : "Connect Four",
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            );
          }),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.bar_chart_rounded),
              tooltip: 'Statistics',
              onPressed: () => Get.to(() => const ConnectFourStatsScreen()),
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              tooltip: 'Settings',
              onPressed: () {
                if (!Get.isRegistered<ConnectFourSettingsController>()) {
                  Get.put(ConnectFourSettingsController(), permanent: true);
                }
                Get.to(() => ConnectFourSettingsScreen());
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            const PremiumBackground(),
            SafeArea(
              child: Column(
                children: [
                  _buildTopInfoBar(context, controller),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            _buildGameBoard(context, controller),
                            const SizedBox(height: 32),
                            _buildPlayerStats(context, controller),
                            const SizedBox(height: 32),
                            _buildGameStatusMessage(context, controller),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Winning Animation Overlay
            Obx(() {
              final status = controller.board.value.status;
              if (status == GameStatus.playing) return const SizedBox.shrink();
              return _buildWinOverlay(context, controller);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTopInfoBar(
      BuildContext context, ConnectFourController controller) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() => Row(
                children: [
                  AnimatedContainer(
                    duration: 400.ms,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: controller.currentPlayer.value == CellState.player1
                          ? Colors.red
                          : Colors.yellow.shade600,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (controller.currentPlayer.value ==
                                      CellState.player1
                                  ? Colors.red
                                  : Colors.yellow.shade600)
                              .withValues(alpha: 0.4),
                          blurRadius: 8,
                        )
                      ],
                    ),
                    child: Icon(
                      controller.currentPlayer.value == CellState.player1
                          ? Icons.person
                          : (controller.gameMode.value == GameMode.vsAI
                              ? Icons.smart_toy_rounded
                              : Icons.person),
                      size: 16,
                      color: controller.currentPlayer.value == CellState.player1
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        controller.currentPlayer.value == CellState.player1
                            ? 'Player 1\'s Turn'
                            : (controller.gameMode.value == GameMode.vsAI
                                ? 'AI\'s Turn'
                                : 'Player 2\'s Turn'),
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (controller.isAIThinking.value)
                        Text(
                          'Thinking...',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ).animate(onPlay: (c) => c.repeat()).shimmer(),
                    ],
                  ),
                ],
              )),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                _showRestartConfirmationDialog(context, controller),
            tooltip: 'Restart',
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
              padding: const EdgeInsets.all(8),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  Widget _buildDifficultySelector(
      BuildContext context, ConnectFourController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: AIDifficulty.values.map((diff) {
            return Obx(() {
              final isSelected = controller.aiDifficulty.value == diff;
              final color = diff == AIDifficulty.easy
                  ? Colors.green
                  : (diff == AIDifficulty.medium ? Colors.orange : Colors.red);
              return GestureDetector(
                onTap: () => controller.setAIDifficulty(diff),
                child: AnimatedContainer(
                  duration: 300.ms,
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    diff.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : color,
                    ),
                  ),
                ),
              );
            });
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildGameBoard(
      BuildContext context, ConnectFourController controller) {
    final size = MediaQuery.of(context).size.width - 32;

    return Container(
      width: size,
      height: size * (6 / 7),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade900,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: BoardWidget(controller: controller),
    ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack);
  }

  Widget _buildPlayerStats(
      BuildContext context, ConnectFourController controller) {
    final statsController = Get.find<ConnectFourStatsController>();

    return Obx(() => Row(
          children: [
            Expanded(
              child: _buildStatTile(
                context,
                'Player 1',
                controller.gameMode.value == GameMode.vsAI
                    ? statsController.playerWins.value
                    : statsController.player1Wins.value,
                Colors.red,
                Icons.person,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatTile(
                context,
                controller.gameMode.value == GameMode.vsAI ? 'AI' : 'Player 2',
                controller.gameMode.value == GameMode.vsAI
                    ? statsController.aiWins.value
                    : statsController.player2Wins.value,
                Colors.yellow.shade700,
                controller.gameMode.value == GameMode.vsAI
                    ? Icons.smart_toy_rounded
                    : Icons.person,
              ),
            ),
          ],
        ));
  }

  Widget _buildStatTile(BuildContext context, String label, int wins,
      Color color, IconData icon) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              wins.toString(),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ),
          Text(
            'WINS',
            style: theme.textTheme.bodySmall?.copyWith(
              letterSpacing: 1.5,
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameStatusMessage(
      BuildContext context, ConnectFourController controller) {
    final theme = Theme.of(context);
    return Obx(() {
      final status = controller.board.value.status;
      if (status == GameStatus.playing) {
        if (controller.gameMode.value == GameMode.vsAI) {
          return _buildDifficultySelector(context, controller);
        }
        return const SizedBox.shrink();
      }

      String message = "";
      IconData icon = Icons.info_outline_rounded;
      Color color = theme.colorScheme.primary;

      if (status == GameStatus.draw) {
        message = "It's a Draw!";
        icon = Icons.balance_rounded;
        color = Colors.blueGrey;
      } else {
        final isP1 = status == GameStatus.player1Won;
        final name = isP1
            ? "Player 1"
            : (controller.gameMode.value == GameMode.vsAI ? "AI" : "Player 2");
        message = "$name Wins!";
        icon = Icons.emoji_events_rounded;
        color = isP1 ? Colors.red : Colors.yellow.shade700;
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              message,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ).animate().fadeIn().slideY(begin: 0.5);
    });
  }

  Widget _buildWinOverlay(
      BuildContext context, ConnectFourController controller) {
    final status = controller.board.value.status;
    final isP1 = status == GameStatus.player1Won;
    final color = status == GameStatus.draw
        ? Colors.blueGrey
        : (isP1 ? Colors.red : Colors.yellow.shade700);

    return Container(
      color: Colors.black.withValues(alpha: 0.4),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status != GameStatus.draw)
              Lottie.network(
                'https://assets2.lottiefiles.com/packages/lf20_obhph3sh.json',
                width: 250,
                height: 250,
              ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.5),
                    blurRadius: 20,
                  )
                ],
              ),
              child: Column(
                children: [
                  Text(
                    status == GameStatus.draw ? "DRAW!" : "VICTORY!",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: color,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => controller.resetGame(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text('PLAY AGAIN',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
          ],
        ),
      ),
    ).animate().fadeIn();
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('Exit Game?'),
            content: const Text('Your current match progress will be lost.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('CANCEL')),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('EXIT',
                    style: TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Restart?'),
        content: const Text('Current board state will be cleared.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('CANCEL')),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('RESTART')),
        ],
      ),
    );

    if (shouldRestart == true) {
      controller.resetGame();
    }
  }
}
