import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
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

  // Challenge mode tracking
  int _challengeLevel = 1;
  int get challengeLevel => _challengeLevel;

  @override
  void onInit() {
    super.onInit();
    _soundService = Get.find<SoundService>();
  }

  @override
  void onClose() {
    _gameTimer?.cancel();
    _flipBackTimer?.cancel();
    super.onClose();
  }

  void initGame(MemoryMatchMode mode, GameDifficulty difficulty) {
    _gameTimer?.cancel();
    _flipBackTimer?.cancel();
    if (mode == MemoryMatchMode.challenge) _challengeLevel = 1;

    final cards = _generateCards(difficulty);
    _state.value = MemoryMatchState(
      cards: cards,
      mode: mode,
      difficulty: difficulty,
      startTime: DateTime.now(),
      status: GameStatus.playing,
    );
    _startGameTimer();
  }

  // ---- Card Generation ----

  List<MemoryCard> _generateCards(GameDifficulty difficulty) {
    final cols = switch (difficulty) {
      GameDifficulty.easy => 4,
      GameDifficulty.medium => 4,
      GameDifficulty.hard => 5,
    };
    final rows = switch (difficulty) {
      GameDifficulty.easy => 3,
      GameDifficulty.medium => 4,
      GameDifficulty.hard => 4,
    };
    final pairCount = (cols * rows) ~/ 2;

    // Pick a random theme or mix themes
    final random = Random();
    final themeIndex = random.nextInt(CardThemes.allThemes.length);
    final themeEmojis = List<String>.from(CardThemes.allThemes[themeIndex])
      ..shuffle(random);

    // If theme doesn't have enough, pull from other themes
    final pool = List<String>.from(themeEmojis);
    if (pool.length < pairCount) {
      for (final theme in CardThemes.allThemes) {
        if (theme == CardThemes.allThemes[themeIndex]) continue;
        for (final emoji in theme) {
          if (!pool.contains(emoji)) pool.add(emoji);
          if (pool.length >= pairCount) break;
        }
        if (pool.length >= pairCount) break;
      }
    }

    final selectedEmojis = pool.sublist(0, pairCount);
    final cards = <MemoryCard>[];

    for (var i = 0; i < pairCount; i++) {
      final color = CardThemes.getColorForIndex(i);
      for (var j = 0; j < 2; j++) {
        cards.add(MemoryCard(
          id: i * 2 + j,
          emoji: selectedEmojis[i],
          backgroundColor: color,
        ));
      }
    }

    cards.shuffle(random);
    return cards;
  }

  // ---- Timer ----

  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final s = state;
      if (s == null || s.status != GameStatus.playing) return;

      final newTime = s.timeElapsed + 1;

      // Time-trial: check time limit
      if (s.mode == MemoryMatchMode.timeTrial && newTime >= s.timeLimit) {
        _state.value = s.copyWith(
          timeElapsed: newTime,
          status: GameStatus.timeUp,
        );
        _gameTimer?.cancel();
        _soundService.playMatchFail();
        _onGameOver();
        return;
      }

      _state.value = s.copyWith(timeElapsed: newTime);
    });
  }

  // ---- Card Flipping ----

  void flipCard(int index) {
    final s = state;
    if (s == null) return;

    final card = s.cards[index];
    if (s.isChecking || card.isFlipped || card.isMatched) return;
    if (s.status != GameStatus.playing) return;
    if (s.firstCard?.id == card.id) return;

    _flipBackTimer?.cancel();
    _soundService.playCardFlip();

    final cards = List<MemoryCard>.from(s.cards);
    cards[index] = cards[index].copyWith(isFlipped: true);

    if (s.firstCard == null) {
      _state.value = s.copyWith(cards: cards, firstCard: cards[index]);
    } else {
      _state.value = s.copyWith(
        cards: cards,
        secondCard: cards[index],
        moves: s.moves + 1,
        isChecking: true,
      );
      _checkMatch();
    }
  }

  void _checkMatch() {
    _flipBackTimer?.cancel();
    _flipBackTimer = Timer(const Duration(milliseconds: 700), () {
      final s = state;
      if (s == null || !s.isChecking) return;

      final first = s.firstCard;
      final second = s.secondCard;
      if (first == null || second == null) {
        _state.value = s.copyWith(isChecking: false);
        return;
      }

      final cards = List<MemoryCard>.from(s.cards);
      final firstIdx = cards.indexWhere((c) => c.id == first.id);
      final secondIdx = cards.indexWhere((c) => c.id == second.id);
      if (firstIdx == -1 || secondIdx == -1) return;

      if (first.emoji == second.emoji) {
        // ---- MATCH ----
        _soundService.playMatchSuccess();
        cards[firstIdx] =
            cards[firstIdx].copyWith(isMatched: true, isFlipped: true);
        cards[secondIdx] =
            cards[secondIdx].copyWith(isMatched: true, isFlipped: true);

        final newCombo = s.combo + 1;
        final newBest = max(newCombo, s.bestCombo);
        final newMatch = s.matchCount + 1;
        final scoreGain = _calculateScore(s, newCombo);

        final isComplete = cards.every((c) => c.isMatched);

        _state.value = s.copyWith(
          cards: cards,
          firstCard: null,
          secondCard: null,
          isChecking: false,
          score: s.score + scoreGain,
          combo: newCombo,
          bestCombo: newBest,
          matchCount: newMatch,
          status: isComplete ? GameStatus.completed : GameStatus.playing,
        );

        if (isComplete) {
          Future.delayed(const Duration(milliseconds: 800), _onGameComplete);
        }
      } else {
        // ---- NO MATCH ----
        _soundService.playMatchFail();
        Future.delayed(const Duration(milliseconds: 300), () {
          if (state == null) return;
          final updatedCards = List<MemoryCard>.from(state!.cards);
          final fi = updatedCards.indexWhere((c) => c.id == first.id);
          final si = updatedCards.indexWhere((c) => c.id == second.id);
          if (fi != -1) {
            updatedCards[fi] = updatedCards[fi].copyWith(isFlipped: false);
          }
          if (si != -1) {
            updatedCards[si] = updatedCards[si].copyWith(isFlipped: false);
          }

          _state.value = state!.copyWith(
            cards: updatedCards,
            firstCard: null,
            secondCard: null,
            isChecking: false,
            combo: 0,
          );
        });
      }
    });
  }

  // ---- Scoring ----

  int _calculateScore(MemoryMatchState s, int combo) {
    int base = 100;

    // Combo multiplier: 1x, 1.5x, 2x, 2.5x, 3x...
    final comboMultiplier = 1.0 + (combo - 1) * 0.5;
    base = (base * comboMultiplier).round();

    // Time bonus (time trial): faster = more points
    if (s.mode == MemoryMatchMode.timeTrial) {
      base += max(0, (s.timeLimit - s.timeElapsed) * 2);
    }

    // Fewer moves bonus
    final expectedMoves = s.totalPairs;
    if (s.moves <= expectedMoves * 2) {
      base += 50;
    }

    // Difficulty multiplier
    final diffMult = switch (s.difficulty) {
      GameDifficulty.easy => 1.0,
      GameDifficulty.medium => 1.5,
      GameDifficulty.hard => 2.0,
    };

    // Challenge level bonus
    final challengeBonus =
        s.mode == MemoryMatchMode.challenge ? _challengeLevel * 25 : 0;

    return (base * diffMult).round() + challengeBonus;
  }

  // ---- Game Lifecycle ----

  void _onGameComplete() {
    _gameTimer?.cancel();
    _flipBackTimer?.cancel();
    _soundService.playGameComplete();

    final s = state;
    if (s == null) return;

    // Challenge mode: auto-advance difficulty
    if (s.mode == MemoryMatchMode.challenge) {
      _challengeLevel++;
    }

    Timer(const Duration(milliseconds: 400), () {
      Get.to(
        () => GameCompletionScreen(
          mode: s.mode,
          difficulty: s.difficulty,
          score: s.score,
          moves: s.moves,
          timeElapsed: s.timeElapsed,
          combo: s.bestCombo,
          starRating: s.starRating,
          challengeLevel: _challengeLevel,
        ),
        transition: Transition.fadeIn,
      );
    });
  }

  void _onGameOver() {
    _gameTimer?.cancel();
    _flipBackTimer?.cancel();

    final s = state;
    if (s == null) return;

    Timer(const Duration(milliseconds: 600), () {
      Get.to(
        () => GameCompletionScreen(
          mode: s.mode,
          difficulty: s.difficulty,
          score: s.score,
          moves: s.moves,
          timeElapsed: s.timeElapsed,
          combo: s.bestCombo,
          starRating: 0,
          challengeLevel: _challengeLevel,
          isTimeUp: true,
        ),
        transition: Transition.fadeIn,
      );
    });
  }

  // ---- Controls ----

  void pauseGame() {
    _gameTimer?.cancel();
    final s = state;
    if (s != null) _state.value = s.copyWith(status: GameStatus.paused);
  }

  void resumeGame() {
    final s = state;
    if (s?.status == GameStatus.paused) {
      _state.value = s!.copyWith(status: GameStatus.playing);
      _startGameTimer();
    }
  }

  void restartGame() {
    final s = state;
    if (s == null) return;

    _gameTimer?.cancel();
    _flipBackTimer?.cancel();

    final cards = _generateCards(s.difficulty);
    _state.value = MemoryMatchState(
      cards: cards,
      mode: s.mode,
      difficulty: s.difficulty,
      startTime: DateTime.now(),
      status: GameStatus.playing,
    );
    _startGameTimer();
  }

  /// For challenge mode: play the next level with harder difficulty
  void nextChallengeLevel() {
    final s = state;
    if (s == null) return;

    // Cycle difficulty: easy -> medium -> hard -> hard
    final nextDiff = switch (s.difficulty) {
      GameDifficulty.easy => GameDifficulty.medium,
      GameDifficulty.medium => GameDifficulty.hard,
      GameDifficulty.hard => GameDifficulty.hard,
    };

    initGame(MemoryMatchMode.challenge, nextDiff);
  }

  void cleanupGame() {
    _gameTimer?.cancel();
    _flipBackTimer?.cancel();
    state = null;
  }

  void showMatchAnimation(int index) {
    // Kept for backward compatibility - animation is handled by widget
  }
}
