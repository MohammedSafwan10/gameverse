import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/game_types.dart';
import '../models/game_state.dart';
import '../controllers/score_controller.dart';
import '../controllers/settings_controller.dart';
import '../services/audio_service.dart';
import '../screens/game_over_screen.dart';

class WhackAMoleGameController extends GetxController {
  final settingsController = Get.find<WhackAMoleSettingsController>();
  final scoreController = Get.find<WhackAMoleScoreController>();
  final audioService = Get.find<WhackAMoleAudioService>();

  // Game state
  final gameState = GameState.initial().obs;
  final isPlaying = false.obs;
  final isPaused = false.obs;
  final currentScore = 0.obs;
  final timeRemaining = 60.obs;
  final lives = 3.obs;
  final showHitEffect = false.obs;
  final hitEffectIndex = 0.obs;
  final showComboText = false.obs;
  final difficultyLevel = 1.obs;

  // Practice mode settings
  final practiceStage = 0.obs;
  final practiceHits = 0.obs;
  final practiceTarget = 5.obs;
  final showTutorialText = false.obs;
  final tutorialText = ''.obs;
  static const List<Map<String, dynamic>> _practiceStages = [
    {
      'description': 'Hit normal moles to score points!',
      'type': 'normal',
      'target': 5,
      'spawnInterval': 2000,
      'stayDuration': 2000,
    },
    {
      'description': 'Golden moles give bonus points!',
      'type': 'golden',
      'target': 3,
      'spawnInterval': 2000,
      'stayDuration': 2000,
    },
    {
      'description': 'Avoid the bomb moles!',
      'type': 'bomb',
      'target': 3,
      'spawnInterval': 2000,
      'stayDuration': 2000,
    },
    {
      'description': 'Build combos for multiplier points!',
      'type': 'combo',
      'target': 5,
      'spawnInterval': 1500,
      'stayDuration': 1500,
    },
  ];

  // Challenge mode settings
  final targetScore = 0.obs;
  final currentChallenge = 0.obs;
  final challengeDescription = ''.obs;
  static const List<Map<String, dynamic>> _challenges = [
    {
      'description': 'Hit 10 golden moles!',
      'type': 'golden',
      'target': 10,
      'timeLimit': 30,
    },
    {
      'description': 'Score 300 points in 30 seconds!',
      'type': 'score',
      'target': 300,
      'timeLimit': 30,
    },
    {
      'description': 'Get a 10x combo!',
      'type': 'combo',
      'target': 10,
      'timeLimit': 30,
    },
    {
      'description': 'Survive with no misses!',
      'type': 'perfect',
      'target': 20,
      'timeLimit': 30,
    },
  ];

  // Challenge tracking
  final goldenMolesHit = 0.obs;
  final perfectHits = 0.obs;

  // Survival mode settings
  static const int _initialLives = 5;
  static const int _difficultyIncreaseInterval = 30; // seconds
  static const double _difficultySpeedMultiplier = 0.9; // 10% faster each level
  static const double _maxDifficultyLevel = 5.0;
  final survivalTime = 0.obs; // Internal timer for survival mode
  final survivalStage = 1.obs;
  Timer? _survivalTimer;

  // Game mode
  late String gameMode;

  // Timers
  Timer? _gameTimer;
  Timer? _moleTimer;
  final Map<int, Timer> _moleTimers = {};

  @override
  void onInit() {
    super.onInit();
    gameMode = Get.arguments ?? 'classic';
    resetGame();
  }

  @override
  void onClose() {
    _cleanupTimers();
    _survivalTimer?.cancel();
    audioService.stopBackgroundMusic();
    super.onClose();
  }

  void _cleanupTimers() {
    _gameTimer?.cancel();
    _moleTimer?.cancel();
    _survivalTimer?.cancel();
    for (final timer in _moleTimers.values) {
      timer.cancel();
    }
    _moleTimers.clear();
  }

  void startGame() {
    if (isPlaying.value) return;

    // Reset game state for new game
    resetGame();
    isPlaying.value = true;
    isPaused.value = false;
    difficultyLevel.value = 1;

    // Initialize based on game mode
    switch (gameMode) {
      case 'classic':
        timeRemaining.value = 60;
        lives.value = 3;
        _startGameTimer();
        break;
      case 'survival':
        timeRemaining.value = -1;
        _initializeSurvival();
        break;
      case 'challenge':
        timeRemaining.value = -1;
        _initializeChallenge();
        break;
      case 'practice':
        timeRemaining.value = -1;
        _initializePractice();
        break;
    }

    // Start mole spawning
    _startMoleSpawnTimer();

    try {
      audioService.playBackgroundMusic();
    } catch (e) {
      debugPrint('Error playing background music: $e');
    }
  }

