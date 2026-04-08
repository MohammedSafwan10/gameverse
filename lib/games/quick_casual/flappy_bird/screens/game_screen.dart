import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gameverse/widgets/guarded_exit.dart';
import '../controllers/game_controller.dart';
import '../controllers/settings_controller.dart';
import '../widgets/bird_widget.dart';
import '../widgets/pipe_widget.dart';

class FlappyBirdGameScreen extends StatefulWidget {
  const FlappyBirdGameScreen({super.key});

  @override
  State<FlappyBirdGameScreen> createState() => _FlappyBirdGameScreenState();
}

class _FlappyBirdGameScreenState extends State<FlappyBirdGameScreen>
    with SingleTickerProviderStateMixin {
  late final List<_NeonLine> gridLines;
  late Timer _gridTimer;
  double _gridOffset = 0;

  @override
  void initState() {
    super.initState();
    gridLines = List.generate(10, (i) => _NeonLine(x: i * (Get.width / 8)));

    _gridTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final controller = Get.find<FlappyBirdGameController>();
      if (controller.gameRunning.value &&
          !controller.gameOver.value &&
          !controller.isPaused.value) {
        setState(() {
          _gridOffset -= 4; // Move grid backward
          if (_gridOffset <= -(Get.width / 8)) {
            _gridOffset += (Get.width / 8);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _gridTimer.cancel();
    super.dispose();
  }

  Future<bool> _showExitConfirmationDialog(
      BuildContext context, FlappyBirdGameController controller) async {
    if (controller.gameOver.value) return true;

    controller.pauseGame();

    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.logout_rounded,
                      color: Colors.white70, size: 32),
                ),
                const SizedBox(height: 20),
                const Text(
                  'EXIT GAME',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Return to main menu? Your current progress will be lost.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14,
                      height: 1.5),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                          controller.resumeGame();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('Resume',
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF0F172A),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: const Text('Exit',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (result != true) {
      controller.resumeGame();
    }

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<FlappyBirdSettingsController>();
    final isCyber =
        settingsController.currentTheme.value == FlappyBirdTheme.cyberpunk;

    return GetBuilder<FlappyBirdGameController>(
      builder: (controller) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) async {
          if (!didPop) {
            controller.pauseGame();
            final shouldPop =
                await _showExitConfirmationDialog(context, controller);
            if (!shouldPop) {
              controller.resumeGame();
              return;
            }
            if (!context.mounted) return;
            controller.endGame();
            await popAfterConfirmation(
              context,
              confirmExit: () async => true,
            );
          }
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 18),
                  onPressed: () async {
                    controller.pauseGame();
                    final shouldPop =
                        await _showExitConfirmationDialog(context, controller);
                    if (!shouldPop) {
                      controller.resumeGame();
                      return;
                    }
                    if (!context.mounted) return;
                    controller.endGame();
                    await popAfterConfirmation(
                      context,
                      confirmExit: () async => true,
                    );
                  },
                ),
              ),
            ),
          ),
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => controller.jump(),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (isCyber) ...[
                  // Deep Cyberpunk background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF020014), // Super dark purple/black
                          Color(0xFF1A0B2E), // Deep purple
                          Color(0xFF3B0B4E), // Transition
                          Color(0xFF0F0B29), // Horizon line
                        ],
                        stops: [0.0, 0.4, 0.7, 1.0],
                      ),
                    ),
                  ),

                  // Background Sun/Neon Planet
                  Positioned(
                    bottom: 100,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFFF007A),
                              Color(0xFFFF8A00),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF007A)
                                  .withValues(alpha: 0.5),
                              blurRadius: 100,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                        // Grid cutout effect for synthwave sun
                        child: CustomPaint(
                          painter: _SynthwaveSunPainter(),
                        ),
                      ),
                    ),
                  ),

                  // Moving Ground Grid
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 120,
                    child: CustomPaint(
                      painter: _NeonGridPainter(offset: _gridOffset),
                    ),
                  ),
                ] else ...[
                  // Classic Background
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF4FC3F7), // Light blue
                          Color(0xFF2196F3), // Medium blue
                        ],
                      ),
                    ),
                  ),

                  // Ground
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF8D6E63), // Light brown
                            Color(0xFF5D4037), // Dark brown
                          ],
                        ),
                      ),
                      child: CustomPaint(
                        painter: _GroundPainter(),
                        size: Size(Get.width, 80),
                      ),
                    ),
                  ),
                ],

                // Game elements
                Obx(() {
                  final gameController = Get.find<FlappyBirdGameController>();
                  return Stack(
                    children: [
                      // Pipes
                      ...gameController.pipes.map(
                          (pipe) => PipeWidget(pipe: pipe, isCyber: isCyber)),

                      // Bird
                      BirdWidget(bird: gameController.bird, isCyber: isCyber),

                      // Score Display (Top Pill)
                      if (!gameController.gameOver.value)
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 20,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                        color: const Color(0xFF00E5FF)
                                            .withValues(alpha: 0.3)),
                                    boxShadow: [
                                      BoxShadow(
                                          color: const Color(0xFF00E5FF)
                                              .withValues(alpha: 0.1),
                                          blurRadius: 20),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.stars_rounded,
                                          color: Color(0xFFFF007A), size: 24),
                                      const SizedBox(width: 12),
                                      Text(
                                        gameController.score.value.toString(),
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          height: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Pause button
                      if (gameController.gameRunning.value &&
                          !gameController.gameOver.value)
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 20,
                          right: 20,
                          child: GestureDetector(
                            onTap: () => gameController.togglePause(),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              child: Icon(
                                gameController.isPaused.value
                                    ? Icons.play_arrow_rounded
                                    : Icons.pause_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          ),
                        ),

                      // Game over overlay
                      if (gameController.gameOver.value)
                        _buildGameOverOverlay(gameController),

                      // Pause overlay
                      if (gameController.isPaused.value &&
                          !gameController.gameOver.value)
                        _buildPauseOverlay(gameController),

                      // Get ready overlay
                      if (!gameController.gameRunning.value &&
                          !gameController.gameOver.value)
                        _buildGetReadyOverlay(),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay(FlappyBirdGameController controller) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              padding: const EdgeInsets.all(32),
              width: Get.width * 0.85,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B).withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'GAME OVER',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildScoreRow('SCORE', controller.score.value.toString(),
                      Colors.blueAccent),
                  const SizedBox(height: 16),
                  _buildScoreRow('BEST', controller.highScore.value.toString(),
                      Colors.amber),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.2)),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('MENU',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () => controller.restartGame(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: const Text('PLAY AGAIN',
                              style: TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreRow(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 28, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildPauseOverlay(FlappyBirdGameController controller) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pause_circle_filled_rounded,
                size: 80, color: Colors.white),
            const SizedBox(height: 16),
            const Text(
              'PAUSED',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => controller.resumeGame(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('RESUME',
                  style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGetReadyOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.4),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Text(
                'TAP TO FLAP',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Icon(Icons.touch_app_rounded,
                color: Colors.white54, size: 64),
          ],
        ),
      ),
    );
  }
}

class _NeonLine {
  double x;
  _NeonLine({required this.x});
}

class _NeonGridPainter extends CustomPainter {
  final double offset;

  _NeonGridPainter({required this.offset});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFF007A).withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Horizontal lines (perspective)
    for (int i = 0; i < 5; i++) {
      double y =
          size.height * (i / 4) * (i / 4); // exponential spacing for 3D feel
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Vertical lines moving
    double spacing = size.width / 8;
    for (double x = offset; x < size.width + spacing; x += spacing) {
      if (x > 0) {
        // Draw from vanishing point to bottom
        canvas.drawLine(
            Offset(size.width / 2, 0), Offset(x, size.height), paint);
      }
    }

    // Add a glowing horizon line
    final horizonPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawLine(const Offset(0, 0), Offset(size.width, 0), horizonPaint);
    canvas.drawLine(
        const Offset(0, 0),
        Offset(size.width, 0),
        Paint()
          ..color = Colors.white
          ..strokeWidth = 1);
  }

  @override
  bool shouldRepaint(_NeonGridPainter oldDelegate) =>
      oldDelegate.offset != offset;
}

class _SynthwaveSunPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF0F0B29)
      ..style = PaintingStyle.fill;

    // Cut horizontal lines into the sun
    for (int i = 0; i < 8; i++) {
      double y = size.height * 0.6 + (i * 12);
      double height = 2.0 + (i * 0.5);
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.fill;

    final grassPath = Path();

    // Create wavy grass line
    final Random random = Random(42); // Fixed seed for consistent pattern
    double x = 0;

    while (x < size.width) {
      final height = 5 + random.nextDouble() * 10;
      final width = 5 + random.nextDouble() * 15;

      grassPath.moveTo(x, 0);
      grassPath.quadraticBezierTo(x + width / 2, -height, x + width, 0);

      x += width;
    }

    // Fill the grass
    canvas.drawPath(grassPath, paint);
  }

  @override
  bool shouldRepaint(_GroundPainter oldDelegate) => false;
}
