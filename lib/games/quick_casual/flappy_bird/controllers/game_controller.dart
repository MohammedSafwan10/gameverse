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
import 'settings_controller.dart';

class FlappyBirdGameController extends GetxController {
  final ScoreService scoreService;
  late final FlappyBirdSettingsController settingsController;
  final AudioPlayer _audioPlayer = AudioPlayer();

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

  FlappyBirdGameController({required this.scoreService}) {
    developer.log('Initializing FlappyBirdGameController');
    settingsController = Get.find<FlappyBirdSettingsController>();
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
    _audioPlayer.dispose();
    super.onClose();
  }

  Future<void> loadHighScore() async {
    developer.log('Loading high score');
    final loadedHighScore = await scoreService.getHighScore();
    highScore.value = loadedHighScore;

    // Load game stats and ensure high score is in sync
    final loadedStats = await scoreService.getGameStats();

    // Make sure the loaded stats have the correct high score
    if (loadedStats.highScore != loadedHighScore) {
      gameStats.value = loadedStats.copyWith(highScore: loadedHighScore);
      await scoreService.saveGameStats(gameStats.value);
    } else {
      gameStats.value = loadedStats;
    }

    developer.log(
        'Loaded high score: ${highScore.value}, Games played: ${gameStats.value.gamesPlayed}, Total pipes: ${gameStats.value.totalPipesPassed}, Play time: ${gameStats.value.totalPlayTime.inSeconds}s');
  }

  void initGame() {
    developer.log('Initializing game');
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

    if (settingsController.musicEnabled.value) {
      developer.log('Starting background music');
      _audioPlayer.play(AssetSource('audio/background_music.mp3'), volume: 0.5);
      _audioPlayer.setReleaseMode(ReleaseMode.loop);
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

    if (!gameOver.value && !isPaused.value) {
      developer.log('Bird jump');
      bird.flap();
      if (settingsController.vibrationEnabled.value) {
        HapticFeedback.lightImpact();
      }

      if (settingsController.soundEnabled.value) {
        _audioPlayer.play(AssetSource('audio/wing.mp3'), volume: 0.3);
      }
    }
  }

  void updateGame() {
    if (gameOver.value || isPaused.value) return;

    final now = DateTime.now();
    if (lastFrameTime == null) {
      lastFrameTime = now;
      return;
    }

    // Calculate delta time with a maximum to prevent huge jumps
    final dt = (now.difference(lastFrameTime!).inMicroseconds / 1000000)
        .clamp(0, 0.016);
    lastFrameTime = now;

    // Update bird physics with scaled delta time based on difficulty
    final gravityToUse = settingsController.gravity;
    bird.update(gravityToUse * dt);

    // Generate pipes with proper timing
    if (pipes.isEmpty ||
        pipes.last.position.dx < Get.width - GameConstants.pipeSpacing) {
      addPipe();
    }

    // Update pipes with consistent speed
    final frameSpeed = settingsController.pipeSpeed * dt;
    for (var pipe in pipes) {
      pipe.position = Offset(
        pipe.position.dx - frameSpeed,
        pipe.position.dy,
      );
    }

    // Remove off-screen pipes
    pipes.removeWhere((pipe) => pipe.position.dx < -pipe.width);

    // Add grace period at start
    if (score.value > 0 || now.difference(startTime.value).inSeconds > 1.5) {
      if (checkCollision()) {
        developer.log('Collision detected - ending game');
        endGame();
        return;
      }
    }

    // Update score
    updateScore();
  }

  void addPipe() {
    developer.log('Adding new pipe');
    final gapHeight = settingsController.pipeGap;
    final minY = gapHeight;
    final maxY = Get.height - gapHeight - 100; // Leave some space at bottom
    final random = DateTime.now().millisecondsSinceEpoch;
    final centerY = minY + (random % (maxY - minY).toInt());

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
    if (bird.position.dy <= 10 ||
        bird.position.dy >= Get.height - bird.size.height - 10) {
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
      if (!pipe.isTop && !pipe.passed && pipe.position.dx < bird.position.dx) {
        pipe.passed = true;
        score.value++;
        developer.log('Score updated: ${score.value}');

        // Check for new high score during gameplay
        if (score.value > highScore.value) {
          developer
              .log('New high score achieved during gameplay: ${score.value}');
          highScore.value = score.value;
        }

        // Always update statistics - don't conditionally update it
        gameStats.value = gameStats.value.copyWith(
          score: score.value,
          highScore: highScore.value,
          totalPipesPassed: gameStats.value.totalPipesPassed + 1,
        );

        // Save stats immediately for better cross-screen synchronization
        scoreService.saveGameStats(gameStats.value);

        if (settingsController.soundEnabled.value) {
          _audioPlayer.play(AssetSource('audio/score.mp3'));
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
    gameTimer?.cancel();

    if (settingsController.soundEnabled.value) {
      await _audioPlayer.play(AssetSource('audio/hit.mp3'));
      await Future.delayed(Duration(milliseconds: 300));
      await _audioPlayer.play(AssetSource('audio/die.mp3'));
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

    // Save high score if it's a new record
    if (score.value > highScore.value) {
      developer.log('New high score: ${score.value}');
      highScore.value = score.value;
      await scoreService.saveHighScore(score.value);
    }

    try {
      // Increment games played counter
      final currentGamesPlayed = gameStats.value.gamesPlayed + 1;

      // Add new play time to total
      final newTotalPlayTime = Duration(
          milliseconds: gameStats.value.totalPlayTime.inMilliseconds +
              playTime.inMilliseconds);

      developer.log('Updating stats - Games played: $currentGamesPlayed, '
          'Adding playtime: ${playTime.inSeconds}s, '
          'New total play time: ${newTotalPlayTime.inSeconds}s');

      // Create updated stats object
      final updatedStats = GameStats(
        score: score.value,
        highScore: highScore.value,
        gamesPlayed: currentGamesPlayed,
        totalPlayTime: newTotalPlayTime,
        totalPipesPassed: gameStats.value.totalPipesPassed,
      );

      // Explicitly update the observable properties individually
      gameStats.update((stats) {
        if (stats != null) {
          stats.score = updatedStats.score;
          stats.highScore = updatedStats.highScore;
          stats.gamesPlayed = updatedStats.gamesPlayed;
          stats.totalPlayTime = updatedStats.totalPlayTime;
          stats.totalPipesPassed = updatedStats.totalPipesPassed;
        }
      });

      // Force immediate save of game stats
      await scoreService.saveGameStats(gameStats.value);

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
    await scoreService.saveHighScore(0);
    await scoreService.saveGameStats(gameStats.value);
    developer.log('Stats reset complete');
  }

  void restartGame() {
    developer.log('Restarting game');
    initGame();
    startGame();
  }

  void pauseGame() {
    if (gameRunning.value && !gameOver.value && !isPaused.value) {
      developer.log('Pausing game');
      isPaused.value = true;
      pauseStartTime.value = DateTime.now();
      gameTimer?.cancel();
      if (settingsController.musicEnabled.value) {
        _audioPlayer.pause();
      }
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
        _audioPlayer.resume();
      }
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
