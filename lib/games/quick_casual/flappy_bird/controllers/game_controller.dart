import 'dart:async';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:developer' as developer;
import '../models/bird.dart';
import '../models/pipe.dart';
import '../models/game_stats.dart';
import '../services/score_service.dart';
import '../utils/constants.dart';
import 'dart:math';
import 'settings_controller.dart';

class FlappyBirdGameController extends GetxController {
  final ScoreService scoreService;
  late final FlappyBirdSettingsController settingsController;
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _effectsPlayer = AudioPlayer();

  // Game state
  final gameRunning = false.obs;
  final gameOver = false.obs;
  final score = 0.obs;
  final highScore = 0.obs;
  final gameStats = GameStats.initial().obs;
  final startTime = DateTime.now().obs;
  final isPaused = false.obs;
  final pauseStartTime = Rx<DateTime?>(null);
  final totalPauseTime = 0.obs; // Track total pause time in milliseconds

  // Game objects
  late Bird bird;
  final pipes = <Pipe>[].obs;

  // Animation
  Timer? gameTimer;
  DateTime? lastFrameTime;
  final fps = GameConstants.fps.obs;
  bool _audioAssetsAvailable = false;
  late final Random _random;
  bool _collisionPending = false;
  int _roundId = 0;

  FlappyBirdGameController({required this.scoreService}) {
    developer.log('Initializing FlappyBirdGameController');
    settingsController = Get.find<FlappyBirdSettingsController>();
    _random = Random();
  }

  @override
  void onInit() {
    super.onInit();
    developer.log('onInit called');
    initGame();
    loadHighScore();
  }

  @override
  void onClose() {
    developer.log('onClose called');
    gameTimer?.cancel();
    _roundId++;
    _collisionPending = false;
    _musicPlayer.dispose();
    _effectsPlayer.dispose();
    super.onClose();
  }

  Future<void> loadHighScore() async {
    developer.log('Loading high score');
    final loadedStats = await scoreService.getGameStats();
    gameStats.value = loadedStats;
    highScore.value = loadedStats.highScore;

    developer.log(
        'Loaded high score: ${highScore.value}, Games played: ${gameStats.value.gamesPlayed}, Total pipes: ${gameStats.value.totalPipesPassed}, Play time: ${gameStats.value.totalPlayTime.inSeconds}s');
  }

  void initGame() {
    developer.log('Initializing game');
    gameTimer?.cancel();
    bird = Bird(
      position: Offset(Get.width * 0.3, Get.height * 0.45),
      size: const Size(GameConstants.birdSize, GameConstants.birdSize),
    );
    bird.velocity = 0;
    pipes.clear();
    score.value = 0;
    gameOver.value = false;
    gameRunning.value = false;
    isPaused.value = false;
    lastFrameTime = null;
    pauseStartTime.value = null;
    totalPauseTime.value = 0;
    fps.value = GameConstants.fps;
    developer.log('Game initialized');
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    _audioAssetsAvailable = await _detectAudioAssets();
  }

  Future<bool> _detectAudioAssets() async {
    try {
      final manifest = await rootBundle.loadString('AssetManifest.json');
      return manifest.contains('assets/sounds/drop.mp3') &&
          manifest.contains('assets/sounds/win.mp3');
    } catch (e) {
      developer.log('Audio manifest check failed: $e');
      return false;
    }
  }

  Future<void> _playEffect(String assetPath, {double? volume}) async {
    if (!_audioAssetsAvailable) return;
    try {
      await _effectsPlayer.stop();
      await _effectsPlayer.play(AssetSource(assetPath), volume: volume);
    } catch (e) {
      developer.log('Audio playback failed for $assetPath: $e');
    }
  }

