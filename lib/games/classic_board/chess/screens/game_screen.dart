import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/game_controller.dart';
import '../widgets/chess_board_widget.dart';
import '../widgets/countdown_timer.dart';
import 'settings_screen.dart';
import 'package:gameverse/widgets/premium_background.dart';

class ChessGameScreen extends StatelessWidget {
  const ChessGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChessGameController>();
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop =
              await _showExitConfirmationDialog(context, controller);
          if (shouldPop) {
            Get.back();
          }
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Obx(() => Text(
                _getGameTitle(controller.gameMode.value),
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              )),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () async {
              final shouldPop =
                  await _showExitConfirmationDialog(context, controller);
              if (shouldPop) {
                Get.back();
              }
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.restart_alt_rounded),
              onPressed: () =>
                  _showRestartConfirmationDialog(context, controller),
              tooltip: 'Restart Game',
            ),
            Obx(() => IconButton(
                  icon: Icon(
                    controller.soundService.isSoundEnabled.value
                        ? Icons.volume_up_rounded
                        : Icons.volume_off_rounded,
                  ),
                  onPressed: controller.soundService.toggleSound,
                )),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () {
                controller.soundService.playMenuSelectionSound();
                Get.to(() => const ChessSettingsScreen(),
                    transition: Transition.rightToLeft);
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
                            _buildCapturedPieces(context, controller,
                                false), // Black's pieces captured by White
                            const SizedBox(height: 12),
                            _buildMainBoard(context, controller),
                            const SizedBox(height: 12),
                            _buildCapturedPieces(context, controller,
                                true), // White's pieces captured by Black
                            const SizedBox(height: 20),
                            _buildGameStatusMessage(context, controller),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Pause Overlay
            Obx(() {
              if (!controller.isGamePaused.value) {
                return const SizedBox.shrink();
              }
              return _buildPauseOverlay(context, controller);
            }),

            // Countdown Timer Overlay
            Obx(() {
              if (controller.gameState.value == ChessGameState.initial) {
                return CountdownTimer(
                  message: 'Ready to Play?',
                  onComplete: () {
                    controller.gameState.value = ChessGameState.inProgress;
                    controller.soundService.playGameStartSound();
                  },
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTopInfoBar(
      BuildContext context, ChessGameController controller) {
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
          // Player Turn Info
          Obx(() {
            final isWhite = controller.isWhiteTurn.value;
            return Row(
              children: [
                AnimatedContainer(
                  duration: 400.ms,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isWhite ? Colors.white : Colors.black87,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: theme.colorScheme.primary.withValues(alpha: 0.5),
                        width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: (isWhite ? Colors.white : Colors.black)
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                      )
                    ],
                  ),
                  child: Icon(
                    Icons.person,
                    size: 16,
                    color: isWhite ? Colors.black87 : Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isWhite ? 'White\'s Turn' : 'Black\'s Turn',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _getStateText(controller.gameState.value),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _getStateColor(controller.gameState.value),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),

          // Timers (if enabled)
          Obx(() {
            if (!controller.timerEnabled.value) return const SizedBox.shrink();
            return Row(
              children: [
                _buildCompactTimer(
                    context,
                    'W',
                    controller.whiteTimeRemaining.value,
                    controller.isWhiteTurn.value),
                const SizedBox(width: 8),
                _buildCompactTimer(
                    context,
                    'B',
                    controller.blackTimeRemaining.value,
                    !controller.isWhiteTurn.value),
              ],
            );
          }),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  Widget _buildCompactTimer(
      BuildContext context, String label, int seconds, bool isActive) {
    final theme = Theme.of(context);
    final timeStr = seconds ~/ 60 == 0 && seconds < 10
        ? '0:${seconds.toString().padLeft(2, '0')}'
        : '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

    return AnimatedContainer(
      duration: 300.ms,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: isActive
            ? [
                BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 4)
              ]
            : null,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: isActive
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            timeStr,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color: isActive
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapturedPieces(
      BuildContext context, ChessGameController controller, bool forWhite) {
    final theme = Theme.of(context);
    return Obx(() {
      final pieces = controller.capturedPieces
          .where((p) => forWhite ? p.contains('white') : p.contains('black'))
          .toList();
      if (pieces.isEmpty) return const SizedBox(height: 40);

      // Simple scoring for ordering
      pieces.sort((a, b) {
        int val(String s) => s.contains('queen')
            ? 9
            : s.contains('rook')
                ? 5
                : s.contains('bishop') || s.contains('knight')
                    ? 3
                    : 1;
        return val(b).compareTo(val(a));
      });

      return Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Icon(Icons.outbox_rounded,
                size: 14,
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
            const SizedBox(width: 8),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: pieces.length,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: SvgPicture.asset(
                    'assets/chess/images/${pieces[index]}.svg',
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      pieces[index].contains('white')
                          ? Colors.white
                          : Colors.black87,
                      BlendMode.srcIn,
                    ),
                  ),
                ).animate().scale(delay: (index * 50).ms, duration: 300.ms),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMainBoard(BuildContext context, ChessGameController controller) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size.width - 32;

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: const ChessBoardWidget(),
    ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack);
  }

  Widget _buildGameStatusMessage(
      BuildContext context, ChessGameController controller) {
    final theme = Theme.of(context);
    return Obx(() {
      final message = _getGameMessage(controller.gameState.value,
          controller.isWhiteTurn.value, controller.gameMode.value);
      if (message.isEmpty) return const SizedBox.shrink();

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_getMessageIcon(controller.gameState.value),
                color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 12),
            Text(
              message,
              style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary),
            ),
          ],
        ),
      ).animate().fadeIn().slideY(begin: 0.5);
    });
  }

  Widget _buildPauseOverlay(
      BuildContext context, ChessGameController controller) {
    final theme = Theme.of(context);
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle),
                child: Icon(Icons.pause_rounded,
                    size: 48, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 24),
              Text('Game Paused',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        controller.forfeitGame();
                        Get.back();
                      },
                      child: const Text('FORFEIT',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.resumeGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('RESUME'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
    );
  }

  String _getGameTitle(ChessGameMode mode) {
    return switch (mode) {
      ChessGameMode.local => 'Two Players',
      ChessGameMode.ai => 'vs Computer',
      ChessGameMode.training => 'Training',
    };
  }

  String _getStateText(ChessGameState state) {
    return switch (state) {
      ChessGameState.initial => 'READY',
      ChessGameState.inProgress => 'PLAYING',
      ChessGameState.check => 'CHECK!',
      ChessGameState.checkmate => 'FINISHED',
      ChessGameState.stalemate => 'DRAW',
      ChessGameState.draw => 'DRAW',
    };
  }

  Color _getStateColor(ChessGameState state) {
    return switch (state) {
      ChessGameState.check => Colors.orange,
      ChessGameState.checkmate => Colors.red,
      ChessGameState.stalemate => Colors.blueGrey,
      ChessGameState.draw => Colors.blueGrey,
      _ => Colors.green,
    };
  }

  IconData _getMessageIcon(ChessGameState state) {
    return switch (state) {
      ChessGameState.check => Icons.warning_amber_rounded,
      ChessGameState.checkmate => Icons.emoji_events_rounded,
      ChessGameState.stalemate => Icons.block_rounded,
      ChessGameState.draw => Icons.balance_rounded,
      _ => Icons.info_outline_rounded,
    };
  }

  String _getGameMessage(
      ChessGameState state, bool isWhiteTurn, ChessGameMode mode) {
    if (state == ChessGameState.initial) return '';
    if (state == ChessGameState.inProgress) {
      if (mode == ChessGameMode.ai) {
        return isWhiteTurn ? 'Your Move' : 'Computer Thinking...';
      }
      return '${isWhiteTurn ? "White" : "Black"} to move';
    }

    final winner = !isWhiteTurn ? "White" : "Black";
    return switch (state) {
      ChessGameState.check => '${isWhiteTurn ? "White" : "Black"} is in check!',
      ChessGameState.checkmate => '$winner wins!',
      ChessGameState.stalemate => 'Stalemate - Draw',
      ChessGameState.draw => 'Game Draw',
      _ => '',
    };
  }

  Future<bool> _showExitConfirmationDialog(
      BuildContext context, ChessGameController controller) async {
    if (controller.gameState.value == ChessGameState.initial) return true;

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text('Exit Game?'),
            content: const Text('Your current progress will be lost.'),
            actions: [
              TextButton(
                  onPressed: () => Get.back(result: false),
                  child: const Text('CANCEL')),
              TextButton(
                onPressed: () => Get.back(result: true),
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
      BuildContext context, ChessGameController controller) async {
    final shouldRestart = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Restart?'),
        content: const Text('This will reset the current match.'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('RESTART',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (shouldRestart == true) {
      controller.startNewGame(controller.gameMode.value);
    }
  }
}
