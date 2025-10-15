import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../models/card_model.dart';
import '../models/game_mode.dart';
import '../models/game_state.dart';
import '../services/sound_service.dart';
import '../screens/completion_screen.dart';

class MemoryMatchGameController extends GetxController {
  final _state = Rx<MemoryMatchState?>(null);
  MemoryMatchState? get state => _state.value;
  set state(MemoryMatchState? value) => _state.value = value;

  Timer? _gameTimer;
  Timer? _flipBackTimer;
  late final SoundService _soundService;
  final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );

  @override
  void onInit() {
    super.onInit();
    _soundService = Get.find<SoundService>();
  }

  @override
  void onClose() {
    _logger.i('Closing game controller');
    _gameTimer?.cancel();
    _flipBackTimer?.cancel();
    super.onClose();
  }

  void initGame(MemoryMatchMode mode, GameDifficulty difficulty) {
    // Cancel any existing timers
    _gameTimer?.cancel();
    _flipBackTimer?.cancel();

    final cards = _generateCards(difficulty);
    _state.value = MemoryMatchState(
      cards: cards,
      mode: mode,
      difficulty: difficulty,
      startTime: DateTime.now(),
      status: GameStatus.playing,
      moves: 0,
      score: 0,
      timeElapsed: 0,
    );
    _startGameTimer();
  }

  List<MemoryCard> _generateCards(GameDifficulty difficulty) {
    final gridSize = difficulty == GameDifficulty.easy
        ? 4
        : difficulty == GameDifficulty.medium
            ? 6
            : 8;
    final pairCount = (gridSize * gridSize) ~/ 2;

    // Create a shuffled list of emojis and take only what we need
    final shuffledEmojis = List<String>.from(CardThemes.emojis)..shuffle();
    final selectedEmojis = shuffledEmojis.sublist(0, pairCount);

    // Create pairs of cards
    final cards = <MemoryCard>[];
    for (var i = 0; i < pairCount; i++) {
      final emoji = selectedEmojis[i];
      final color = CardThemes.getRandomBackgroundColor();

      // Add two cards with the same emoji (a pair)
      for (var j = 0; j < 2; j++) {
        cards.add(MemoryCard(
          id: i * 2 + j,
          emoji: emoji,
          backgroundColor: color,
        ));
      }
    }

    // Shuffle the cards
    cards.shuffle(Random());
    return cards;
  }

  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentState = state;
      if (currentState != null && currentState.status == GameStatus.playing) {
        _state.value = currentState.copyWith(
          timeElapsed: currentState.timeElapsed + 1,
        );
      }
    });
  }

  void showMatchAnimation(int index) {
    final currentState = state;
    if (currentState == null) return;

    final card = currentState.cards[index];
    if (!card.isMatched) return;

    // Update the card to trigger animation
    final cards = List<MemoryCard>.from(currentState.cards);
    cards[index] = cards[index].copyWith(
      isMatched: true,
      isFlipped: true,
    );

    _state.value = currentState.copyWith(cards: cards);

    // Play match sound for the animation
    _soundService.playMatchSuccess();

    // Add a small vibration effect if available
    try {
      // HapticFeedback.mediumImpact(); // Uncomment if haptics are added
    } catch (e) {
      _logger.d('Haptic feedback not available');
    }
  }

  void flipCard(int index) {
    final currentState = state;
    if (currentState == null) {
      _logger.w('Cannot flip card: game state is null');
      return;
    }

    final card = currentState.cards[index];
    _logger.d(
        'Attempting to flip card $index: ${card.emoji} (isFlipped: ${card.isFlipped}, isMatched: ${card.isMatched})');

    // Check if card can be flipped
    if (currentState.isChecking) {
      _logger.d('Cannot flip: game is checking matches');
      return;
    }
    if (card.isFlipped) {
      _logger.d('Cannot flip: card is already flipped');
      return;
    }
    if (card.isMatched) {
      _logger.d('Cannot flip: card is already matched');
      return;
    }
    if (currentState.status != GameStatus.playing) {
      _logger.d('Cannot flip: game status is ${currentState.status}');
      return;
    }

    // Prevent double-tap issues
    if (currentState.firstCard?.id == card.id) {
      _logger.d('Cannot flip: card was just flipped');
      return;
    }

    // Cancel any pending flip back timer
    _flipBackTimer?.cancel();

    _soundService.playCardFlip();
    final cards = List<MemoryCard>.from(currentState.cards);
    cards[index] = cards[index].copyWith(isFlipped: true);

    if (currentState.firstCard == null) {
      // First card flipped
      _logger.d('First card flipped: ${card.emoji}');
      _state.value = currentState.copyWith(
        cards: cards,
        firstCard: cards[index],
        isChecking: false,
      );
    } else {
      // Second card flipped
      _logger.d('Second card flipped: ${card.emoji}');
      _state.value = currentState.copyWith(
        cards: cards,
        secondCard: cards[index],
        moves: currentState.moves + 1,
        isChecking: true,
      );

      _checkMatch();
    }
  }

  void _checkMatch() {
    _flipBackTimer?.cancel();
    _flipBackTimer = Timer(const Duration(milliseconds: 800), () {
      final currentState = state;
      if (currentState == null || !currentState.isChecking) {
        _logger.w('Cannot check match: invalid state');
        return;
      }

      final cards = List<MemoryCard>.from(currentState.cards);
      final firstCard = currentState.firstCard;
      final secondCard = currentState.secondCard;

      if (firstCard == null || secondCard == null) {
        _logger.w('Cannot check match: cards are null');
        _state.value = currentState.copyWith(
          isChecking: false,
          firstCard: null,
          secondCard: null,
        );
        return;
      }

      _logger.d(
          'Checking match between ${firstCard.emoji} and ${secondCard.emoji}');

      if (firstCard.emoji == secondCard.emoji) {
        // Match found
        _logger.i('Match found! 🎉');
        _soundService.playMatchSuccess();

        final firstIndex = cards.indexWhere((card) => card.id == firstCard.id);
        final secondIndex =
            cards.indexWhere((card) => card.id == secondCard.id);

        if (firstIndex != -1 && secondIndex != -1) {
          // First mark as matched and keep flipped
          cards[firstIndex] = cards[firstIndex].copyWith(
            isMatched: true,
            isFlipped: true,
          );
          cards[secondIndex] = cards[secondIndex].copyWith(
            isMatched: true,
            isFlipped: true,
          );

          final newScore = currentState.score + _calculateScore();
          final isCompleted = cards.every((card) => card.isMatched);

          // Update state immediately to show matched cards
          _state.value = currentState.copyWith(
            cards: cards,
            firstCard: null,
            secondCard: null,
            isChecking: false,
            score: newScore,
            status: isCompleted ? GameStatus.completed : GameStatus.playing,
          );

          // Trigger match animations with a slight delay between them for better visual effect
          showMatchAnimation(firstIndex);
          Future.delayed(const Duration(milliseconds: 200), () {
            showMatchAnimation(secondIndex);
          });

          if (isCompleted) {
            // Add a longer delay before showing completion screen to let animations finish
            Future.delayed(const Duration(milliseconds: 800), () {
              _onGameComplete();
            });
          }
        }
      } else {
        // No match
        _logger.d('No match found');
        _soundService.playMatchFail();

        final firstIndex = cards.indexWhere((card) => card.id == firstCard.id);
        final secondIndex =
            cards.indexWhere((card) => card.id == secondCard.id);

        if (firstIndex != -1 && secondIndex != -1) {
          // Add small delay before flipping back for better UX
          Future.delayed(const Duration(milliseconds: 200), () {
            if (state == null) return; // Safety check

            final updatedCards = List<MemoryCard>.from(cards);
            updatedCards[firstIndex] =
                updatedCards[firstIndex].copyWith(isFlipped: false);
            updatedCards[secondIndex] =
                updatedCards[secondIndex].copyWith(isFlipped: false);

            _state.value = currentState.copyWith(
              cards: updatedCards,
              firstCard: null,
              secondCard: null,
              isChecking: false,
            );
          });
        }
      }
    });
  }

  void _onGameComplete() {
    _gameTimer?.cancel();
    _flipBackTimer?.cancel();
    _soundService.playGameComplete();

    final currentState = state;
    if (currentState == null) return;

    Timer(const Duration(milliseconds: 500), () {
      Get.to(
        () => GameCompletionScreen(
          mode: currentState.mode,
          difficulty: currentState.difficulty,
          score: currentState.score,
          moves: currentState.moves,
          timeElapsed: currentState.timeElapsed,
        ),
        transition: Transition.fadeIn,
      );
    });
  }

  int _calculateScore() {
    final currentState = state;
    if (currentState == null) return 0;

    // Base score for finding a match
    int baseScore = 100;

    // Bonus for quick matches (in time trial mode)
    if (currentState.mode == MemoryMatchMode.timeTrial) {
      baseScore += max(0, 50 - currentState.timeElapsed ~/ 2);
    }

    // Bonus for fewer moves
    baseScore += max(0, 100 - (currentState.moves * 5));

    // Difficulty multiplier
    final multiplier = switch (currentState.difficulty) {
      GameDifficulty.easy => 1.0,
      GameDifficulty.medium => 1.5,
      GameDifficulty.hard => 2.0,
    };

    return (baseScore * multiplier).round();
  }

  void pauseGame() {
    _logger.i('Pausing game');
    _gameTimer?.cancel();
    final currentState = state;
    if (currentState != null) {
      _state.value = currentState.copyWith(status: GameStatus.paused);
    }
    update();
  }

  void resumeGame() {
    _logger.i('Resuming game');
    final currentState = state;
    if (currentState?.status == GameStatus.paused) {
      _state.value = currentState!.copyWith(status: GameStatus.playing);
      _startGameTimer();
      update();
    }
  }

  void cleanupGame() {
    _logger.i('Cleaning up game resources');
    _gameTimer?.cancel();
    _flipBackTimer?.cancel();
    state = null;
    update();
  }

  void restartGame() {
    final currentState = state;
    if (currentState == null) return;

    final cards = _generateCards(currentState.difficulty);
    _state.value = currentState.copyWith(
      cards: cards,
      status: GameStatus.playing,
      moves: 0,
      score: 0,
      timeElapsed: 0,
      startTime: DateTime.now(),
      firstCard: null,
      secondCard: null,
      isChecking: false,
    );
  }
}
