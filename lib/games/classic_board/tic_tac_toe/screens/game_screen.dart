import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../controllers/game_controller.dart';
import '../controllers/stats_controller.dart';
import '../controllers/settings_controller.dart';
import '../models/player.dart';
import '../models/game_mode.dart';
import '../utils/animations.dart';
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
  final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 50,
      colors: true,
      printEmojis: true,
    ),
  );

  static const _boardShadow = [
    BoxShadow(
      color: Color(0x1A2D3436),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    _logger.i('Game screen initialized');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _showContent = true;
        _logger.d('Game board visibility enabled');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
        backgroundColor: TicTacToeTheme.backgroundColor,
        appBar: AppBar(
          title: const Text('Tic Tac Toe'),
          backgroundColor: TicTacToeTheme.primaryColor,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _navigationService.back,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => _showRestartConfirmationDialog(),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _navigationService.toSettings,
            ),
            IconButton(
              icon: const Icon(Icons.bar_chart),
              onPressed: _navigationService.toStats,
            ),
          ],
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Responsive layout based on available height
              final bool isLandscape =
                  constraints.maxWidth > constraints.maxHeight;
              final double boardPadding = isLandscape ? 8.0 : 16.0;

              return Padding(
                padding: EdgeInsets.all(boardPadding),
                child: Column(
                  children: [
                    // Player status with score
                    TicTacToeAnimations.fadeSlide(
                      show: _showContent,
                      offset: const Offset(0, -0.2),
                      child: _buildPlayerStatus(),
                    ),

                    SizedBox(height: isLandscape ? 16.0 : 24.0),

                    // Main game board - takes most of the space
                    Expanded(
                      child: TicTacToeAnimations.fadeSlide(
                        show: _showContent,
                        child: _buildGameBoard(constraints),
                      ),
                    ),

                    SizedBox(height: isLandscape ? 16.0 : 24.0),

                    // Game status (whose turn, AI thinking, game result)
                    TicTacToeAnimations.fadeSlide(
                      show: _showContent,
                      offset: const Offset(0, 0.2),
                      child: _buildGameStatus(),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerStatus() {
    return Obx(() {
      final gameState = _controller.gameState;
      final isThinking = _controller.isThinking;
      final stats = Get.find<TicTacToeStatsController>();
      final settings = Get.find<TicTacToeSettingsController>();
      final isMultiplayer = settings.settings.gameMode == GameMode.multiPlayer;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: PlayerInfo(
                player: Player.x,
                isCurrentPlayer:
                    gameState.currentPlayer == Player.x && !isThinking,
                isWinner: gameState.winner == Player.x,
                wins: isMultiplayer ? stats.player1Wins : stats.playerWins,
                label: isMultiplayer ? 'Player X' : 'You',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: PlayerInfo(
                player: Player.o,
                isCurrentPlayer: gameState.currentPlayer == Player.o &&
                    (isMultiplayer || isThinking),
                isWinner: gameState.winner == Player.o,
                wins: isMultiplayer ? stats.player2Wins : stats.aiWins,
                label: isMultiplayer ? 'Player O' : 'AI',
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildGameBoard(BoxConstraints constraints) {
    _logger.d('Building game board');

    // Calculate the maximum size for the board while keeping it square
    final double maxSize = constraints.maxWidth > constraints.maxHeight
        ? constraints.maxHeight * 0.85
        : constraints.maxWidth;

    return Center(
      child: SizedBox(
        width: maxSize,
        height: maxSize,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: TicTacToeTheme.gridColor.withValues(
                red: TicTacToeTheme.gridColor.r.toDouble(),
                green: TicTacToeTheme.gridColor.g.toDouble(),
                blue: TicTacToeTheme.gridColor.b.toDouble(),
                alpha: 0.1,
              ),
              width: 2,
            ),
            boxShadow: _boardShadow,
          ),
          child: Obx(() {
            final gameState = _controller.gameState;
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 9,
              itemBuilder: (context, index) {
                _logger.t('Building cell at index: $index');
                return BoardCell(
                  player: gameState.board[index],
                  isWinningCell: gameState.winningLine.contains(index),
                  isHighlighted: gameState.lastMove?.position == index,
                  isEnabled: gameState.board[index] == Player.none &&
                      !gameState.isGameOver,
                  onTap: () {
                    _logger.i('Cell tapped at index: $index');
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

  Widget _buildGameStatus() {
    return Obx(() {
      final gameState = _controller.gameState;
      final isThinking = _controller.isThinking;
      final isGameOver = _controller.isGameOver;
      final settings = Get.find<TicTacToeSettingsController>();
      final isMultiplayer = settings.settings.gameMode == GameMode.multiPlayer;

      _logger.d('Game status - thinking: $isThinking, gameOver: $isGameOver');

      if (isGameOver) {
        final winner = gameState.winner;
        String message;
        Color messageColor;

        if (winner == null) {
          message = 'Draw!';
          messageColor = Colors.orange;
        } else if (winner == Player.x) {
          message = isMultiplayer ? 'Player X Won!' : 'You Won!';
          messageColor = Colors.green;
        } else {
          message = isMultiplayer ? 'Player O Won!' : 'AI Won!';
          messageColor = Colors.red;
        }

        _logger.i('Game over: $message');

        return Column(
          children: [
            Text(
              message,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: messageColor,
                  ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => _controller.resetGame(),
              style: FilledButton.styleFrom(
                backgroundColor: TicTacToeTheme.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Play Again'),
            ),
          ],
        );
      }

      if (isThinking) {
        return Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'AI is thinking...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: TicTacToeTheme.primaryColor,
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

      return Text(
        turnMessage,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: TicTacToeTheme.primaryColor,
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
              borderRadius: BorderRadius.circular(16),
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
          borderRadius: BorderRadius.circular(16),
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