  void _initializePractice() {
    timeRemaining.value = -1; // Hide timer
    lives.value = 999;
    practiceStage.value = 0;
    practiceHits.value = 0;
    _showPracticeTutorial();
  }

  void _showPracticeTutorial() {
    if (practiceStage.value >= _practiceStages.length) {
      // Practice completed
      Get.snackbar(
        'Congratulations!',
        'You\'ve completed all practice stages!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      );
      endGame();
      return;
    }

    final stage = _practiceStages[practiceStage.value];
    tutorialText.value = stage['description'];
    practiceTarget.value = stage['target'];
    showTutorialText.value = true;

    Get.snackbar(
      'Practice Stage ${practiceStage.value + 1}',
      tutorialText.value,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
    );
  }

  void _initializeChallenge() {
    // Select a random challenge if not set
    if (currentChallenge.value >= _challenges.length) {
      currentChallenge.value = 0;
    }

    final challenge = _challenges[currentChallenge.value];
    challengeDescription.value = challenge['description'];
    timeRemaining.value = -1; // Always keep timer hidden in challenge mode
    targetScore.value = challenge['target'];

    // Reset challenge-specific counters
    goldenMolesHit.value = 0;
    perfectHits.value = 0;

    // Show challenge description
    Get.snackbar(
      'Challenge ${currentChallenge.value + 1}',
      challengeDescription.value,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.TOP,
    );
  }

  bool _checkChallengeComplete() {
    final challenge = _challenges[currentChallenge.value];
    switch (challenge['type']) {
      case 'golden':
        return goldenMolesHit.value >= targetScore.value;
      case 'score':
        return currentScore.value >= targetScore.value;
      case 'combo':
        return scoreController.consecutiveHits.value >= targetScore.value;
      case 'perfect':
        return perfectHits.value >= targetScore.value;
      default:
        return false;
    }
  }

  void pauseGame() {
    if (!isPlaying.value) return;
    isPaused.value = true;
    _cleanupTimers();
    try {
      audioService.pauseBackgroundMusic();
    } catch (e) {
      debugPrint('Error pausing background music: $e');
    }
  }

  void resumeGame() {
    if (!isPlaying.value) return;
    isPaused.value = false;

    // Only start game timer in classic mode
    if (gameMode == 'classic') {
      _startGameTimer();
    }

    _startMoleSpawnTimer();
    try {
      audioService.resumeBackgroundMusic();
    } catch (e) {
      debugPrint('Error resuming background music: $e');
    }
  }

  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!isPlaying.value || isPaused.value) return;

