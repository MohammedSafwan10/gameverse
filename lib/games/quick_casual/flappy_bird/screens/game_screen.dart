import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:developer' as developer;
import '../controllers/game_controller.dart';
import '../widgets/bird_widget.dart';
import '../widgets/pipe_widget.dart';

class FlappyBirdGameScreen extends StatefulWidget {
  const FlappyBirdGameScreen({super.key});

  @override
  State<FlappyBirdGameScreen> createState() => _FlappyBirdGameScreenState();
}

class _FlappyBirdGameScreenState extends State<FlappyBirdGameScreen> {
  late final List<_Cloud> clouds;
  late Timer _cloudsTimer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Initialize some clouds
    clouds = List.generate(6, (_) => _createRandomCloud());

    // Start cloud animation
    _cloudsTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      setState(() {
        _updateClouds();
      });
    });
  }

  @override
  void dispose() {
    _cloudsTimer.cancel();
    super.dispose();
  }

  _Cloud _createRandomCloud() {
    final screenWidth = Get.width;
    final screenHeight = Get.height;

    return _Cloud(
      position: Offset(
        _random.nextDouble() * screenWidth,
        _random.nextDouble() * (screenHeight * 0.6),
      ),
      size: 80.0 + _random.nextDouble() * 120,
      speed: 0.5 + _random.nextDouble() * 1.5,
      opacity: 0.5 + _random.nextDouble() * 0.3,
    );
  }

  void _updateClouds() {
    final screenWidth = Get.width;

    for (int i = 0; i < clouds.length; i++) {
      final cloud = clouds[i];
      cloud.position = Offset(
        cloud.position.dx - cloud.speed,
        cloud.position.dy,
      );

      // If cloud goes off screen, recycle it
      if (cloud.position.dx < -cloud.size) {
        clouds[i] = _Cloud(
          position: Offset(
            screenWidth + _random.nextDouble() * 100,
            _random.nextDouble() * (Get.height * 0.6),
          ),
          size: 80.0 + _random.nextDouble() * 120,
          speed: 0.5 + _random.nextDouble() * 1.5,
          opacity: 0.5 + _random.nextDouble() * 0.3,
        );
      }
    }
  }

  Future<bool> _showExitConfirmationDialog(
      BuildContext context, FlappyBirdGameController controller) async {
    if (controller.gameOver.value) return true;

    controller.pauseGame();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Pause Game'),
        content: const Text(
            'Do you want to exit the game? Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
              controller.resumeGame();
            },
            child: const Text('Resume'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Exit', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (result != true) {
      controller.resumeGame();
    }

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FlappyBirdGameController>(
      builder: (controller) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) async {
          if (!didPop) {
            controller.pauseGame();
            final shouldPop =
                await _showExitConfirmationDialog(context, controller);
            if (shouldPop) {
              controller.endGame();
              Get.back();
            } else {
              controller.resumeGame();
            }
          }
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
              onPressed: () async {
                controller.pauseGame();
                final shouldPop =
                    await _showExitConfirmationDialog(context, controller);
                if (shouldPop) {
                  controller.endGame();
                  Get.back();
                } else {
                  controller.resumeGame();
                }
              },
            ),
          ),
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => controller.jump(),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Sky background
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

                // Clouds - in background
                ...clouds.map((cloud) => Positioned(
                      left: cloud.position.dx,
                      top: cloud.position.dy,
                      child: Opacity(
                        opacity: cloud.opacity,
                        child: _CloudPainter(size: cloud.size),
                      ),
                    )),

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

                // Game elements
                Obx(() {
                  final gameController = Get.find<FlappyBirdGameController>();
                  return Stack(
                    children: [
                      // Pipes
                      ...gameController.pipes
                          .map((pipe) => PipeWidget(pipe: pipe)),

                      // Bird
                      BirdWidget(bird: gameController.bird),

                      // Score display
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.white.withOpacity(0.3)),
                            ),
                            child: Text(
                              gameController.score.value.toString(),
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    blurRadius: 10,
                                    color: Colors.black26,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      // High score display
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 90,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Best: ${gameController.highScore.value}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Pause button
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        right: 20,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              gameController.isPaused.value
                                  ? Icons.play_arrow_rounded
                                  : Icons.pause_rounded,
                              color: Colors.white,
                              size: 32,
                            ),
                            onPressed: () {
                              if (gameController.gameRunning.value &&
                                  !gameController.gameOver.value) {
                                developer.log('Pause button pressed');
                                gameController.togglePause();
                              }
                            },
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
      color: Colors.black.withOpacity(0.6),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Game Over',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildResultItem('Score', '${controller.score.value}'),
                  Container(width: 1, height: 40, color: Colors.grey[300]),
                  _buildResultItem('Best', '${controller.highScore.value}'),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.exit_to_app_rounded),
                    label: const Text('Exit'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: () => controller.restartGame(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Try Again'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildResultItem(String label, String value) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
            letterSpacing: 1,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPauseOverlay(FlappyBirdGameController controller) {
    return Container(
      color: Colors.black.withOpacity(0.4),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.pause_circle_filled_rounded, size: 64, color: Colors.blue),
              const SizedBox(height: 16),
              const Text(
                'Paused',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => controller.resumeGame(),
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Resume'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn();
  }

  Widget _buildGetReadyOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.touch_app_rounded, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              'Tap to Jump',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 2))],
              ),
            ).animate().fadeIn().scale(),
          ],
        ),
      ),
    );
  }
}

// Cloud model
class _Cloud {
  Offset position;
  final double size;
  final double speed;
  final double opacity;

  _Cloud({
    required this.position,
    required this.size,
    required this.speed,
    this.opacity = 0.7,
  });
}

// Cloud painter widget
class _CloudPainter extends StatelessWidget {
  final double size;

  const _CloudPainter({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CloudCustomPainter(),
      size: Size(size, size * 0.6),
    );
  }
}

// Ground painter
class _GroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw some grass tufts
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

// Cloud custom painter
class _CloudCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();

    // Draw a cloud using multiple circles
    path.addOval(Rect.fromCircle(
      center: Offset(size.width * 0.3, size.height * 0.5),
      radius: size.width * 0.3,
    ));

    path.addOval(Rect.fromCircle(
      center: Offset(size.width * 0.5, size.height * 0.3),
      radius: size.width * 0.25,
    ));

    path.addOval(Rect.fromCircle(
      center: Offset(size.width * 0.7, size.height * 0.4),
      radius: size.width * 0.28,
    ));

    path.addOval(Rect.fromCircle(
      center: Offset(size.width * 0.9, size.height * 0.6),
      radius: size.width * 0.2,
    ));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CloudCustomPainter oldDelegate) => false;
}
