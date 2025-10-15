import 'package:flutter/material.dart';
import '../models/player.dart';
import '../theme/game_theme.dart';

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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: isCurrentPlayer
            ? TicTacToeTheme.primaryColor.withValues(
                red: TicTacToeTheme.primaryColor.r.toDouble(),
                green: TicTacToeTheme.primaryColor.g.toDouble(),
                blue: TicTacToeTheme.primaryColor.b.toDouble(),
                alpha: 0.1,
              )
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentPlayer
              ? TicTacToeTheme.primaryColor
              : Colors.black.withValues(
                  red: 0,
                  green: 0,
                  blue: 0,
                  alpha: 0.1,
                ),
          width: isCurrentPlayer ? 2 : 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: isCurrentPlayer
                            ? TicTacToeTheme.primaryColor
                            : Colors.black87,
                        fontWeight: isCurrentPlayer
                            ? FontWeight.bold
                            : FontWeight.normal,
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
              color: Colors.grey.withValues(
                red: Colors.grey.r.toDouble(),
                green: Colors.grey.g.toDouble(),
                blue: Colors.grey.b.toDouble(),
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Wins: $wins',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          if (isWinner)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: TicTacToeTheme.primaryColor.withValues(
                  red: TicTacToeTheme.primaryColor.r.toDouble(),
                  green: TicTacToeTheme.primaryColor.g.toDouble(),
                  blue: TicTacToeTheme.primaryColor.b.toDouble(),
                  alpha: 0.2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: TicTacToeTheme.primaryColor,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Winner!',
                    style: TextStyle(
                      color: TicTacToeTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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
                    color: TicTacToeTheme.primaryColor.withValues(
                      red: TicTacToeTheme.primaryColor.r.toDouble(),
                      green: TicTacToeTheme.primaryColor.g.toDouble(),
                      blue: TicTacToeTheme.primaryColor.b.toDouble(),
                      alpha: 0.4,
                    ),
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
    final icon = player == Player.x ? Icons.close : Icons.circle_outlined;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(
          red: color.r.toDouble(),
          green: color.g.toDouble(),
          blue: color.b.toDouble(),
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }
}