        // Only handle timer in classic mode
        if (gameMode == 'classic' && timeRemaining.value > 0) {
          timeRemaining.value--;
          if (timeRemaining.value <= 0) {
            endGame();
          }
        }
      },
    );
  }

  void _updateSurvivalDifficulty() {
    // Restart mole spawn timer with updated difficulty
    _startMoleSpawnTimer();

    // Show difficulty increase message
    Get.snackbar(
      'Stage Up!',
      'Stage ${survivalStage.value} - Difficulty increased!',
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
    );
  }

  void _startMoleSpawnTimer() {
    _moleTimer?.cancel();
    var spawnInterval = 1200; // default

    if (gameMode == 'practice') {
      final stage = _practiceStages[practiceStage.value];
      spawnInterval = stage['spawnInterval'] as int;
    } else if (gameMode == 'survival') {
      // Start with base spawn interval and adjust based on difficulty
      spawnInterval = 1200;
      // Adjust spawn interval based on difficulty level, but don't exceed max difficulty
      final adjustedLevel =
          min(difficultyLevel.value.toDouble(), _maxDifficultyLevel);
      spawnInterval =
          (spawnInterval * pow(_difficultySpeedMultiplier, adjustedLevel - 1))
              .toInt();
    } else {
      final settings = settingsController.getDifficultySettings();
      spawnInterval = settings['spawnInterval'] as int? ?? 1200;
    }

    _moleTimer = Timer.periodic(
      Duration(milliseconds: spawnInterval),
      (timer) {
        if (!isPlaying.value || isPaused.value) return;
        _spawnMole();
      },
    );
  }

  MoleType _getRandomMoleType(Random random, Map<String, dynamic> settings) {
    if (gameMode == 'practice') {
      final stage = _practiceStages[practiceStage.value];
      switch (stage['type']) {
        case 'normal':
          return MoleType.normal;
        case 'golden':
          return random.nextDouble() < 0.4 ? MoleType.golden : MoleType.normal;
        case 'bomb':
          return random.nextDouble() < 0.3 ? MoleType.bomb : MoleType.normal;
        case 'combo':
          return random.nextDouble() < 0.1 ? MoleType.bomb : MoleType.normal;
        default:
          return MoleType.normal;
      }
    }

    final value = random.nextDouble();
    var bombChance = settings['bombFrequency'] as double? ?? 0.2;
    var goldenChance = settings['goldenFrequency'] as double? ?? 0.15;

    // Adjust chances based on game mode and difficulty
    if (gameMode == 'survival') {
      // Start with base chances
      bombChance = 0.1;
      goldenChance = 0.2;

      // Adjust based on difficulty level
      bombChance += 0.02 *
          (difficultyLevel.value - 1); // Gradually increase from 10% to 18%
      goldenChance -= 0.02 *
          (difficultyLevel.value - 1); // Gradually decrease from 20% to 12%
    }

    if (value < bombChance) {
      return MoleType.bomb;
    } else if (value < bombChance + goldenChance) {
      return MoleType.golden;
    }
    return MoleType.normal;
  }

  void _startMoleProgressTimer(int index, int duration) {
    _moleTimers[index]?.cancel();

    const updateInterval = Duration(milliseconds: 16); // ~60 FPS
    var progress = 0.0;
    final progressIncrement = updateInterval.inMilliseconds / duration;

    _moleTimers[index] = Timer.periodic(updateInterval, (timer) {
      if (!isPlaying.value || isPaused.value) {
        timer.cancel();
        _moleTimers.remove(index);
        return;
      }

      progress += progressIncrement;

      if (progress >= 1.0) {
        timer.cancel();
        _moleTimers.remove(index);
        if (gameState.value.isActive[index]) {
          onMoleMissed();
          _hideMole(index);
        }
      } else {
        try {
          final newState = gameState.value.copyWith(
            moleProgress: List.from(gameState.value.moleProgress)
              ..[index] = progress,
          );
          gameState.value = newState;
        } catch (e) {
          debugPrint('Error updating mole progress: $e');
          timer.cancel();
          _moleTimers.remove(index);
        }
      }
    });
  }

  void _spawnMole() {
    if (!isPlaying.value || isPaused.value) return;

    try {
      final settings = settingsController.getDifficultySettings();
      final random = Random();

      // Find an empty hole
      final emptyHoles = List.generate(9, (i) => i)
          .where((i) => !gameState.value.isActive[i])
          .toList();

      if (emptyHoles.isEmpty) return;

      final holeIndex = emptyHoles[random.nextInt(emptyHoles.length)];
      final moleType = _getRandomMoleType(random, settings);
      final stayDuration = settings['stayDuration'] as int? ?? 1500;

      // Update game state
      final newState = gameState.value.copyWith(
        moles: List.from(gameState.value.moles)..[holeIndex] = moleType,
        isActive: List.from(gameState.value.isActive)..[holeIndex] = true,
        moleProgress: List.from(gameState.value.moleProgress)
          ..[holeIndex] = 0.0,
      );
      gameState.value = newState;

      // Start progress timer for this mole
      _startMoleProgressTimer(holeIndex, stayDuration);
    } catch (e) {
      debugPrint('Error spawning mole: $e');
    }
  }

  void _hideMole(int index) {
    try {
      _moleTimers[index]?.cancel();
      _moleTimers.remove(index);

      final newState = gameState.value.copyWith(
        moles: List.from(gameState.value.moles)..[index] = null,
        isActive: List.from(gameState.value.isActive)..[index] = false,
        moleProgress: List.from(gameState.value.moleProgress)..[index] = 0.0,
      );
      gameState.value = newState;
    } catch (e) {
      debugPrint('Error hiding mole: $e');
    }
  }

  void onMoleHit(int index) {
    if (!isPlaying.value || isPaused.value) return;

    final moleType = gameState.value.moles[index];
    if (moleType == null || !gameState.value.isActive[index]) return;

    try {
      hitEffectIndex.value = index;
      showHitEffect.value = true;

      // Update score based on mole type
      switch (moleType) {
        case MoleType.normal:
          final basePoints = gameMode == 'survival' ? 15 : 10;
          currentScore.value +=
              (basePoints * scoreController.getComboMultiplier()).toInt();
          scoreController.incrementCombo();
          if (gameMode == 'challenge') {
            perfectHits.value++;
          } else if (gameMode == 'practice') {
            _updatePracticeProgress(true);
          }
          audioService.playHitSound(false);
          break;
        case MoleType.golden:
          final basePoints = gameMode == 'survival' ? 45 : 30;
          currentScore.value +=
              (basePoints * scoreController.getComboMultiplier()).toInt();
          if (gameMode == 'survival' && lives.value < _initialLives) {
            lives.value++;
            Get.snackbar(
              'Extra Life!',
              'Golden mole gave you an extra life!',
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 1),
              snackPosition: SnackPosition.TOP,
            );
          } else if (gameMode == 'challenge') {
            goldenMolesHit.value++;
            perfectHits.value++;
          } else if (gameMode == 'practice') {
            _updatePracticeProgress(true);
          }
          scoreController.incrementCombo();
          audioService.playHitSound(true);
          break;
        case MoleType.bomb:
          if (gameMode == 'survival') {
            lives.value--;
            if (lives.value <= 0) {
              endGame();
              return;
            }
            Get.snackbar(
              'Lost a Life!',
              'Lives remaining: ${lives.value}',
              backgroundColor: Colors.red,
              colorText: Colors.white,
              duration: const Duration(seconds: 1),
              snackPosition: SnackPosition.TOP,
            );
          } else {
            currentScore.value = max(0, currentScore.value - 50);
            if (gameMode == 'challenge') {
              perfectHits.value = 0;
            } else if (gameMode == 'practice') {
              _updatePracticeProgress(false);
            }
          }
          scoreController.resetCombo();
          audioService.playBombSound();
          break;
      }

      // Check for challenge completion
      if (gameMode == 'challenge' && _checkChallengeComplete()) {
        currentChallenge.value++;
        if (currentChallenge.value >= _challenges.length) {
          // All challenges completed
          Get.snackbar(
            'Congratulations!',
            'All challenges completed!',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
            snackPosition: SnackPosition.TOP,
          );
          endGame();
        } else {
          // Next challenge
          Get.snackbar(
            'Challenge Complete!',
            'Starting next challenge...',
            backgroundColor: Colors.green,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
            snackPosition: SnackPosition.TOP,
          );
          _initializeChallenge();
        }
        return;
      }

      _hideMole(index);

      if (scoreController.consecutiveHits.value > 1) {
        showComboText.value = true;
        try {
          audioService.playComboSound(scoreController.consecutiveHits.value);
        } catch (e) {
          debugPrint('Error playing combo sound: $e');
        }
      }
    } catch (e) {
      debugPrint('Error handling mole hit: $e');
    }
  }

  void _updatePracticeProgress(bool success) {
    if (success) {
      practiceHits.value++;
      if (practiceHits.value >= practiceTarget.value) {
        // Stage completed
        practiceStage.value++;
        practiceHits.value = 0;
        Get.snackbar(
          'Stage Complete!',
          'Well done! Moving to next stage...',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          snackPosition: SnackPosition.TOP,
        );
        _showPracticeTutorial();
      }
    } else {
      // Show hint on failure
      Get.snackbar(
        'Try Again!',
        'Remember to avoid the bomb moles!',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void onMoleMissed() {
    scoreController.resetCombo();
    if (gameMode == 'challenge') {
      perfectHits.value = 0;
    } else if (gameMode == 'practice') {
      // Show encouraging message in practice mode
      Get.snackbar(
        'Keep Trying!',
        'Try to hit the mole before it disappears!',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.TOP,
      );
    }
    try {
      audioService.playMissSound();
    } catch (e) {
      debugPrint('Error playing miss sound: $e');
    }
  }

  void endGame() {
    isPlaying.value = false;
    _cleanupTimers();

    try {
      audioService.stopBackgroundMusic();
    } catch (e) {
      debugPrint('Error stopping background music: $e');
    }

    // Update stats
    settingsController.updateStats(
      score: currentScore.value,
      combo: scoreController.highestCombo.value,
    );

    // Navigate to game over screen
    Get.off(
      () => WhackAMoleGameOverScreen(
        score: currentScore.value,
        highScore: settingsController.highScore,
        combo: scoreController.highestCombo.value,
      ),
      transition: Transition.fadeIn,
    );
  }

  void resetGame() {
    // Reset game state
    gameState.value = GameState.initial();
    currentScore.value = 0;
    timeRemaining.value = -1; // Default to hidden timer
    lives.value = 3;
    isPlaying.value = false;
    isPaused.value = false;
    showHitEffect.value = false;
    showComboText.value = false;
    hitEffectIndex.value = 0;
    survivalTime.value = 0; // Reset survival time
    scoreController.resetScore();

    // Cleanup
    _cleanupTimers();
    try {
      audioService.stopBackgroundMusic();
    } catch (e) {
      debugPrint('Error stopping background music: $e');
    }
  }

  void quitGame() {
    resetGame();
    Get.back(); // Return to mode selection screen
  }

  void onHitEffectComplete() {
    showHitEffect.value = false;
  }

  void onComboTextComplete() {
    showComboText.value = false;
  }

  void _initializeSurvival() {
    lives.value = 3;
    timeRemaining.value = -1; // Hide timer
    _startSurvivalTimer();
  }

  void _startSurvivalTimer() {
    _survivalTimer?.cancel();
    _survivalTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        survivalTime.value++;
        // Increase difficulty every _difficultyIncreaseInterval seconds
        if (survivalTime.value % _difficultyIncreaseInterval == 0 &&
            difficultyLevel.value < _maxDifficultyLevel) {
          survivalStage.value++;
          difficultyLevel.value++;
          _updateSurvivalDifficulty();
        }
      },
    );
  }
}
