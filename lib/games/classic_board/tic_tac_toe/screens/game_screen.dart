import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gameverse/theme/app_theme.dart';
import 'package:gameverse/widgets/premium_background.dart';
import '../controllers/game_controller.dart';
import '../controllers/stats_controller.dart';
import '../controllers/settings_controller.dart';
import '../models/player.dart';
import '../models/game_mode.dart';
import '../widgets/board_cell.dart';
import '../theme/game_theme.dart';
import '../services/navigation_service.dart';
import '../widgets/player_info.dart';
import 'package:gameverse/widgets/guarded_exit.dart';

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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await popAfterConfirmation(
            context,
            confirmExit: _showExitConfirmationDialog,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const PremiumBackground(),
            Positioned.fill(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          const Color(0xFF101B2E),
                          const Color(0xFF0B1220),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: -100,
                    right: -80,
                    child: Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            TicTacToeTheme.primaryColor.withValues(alpha: 0.16),
                            TicTacToeTheme.primaryColor.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -110,
                    left: -90,
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.accentColor.withValues(alpha: 0.12),
                            AppTheme.accentColor.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
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

                        return Padding(
                          padding: EdgeInsets.fromLTRB(
                            isLandscape ? 18 : 20,
                            8,
                            isLandscape ? 18 : 20,
                            20,
                          ),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight - 12,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildPlayerStatus(theme)
                                      .animate(target: _showContent ? 1 : 0)
                                      .fadeIn(duration: const Duration(milliseconds: 600))
                                      .slideY(begin: -0.18, end: 0),
                                  SizedBox(height: isLandscape ? 18 : 26),
                                  _buildBoardShell(constraints, theme)
                                      .animate(target: _showContent ? 1 : 0)
                                      .fadeIn(duration: const Duration(milliseconds: 800))
                                      .scale(begin: const Offset(0.94, 0.94)),
                                  SizedBox(height: isLandscape ? 18 : 26),
                                  _buildGameStatus(theme)
                                      .animate(target: _showContent ? 1 : 0)
                                      .fadeIn(duration: const Duration(milliseconds: 600))
                                      .slideY(begin: 0.16, end: 0),
                                ],
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
            _buildGameOverOverlay(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay(ThemeData theme) {
    return Obx(() {
      final gameState = _controller.gameState;
      final isGameOver = _controller.isGameOver;
      final settings = Get.find<TicTacToeSettingsController>();
      final isMultiplayer = settings.settings.gameMode == GameMode.multiPlayer;

      if (!isGameOver) return const SizedBox.shrink();

      final winner = gameState.winner;
      String message;
      String subMessage;
      Color messageColor;

      if (winner == null) {
        message = 'Drawn Round';
        subMessage = 'A perfect balance of skill. Shake hands and go again!';
        messageColor = Colors.orangeAccent;
      } else if (winner == Player.x) {
        message = isMultiplayer ? 'Player X Wins!' : 'Victory!';
        subMessage = 'Superior strategy! Your dominance continues.';
        messageColor = TicTacToeTheme.xColor;
      } else {
        message = isMultiplayer ? 'Player O Wins!' : 'Defeat';
        subMessage = 'The AI outsmarted you this time. Rise again!';
        messageColor = TicTacToeTheme.oColor;
      }

      return Container(
        color: Colors.black.withValues(alpha: 0.85),
        child: Align(
          alignment: const Alignment(0, -0.15),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(44),
              border: Border.all(
                color: messageColor.withValues(alpha: 0.35),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: messageColor.withValues(alpha: 0.12),
                  blurRadius: 50,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Icon
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: messageColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: messageColor.withValues(alpha: 0.25),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    winner == null
                        ? Icons.handshake_rounded
                        : (winner == Player.x
                            ? Icons.emoji_events_rounded
                            : (isMultiplayer
                                ? Icons.emoji_events_rounded
                                : Icons.psychology_rounded)),
                    size: 60,
                    color: messageColor,
                  ).animate(onPlay: (c) => c.repeat(reverse: true))
                   .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 800.ms, curve: Curves.easeInOut),
                ),
                const SizedBox(height: 24),
                
                // Winner Message
                Text(
                  message.toUpperCase(),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: messageColor,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2),
                
                const SizedBox(height: 10),
                
                // Submessage
                Text(
                  subMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
                
                const SizedBox(height: 36),

                // Action area
                if (settings.settings.autoRestart) ...[
                  // Circular Countdown
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: _controller.countdown.value / 3,
                          strokeWidth: 6,
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          valueColor: AlwaysStoppedAnimation<Color>(messageColor),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Obx(() => Text(
                        '${_controller.countdown.value}',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ).animate(key: ValueKey(_controller.countdown.value))
                       .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: 300.ms, curve: Curves.easeOutBack)
                       .fadeIn()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Restarting shortly...',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                ] else ...[
                  // Play Again Button
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: TicTacToeTheme.primaryColor.withValues(alpha: 0.25),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => _controller.resetGame(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TicTacToeTheme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.replay_rounded),
                            SizedBox(width: 12),
                            Text(
                              'PLAY AGAIN',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                ],
                
                const SizedBox(height: 24),
                
                // Quit Button
                TextButton(
                  onPressed: () => _controller.navigateBack(),
                  child: Text(
                    'BACK TO MENU',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.3),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().scale(curve: Curves.easeOutBack, duration: 600.ms).fadeIn(),
        ),
      ).animate().fadeIn();
    });
  }

  Widget _buildBoardShell(BoxConstraints constraints, ThemeData theme) {
    final double maxSize = constraints.maxWidth > constraints.maxHeight
        ? constraints.maxHeight * 0.72
        : constraints.maxWidth * 0.9;

    return Container(
      width: maxSize,
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.glassmorphicDecoration(
        backgroundColor: Colors.white,
        borderColor: Colors.white,
        borderRadius: 34,
      ).copyWith(
        boxShadow: [
          BoxShadow(
            color: TicTacToeTheme.primaryColor.withValues(alpha: 0.08),
            blurRadius: 40,
            spreadRadius: 10,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildMetricChip(
                icon: Icons.auto_graph_rounded,
                label: 'Match',
                value: _controller.gameState.settings.gameMode == GameMode.multiPlayer
                    ? 'Local'
                    : _controller.gameState.settings.difficulty.displayName,
              ),
              const Spacer(),
              _buildMetricChip(
                icon: Icons.grid_view_rounded,
                label: 'Board',
                value: '3 x 3',
              ),
            ],
          ),
          const SizedBox(height: 18),
          _buildGameBoard(constraints, theme),
        ],
      ),
    );
  }

  Widget _buildMetricChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 0.4,
                  color: Colors.white60,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: Colors.white,
              onPressed: () async {
                final shouldPop = await _showExitConfirmationDialog();
                if (shouldPop) {
                  _navigationService.back();
                }
              },
            ),
          ),
          Column(
            children: [
              Text(
                'Tic Tac Toe',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                'Classic Board',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Obx(() => _headerIconButton(
                    icon: Icons.auto_mode_rounded,
                    onTap: _controller.toggleAutoRestart,
                    isActive: _controller.gameState.settings.autoRestart,
                    tooltip: 'Auto Restart: ${_controller.gameState.settings.autoRestart ? 'ON' : 'OFF'}',
                    showLabel: true,
                  )),
              const SizedBox(width: 8),
              _headerIconButton(
                icon: Icons.refresh_rounded,
                onTap: _showRestartConfirmationDialog,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
    String? tooltip,
    bool showLabel = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isActive
                ? TicTacToeTheme.primaryColor.withValues(alpha: 0.25)
                : Colors.white.withValues(alpha: 0.14),
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive
                  ? TicTacToeTheme.primaryColor.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.16),
              width: isActive ? 2 : 1,
            ),
            boxShadow: isActive ? [
              BoxShadow(
                color: TicTacToeTheme.primaryColor.withValues(alpha: 0.2),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ] : null,
          ),
          child: Tooltip(
            message: tooltip ?? '',
            child: IconButton(
              icon: Icon(icon, size: 20),
              color: isActive ? TicTacToeTheme.primaryColor : Colors.white,
              onPressed: onTap,
            ),
          ),
        ),
        if (showLabel) ...[
          const SizedBox(height: 4),
          Text(
            'AUTO',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w900,
              color: isActive ? TicTacToeTheme.primaryColor : Colors.white38,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPlayerStatus(ThemeData theme) {
    return Obx(() {
      final gameState = _controller.gameState;
      final isThinking = _controller.isThinking;
      final stats = Get.find<TicTacToeStatsController>();
      final settings = Get.find<TicTacToeSettingsController>();
      final isMultiplayer = settings.settings.gameMode == GameMode.multiPlayer;

      return Container(
        padding: const EdgeInsets.all(14),
        decoration: AppTheme.glassmorphicDecoration(
          backgroundColor: Colors.white,
          borderColor: Colors.white,
          borderRadius: 28,
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                'VS',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w800,
                ),
              ),
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
        ? constraints.maxHeight * 0.58
        : constraints.maxWidth * 0.72;

    return Center(
      child: SizedBox(
        width: maxSize,
        height: maxSize,
        child: Obx(() {
          final gameState = _controller.gameState;
          return GridView.builder(
            padding: EdgeInsets.zero,
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
    );
  }

  Widget _buildGameStatus(ThemeData theme) {
    return Obx(() {
      final gameState = _controller.gameState;
      final isThinking = _controller.isThinking;
      final isGameOver = _controller.isGameOver;
      final settings = Get.find<TicTacToeSettingsController>();
      final isMultiplayer = settings.settings.gameMode == GameMode.multiPlayer;
      if (isGameOver) {
        return const SizedBox.shrink();
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
                color: Colors.white.withValues(alpha: 0.72),
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
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: AppTheme.glassmorphicDecoration(
          backgroundColor: Colors.white,
          borderColor: Colors.white,
          borderRadius: 24,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: currentPlayer == Player.x
                    ? TicTacToeTheme.xColor
                    : TicTacToeTheme.oColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (currentPlayer == Player.x
                            ? TicTacToeTheme.xColor
                            : TicTacToeTheme.oColor)
                        .withValues(alpha: 0.5),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              turnMessage,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<bool> _showExitConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF111827),
            surfaceTintColor: Colors.transparent,
            title: const Text('Exit Game?', style: TextStyle(color: Colors.white)),
            content: Text(
              'Are you sure you want to exit the current match?',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.72)),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
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
                    borderRadius: BorderRadius.circular(14),
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
        backgroundColor: const Color(0xFF111827),
        surfaceTintColor: Colors.transparent,
        title: const Text('Restart Game?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to restart the game?',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.72)),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
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
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Restart'),
          ),
        ],
      ),
    );

    if (shouldRestart == true) {
      _controller.resetGame();
    }
  }
}
