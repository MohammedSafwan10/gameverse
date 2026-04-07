import 'package:flutter_test/flutter_test.dart';
import 'package:gameverse/games/word_games/hangman/models/game_state.dart';
import 'package:gameverse/games/word_games/hangman/services/word_service.dart';

void main() {
  test('daily category and word are stable for the same date', () {
    final date = DateTime(2026, 4, 7);

    final categoryA = WordService.getDailyCategory(date: date);
    final categoryB = WordService.getDailyCategory(date: date);
    final wordA = WordService.getDailyWord(date: date);
    final wordB = WordService.getDailyWord(date: date);

    expect(categoryA, categoryB);
    expect(wordA, wordB);
    expect(categoryA, isNot(WordCategory.custom));
  });

  test('daily category and word stay aligned across dates', () {
    final firstDate = DateTime(2026, 4, 7);
    final secondDate = DateTime(2026, 4, 8);

    final firstCategory = WordService.getDailyCategory(date: firstDate);
    final secondCategory = WordService.getDailyCategory(date: secondDate);
    final firstWord = WordService.getDailyWord(date: firstDate);
    final secondWord = WordService.getDailyWord(date: secondDate);

    expect(firstCategory, isNot(WordCategory.custom));
    expect(secondCategory, isNot(WordCategory.custom));
    expect(firstWord, isNotEmpty);
    expect(secondWord, isNotEmpty);
  });
}
