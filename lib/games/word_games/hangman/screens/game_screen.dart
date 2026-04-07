import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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
    // Normalize existing guessed letters if any
    _guessedLetters.addAll(gameState.guessedLetters.map((e) => e.toLowerCase()));
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
    
    final l = letter.toLowerCase();
    if (_guessedLetters.contains(l)) return;

    setState(() {
      _guessedLetters.add(l);

      // Update game state
      final isCorrect = gameState.word.toLowerCase().contains(l);
      final newLives = isCorrect ? gameState.remainingLives : gameState.remainingLives - 1;

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
    });
    _onLetterPressed(hint);
  }

  HangmanGameStatus _determineGameStatus(int lives) {
    if (gameState.isWordGuessed) return HangmanGameStatus.won;
    if (lives <= 0) return HangmanGameStatus.lost;
    return HangmanGameStatus.playing;
  }

  void _showGameOverDialog() {
    final score = WordService.calculateScore(gameState);
    final won = gameState.status == HangmanGameStatus.won;

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0C29).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: won ? Colors.cyanAccent.withValues(alpha: 0.5) : Colors.redAccent.withValues(alpha: 0.5),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: won ? Colors.cyanAccent.withValues(alpha: 0.15) : Colors.redAccent.withValues(alpha: 0.15),
                    blurRadius: 50,
                    spreadRadius: 10,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    won ? Icons.workspace_premium_rounded : Icons.warning_amber_rounded,
                    size: 80,
                    color: won ? Colors.cyanAccent : Colors.redAccent,
                  ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut),
                  const SizedBox(height: 24),
                  Text(
                    won ? 'SYSTEM HACKED\nACCESS GRANTED' : 'SYSTEM FAILURE\nACCESS DENIED',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 3,
                      height: 1.4,
                      color: won ? Colors.cyanAccent : Colors.redAccent,
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 16),
                  Text(
                    won ? 'Word successfully decoded.' : 'The encrypted word was:',
                    style: const TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 1),
                  ),
                  if (!won) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        gameState.word.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 6,
                        ),
                      ),
                    ).animate().shimmer(delay: 600.ms, duration: 1.seconds, color: Colors.white30),
                  ],
                  if (won) ...[
                    const SizedBox(height: 32),
                    _buildStatRow('Score', '$score', Icons.stars_rounded, Colors.amberAccent),
                    _buildStatRow('Time', '${DateTime.now().difference(gameState.startTime).inSeconds}s', Icons.timer_outlined, Colors.cyanAccent),
                    _buildStatRow('Precision', '${((gameState.word.length / _guessedLetters.length) * 100).clamp(0, 100).toInt()}%', Icons.analytics_outlined, Colors.purpleAccent),
                  ],
                  const SizedBox(height: 40),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('EXIT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
                        ),
                      ),
                      if (gameState.mode == HangmanGameMode.singlePlayer) ...[
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
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
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: won ? Colors.cyanAccent : Colors.redAccent,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text(
                              'RETRY',
                              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
                            ),
                          ),
                        ),
                      ]
                    ],
                  ).animate().slideY(begin: 0.5, curve: Curves.easeOutCubic, duration: 600.ms, delay: 600.ms).fadeIn(delay: 600.ms),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: Curves.easeOutBack.transform(anim1.value),
          child: Opacity(
             opacity: anim1.value,
             child: child,
          ),
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1)),
            ],
          ),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0C29),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Text(
            gameState.category.displayName.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 3, fontSize: 13, color: Colors.cyanAccent),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (gameState.hintsRemaining > 0 && !gameState.isGameOver)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(Icons.emergency_share_outlined),
                color: Colors.amberAccent,
                onPressed: _useHint,
                tooltip: 'Use Hint (${gameState.hintsRemaining} remaining)',
              ).animate(onPlay: (controller) => controller.repeat(reverse: true)).shimmer(duration: 2.seconds, color: Colors.white),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Cyberpunk Background Elements
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0F0C29),
                  Color(0xFF302B63),
                  Color(0xFF0F0C29),
                ],
              ),
            ),
          ),
          Positioned(
            top: -150,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.cyanAccent.withValues(alpha: 0.05),
                boxShadow: const [BoxShadow(color: Colors.cyanAccent, blurRadius: 200)],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purpleAccent.withValues(alpha: 0.05),
                boxShadow: const [BoxShadow(color: Colors.purpleAccent, blurRadius: 150)],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                const SizedBox(height: 16),
                Expanded(
                  flex: 3,
                  child: _buildHangmanDrawing(),
                ),
                Expanded(
                  flex: 2,
                  child: _buildWordDisplay(),
                ),
                _buildKeyboard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildGlassMetric('LIVES', '${gameState.remainingLives}', Colors.pinkAccent),
          _buildGlassMetric('TIME', _timeDisplay, Colors.cyanAccent),
          if (gameState.mode == HangmanGameMode.singlePlayer) ...[
            _buildGlassMetric('SCORE', '${WordService.calculateScore(gameState)}', Colors.amberAccent),
          ] else ... [
            _buildGlassMetric('MODE', 'PVP', Colors.purpleAccent),
          ]
        ],
      ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
    );
  }

  Widget _buildGlassMetric(String label, String value, Color accentColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Text(
            value,
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.w900,
              fontSize: 16,
              letterSpacing: 1,
              shadows: [Shadow(color: accentColor.withValues(alpha: 0.5), blurRadius: 10)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHangmanDrawing() {
    return Hero(
      tag: 'hangman_drawing', // Matches with mode selection if available
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.15), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.cyanAccent.withValues(alpha: 0.02),
              blurRadius: 30,
              spreadRadius: 5,
            )
          ]
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Stack(
              children: [
                // Minimalist coordinate grid background
                CustomPaint(
                  painter: GridPainter(),
                  size: Size.infinite,
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 200, maxHeight: 250),
                      child: CustomPaint(
                        painter: HologramHangmanPainter(
                          incorrectGuesses: 6 - gameState.remainingLives,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ).animate().fadeIn(duration: 800.ms, curve: Curves.easeOut).scaleXY(begin: 0.95),
    );
  }

  Widget _buildWordDisplay() {
    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(gameState.word.length, (index) {
            final letter = gameState.word[index];
            final isGuessed = _guessedLetters.contains(letter.toLowerCase());
            final isSpace = letter == ' ';
            
            if (isSpace) return const SizedBox(width: 24);
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 44,
              height: 56,
              decoration: BoxDecoration(
                color: isGuessed ? Colors.cyanAccent.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isGuessed ? Colors.cyanAccent.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1),
                  width: isGuessed ? 2 : 1,
                ),
                boxShadow: isGuessed ? [
                  BoxShadow(
                    color: Colors.cyanAccent.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ] : null,
              ),
              alignment: Alignment.center,
              child: isGuessed
                  ? Text(
                      letter.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Colors.cyanAccent, blurRadius: 10),
                        ],
                      ),
                    ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack, begin: const Offset(0.5, 0.5))
                  : Container(
                      width: 16,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
            );
          }),
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

    final screenWidth = MediaQuery.of(context).size.width;
    // Base padding is 24 on each side, with a little internal spacing
    final maxKeyWidth = (screenWidth - 48 - (9 * 6)) / 10; 
    
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: letters.map((row) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((letter) {
                final isGuessed = _guessedLetters.contains(letter.toLowerCase());
                final isCorrect = gameState.word.toUpperCase().contains(letter);
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: _buildKey(letter, isGuessed, isCorrect, maxKeyWidth),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    ).animate().slideY(begin: 0.3, duration: 600.ms, curve: Curves.easeOutBack).fadeIn();
  }

  Widget _buildKey(String letter, bool isGuessed, bool isCorrect, double keyWidth) {
    Color bgColor = Colors.black.withValues(alpha: 0.3);
    Color textColor = Colors.white;
    Color borderColor = Colors.white.withValues(alpha: 0.1);
    
    if (isGuessed) {
      if (isCorrect) {
        bgColor = Colors.cyanAccent.withValues(alpha: 0.15);
        textColor = Colors.cyanAccent;
        borderColor = Colors.cyanAccent.withValues(alpha: 0.4);
      } else {
        bgColor = Colors.black.withValues(alpha: 0.6);
        textColor = Colors.white.withValues(alpha: 0.2);
        borderColor = Colors.transparent;
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isGuessed ? null : () => _onLetterPressed(letter),
        borderRadius: BorderRadius.circular(10),
        splashColor: Colors.cyanAccent.withValues(alpha: 0.3),
        highlightColor: Colors.cyanAccent.withValues(alpha: 0.1),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          width: keyWidth,
          height: 52,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
            boxShadow: isGuessed && isCorrect ? [
              BoxShadow(
                color: Colors.cyanAccent.withValues(alpha: 0.2),
                blurRadius: 10,
              )
            ] : null,
          ),
          alignment: Alignment.center,
          child: Text(
            letter,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: keyWidth > 32 ? 18 : 16,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.03)
      ..strokeWidth = 1;
    
    const double gridSize = 20;

    for (double i = 0; i <= size.width; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i <= size.height; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HologramHangmanPainter extends CustomPainter {
  final int incorrectGuesses;

  HologramHangmanPainter({required this.incorrectGuesses});

  void drawNeonLine(Canvas canvas, Offset p1, Offset p2, Color color) {
    final paintBase = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
      
    final paintGlow = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..imageFilter = ImageFilter.blur(sigmaX: 4, sigmaY: 4);

    canvas.drawLine(p1, p2, paintGlow);
    canvas.drawLine(p1, p2, paintBase);

    // Draw glowing joints
    final jointPaint = Paint()..color = Colors.white;
    final jointGlow = Paint()
      ..color = color
      ..imageFilter = ImageFilter.blur(sigmaX: 2, sigmaY: 2);
    
    canvas.drawCircle(p1, 3, jointGlow);
    canvas.drawCircle(p1, 1.5, jointPaint);
    canvas.drawCircle(p2, 3, jointGlow);
    canvas.drawCircle(p2, 1.5, jointPaint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Structural Scaffold (Gallows)
    final scaffoldColor = Colors.purpleAccent.withValues(alpha: 0.7);
    
    // Base node to pole connection
    drawNeonLine(canvas, Offset(w * 0.1, h * 0.9), Offset(w * 0.5, h * 0.9), scaffoldColor);
    drawNeonLine(canvas, Offset(w * 0.3, h * 0.9), Offset(w * 0.3, h * 0.1), scaffoldColor);
    drawNeonLine(canvas, Offset(w * 0.3, h * 0.1), Offset(w * 0.7, h * 0.1), scaffoldColor);
    
    // Laser rope
    drawNeonLine(canvas, Offset(w * 0.7, h * 0.1), Offset(w * 0.7, h * 0.25), Colors.pinkAccent.withValues(alpha: 0.7));

    // Hologram Subject
    final bodyColor = incorrectGuesses >= 6 ? Colors.redAccent : Colors.cyanAccent;
    final centerX = w * 0.7;
    final headRadius = h * 0.08;
    final bodyTopY = h * 0.25 + (headRadius * 2);
    final bodyBottomY = h * 0.6;

    // 1 - Head
    if (incorrectGuesses >= 1) {
      final headCenter = Offset(centerX, h * 0.25 + headRadius);
      final headPaint = Paint()
        ..color = bodyColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      final headGlow = Paint()
        ..color = bodyColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..imageFilter = ImageFilter.blur(sigmaX: 4, sigmaY: 4);

      canvas.drawCircle(headCenter, headRadius, headGlow);
      canvas.drawCircle(headCenter, headRadius, headPaint);
    }

    // 2 - Core Spine (Body)
    if (incorrectGuesses >= 2) {
      drawNeonLine(canvas, Offset(centerX, bodyTopY), Offset(centerX, bodyBottomY), bodyColor);
    }

    // 3 - Left Arm Structure
    if (incorrectGuesses >= 3) {
      drawNeonLine(canvas, Offset(centerX, bodyTopY + h * 0.05), Offset(centerX - w * 0.2, bodyTopY + h * 0.15), bodyColor);
    }

    // 4 - Right Arm Structure
    if (incorrectGuesses >= 4) {
      drawNeonLine(canvas, Offset(centerX, bodyTopY + h * 0.05), Offset(centerX + w * 0.2, bodyTopY + h * 0.15), bodyColor);
    }

    // 5 - Left Leg Structure
    if (incorrectGuesses >= 5) {
      drawNeonLine(canvas, Offset(centerX, bodyBottomY), Offset(centerX - w * 0.15, bodyBottomY + h * 0.2), bodyColor);
    }

    // 6 - Right Leg Structure
    if (incorrectGuesses >= 6) {
      drawNeonLine(canvas, Offset(centerX, bodyBottomY), Offset(centerX + w * 0.15, bodyBottomY + h * 0.2), bodyColor);
    }
  }

  @override
  bool shouldRepaint(covariant HologramHangmanPainter oldDelegate) {
    return oldDelegate.incorrectGuesses != incorrectGuesses;
  }
}
