import 'package:flutter/material.dart';

class GameHUD extends StatelessWidget {
  final int score;
  final int timeRemaining;
  final int? lives;
  final VoidCallback onPause;
  final Future<bool> Function(BuildContext) onBackPressed;
  final String gameMode;

  const GameHUD({
    super.key,
    required this.score,
    required this.timeRemaining,
    this.lives,
    required this.onPause,
    required this.onBackPressed,
    required this.gameMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => onBackPressed(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),

          // Score, time, and lives
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Score
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.stars, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '$score',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Time (ONLY show in classic mode)
                if (gameMode == 'classic' && timeRemaining > 0)
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.timer, color: Colors.white, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '$timeRemaining',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Lives (show in survival mode)
                if (lives != null && gameMode == 'survival')
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.favorite, color: Colors.red, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '$lives',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Game mode indicator (small icon only)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    _getModeIcon(),
                    color: _getModeColor(),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          // Pause button
          IconButton(
            icon: const Icon(Icons.pause, color: Colors.white),
            onPressed: onPause,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  IconData _getModeIcon() {
    return switch (gameMode) {
      'classic' => Icons.watch_later,
      'survival' => Icons.favorite,
      'challenge' => Icons.emoji_events,
      'practice' => Icons.school,
      _ => Icons.gamepad,
    };
  }

  Color _getModeColor() {
    return switch (gameMode) {
      'classic' => Colors.blue,
      'survival' => Colors.red,
      'challenge' => Colors.amber,
      'practice' => Colors.green,
      _ => Colors.white,
    };
  }
}
