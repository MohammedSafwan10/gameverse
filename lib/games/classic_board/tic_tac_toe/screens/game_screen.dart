import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/game_controller.dart';
import '../controllers/stats_controller.dart';
import '../controllers/settings_controller.dart';
import '../models/player.dart';
import '../models/game_mode.dart';
import '../widgets/board_cell.dart';
import '../theme/game_theme.dart';
import '../services/navigation_service.dart';
import '../widgets/player_info.dart';

class TicTacToeGameScreen extends StatefulWidget {
  const TicTacToeGameScreen({super.key});

  @override
  State<TicTacToeGameScreen> createState() => _TicTacToeGameScreenState();
}

class _TicTacToeGameScreenState extends State<TicTacToeGameScreen> {
  final _controller = Get.find<TicTacToeGameController>();
  final _navigationService = Get.find<TicTacToeNavigationService>();

  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _showContent = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _showExitConfirmationDialog();
          if (shouldPop) {
            _navigationService.back();
          }
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: Stack(
          children: [
            // Decorative Background Elements
            Positioned(
              right: -100,
              top: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: TicTacToeTheme.primaryColor.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -50,
              bottom: 100,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: TicTacToeTheme.oColor.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  _buildCustomHeader(theme),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final bool isLandscape =
                            constraints.maxWidth > constraints.maxHeight;
                        final double boardPadding = isLandscape ? 8.0 : 24.0;

                        return Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: boardPadding),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildPlayerStatus(theme)
                                        .animate(target: _showContent ? 1 : 0)
                                        .fadeIn(duration: 600.ms)
                                        .slideY(begin: -0.2, end: 0),

                                    SizedBox(height: isLandscape ? 16.0 : 40.0),

                                    _buildGameBoard(constraints, theme)
                                        .animate(target: _showContent ? 1 : 0)
                                        .fadeIn(duration: 800.ms)
                                        .scale(begin: const Offset(0.9, 0.9)),

                                    SizedBox(height: isLandscape ? 16.0 : 40.0),

                                    _buildGameStatus(theme)
                                        .animate(target: _showContent ? 1 : 0)
                                        .fadeIn(duration: 600.ms)
                                        .slideY(begin: 0.2, end: 0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomHeader(ThemeData theme) {
    final onSurface = theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: onSurface,
            onPressed: () async {
              final shouldPop = await _showExitConfirmationDialog();
              if (shouldPop) {
                _navigationService.back();
              }
            },
          ),
          Text(
            'Tic Tac Toe',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: onSurface,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                color: onSurface,
                onPressed: () => _showRestartConfirmationDialog(),
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                color: onSurface,
                onPressed: _navigationService.toSettings,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerStatus(ThemeData theme) {
    return Obx(() {
      final gameState = _controller.gameState;
      final isThinking = _controller.isThinking;
      final stats = Get.find<TicTacToeStatsController>();
      final settings = Get.find<TicTacToeSettingsController>();
      final isMultiplayer = settings.settings.gameMode == GameMode.multiPlayer;
      final colorScheme = theme.colorScheme;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: PlayerInfo(
                player: Player.x,
                isCurrentPlayer:
                    gameState.currentPlayer == Player.x && !isThinking,
                isWinner: gameState.winner == Player.x,
                wins: isMultiplayer
                    ? stats.player1Wins
                    : stats.getWinsForDifficulty(settings.settings.difficulty),
                label: isMultiplayer ? 'Player X' : 'You',
              ),
            ),
            Container(
              height: 40,
              width: 1,
              color: colorScheme.onSurface.withValues(alpha: 0.1),
              margin: const EdgeInsets.symmetric(horizontal: 16),
            ),
            Expanded(
              child: PlayerInfo(
                player: Player.o,
                isCurrentPlayer: gameState.currentPlayer == Player.o &&
                    (isMultiplayer || isThinking),
                isWinner: gameState.winner == Player.o,
                wins: isMultiplayer
                    ? stats.player2Wins
                    : stats
                        .getLossesForDifficulty(settings.settings.difficulty),
                label: isMultiplayer ? 'Player O' : 'AI',
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildGameBoard(BoxConstraints constraints, ThemeData theme) {
    final double maxSize = constraints.maxWidth > constraints.maxHeight
        ? constraints.maxHeight * 0.7
        : constraints.maxWidth * 0.9;

    return Center(
      child: SizedBox(
        width: maxSize,
        height: maxSize,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: TicTacToeTheme.primaryColor.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Obx(() {
            final gameState = _controller.gameState;
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 9,
              itemBuilder: (context, index) {
                return BoardCell(
                  player: gameState.board[index],
                  isWinningCell: gameState.winningLine.contains(index),
                  isHighlighted: gameState.lastMove?.position == index,
                  isEnabled: gameState.board[index] == Player.none &&
                      !gameState.isGameOver,
                  onTap: () {
                    _controller.makeMove(index);
                  },
                );
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _buildGameStatus(ThemeData theme) {
    return Obx(() {
      final gameState = _controller.gameState;
      final isThinking = _controller.isThinking;
      final isGameOver = _controller.isGameOver;
      final settings = Get.find<TicTacToeSettingsController>();
      final isMultiplayer = settings.settings.gameMode == GameMode.multiPlayer;
      final onSurface = theme.colorScheme.onSurface;

      if (isGameOver) {
        final winner = gameState.winner;
        String message;
        Color messageColor;

        if (winner == null) {
          message = 'It\'s a Draw!';
          messageColor = Colors.orange;
        } else if (winner == Player.x) {
          message = isMultiplayer ? 'Player X Wins!' : 'You Win!';
          messageColor = TicTacToeTheme.xColor;
        } else {
          message = isMultiplayer ? 'Player O Wins!' : 'AI Wins!';
          messageColor = TicTacToeTheme.oColor;
        }

        return Column(
          children: [
            Text(
              message,
              style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: messageColor,
                  ),
            ).animate().scale(curve: Curves.elasticOut),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _controller.resetGame(),
              icon: const Icon(Icons.replay_rounded),
              label: const Text('Play Again'),
              style: FilledButton.styleFrom(
                backgroundColor: TicTacToeTheme.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
            ).animate().fadeIn(delay: 300.ms),
          ],
        );
      }

      if (isThinking) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: TicTacToeTheme.primaryColor,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'AI is thinking...',
              style: TextStyle(
                color: onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      }

      final currentPlayer = gameState.currentPlayer;
      String turnMessage;

      if (isMultiplayer) {
        turnMessage =
            currentPlayer == Player.x ? 'Player X Turn' : 'Player O Turn';
      } else {
        turnMessage = currentPlayer == Player.x ? 'Your Turn' : 'AI Turn';
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: (currentPlayer == Player.x
                  ? TicTacToeTheme.xColor
                  : TicTacToeTheme.oColor)
                .withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          turnMessage,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: currentPlayer == Player.x
                ? TicTacToeTheme.xColor
                : TicTacToeTheme.oColor,
            fontSize: 16,
          ),
        ),
      );
    });
  }

  Future<bool> _showExitConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit Game?'),
            content: const Text('Are you sure you want to exit the game?'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: TicTacToeTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _showRestartConfirmationDialog() async {
    final shouldRestart = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restart Game?'),
        content: const Text('Are you sure you want to restart the game?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: TicTacToeTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (shouldRestart == true) {
      _controller.resetGame();
    }
  }
}
