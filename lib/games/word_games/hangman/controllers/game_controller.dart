import 'package:get/get.dart';
import '../models/game_state.dart';
import '../services/word_service.dart';
import '../services/storage_service.dart';
import '../services/sound_service.dart';

class HangmanGameController extends GetxController {
  final HangmanStorageService _storageService;
  final HangmanSoundService _soundService;

  final Rx<HangmanGameState> gameState = HangmanGameState(
    word: '',
    mode: HangmanGameMode.singlePlayer,
    category: WordCategory.custom,
    startTime: DateTime.now(),
  ).obs;

  final RxList<int> highScores = <int>[].obs;
  final RxMap<String, int> stats = <String, int>{}.obs;

  HangmanGameController(
    this._storageService,
    this._soundService,
  );

  @override
  void onInit() {
    super.onInit();
    _loadHighScores();
    _loadStats();
  }

  Future<void> startGame(HangmanGameMode mode,
      {WordCategory? category, String? customWord}) async {
    String word;
    WordCategory finalCategory;

    if (mode == HangmanGameMode.dailyChallenge) {
      if (!_storageService.canPlayDailyChallenge()) {
        Get.snackbar(
          'Daily Challenge',
          'You have already played today\'s challenge. Come back tomorrow!',
          duration: const Duration(seconds: 3),
        );
        return;
      }
      word = WordService.getDailyWord();
      finalCategory = WordCategory.custom;
    } else if (mode == HangmanGameMode.twoPlayers) {
      if (customWord == null || customWord.isEmpty) {
        throw ArgumentError('Custom word required for two players mode');
      }
      word = customWord;
      finalCategory = WordCategory.custom;
    } else {
      if (category == null) {
        throw ArgumentError('Category required for single player mode');
      }
      word = WordService.getRandomWord(category);
      finalCategory = category;
    }

    gameState.value = HangmanGameState(
      word: word,
      mode: mode,
      category: finalCategory,
      startTime: DateTime.now(),
    );
  }

  Future<void> makeGuess(String letter) async {
    if (gameState.value.isGameOver) return;

    final isCorrect =
        gameState.value.word.toLowerCase().contains(letter.toLowerCase());

    // Play sound effect
    if (isCorrect) {
      await _soundService.playCorrectGuess();
    } else {
      await _soundService.playWrongGuess();
    }

    // Update game state
    final newLives = isCorrect
        ? gameState.value.remainingLives
        : gameState.value.remainingLives - 1;
    final newGuessedLetters = Set<String>.from(gameState.value.guessedLetters)
      ..add(letter.toLowerCase());

    final newStatus = _determineGameStatus(
      newLives,
      gameState.value.word,
      newGuessedLetters,
    );

    gameState.value = gameState.value.copyWith(
      guessedLetters: newGuessedLetters,
      remainingLives: newLives,
      status: newStatus,
    );

    // Handle game over
    if (newStatus != HangmanGameStatus.playing) {
      await _handleGameOver(newStatus);
    }
  }

  Future<void> useHint() async {
    if (gameState.value.isGameOver || gameState.value.hintsRemaining <= 0) return;

    final hint = WordService.getRandomHint(gameState.value);
    if (hint.isEmpty) return;

    await _soundService.playHint();

    gameState.value = gameState.value.copyWith(
      hintsRemaining: gameState.value.hintsRemaining - 1,
    );

    await makeGuess(hint);
  }

  HangmanGameStatus _determineGameStatus(
    int lives,
    String word,
    Set<String> guessedLetters,
  ) {
    if (lives <= 0) return HangmanGameStatus.lost;

    // Check if all letters are guessed
    final unguessedLetters = word
        .toLowerCase()
        .split('')
        .where((letter) => !guessedLetters.contains(letter))
        .where((letter) => letter != ' ');

    return unguessedLetters.isEmpty
        ? HangmanGameStatus.won
        : HangmanGameStatus.playing;
  }

  Future<void> _handleGameOver(HangmanGameStatus status) async {
    if (status == HangmanGameStatus.won) {
      await _soundService.playGameWon();
      final score = WordService.calculateScore(gameState.value);
      await _storageService.addHighScore(score);

      if (gameState.value.mode == HangmanGameMode.dailyChallenge) {
        await _storageService.saveDailyChallengeProgress(
          DateTime.now(),
          score,
        );
      }
    } else {
      await _soundService.playGameOver();
    }

    await _storageService.updateStats(gameState.value);
    _loadStats();
    _loadHighScores();
  }

  void _loadHighScores() {
    highScores.value = _storageService.getHighScores();
  }

  void _loadStats() {
    stats.value = _storageService.getStats();
  }

  void toggleSound() {
    _soundService.toggleMute();
    update(); // Notify UI about sound state change
  }

  bool get isSoundMuted => _soundService.isMuted;
}
