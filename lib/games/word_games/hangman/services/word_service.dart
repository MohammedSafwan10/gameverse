import 'dart:math';
import '../models/game_state.dart';

class WordService {
  static final Map<WordCategory, List<String>> _wordDatabase = {
    WordCategory.animals: [
      'ELEPHANT', 'GIRAFFE', 'PENGUIN', 'DOLPHIN', 'KANGAROO',
      'OCTOPUS', 'CHEETAH', 'ZEBRA', 'LION', 'TIGER',
      'PANDA', 'KOALA', 'MONKEY', 'GORILLA', 'RHINOCEROS',
    ],
    WordCategory.countries: [
      'BRAZIL', 'JAPAN', 'FRANCE', 'AUSTRALIA', 'CANADA',
      'ITALY', 'SPAIN', 'EGYPT', 'INDIA', 'MEXICO',
      'RUSSIA', 'CHINA', 'GERMANY', 'THAILAND', 'GREECE',
    ],
    WordCategory.sports: [
      'FOOTBALL', 'BASKETBALL', 'TENNIS', 'VOLLEYBALL', 'CRICKET',
      'BASEBALL', 'HOCKEY', 'RUGBY', 'SWIMMING', 'BOXING',
      'GOLF', 'SKIING', 'SURFING', 'CYCLING', 'WRESTLING',
    ],
    WordCategory.food: [
      'PIZZA', 'SUSHI', 'BURGER', 'PASTA', 'TACOS',
      'PANCAKES', 'CHOCOLATE', 'SANDWICH', 'NOODLES', 'CURRY',
      'SALAD', 'STEAK', 'ICECREAM', 'COOKIES', 'SMOOTHIE',
    ],
    WordCategory.movies: [
      'AVATAR', 'TITANIC', 'STARWARS', 'MATRIX', 'INCEPTION',
      'JAWS', 'FROZEN', 'GLADIATOR', 'BATMAN', 'SPIDERMAN',
      'JURASSIC', 'AVENGERS', 'GODFATHER', 'TERMINATOR', 'ALIEN',
    ],
  };

  static String getRandomWord(WordCategory category) {
    if (category == WordCategory.custom) {
      throw ArgumentError('Custom category requires a specific word');
    }
    
    final words = _wordDatabase[category]!;
    return words[Random().nextInt(words.length)];
  }

  static String getDailyWord() {
    // Get a random category
    final categories = WordCategory.values.where((c) => c != WordCategory.custom).toList();
    final category = categories[Random().nextInt(categories.length)];
    
    // Use the day of year as seed for consistent daily word
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    final words = _wordDatabase[category]!;
    return words[dayOfYear % words.length];
  }

  static bool isValidWord(String word) {
    // Check if the word contains only letters and spaces
    return RegExp(r'^[A-Z ]+$').hasMatch(word);
  }

  static int calculateScore(HangmanGameState state) {
    if (state.status != HangmanGameStatus.won) return 0;

    final timeBonus = max(0, 300 - DateTime.now().difference(state.startTime).inSeconds);
    final livesBonus = state.remainingLives * 50;
    final wordLengthBonus = state.word.length * 10;
    final hintsDeduction = (3 - state.hintsRemaining) * 30;

    return timeBonus + livesBonus + wordLengthBonus - hintsDeduction;
  }

  static String getRandomHint(HangmanGameState state) {
    final unguessedLetters = state.word
        .split('')
        .where((letter) => !state.guessedLetters.contains(letter.toLowerCase()))
        .toList();
    
    if (unguessedLetters.isEmpty) return '';
    return unguessedLetters[Random().nextInt(unguessedLetters.length)];
  }
} 