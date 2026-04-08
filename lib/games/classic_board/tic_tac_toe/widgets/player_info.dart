import 'package:flutter/material.dart';
import 'package:gameverse/theme/app_theme.dart';
import '../models/player.dart';
import '../theme/game_theme.dart';
import 'symbol_painters.dart';

class PlayerInfo extends StatelessWidget {
  final Player player;
  final bool isCurrentPlayer;
  final bool isWinner;
  final int wins;
  final String label;

  const PlayerInfo({
    super.key,
    required this.player,
    required this.isCurrentPlayer,
    required this.isWinner,
    required this.wins,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: isCurrentPlayer
            ? TicTacToeTheme.primaryColor.withValues(alpha: 0.14)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isCurrentPlayer
              ? TicTacToeTheme.primaryColor
              : Colors.white.withValues(alpha: 0.08),
          width: isCurrentPlayer ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 16,
            spreadRadius: -4,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPlayerIcon(),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isCurrentPlayer
                        ? TicTacToeTheme.primaryColor
                        : Colors.white,
                    fontWeight:
                        isCurrentPlayer ? FontWeight.bold : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Wins: $wins',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.82),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (isWinner)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.emoji_events,
                    color: TicTacToeTheme.primaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: const Text(
                      'Winner!',
                      style: TextStyle(
                        color: TicTacToeTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (isCurrentPlayer && !isWinner)
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: TicTacToeTheme.primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: TicTacToeTheme.primaryColor.withValues(alpha: 0.4),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlayerIcon() {
    final color =
        player == Player.x ? TicTacToeTheme.xColor : TicTacToeTheme.oColor;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        width: 24,
        height: 24,
        child: CustomPaint(
          painter: player == Player.x
              ? XSymbolPainter(color: color, isWinning: false)
              : OSymbolPainter(color: color, isWinning: false),
        ),
      ),
    );
  }
}
