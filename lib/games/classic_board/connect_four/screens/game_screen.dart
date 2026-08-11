import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/game_controller.dart';
import '../controllers/stats_controller.dart';
import '../controllers/settings_controller.dart';
import '../models/board.dart';
import '../widgets/board_widget.dart';
import 'package:gameverse/theme/app_theme.dart';
import 'package:gameverse/widgets/guarded_exit.dart';
import 'mode_selection_screen.dart';
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
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: Colors.white),
            ),
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
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: Colors.white,
              ),
            );
          }),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.bar_chart_rounded,
                    size: 18, color: Colors.white),
              ),
              tooltip: 'Statistics',
              onPressed: () => Get.to(() => const ConnectFourStatsScreen()),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.settings_outlined,
                    size: 18, color: Colors.white),
              ),
              tooltip: 'Settings',
              onPressed: () {
                if (!Get.isRegistered<ConnectFourSettingsController>()) {
                  Get.put(ConnectFourSettingsController(), permanent: true);
                }
                Get.to(() => ConnectFourSettingsScreen());
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Stack(
          children: [
            // Connect Four specific animated/gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF1E3A8A), // Deep blue
                    Color(0xFF0F172A),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withValues(alpha: 0.15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.2),
                      blurRadius: 100,
                      spreadRadius: 50,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withValues(alpha: 0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.15),
                      blurRadius: 100,
                      spreadRadius: 50,
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildTopInfoBar(context, controller),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 8.0),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            _buildGameBoard(context, controller),
                            const SizedBox(height: 32),
                            _buildPlayerStats(context, controller),
                            const SizedBox(height: 24),
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
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: AppTheme.glassmorphicDecoration(
        backgroundColor: Colors.white.withValues(alpha: 0.05),
        borderColor: Colors.white.withValues(alpha: 0.1),
        borderRadius: 24,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() {
            final isPlayer1 =
                controller.currentPlayer.value == CellState.player1;
            final isAI =
                controller.gameMode.value == GameMode.vsAI && !isPlayer1;
            final color = isPlayer1 ? Colors.redAccent : Colors.yellow.shade600;
            final icon = isPlayer1
                ? Icons.person
                : (isAI ? Icons.smart_toy_rounded : Icons.person);

            return Row(
              children: [
                AnimatedContainer(
                  duration: 400.ms,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: color.withValues(alpha: 0.5), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: color,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isPlayer1
                          ? 'Player 1\'s Turn'
                          : (isAI ? 'AI\'s Turn' : 'Player 2\'s Turn'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    if (controller.isAIThinking.value)
                      const Text(
                        'Thinking...',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ).animate(onPlay: (c) => c.repeat()).shimmer(),
                  ],
                ),
              ],
            );
          }),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () =>
                _showRestartConfirmationDialog(context, controller),
            tooltip: 'Restart',
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              padding: const EdgeInsets.all(10),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 12),
            child: Text(
              'AI DIFFICULTY',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: AIDifficulty.values.map((diff) {
                return Obx(() {
                  final isSelected = controller.aiDifficulty.value == diff;
                  final color = diff == AIDifficulty.easy
                      ? Colors.greenAccent
                      : (diff == AIDifficulty.medium
                          ? Colors.orangeAccent
                          : Colors.redAccent);
                  return GestureDetector(
                    onTap: () => controller.setAIDifficulty(diff),
                    child: AnimatedContainer(
                      duration: 300.ms,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withValues(alpha: 0.2)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? color
                              : Colors.white.withValues(alpha: 0.1),
                          width: isSelected ? 1.5 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                )
                              ]
                            : null,
                      ),
                      child: Text(
                        diff.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                          color: isSelected ? color : Colors.white70,
                        ),
                      ),
                    ),
                  );
                });
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard(
      BuildContext context, ConnectFourController controller) {
    final size = MediaQuery.of(context).size.width - 40;

    return Container(
      width: size,
      height: size * (6 / 7),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade800
            .withValues(alpha: 0.9), // Classic Connect Four Blue but modern
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.blue.shade400.withValues(alpha: 0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade900.withValues(alpha: 0.5),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.1),
            blurRadius: 0,
            spreadRadius: 1,
            offset: const Offset(0, 1), // inner highlight
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BoardWidget(controller: controller),
      ),
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
                Colors.redAccent,
                Icons.person,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatTile(
                context,
                controller.gameMode.value == GameMode.vsAI
                    ? 'AI Bot'
                    : 'Player 2',
                controller.gameMode.value == GameMode.vsAI
                    ? statsController.aiWins.value
                    : statsController.player2Wins.value,
                Colors.yellow.shade600,
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: AppTheme.glassmorphicDecoration(
        backgroundColor: Colors.white.withValues(alpha: 0.03),
        borderColor: color.withValues(alpha: 0.3),
        borderRadius: 24,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color.withValues(alpha: 0.8)),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            wins.toString(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'WINS',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: color.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameStatusMessage(
      BuildContext context, ConnectFourController controller) {
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
      Color color = Colors.white;

      if (status == GameStatus.draw) {
        message = "It's a Draw!";
        icon = Icons.balance_rounded;
        color = Colors.blueGrey.shade300;
      } else {
        final isP1 = status == GameStatus.player1Won;
        final name = isP1
            ? "Player 1"
            : (controller.gameMode.value == GameMode.vsAI ? "AI" : "Player 2");
        message = "$name Wins!";
        icon = Icons.emoji_events_rounded;
        color = isP1 ? Colors.redAccent : Colors.yellow.shade600;
      }

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 20,
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Text(
              message,
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ).animate().fadeIn().slideY(begin: 0.3);
    });
  }

  Widget _buildWinOverlay(
      BuildContext context, ConnectFourController controller) {
    final status = controller.board.value.status;
    final isP1 = status == GameStatus.player1Won;
    final color = status == GameStatus.draw
        ? Colors.blueGrey
        : (isP1 ? Colors.redAccent : Colors.yellow.shade600);

    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (status != GameStatus.draw)
                Container(
                  width: 132,
                  height: 132,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withValues(alpha: 0.5),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.35),
                        blurRadius: 32,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: color,
                    size: 76,
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .scaleXY(
                      begin: .92,
                      end: 1.05,
                      duration: 900.ms,
                      curve: Curves.easeInOut,
                    )
                    .then()
                    .scaleXY(
                      begin: 1.05,
                      end: .92,
                      duration: 900.ms,
                      curve: Curves.easeInOut,
                    ),
              Container(
                padding: const EdgeInsets.all(32),
                margin: const EdgeInsets.symmetric(horizontal: 32),
                decoration: AppTheme.glassmorphicDecoration(
                  backgroundColor: color.withValues(alpha: 0.1),
                  borderColor: color.withValues(alpha: 0.3),
                  borderRadius: 32,
                ),
                child: Column(
                  children: [
                    Text(
                      status == GameStatus.draw ? "DRAW!" : "VICTORY!",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: color,
                        letterSpacing: 3,
                        shadows: [
                          Shadow(
                            color: color.withValues(alpha: 0.5),
                            blurRadius: 20,
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () => controller.resetGame(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            elevation: 10,
                            shadowColor: color.withValues(alpha: 0.5),
                            minimumSize: const Size(double.infinity, 56),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.replay_rounded, size: 20),
                              SizedBox(width: 12),
                              Text(
                                'PLAY AGAIN',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () {
                            controller.resetGame();
                            Get.off(() => const ConnectFourModeScreen());
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 2),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            minimumSize: const Size(double.infinity, 56),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.home_rounded, size: 20),
                              SizedBox(width: 12),
                              Text(
                                'MAIN MENU',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
            ],
          ),
        ),
      ),
    ).animate().fadeIn();
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            title: const Text('Exit Game?',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            content: const Text('Your current match progress will be lost.',
                style: TextStyle(color: Colors.white70)),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('CANCEL',
                      style: TextStyle(color: Colors.white60))),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('EXIT',
                    style: TextStyle(
                        color: Colors.redAccent, fontWeight: FontWeight.bold)),
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
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Text('Restart?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('Current board state will be cleared.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('CANCEL',
                  style: TextStyle(color: Colors.white60))),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('RESTART',
                  style: TextStyle(
                      color: Colors.blueAccent, fontWeight: FontWeight.bold))),
        ],
      ),
    );

    if (shouldRestart == true) {
      controller.resetGame();
    }
  }
}
