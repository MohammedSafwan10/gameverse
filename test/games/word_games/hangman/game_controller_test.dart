import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameverse/games/word_games/hangman/controllers/game_controller.dart';
import 'package:gameverse/games/word_games/hangman/models/game_state.dart';
import 'package:gameverse/games/word_games/hangman/services/sound_service.dart';
import 'package:gameverse/games/word_games/hangman/services/storage_service.dart';

class _FakeStorageService extends HangmanStorageService {
  Map<String, int> storedStats = {
    'gamesPlayed': 0,
    'gamesWon': 0,
    'currentStreak': 0,
    'bestStreak': 0,
    'hintsUsed': 0,
    'totalScore': 0,
  };
  final List<int> storedScores = [];

  @override
  List<int> getHighScores() => List<int>.from(storedScores);

  @override
  Future<void> addHighScore(int score) async {
    storedScores.add(score);
  }

  @override
  Map<String, int> getStats() => Map<String, int>.from(storedStats);

  @override
  Future<void> updateStats(HangmanGameState state) async {
    storedStats['gamesPlayed'] = (storedStats['gamesPlayed'] ?? 0) + 1;
  }

  @override
  bool canPlayDailyChallenge() => true;

  @override
  Future<void> saveDailyChallengeProgress(DateTime date, int score) async {}
}

class _FakeSoundService extends HangmanSoundService {
  int correctCalls = 0;
  int wrongCalls = 0;
  int hintCalls = 0;

  @override
  Future<void> playCorrectGuess() async {
    correctCalls++;
  }

  @override
  Future<void> playWrongGuess() async {
    wrongCalls++;
  }

  @override
  Future<void> playGameOver() async {}

  @override
  Future<void> playGameWon() async {}

  @override
  Future<void> playHint() async {
    hintCalls++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');

  setUpAll(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (methodCall) async {
      if (methodCall.method == 'getApplicationDocumentsDirectory' ||
          methodCall.method == 'getApplicationSupportDirectory' ||
          methodCall.method == 'getTemporaryDirectory') {
        return 'D:/Dev/freela/gameverse/.dart_tool/test_storage';
      }
      return null;
    });
  });

  test('duplicate wrong guesses do not cost extra lives or replay sound', () async {
    final sound = _FakeSoundService();
    final controller = HangmanGameController(_FakeStorageService(), sound);

    await controller.startGame(
      HangmanGameMode.twoPlayers,
      customWord: 'DART',
    );

    await controller.makeGuess('z');
    await controller.makeGuess('Z');

    expect(controller.gameState.value.remainingLives, 5);
    expect(controller.gameState.value.guessedLetters, {'z'});
    expect(sound.wrongCalls, 1);
  });

  test('hint reveals only a new letter and consumes one hint', () async {
    final sound = _FakeSoundService();
    final controller = HangmanGameController(_FakeStorageService(), sound);

    await controller.startGame(
      HangmanGameMode.twoPlayers,
      customWord: 'A B',
    );
    await controller.makeGuess('a');

    await controller.useHint();

    expect(controller.gameState.value.guessedLetters, containsAll({'a', 'b'}));
    expect(controller.gameState.value.guessedLetters, isNot(contains(' ')));
    expect(controller.gameState.value.hintsRemaining, 2);
    expect(sound.hintCalls, 1);
  });
}