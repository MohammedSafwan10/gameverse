enum GameDifficulty {
  easy,
  medium,
  hard,
  impossible;

  String get displayName {
    switch (this) {
      case GameDifficulty.easy:
        return 'Easy';
      case GameDifficulty.medium:
        return 'Medium';
      case GameDifficulty.hard:
        return 'Hard';
      case GameDifficulty.impossible:
        return 'Impossible';
    }
  }
}
