import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/game_controller.dart';
import '../widgets/chess_board_widget.dart';
import '../widgets/countdown_timer.dart';
import 'settings_screen.dart';

class ChessGameScreen extends StatelessWidget {
  const ChessGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChessGameController>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isPortrait = screenHeight > screenWidth;

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
        backgroundColor: const Color(0xFFF8F9FE), // AppTheme clean background
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: Colors.black87,
            onPressed: () async {
              final shouldPop =
                  await _showExitConfirmationDialog(context, controller);
              if (shouldPop) {
                Get.back();
              }
            },
          ),
          centerTitle: true,
          title: Obx(() => Text(
                _getGameTitle(controller.gameMode.value),
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              )),
          actions: [
            // Restart Button
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              color: Colors.black87,
              onPressed: () =>
                  _showRestartConfirmationDialog(context, controller),
              tooltip: 'Restart Game',
            ),
            // Pause/Resume Button (only when timer is enabled)
            Obx(() {
              if (!controller.timerEnabled.value) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: Icon(
                  controller.isGamePaused.value
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
                ),
                color: Colors.black87,
                onPressed: () {
                  if (controller.isGamePaused.value) {
                    controller.resumeGame();
                  } else {
                    controller.pauseGame();
                  }
                },
                tooltip: controller.isGamePaused.value
                    ? 'Resume Game'
                    : 'Pause Game',
              );
            }),
            // Settings
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              color: Colors.black87,
              onPressed: () {
                controller.soundService.playMenuSelectionSound();
                Get.to(
                  () => const ChessSettingsScreen(),
                  transition: Transition.rightToLeft,
                );
              },
              tooltip: 'Game Settings',
            ),
          ],
        ),
        body: Stack(
          children: [
            // Decorative Background
            Positioned(
              right: -50,
              top: 50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  // Game Info Bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Turn Indicator
                        Obx(() => Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: controller.isWhiteTurn.value
                                        ? Colors.orange.withOpacity(0.1)
                                        : Colors.grey.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.person_rounded,
                                    color: controller.isWhiteTurn.value
                                        ? Colors.orange
                                        : Colors.grey[700],
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Current Turn',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    Text(
                                      controller.isWhiteTurn.value ? "White" : "Black",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                        // Game State
                        Obx(() => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStateColor(controller.gameState.value).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                                _getStateText(controller.gameState.value),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _getStateColor(
                                      controller.gameState.value),
                                  fontSize: 12,
                                ),
                              ),
                        )),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: -0.2),

                  const SizedBox(height: 16),

                  // Timer Display (if enabled)
                  Obx(() {
                    if (!controller.timerEnabled.value) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Black's Timer
                          _buildTimerDisplay(
                            'Black',
                            controller.formatTime(
                                controller.blackTimeRemaining.value),
                            !controller.isWhiteTurn.value,
                          ),
                          // White's Timer
                          _buildTimerDisplay(
                            'White',
                            controller.formatTime(
                                controller.whiteTimeRemaining.value),
                            controller.isWhiteTurn.value,
                          ),
                        ],
                      ),
                    );
                  }),

                  // Main Game Area
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final maxSize = isPortrait
                            ? constraints.maxWidth
                            : constraints.maxHeight * 0.9;
                        final boardSize = maxSize - 32;

                        return SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Captured Pieces - Top (Black's captures)
                                _buildCapturedPiecesBar(controller, isTop: true),

                                const SizedBox(height: 16),

                                // Chess Board
                                Hero(
                                  tag: 'chess_board',
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 20,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: SizedBox(
                                        width: boardSize,
                                        height: boardSize,
                                        child: const ChessBoardWidget(),
                                      ),
                                    ),
                                  ),
                                ).animate().scale(curve: Curves.easeOutBack, duration: 600.ms),

                                const SizedBox(height: 16),

                                // Captured Pieces - Bottom (White's captures)
                                _buildCapturedPiecesBar(controller, isTop: false),

                                // Game Messages
                                Obx(() {
                                  final message = _getGameMessage(
                                    controller.gameState.value,
                                    controller.isWhiteTurn.value,
                                    controller.gameMode.value,
                                  );
                                  if (message.isEmpty) {
                                    return const SizedBox.shrink();
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.only(top: 24),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: _getStateColor(controller.gameState.value).withOpacity(0.2),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _getMessageIcon(
                                                controller.gameState.value),
                                            color: _getStateColor(
                                                controller.gameState.value),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            message,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ).animate().fadeIn().slideY(begin: 0.2);
                                }),
                              ],
                            ),
                          ),
                        );
                      },
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
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.white.withOpacity(0.8), // Modern light overlay
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.all(32),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.pause_circle_outline_rounded, size: 64, color: Colors.indigo),
                        const SizedBox(height: 16),
                        const Text(
                          'Game Paused',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton.icon(
                              onPressed: () {
                                controller.forfeitGame();
                                Get.back();
                              },
                              icon: const Icon(Icons.flag_outlined),
                              label: const Text('Forfeit'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                              ),
                            ),
                            const SizedBox(width: 16),
                            FilledButton.icon(
                              onPressed: controller.resumeGame,
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: const Text('Resume'),
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.indigo,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ).animate().fadeIn();
            }),

            // Countdown Timer Overlay
            Obx(() {
              if (controller.gameState.value == ChessGameState.initial) {
                return CountdownTimer(
                  message: 'Game Starting',
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

  Widget _buildCapturedPiecesBar(ChessGameController controller, {required bool isTop}) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Player indicator
          Icon(
            Icons.person_rounded,
            color: (isTop ? !controller.isWhiteTurn.value : controller.isWhiteTurn.value)
                ? Colors.amber
                : Colors.grey[400],
            size: 20,
          ),
          const SizedBox(width: 12),
          // Captured pieces list
          Expanded(
            child: Obx(() {
              final filteredPieces = controller.capturedPieces.where((piece) {
                // Top Bar (Opponent/Black) -> Displays White pieces captured.
                // Bottom Bar (You/White) -> Displays Black pieces captured.
                return isTop ? piece.contains('white') : piece.contains('black');
              }).toList();

              // Sort by value
               filteredPieces.sort((a, b) {
                  final valueA = _getPieceValue(a);
                  final valueB = _getPieceValue(b);
                  return valueB.compareTo(valueA);
               });

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filteredPieces.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final piece = filteredPieces[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/chess/images/$piece.svg',
                        width: 24,
                        height: 24,
                        colorFilter: ColorFilter.mode(
                          piece.contains('white') ? Colors.grey[400]! : Colors.black87, // Styling choice
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  int _getPieceValue(String piece) {
    if (piece.contains('queen')) return 9;
    if (piece.contains('rook')) return 5;
    if (piece.contains('bishop') || piece.contains('knight')) return 3;
    if (piece.contains('pawn')) return 1;
    return 0;
  }

  String _getGameTitle(ChessGameMode mode) {
    return switch (mode) {
      ChessGameMode.local => 'Two Players',
      ChessGameMode.ai => 'vs Computer',
      ChessGameMode.training => 'Training Mode',
    };
  }

  String _getStateText(ChessGameState state) {
    return switch (state) {
      ChessGameState.initial => 'NEW GAME',
      ChessGameState.inProgress => 'PLAYING',
      ChessGameState.check => 'CHECK!',
      ChessGameState.checkmate => 'CHECKMATE!',
      ChessGameState.stalemate => 'STALEMATE',
      ChessGameState.draw => 'DRAW',
    };
  }

  Color _getStateColor(ChessGameState state) {
    return switch (state) {
      ChessGameState.check => Colors.orange,
      ChessGameState.checkmate => Colors.red,
      ChessGameState.stalemate => Colors.grey,
      ChessGameState.draw => Colors.blue,
      _ => Colors.green,
    };
  }

  IconData _getMessageIcon(ChessGameState state) {
    return switch (state) {
      ChessGameState.check => Icons.warning_rounded,
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
        return isWhiteTurn ? 'Your turn' : 'Computer is thinking...';
      }
      return '${isWhiteTurn ? "White" : "Black"} to move';
    }

    final winner = !isWhiteTurn ? "White" : "Black";
    return switch (state) {
      ChessGameState.check => '${isWhiteTurn ? "White" : "Black"} is in check!',
      ChessGameState.checkmate => '$winner wins by checkmate!',
      ChessGameState.stalemate => 'Game drawn by stalemate',
      ChessGameState.draw => 'Game drawn by agreement',
      _ => '',
    };
  }

  Future<bool> _showExitConfirmationDialog(
    BuildContext context,
    ChessGameController controller,
  ) async {
    if (controller.gameState.value == ChessGameState.initial) {
      return true;
    }

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            title: const Text('Exit Game?'),
            content: const Text(
              'Are you sure you want to exit the game? '
              'Your progress will be lost.',
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('CANCEL'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('EXIT'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildTimerDisplay(String player, String time, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.indigo : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isActive ? Colors.indigo.withOpacity(0.3) : Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            player,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.black87,
              fontFamily: 'Courier', // Monospace for timer
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showRestartConfirmationDialog(
    BuildContext context,
    ChessGameController controller,
  ) async {
    final shouldRestart = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text('Restart Game'),
        content: const Text(
          'Are you sure you want to restart the game? '
          'Current progress will be lost.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
             style: FilledButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
            child: const Text('RESTART'),
          ),
        ],
      ),
    );

    if (shouldRestart == true) {
      controller.startNewGame(controller.gameMode.value);
    }
  }
}
