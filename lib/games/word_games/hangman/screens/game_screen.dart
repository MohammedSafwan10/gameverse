import 'package:flutter/material.dart';
import 'dart:async';
import '../models/game_state.dart';
import '../services/word_service.dart';

class HangmanGameScreen extends StatefulWidget {
  final HangmanGameState initialState;

  const HangmanGameScreen({
    super.key,
    required this.initialState,
  });

  @override
  State<HangmanGameScreen> createState() => _HangmanGameScreenState();
}

class _HangmanGameScreenState extends State<HangmanGameScreen> {
  late HangmanGameState gameState;
  final Set<String> _guessedLetters = {};
  Timer? _timer;
  String _timeDisplay = '0s';

  @override
  void initState() {
    super.initState();
    gameState = widget.initialState;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && !gameState.isGameOver) {
        setState(() {
          final duration = DateTime.now().difference(gameState.startTime);
          if (duration.inHours > 0) {
            _timeDisplay = '${duration.inHours}h ${duration.inMinutes % 60}m';
          } else if (duration.inMinutes > 0) {
            _timeDisplay = '${duration.inMinutes}m ${duration.inSeconds % 60}s';
          } else {
            _timeDisplay = '${duration.inSeconds}s';
          }
        });
      }
    });
  }

  void _onLetterPressed(String letter) {
    if (gameState.isGameOver) return;

    setState(() {
      _guessedLetters.add(letter.toLowerCase());

      // Update game state
      final newLives =
          gameState.word.toLowerCase().contains(letter.toLowerCase())
              ? gameState.remainingLives
              : gameState.remainingLives - 1;

      gameState = gameState.copyWith(
        guessedLetters: _guessedLetters,
        remainingLives: newLives,
        status: _determineGameStatus(newLives),
      );

      if (gameState.isGameOver) {
        _showGameOverDialog();
      }
    });
  }

  void _useHint() {
    if (gameState.hintsRemaining <= 0 || gameState.isGameOver) return;

    final hint = WordService.getRandomHint(gameState);
    if (hint.isEmpty) return;

    setState(() {
      gameState = gameState.copyWith(
        hintsRemaining: gameState.hintsRemaining - 1,
      );
      _onLetterPressed(hint);
    });
  }

  HangmanGameStatus _determineGameStatus(int lives) {
    if (gameState.isWordGuessed) return HangmanGameStatus.won;
    if (lives <= 0) return HangmanGameStatus.lost;
    return HangmanGameStatus.playing;
  }

  void _showGameOverDialog() {
    final score = WordService.calculateScore(gameState);
    final title = gameState.status == HangmanGameStatus.won
        ? 'Congratulations!'
        : 'Game Over';
    final message = gameState.status == HangmanGameStatus.won
        ? 'You won! Score: $score'
        : 'The word was: ${gameState.word}';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            if (gameState.status == HangmanGameStatus.won) ...[
              const SizedBox(height: 8),
              Text(
                'Time: ${DateTime.now().difference(gameState.startTime).inSeconds}s\n'
                'Lives: ${gameState.remainingLives}\n'
                'Hints: ${3 - gameState.hintsRemaining} used',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Return to previous screen
            },
            child: const Text('Back'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              // Reset game with new word
              if (gameState.mode == HangmanGameMode.singlePlayer) {
                setState(() {
                  gameState = gameState.copyWith(
                    word: WordService.getRandomWord(gameState.category),
                    guessedLetters: {},
                    remainingLives: 6,
                    hintsRemaining: 3,
                    status: HangmanGameStatus.playing,
                    startTime: DateTime.now(),
                  );
                  _guessedLetters.clear();
                });
              } else {
                Navigator.of(context).pop(); // Return to previous screen
              }
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gameState.category.displayName),
        centerTitle: true,
        actions: [
          if (gameState.hintsRemaining > 0 && !gameState.isGameOver)
            Tooltip(
              message: 'Use Hint (${gameState.hintsRemaining} left)',
              child: IconButton(
                icon: const Icon(Icons.help_outline),
                onPressed: _useHint,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoChip(
                  Icons.favorite,
                  '${gameState.remainingLives}',
                  Colors.red,
                ),
                if (gameState.mode == HangmanGameMode.singlePlayer)
                  _buildInfoChip(
                    Icons.score,
                    '${WordService.calculateScore(gameState)}',
                    Colors.amber,
                  ),
                _buildInfoChip(
                  Icons.timer,
                  _timeDisplay,
                  Colors.blue,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: _buildHangmanDrawing(),
          ),
          Expanded(
            flex: 1,
            child: _buildWordDisplay(),
          ),
          Expanded(
            flex: 2,
            child: _buildKeyboard(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(
          red: color.r.toDouble(),
          green: color.g.toDouble(),
          blue: color.b.toDouble(),
          alpha: 0.1 * 255,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(
            red: color.r.toDouble(),
            green: color.g.toDouble(),
            blue: color.b.toDouble(),
            alpha: 0.3 * 255,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHangmanDrawing() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10),
      ),
      child: CustomPaint(
        painter: HangmanPainter(
          incorrectGuesses: gameState.incorrectGuesses,
        ),
      ),
    );
  }

  Widget _buildWordDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: gameState.maskedWord.map((letter) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 28,
              child: Text(
                letter,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildKeyboard() {
    const letters = [
      ['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'],
      ['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L'],
      ['Z', 'X', 'C', 'V', 'B', 'N', 'M'],
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: letters.map((row) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((letter) {
                final isGuessed =
                    _guessedLetters.contains(letter.toLowerCase());
                final isCorrect = gameState.word.toUpperCase().contains(letter);
                return Padding(
                  padding: const EdgeInsets.all(2),
                  child: SizedBox(
                    width: 32,
                    height: 42,
                    child: ElevatedButton(
                      onPressed:
                          isGuessed ? null : () => _onLetterPressed(letter),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: isGuessed
                            ? (isCorrect ? Colors.green[100] : Colors.red[100])
                            : Theme.of(context).colorScheme.primary.withValues(
                                  red: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .r
                                      .toDouble(),
                                  green: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .g
                                      .toDouble(),
                                  blue: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .b
                                      .toDouble(),
                                  alpha: 0.1 * 255,
                                ),
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        letter,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isGuessed
                              ? (isCorrect
                                  ? Colors.green[900]
                                  : Colors.red[900])
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class HangmanPainter extends CustomPainter {
  final int incorrectGuesses;

  HangmanPainter({required this.incorrectGuesses});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final headRadius = size.width * 0.12;
    final centerX = size.width * 0.7;

    // Base
    if (incorrectGuesses >= 1) {
      canvas.drawLine(
        Offset(size.width * 0.1, size.height * 0.9),
        Offset(size.width * 0.9, size.height * 0.9),
        paint,
      );
    }

    // Vertical pole
    if (incorrectGuesses >= 2) {
      canvas.drawLine(
        Offset(size.width * 0.3, size.height * 0.9),
        Offset(size.width * 0.3, size.height * 0.1),
        paint,
      );
    }

    // Horizontal beam
    if (incorrectGuesses >= 3) {
      canvas.drawLine(
        Offset(size.width * 0.3, size.height * 0.1),
        Offset(centerX, size.height * 0.1),
        paint,
      );
    }

    // Rope
    if (incorrectGuesses >= 4) {
      final ropePaint = Paint()
        ..color = Colors.brown
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(centerX, size.height * 0.1);
      for (var i = 0; i < 3; i++) {
        path.relativeLineTo(2, 15);
        path.relativeLineTo(-4, 15);
      }
      canvas.drawPath(path, ropePaint);
    }

    // Head
    if (incorrectGuesses >= 5) {
      // Head outline
      canvas.drawCircle(
        Offset(centerX, size.height * 0.3),
        headRadius,
        paint,
      );

      // Simple face features if space allows
      if (headRadius > 15) {
        final facePaint = Paint()
          ..color = Colors.black87
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

        // Eyes
        canvas.drawCircle(
          Offset(centerX - headRadius * 0.3, size.height * 0.28),
          2,
          facePaint,
        );
        canvas.drawCircle(
          Offset(centerX + headRadius * 0.3, size.height * 0.28),
          2,
          facePaint,
        );

        // Sad mouth
        final mouthPath = Path();
        mouthPath.moveTo(centerX - headRadius * 0.3, size.height * 0.33);
        mouthPath.quadraticBezierTo(
          centerX,
          size.height * 0.36,
          centerX + headRadius * 0.3,
          size.height * 0.33,
        );
        canvas.drawPath(mouthPath, facePaint);
      }
    }

    // Body and limbs
    if (incorrectGuesses >= 6) {
      // Body
      canvas.drawLine(
        Offset(centerX, size.height * 0.42),
        Offset(centerX, size.height * 0.65),
        paint,
      );

      // Arms with slight curve
      final armPath = Path();
      // Left arm
      armPath.moveTo(centerX, size.height * 0.45);
      armPath.quadraticBezierTo(
        centerX - size.width * 0.1,
        size.height * 0.5,
        centerX - size.width * 0.15,
        size.height * 0.55,
      );
      // Right arm
      armPath.moveTo(centerX, size.height * 0.45);
      armPath.quadraticBezierTo(
        centerX + size.width * 0.1,
        size.height * 0.5,
        centerX + size.width * 0.15,
        size.height * 0.55,
      );
      canvas.drawPath(armPath, paint);

      // Legs with slight curve
      final legPath = Path();
      // Left leg
      legPath.moveTo(centerX, size.height * 0.65);
      legPath.quadraticBezierTo(
        centerX - size.width * 0.1,
        size.height * 0.75,
        centerX - size.width * 0.15,
        size.height * 0.8,
      );
      // Right leg
      legPath.moveTo(centerX, size.height * 0.65);
      legPath.quadraticBezierTo(
        centerX + size.width * 0.1,
        size.height * 0.75,
        centerX + size.width * 0.15,
        size.height * 0.8,
      );
      canvas.drawPath(legPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
