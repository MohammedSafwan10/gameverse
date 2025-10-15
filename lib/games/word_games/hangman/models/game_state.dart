import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum HangmanGameMode { singlePlayer, twoPlayers, dailyChallenge }
enum HangmanGameStatus { playing, won, lost }
enum WordCategory {
  animals,
  countries,
  sports,
  food,
  movies,
  custom;

  String get displayName {
    switch (this) {
      case WordCategory.animals:
        return 'Animals';
      case WordCategory.countries:
        return 'Countries';
      case WordCategory.sports:
        return 'Sports';
      case WordCategory.food:
        return 'Food & Drinks';
      case WordCategory.movies:
        return 'Movies & TV';
      case WordCategory.custom:
        return 'Custom';
    }
  }

  IconData get icon {
    switch (this) {
      case WordCategory.animals:
        return Icons.pets;
      case WordCategory.countries:
        return Icons.public;
      case WordCategory.sports:
        return Icons.sports;
      case WordCategory.food:
        return Icons.restaurant;
      case WordCategory.movies:
        return Icons.movie;
      case WordCategory.custom:
        return Icons.edit;
    }
  }

  Color get color {
    switch (this) {
      case WordCategory.animals:
        return Colors.green;
      case WordCategory.countries:
        return Colors.blue;
      case WordCategory.sports:
        return Colors.orange;
      case WordCategory.food:
        return Colors.red;
      case WordCategory.movies:
        return Colors.purple;
      case WordCategory.custom:
        return Colors.teal;
    }
  }
}

@immutable
class HangmanGameState extends Equatable {
  final String word;
  final Set<String> guessedLetters;
  final int remainingLives;
  final int score;
  final int hintsRemaining;
  final HangmanGameStatus status;
  final HangmanGameMode mode;
  final WordCategory category;
  final DateTime startTime;

  const HangmanGameState({
    required this.word,
    this.guessedLetters = const {},
    this.remainingLives = 6,
    this.score = 0,
    this.hintsRemaining = 3,
    this.status = HangmanGameStatus.playing,
    required this.mode,
    required this.category,
    required this.startTime,
  });

  List<String> get maskedWord {
    return word.split('').map((letter) {
      if (letter == ' ') return ' ';
      return guessedLetters.contains(letter.toLowerCase()) ? letter : '_';
    }).toList();
  }

  bool get isWordGuessed => !maskedWord.contains('_');
  bool get isGameOver => status != HangmanGameStatus.playing;
  int get incorrectGuesses => 6 - remainingLives;

  HangmanGameState copyWith({
    String? word,
    Set<String>? guessedLetters,
    int? remainingLives,
    int? score,
    int? hintsRemaining,
    HangmanGameStatus? status,
    HangmanGameMode? mode,
    WordCategory? category,
    DateTime? startTime,
  }) {
    return HangmanGameState(
      word: word ?? this.word,
      guessedLetters: guessedLetters ?? this.guessedLetters,
      remainingLives: remainingLives ?? this.remainingLives,
      score: score ?? this.score,
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
      status: status ?? this.status,
      mode: mode ?? this.mode,
      category: category ?? this.category,
      startTime: startTime ?? this.startTime,
    );
  }

  @override
  List<Object?> get props => [
        word,
        guessedLetters,
        remainingLives,
        score,
        hintsRemaining,
        status,
        mode,
        category,
        startTime,
      ];
} 