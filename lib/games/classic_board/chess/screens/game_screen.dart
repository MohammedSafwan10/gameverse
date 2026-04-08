import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/game_controller.dart';
import '../widgets/chess_board_widget.dart';
import '../widgets/countdown_timer.dart';
import 'settings_screen.dart';
import 'package:gameverse/theme/app_theme.dart';
import 'package:gameverse/widgets/guarded_exit.dart';

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
          await popAfterConfirmation(
            context,
            confirmExit: () => _showExitConfirmationDialog(context, controller),
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
              confirmExit: () =>
                  _showExitConfirmationDialog(context, controller),
            ),
          ),
          title: Obx(() => FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _getGameTitle(controller.gameMode.value),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: Colors.white,
                  ),
                ),
              )),
          centerTitle: true,
          actions: [
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.restart_alt_rounded,
                    size: 16, color: Colors.white),
              ),
              onPressed: () =>
                  _showRestartConfirmationDialog(context, controller),
              tooltip: 'Restart Game',
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.history_rounded,
                    size: 16, color: Colors.white),
              ),
              onPressed: () => _showMoveHistoryDialog(context, controller),
              tooltip: 'Move History',
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.settings_outlined,
                    size: 16, color: Colors.white),
              ),
              onPressed: () {
                controller.soundService.playMenuSelectionSound();
                Get.to(() => const ChessSettingsScreen(),
                    transition: Transition.rightToLeft);
              },
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: Stack(
          children: [
            // Chess specific animated/gradient background - more vibrant
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0F172A),
                    Color(0xFF1E3A8A), // Brighter blue
                    Color(0xFF0F172A),
                  ],
                ),
              ),
            ),
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF4B860).withValues(alpha: 0.12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF4B860).withValues(alpha: 0.2),
                      blurRadius: 120,
                      spreadRadius: 60,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 100,
              left: -80,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent.withValues(alpha: 0.1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueAccent.withValues(alpha: 0.15),
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
                            horizontal: 12.0, vertical: 8.0),
                        child: Column(
                          children: [
                            _buildCapturedPieces(context, controller, false),
                            // Black's pieces captured by White
                            const SizedBox(height: 12),
                            _buildMainBoard(context, controller),
                            const SizedBox(height: 12),
                            _buildCapturedPieces(context, controller, true),
                            // White's pieces captured by Black
                            const SizedBox(height: 20),
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
          // Player Turn Info
          Obx(() {
            final isWhite = controller.isWhiteTurn.value;

            return Row(
              children: [
                AnimatedContainer(
                  duration: 400.ms,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isWhite
                        ? Colors.white.withValues(alpha: 0.9)
                        : const Color(0xFF0F172A),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isWhite
                          ? const Color(0xFFF4B860).withValues(alpha: 0.4)
                          : Colors.white.withValues(alpha: 0.2),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (isWhite ? const Color(0xFFF4B860) : Colors.white)
                                .withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Icon(
                    Icons.person,
                    size: 20,
                    color: isWhite ? const Color(0xFF0F172A) : Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isWhite ? 'White\'s Turn' : 'Black\'s Turn',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _getStateText(controller.gameState.value),
                      style: TextStyle(
                        color: _getStateColor(controller.gameState.value)
                            .withValues(alpha: 0.9),
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                        letterSpacing: 1,
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
                const SizedBox(width: 10),
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
    final timeStr = seconds ~/ 60 == 0 && seconds < 10
        ? '0:${seconds.toString().padLeft(2, '0')}'
        : '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

    return AnimatedContainer(
      duration: 300.ms,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFF4B860).withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? Colors.white.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                    color: const Color(0xFFF4B860).withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 2))
              ]
            : null,
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: isActive ? const Color(0xFF0F172A) : Colors.white60,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            timeStr,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              fontFamily: 'monospace',
              color: isActive ? const Color(0xFF0F172A) : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapturedPieces(
      BuildContext context, ChessGameController controller, bool forWhite) {
    return Obx(() {
      final pieces = controller.capturedPieces
          .where((p) => forWhite ? p.contains('white') : p.contains('black'))
          .toList();

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
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: AppTheme.glassmorphicDecoration(
          backgroundColor: Colors.white.withValues(alpha: 0.03),
          borderColor: Colors.white.withValues(alpha: 0.08),
          borderRadius: 20,
        ),
        child: Row(
          children: [
            Icon(Icons.outbox_rounded,
                size: 16, color: Colors.white.withValues(alpha: 0.4)),
            const SizedBox(width: 12),
            Expanded(
              child: pieces.isEmpty
                  ? Center(
                      child: Text('NO CAPTURES',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.2),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1)))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemCount: pieces.length,
                      itemBuilder: (context, index) {
                        final isWhitePiece = pieces[index].contains('white');
                        final pieceColor = isWhitePiece
                            ? const Color(0xFFF7F7FA)
                            : const Color(0xFF111111);

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/chess/images/${pieces[index]}.svg',
                              width: 28,
                              height: 28,
                              colorFilter: ColorFilter.mode(
                                isWhitePiece
                                    ? pieceColor
                                    : const Color(0xFF1E293B),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        )
                            .animate()
                            .scale(delay: (index * 50).ms, duration: 300.ms);
                      },
                    ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMainBoard(BuildContext context, ChessGameController controller) {
    // Made board bigger by reducing side margin padding
    final size = MediaQuery.of(context).size.width - 16;

    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF4B860).withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: const ChessBoardWidget(),
      ),
    ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack);
  }

  Widget _buildGameStatusMessage(
      BuildContext context, ChessGameController controller) {
    return Obx(() {
      final message = _getGameMessage(controller.gameState.value,
          controller.isWhiteTurn.value, controller.gameMode.value);
      if (message.isEmpty) return const SizedBox.shrink();

      final statusColor = _getStateColor(controller.gameState.value);

      return Container(
        // Removed double.infinity to make it compact
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: statusColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: statusColor.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: statusColor.withValues(alpha: 0.1),
              blurRadius: 15,
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Compact size
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getMessageIcon(controller.gameState.value),
                color: statusColor, size: 20),
            const SizedBox(width: 12),
            Text(
              message,
              style: TextStyle(
                color: statusColor,
                fontSize: 16, // Slightly smaller font
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ).animate().fadeIn().slideY(begin: 0.3);
    });
  }

  Widget _buildPauseOverlay(
      BuildContext context, ChessGameController controller) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(32),
            decoration: AppTheme.glassmorphicDecoration(
              backgroundColor: Colors.white.withValues(alpha: 0.05),
              borderColor: Colors.white.withValues(alpha: 0.1),
              borderRadius: 32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4B860).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: const Color(0xFFF4B860).withValues(alpha: 0.4),
                        width: 2),
                  ),
                  child: const Icon(Icons.pause_rounded,
                      size: 48, color: Color(0xFFF4B860)),
                ),
                const SizedBox(height: 24),
                const Text('Game Paused',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1)),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          controller.forfeitGame();
                          Navigator.of(context).pop();
                        },
                        child: const Text('FORFEIT',
                            style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: controller.resumeGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF4B860),
                          foregroundColor: const Color(0xFF0F172A),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 8,
                          shadowColor:
                              const Color(0xFFF4B860).withValues(alpha: 0.4),
                        ),
                        child: const Text('RESUME',
                            style: TextStyle(
                                fontWeight: FontWeight.w900, letterSpacing: 1)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  String _getGameTitle(ChessGameMode mode) {
    return switch (mode) {
      ChessGameMode.local => 'Local PVP',
      ChessGameMode.ai => 'vs AI',
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
      ChessGameState.check => Colors.orangeAccent,
      ChessGameState.checkmate => Colors.redAccent,
      ChessGameState.stalemate => Colors.blueGrey.shade300,
      ChessGameState.draw => Colors.blueGrey.shade300,
      _ => Colors.greenAccent,
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
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            title: const Text('Exit Game?',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            content: const Text('Your current progress will be lost.',
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

  Future<void> _showMoveHistoryDialog(
      BuildContext context, ChessGameController controller) async {
    final moves = controller.formattedMovePairs();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Text('Move History',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 320,
          child: moves.isEmpty
              ? const Text('No moves yet.',
                  style: TextStyle(color: Colors.white70))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: moves.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: SelectableText(moves[index],
                        style: const TextStyle(
                            color: Colors.white, fontFamily: 'monospace')),
                  ),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(
                ClipboardData(text: moves.join('\n')),
              );
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Move history copied'),
                    backgroundColor: const Color(0xFFF4B860),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              }
            },
            child: const Text('COPY',
                style: TextStyle(
                    color: Color(0xFFF4B860), fontWeight: FontWeight.bold)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CLOSE', style: TextStyle(color: Colors.white60)),
          ),
        ],
      ),
    );
  }

  Future<void> _showRestartConfirmationDialog(
      BuildContext context, ChessGameController controller) async {
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
        content: const Text('This will reset the current match.',
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
                    color: Color(0xFFF4B860), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (shouldRestart == true) {
      controller.startNewGame(controller.gameMode.value);
    }
  }
}
