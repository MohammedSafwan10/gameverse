class GameStats {
  int score;
  int highScore;
  int gamesPlayed;
  Duration totalPlayTime;
  int totalPipesPassed;

  GameStats({
    required this.score,
    required this.highScore,
    required this.gamesPlayed,
    required this.totalPlayTime,
    required this.totalPipesPassed,
  });

  factory GameStats.initial() {
    return GameStats(
      score: 0,
      highScore: 0,
      gamesPlayed: 0,
      totalPlayTime: Duration.zero,
      totalPipesPassed: 0,
    );
  }

  GameStats copyWith({
    int? score,
    int? highScore,
    int? gamesPlayed,
    Duration? totalPlayTime,
    int? totalPipesPassed,
  }) {
    return GameStats(
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      totalPlayTime: totalPlayTime ?? this.totalPlayTime,
      totalPipesPassed: totalPipesPassed ?? this.totalPipesPassed,
    );
  }

  @override
  String toString() {
    return 'GameStats(score: $score, highScore: $highScore, gamesPlayed: $gamesPlayed, '
        'totalPlayTime: ${totalPlayTime.inSeconds}s, totalPipesPassed: $totalPipesPassed)';
  }
}