  Future<void> _startBackgroundAudio() async {
    if (!_audioAssetsAvailable || !settingsController.musicEnabled.value) {
      return;
    }
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer.play(AssetSource('sounds/drop.mp3'), volume: 0.12);
    } catch (e) {
      developer.log('Background audio playback failed: $e');
    }
  }

  void startGame() {
    if (gameRunning.value) {
      developer.log('Game already running');
      return;
    }

    developer.log('Starting game');
    initGame();
    gameRunning.value = true;
    gameOver.value = false;
    startTime.value = DateTime.now();
    lastFrameTime = DateTime.now();

    if (settingsController.musicEnabled.value && _audioAssetsAvailable) {
      developer.log('Starting background music');
      _startBackgroundAudio();
    }

    gameTimer = Timer.periodic(
      Duration(milliseconds: (1000 / fps.value).round()),
      (_) => updateGame(),
    );
    developer.log('Game started');
  }

  void jump() {
    if (!gameRunning.value) {
      developer.log('First jump - starting game');
      startGame();
      return;
    }

    if (!gameOver.value && !isPaused.value && !_collisionPending) {
      developer.log('Bird jump');
      bird.flap();
      if (settingsController.vibrationEnabled.value) {
        HapticFeedback.lightImpact();
      }

      if (settingsController.soundEnabled.value) {
        _playEffect('sounds/drop.mp3', volume: 0.3);
      }
    }
  }

  void updateGame() {
    if (gameOver.value || isPaused.value || _collisionPending) return;

    final now = DateTime.now();
    if (lastFrameTime == null) {
      lastFrameTime = now;
      return;
    }

    // Calculate delta time with a maximum to prevent huge jumps while still
    // letting slow frames advance closer to real elapsed time.
    final dt = (now.difference(lastFrameTime!).inMicroseconds / 1000000)
        .clamp(0, 0.05);
    lastFrameTime = now;

    // Generate pipes with proper timing
    if (pipes.isEmpty ||
        pipes.last.position.dx < Get.width - GameConstants.pipeSpacing) {
      addPipe();
    }

    // Split slow frames into small deterministic steps. This keeps collisions
    // reliable and prevents tunnelling through a pipe after a brief UI stall.
    var remaining = dt;
    while (remaining > 0) {
      final step = min(remaining, 1 / 120).toDouble();
      bird.update(GameConstants.gravity, step);
      final frameSpeed = GameConstants.pipeSpeed * step;
      for (final pipe in pipes) {
        pipe.position = Offset(pipe.position.dx - frameSpeed, pipe.position.dy);
      }
      remaining -= step;
    }

    // Remove off-screen pipes
    pipes.removeWhere((pipe) => pipe.position.dx < -pipe.width);

    // Add grace period at start
    if (score.value > 0 || now.difference(startTime.value).inSeconds > 1.5) {
      if (checkCollision()) {
        developer.log('Collision detected - ending game');
        _showImpactThenEnd();
        return;
      }
    }

    // Update score
    updateScore();
    // Bird and pipe coordinates are mutable model fields, so explicitly notify
    // the gameplay canvas every frame instead of relying on Rx list mutations.
    update();
  }

  void _showImpactThenEnd() {
    if (_collisionPending) return;
    _collisionPending = true;
    gameTimer?.cancel();
    final impactedRound = _roundId;
    update();
    Future<void>.delayed(const Duration(milliseconds: 85), () {
      if (_roundId == impactedRound &&
          _collisionPending &&
          gameRunning.value &&
          !gameOver.value) {
        endGame();
      }
    });
  }

  void addPipe() {
    developer.log('Adding new pipe');
    const gapHeight = GameConstants.pipeGap;
    final minY = gapHeight;
    final maxY = Get.height - gapHeight - 100; // Leave some space at bottom

    // Safety check: ensure valid range
    if (maxY <= minY) {
      developer.log('Screen too small for pipes: minY=$minY, maxY=$maxY');
      return;
    }

    final centerY = minY + _random.nextDouble() * (maxY - minY);

    // Top pipe
    pipes.add(
      Pipe(
        position: Offset(Get.width, 0),
        size: Size(GameConstants.pipeWidth, centerY - gapHeight / 2),
        isTop: true,
      ),
    );

    // Bottom pipe
    pipes.add(
      Pipe(
        position: Offset(Get.width, centerY + gapHeight / 2),
        size: Size(
            GameConstants.pipeWidth, Get.height - (centerY + gapHeight / 2)),
        isTop: false,
      ),
    );
    developer.log('Pipe added at centerY: $centerY with gap: $gapHeight');
  }

  bool checkCollision() {
    // Check if bird hits the ground or ceiling with some padding
    if (bird.hitbox.top <= 0 || bird.hitbox.bottom >= Get.height) {
      developer.log('Bird hit boundary - y: ${bird.position.dy}');
      return true;
    }

    // Check collision with pipes using the improved collision detection
    for (var pipe in pipes) {
      if (bird.collidesWith(pipe)) {
        developer.log(
            'Bird hit pipe at x: ${pipe.position.dx}, y: ${pipe.position.dy}');
        return true;
      }
    }

    return false;
  }

  void updateScore() {
    for (var pipe in pipes) {
      if (!pipe.isTop &&
          !pipe.passed &&
          pipe.position.dx + pipe.width < bird.hitbox.left) {
        pipe.passed = true;
        score.value++;
        developer.log('Score updated: ${score.value}');

        // Check for new high score during gameplay
        if (score.value > highScore.value) {
          developer
              .log('New high score achieved during gameplay: ${score.value}');
          highScore.value = score.value;
        }

        gameStats.value = gameStats.value.copyWith(
          highScore: highScore.value,
          totalPipesPassed: gameStats.value.totalPipesPassed + 1,
        );

        if (settingsController.soundEnabled.value) {
          _playEffect('sounds/win.mp3', volume: 0.4);
        }
      }
    }
  }

  Future<void> endGame() async {
    if (!gameRunning.value || gameOver.value) {
      developer.log('Game already ended or not running, skipping endGame');
      return;
    }

    developer.log('Ending game');
    gameRunning.value = false;
    gameOver.value = true;
    _collisionPending = false;
    gameTimer?.cancel();

    if (settingsController.soundEnabled.value) {
      await _playEffect('sounds/drop.mp3', volume: 0.5);
      await Future.delayed(Duration(milliseconds: 300));
      await _playEffect('sounds/win.mp3', volume: 0.5);
    }
    if (settingsController.vibrationEnabled.value) {
      HapticFeedback.heavyImpact();
    }

    // Calculate actual play time, accounting for pauses
    final now = DateTime.now();
    final rawPlayTime = now.difference(startTime.value);
    final actualPlayTimeMs = rawPlayTime.inMilliseconds - totalPauseTime.value;
    final playTime =
        Duration(milliseconds: actualPlayTimeMs > 0 ? actualPlayTimeMs : 0);

    developer.log(
        'Game played for ${playTime.inSeconds} seconds (excluding pauses)');

    try {
      final finalHighScore = score.value > gameStats.value.highScore
          ? score.value
          : gameStats.value.highScore;
      final newTotalPlayTime = Duration(
          milliseconds: gameStats.value.totalPlayTime.inMilliseconds +
              playTime.inMilliseconds);

      developer.log(
          'Updating stats - Games played: ${gameStats.value.gamesPlayed + 1}, '
          'Adding playtime: ${playTime.inSeconds}s, '
          'New total play time: ${newTotalPlayTime.inSeconds}s');

      final updatedStats = GameStats(
        score: score.value,
        highScore: finalHighScore,
        gamesPlayed: gameStats.value.gamesPlayed + 1,
        totalPlayTime: newTotalPlayTime,
        totalPipesPassed: gameStats.value.totalPipesPassed,
      );
      gameStats.value = updatedStats;
      highScore.value = finalHighScore;
      await scoreService.saveGameStats(updatedStats);

      developer.log(
          'Game ended - Final score: ${score.value}, High score: ${highScore.value}, '
          'Total games: ${gameStats.value.gamesPlayed}, Total time: ${gameStats.value.totalPlayTime.inSeconds}s, '
          'Total pipes: ${gameStats.value.totalPipesPassed}');
    } catch (e, stackTrace) {
      developer.log('Error updating game stats: $e\n$stackTrace');
    }
  }

  Future<void> resetStats() async {
    developer.log('Resetting stats');
    gameStats.value = GameStats.initial();
    highScore.value = 0;
    score.value = 0;
    await scoreService.saveGameStats(gameStats.value);
    developer.log('Stats reset complete');
  }

  void restartGame() {
    developer.log('Restarting game');
    gameTimer?.cancel();
    gameRunning.value = false;
    startGame();
  }

  void pauseGame() {
    if (gameRunning.value && !gameOver.value && !isPaused.value) {
      developer.log('Pausing game');
      isPaused.value = true;
      pauseStartTime.value = DateTime.now();
      gameTimer?.cancel();
      if (settingsController.musicEnabled.value) {
        _musicPlayer.pause();
      }
      update();
    }
  }

  void resumeGame() {
    if (isPaused.value && !gameOver.value) {
      developer.log('Resuming game');

      // Calculate pause duration and add to total pause time
      if (pauseStartTime.value != null) {
        final pauseDuration =
            DateTime.now().difference(pauseStartTime.value!).inMilliseconds;
        totalPauseTime.value += pauseDuration;
        developer.log(
            'Game was paused for ${pauseDuration}ms, total pause time: ${totalPauseTime.value}ms');
      }

      isPaused.value = false;
      lastFrameTime = DateTime.now();
      gameTimer = Timer.periodic(
        Duration(milliseconds: (1000 / fps.value).round()),
        (_) => updateGame(),
      );
      if (settingsController.musicEnabled.value) {
        _musicPlayer.resume();
      }
      update();
    }
  }

  void togglePause() {
    developer.log(
        'Toggle pause called, current state: ${isPaused.value}, gameRunning: ${gameRunning.value}, gameOver: ${gameOver.value}');

    if (gameOver.value) {
      developer.log('Game is over, cannot toggle pause');
      return;
    }

    if (!gameRunning.value) {
      developer.log('Game not running, cannot toggle pause');
      return;
    }

    try {
      if (isPaused.value) {
        resumeGame();
      } else {
        pauseGame();
      }
      developer.log('Pause state after toggle: ${isPaused.value}');
    } catch (e, stackTrace) {
      developer.log('Error in togglePause: $e\n$stackTrace');
    }
  }
}
