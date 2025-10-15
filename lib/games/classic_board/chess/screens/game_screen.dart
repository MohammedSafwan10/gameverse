import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
        appBar: AppBar(
          title: Obx(() => Text(
                _getGameTitle(controller.gameMode.value),
                style: const TextStyle(fontWeight: FontWeight.bold),
              )),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              final shouldPop =
                  await _showExitConfirmationDialog(context, controller);
              if (shouldPop) {
                Get.back();
              }
            },
          ),
          actions: [
            // Restart Button
            IconButton(
              icon: const Icon(Icons.restart_alt),
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
                      ? Icons.play_arrow
                      : Icons.pause,
                ),
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
            // Sound Toggle
            Obx(() => IconButton(
                  icon: Icon(
                    controller.soundService.isSoundEnabled.value
                        ? Icons.volume_up
                        : Icons.volume_off,
                  ),
                  onPressed: controller.soundService.toggleSound,
                  tooltip: 'Toggle Sound',
                )),
            // Settings
            IconButton(
              icon: const Icon(Icons.settings),
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
            // Main Game Content
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primary.withValues(
                      red: theme.colorScheme.primary.r.toDouble(),
                      green: theme.colorScheme.primary.g.toDouble(),
                      blue: theme.colorScheme.primary.b.toDouble(),
                      alpha: 0.1,
                    ),
                    theme.colorScheme.surfaceContainerHighest,
                  ],
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // Game Info Bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              red: 0.0,
                              green: 0.0,
                              blue: 0.0,
                              alpha: 0.1,
                            ),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Turn Indicator
                          Obx(() => Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: controller.isWhiteTurn.value
                                        ? Colors.amber
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Turn: ${controller.isWhiteTurn.value ? "White" : "Black"}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )),
                          // Game State
                          Obx(() => Text(
                                _getStateText(controller.gameState.value),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _getStateColor(
                                      controller.gameState.value),
                                ),
                              )),
                        ],
                      ),
                    ),

                    // Timer Display (if enabled)
                    Obx(() {
                      if (!controller.timerEnabled.value) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Black's Timer
                            _buildTimerDisplay(
                              'Black',
                              controller.formatTime(
                                  controller.blackTimeRemaining.value),
                              !controller.isWhiteTurn.value,
                              theme,
                            ),
                            // White's Timer
                            _buildTimerDisplay(
                              'White',
                              controller.formatTime(
                                  controller.whiteTimeRemaining.value),
                              controller.isWhiteTurn.value,
                              theme,
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
                                  Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Container(
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Row(
                                        children: [
                                          // Player indicator
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                right: BorderSide(
                                                  color: Get
                                                      .theme.colorScheme.outline
                                                      .withValues(
                                                    red: Get.theme.colorScheme
                                                        .outline.r
                                                        .toDouble(),
                                                    green: Get.theme.colorScheme
                                                        .outline.g
                                                        .toDouble(),
                                                    blue: Get.theme.colorScheme
                                                        .outline.b
                                                        .toDouble(),
                                                    alpha: 0.5,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.person,
                                              color:
                                                  controller.isWhiteTurn.value
                                                      ? Colors.amber
                                                      : Colors.grey,
                                              size: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Captured pieces list
                                          Expanded(
                                            child: Obx(() {
                                              // Filter and sort pieces
                                              final filteredPieces = controller
                                                  .capturedPieces
                                                  .where((piece) =>
                                                      (piece.contains(
                                                              'black') &&
                                                          controller.isWhiteTurn
                                                              .value) ||
                                                      (piece.contains(
                                                              'white') &&
                                                          !controller
                                                              .isWhiteTurn
                                                              .value))
                                                  .toList();

                                              // Sort by piece value
                                              filteredPieces.sort((a, b) {
                                                final valueA = switch (a) {
                                                  String p
                                                      when p
                                                          .contains('queen') =>
                                                    9,
                                                  String p
                                                      when p.contains('rook') =>
                                                    5,
                                                  String p
                                                      when p.contains(
                                                              'bishop') ||
                                                          p.contains(
                                                              'knight') =>
                                                    3,
                                                  String p
                                                      when p.contains('pawn') =>
                                                    1,
                                                  _ => 0,
                                                };
                                                final valueB = switch (b) {
                                                  String p
                                                      when p
                                                          .contains('queen') =>
                                                    9,
                                                  String p
                                                      when p.contains('rook') =>
                                                    5,
                                                  String p
                                                      when p.contains(
                                                              'bishop') ||
                                                          p.contains(
                                                              'knight') =>
                                                    3,
                                                  String p
                                                      when p.contains('pawn') =>
                                                    1,
                                                  _ => 0,
                                                };
                                                return valueB.compareTo(
                                                    valueA); // Sort descending
                                              });

                                              return ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount:
                                                    filteredPieces.length,
                                                physics:
                                                    const BouncingScrollPhysics(),
                                                itemBuilder: (context, index) {
                                                  final piece =
                                                      filteredPieces[index];
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 2,
                                                        vertical: 4),
                                                    child: SvgPicture.asset(
                                                      'assets/chess/images/$piece.svg',
                                                      width: 20,
                                                      height: 20,
                                                      colorFilter:
                                                          ColorFilter.mode(
                                                        piece.contains('white')
                                                            ? Colors.white
                                                            : Colors.black,
                                                        BlendMode.srcIn,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Chess Board
                                  Hero(
                                    tag: 'chess_board',
                                    child: Card(
                                      elevation: 8,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                        padding: const EdgeInsets.all(12.0),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: theme.colorScheme.shadow
                                                  .withValues(
                                                red: theme.colorScheme.shadow.r
                                                    .toDouble(),
                                                green: theme
                                                    .colorScheme.shadow.g
                                                    .toDouble(),
                                                blue: theme.colorScheme.shadow.b
                                                    .toDouble(),
                                                alpha: 0.1,
                                              ),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: SizedBox(
                                          width: boardSize,
                                          height: boardSize,
                                          child: const ChessBoardWidget(),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Captured Pieces - Bottom (White's captures)
                                  Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Container(
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Row(
                                        children: [
                                          // Player indicator
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            decoration: BoxDecoration(
                                              border: Border(
                                                right: BorderSide(
                                                  color: Get
                                                      .theme.colorScheme.outline
                                                      .withValues(
                                                    red: Get.theme.colorScheme
                                                        .outline.r
                                                        .toDouble(),
                                                    green: Get.theme.colorScheme
                                                        .outline.g
                                                        .toDouble(),
                                                    blue: Get.theme.colorScheme
                                                        .outline.b
                                                        .toDouble(),
                                                    alpha: 0.5,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.person,
                                              color:
                                                  !controller.isWhiteTurn.value
                                                      ? Colors.amber
                                                      : Colors.grey,
                                              size: 16,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Captured pieces list
                                          Expanded(
                                            child: Obx(() {
                                              // Filter and sort pieces
                                              final filteredPieces = controller
                                                  .capturedPieces
                                                  .where((piece) =>
                                                      (piece.contains(
                                                              'white') &&
                                                          controller.isWhiteTurn
                                                              .value) ||
                                                      (piece.contains(
                                                              'black') &&
                                                          !controller
                                                              .isWhiteTurn
                                                              .value))
                                                  .toList();

                                              // Sort by piece value
                                              filteredPieces.sort((a, b) {
                                                final valueA = switch (a) {
                                                  String p
                                                      when p
                                                          .contains('queen') =>
                                                    9,
                                                  String p
                                                      when p.contains('rook') =>
                                                    5,
                                                  String p
                                                      when p.contains(
                                                              'bishop') ||
                                                          p.contains(
                                                              'knight') =>
                                                    3,
                                                  String p
                                                      when p.contains('pawn') =>
                                                    1,
                                                  _ => 0,
                                                };
                                                final valueB = switch (b) {
                                                  String p
                                                      when p
                                                          .contains('queen') =>
                                                    9,
                                                  String p
                                                      when p.contains('rook') =>
                                                    5,
                                                  String p
                                                      when p.contains(
                                                              'bishop') ||
                                                          p.contains(
                                                              'knight') =>
                                                    3,
                                                  String p
                                                      when p.contains('pawn') =>
                                                    1,
                                                  _ => 0,
                                                };
                                                return valueB.compareTo(
                                                    valueA); // Sort descending
                                              });

                                              return ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount:
                                                    filteredPieces.length,
                                                physics:
                                                    const BouncingScrollPhysics(),
                                                itemBuilder: (context, index) {
                                                  final piece =
                                                      filteredPieces[index];
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 2,
                                                        vertical: 4),
                                                    child: SvgPicture.asset(
                                                      'assets/chess/images/$piece.svg',
                                                      width: 20,
                                                      height: 20,
                                                      colorFilter:
                                                          ColorFilter.mode(
                                                        piece.contains('white')
                                                            ? Colors.white
                                                            : Colors.black,
                                                        BlendMode.srcIn,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            }),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

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
                                      padding: const EdgeInsets.only(top: 16),
                                      child: Card(
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(12),
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
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
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
            ),

            // Pause Overlay
            Obx(() {
              if (!controller.isGamePaused.value) {
                return const SizedBox.shrink();
              }
              return Container(
                width: double.infinity,
                height: double.infinity,
                color: Colors.black.withValues(
                  red: 0.0,
                  green: 0.0,
                  blue: 0.0,
                  alpha: 0.7,
                ),
                child: Center(
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.pause_circle_outline, size: 48),
                          const SizedBox(height: 16),
                          const Text(
                            'Game Paused',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  controller.forfeitGame();
                                  Get.back();
                                },
                                icon: const Icon(Icons.flag),
                                label: const Text('Forfeit'),
                                style: TextButton.styleFrom(
                                  foregroundColor: theme.colorScheme.error,
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                onPressed: controller.resumeGame,
                                icon: const Icon(Icons.play_arrow),
                                label: const Text('Resume'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
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
      ChessGameState.inProgress => 'IN PROGRESS',
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
      ChessGameState.check => Icons.warning,
      ChessGameState.checkmate => Icons.emoji_events,
      ChessGameState.stalemate => Icons.block,
      ChessGameState.draw => Icons.balance,
      _ => Icons.info_outline,
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
            title: const Text('Exit Game?'),
            content: const Text(
              'Are you sure you want to exit the game? '
              'Your progress will be lost.',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: const Text(
                  'EXIT',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  Widget _buildTimerDisplay(
      String player, String time, bool isActive, ThemeData theme) {
    return Card(
      elevation: isActive ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isActive
              ? Border.all(
                  color: theme.colorScheme.primary,
                  width: 2,
                )
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              player,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isActive ? theme.colorScheme.primary : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isActive ? theme.colorScheme.primary : null,
              ),
            ),
          ],
        ),
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
        title: const Text('Restart Game'),
        content: const Text(
          'Are you sure you want to restart the game? '
          'Current progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
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
