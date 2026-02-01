import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    final isWin = gameState.status == HangmanGameStatus.won;
    final title = isWin ? 'Congratulations!' : 'Game Over';
    final message = isWin
        ? 'You won! Score: $score'
        : 'The word was: ${gameState.word}';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(title, style: TextStyle(color: isWin ? Colors.green : Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, style: const TextStyle(fontSize: 18)),
            if (isWin) ...[
              const SizedBox(height: 16),
              Text(
                'Time: ${DateTime.now().difference(gameState.startTime).inSeconds}s\n'
                'Lives: ${gameState.remainingLives}\n'
                'Hints: ${3 - gameState.hintsRemaining} used',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
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
          FilledButton(
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
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: Text(
            gameState.category.displayName,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (gameState.hintsRemaining > 0 && !gameState.isGameOver)
            Tooltip(
              message: 'Use Hint (${gameState.hintsRemaining} left)',
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6584).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFFF6584)),
                  onPressed: _useHint,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
             // Decorative Background
            Positioned(
              left: -50,
              top: 50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildInfoChip(
                          Icons.favorite_rounded,
                          '${gameState.remainingLives}',
                          const Color(0xFFFF4757),
                        ),
                        if (gameState.mode == HangmanGameMode.singlePlayer)
                          _buildInfoChip(
                            Icons.emoji_events_rounded,
                            '${WordService.calculateScore(gameState)}',
                            const Color(0xFFFFA502),
                          ),
                        _buildInfoChip(
                          Icons.timer_rounded,
                          _timeDisplay,
                          const Color(0xFF2ED573),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: -0.2),

                  Expanded(
                    flex: 3,
                    child: Center(
                        child: _buildHangmanDrawing().animate().fadeIn(duration: 600.ms),
                    ),
                  ),

                  Expanded(
                    flex: 1,
                    child: _buildWordDisplay().animate().fadeIn(delay: 200.ms),
                  ),

                  Expanded(
                    flex: 2,
                    child: _buildKeyboard().animate().slideY(begin: 0.2, duration: 400.ms),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHangmanDrawing() {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
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
      width: double.infinity,
      alignment: Alignment.center,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: gameState.maskedWord.map((letter) {
            final isRevealed = letter != '_';
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isRevealed ? const Color(0xFF6C63FF).withOpacity(0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border(
                    bottom: BorderSide(
                        color: isRevealed ? Colors.transparent : Colors.black87,
                        width: 3
                    ),
                ),
              ),
              child: Text(
                letter,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6C63FF),
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: letters.map((row) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((letter) {
                final isGuessed =
                    _guessedLetters.contains(letter.toLowerCase());
                final isCorrect = gameState.word.toUpperCase().contains(letter);
                return Padding(
                  padding: const EdgeInsets.all(3),
                  child: SizedBox(
                    width: 34,
                    height: 48,
                    child: ElevatedButton(
                      onPressed:
                          isGuessed ? null : () => _onLetterPressed(letter),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: isGuessed
                            ? (isCorrect ? const Color(0xFF2ED573) : const Color(0xFFFF4757))
                            : Colors.white,
                        foregroundColor: const Color(0xFF2A2D3E),
                        elevation: isGuessed ? 0 : 2,
                        shadowColor: Colors.black.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: isGuessed
                            ? BorderSide.none
                            : BorderSide(color: Colors.grey.withOpacity(0.2)),
                        ),
                      ),
                      child: Text(
                        letter,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isGuessed
                              ? Colors.white
                              : const Color(0xFF2A2D3E),
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
      ..color = const Color(0xFF2A2D3E)
      ..strokeWidth = 4
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
        ..color = const Color(0xFFFFA502)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(centerX, size.height * 0.1),
        Offset(centerX, size.height * 0.25),
        ropePaint,
      );
    }

    // Head
    if (incorrectGuesses >= 5) {
      canvas.drawCircle(
        Offset(centerX, size.height * 0.35),
        headRadius,
        paint..color = const Color(0xFF6C63FF),
      );
    }

    // Body
    if (incorrectGuesses >= 6) {
      canvas.drawLine(
        Offset(centerX, size.height * 0.45),
        Offset(centerX, size.height * 0.7),
        paint..color = const Color(0xFF2A2D3E),
      );

      // Arms
       canvas.drawLine(
        Offset(centerX, size.height * 0.5),
        Offset(centerX - 30, size.height * 0.6),
        paint,
      );
       canvas.drawLine(
        Offset(centerX, size.height * 0.5),
        Offset(centerX + 30, size.height * 0.6),
        paint,
      );

      // Legs
       canvas.drawLine(
        Offset(centerX, size.height * 0.7),
        Offset(centerX - 30, size.height * 0.85),
        paint,
      );
       canvas.drawLine(
        Offset(centerX, size.height * 0.7),
        Offset(centerX + 30, size.height * 0.85),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
