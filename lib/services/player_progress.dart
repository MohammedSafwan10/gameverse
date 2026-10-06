import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

/// Reads existing game records; no synthetic wins, XP, ranks or migrations.
class PlayerProgress {
  PlayerProgress(
      {this.played = 0,
      this.wins = 0,
      this.games = 0,
      this.quizzes = 0,
      this.memoryWins = 0,
      this.flappyBest = 0,
      this.highestTile = 0});

  final int played, wins, games, quizzes, memoryWins, flappyBest, highestTile;

  static int count(dynamic value) => value is int && value >= 0 ? value : 0;
  static Map<dynamic, dynamic> map(dynamic value) {
    if (value is String) {
      try {
        value = jsonDecode(value);
      } catch (_) {
        return {};
      }
    }
    return value is Map ? value : {};
  }

  factory PlayerProgress.fromRecords(
      Map<dynamic, dynamic> records, Map<dynamic, dynamic> quiz) {
    final tic = map(records['tic_tac_toe_stats']);
    final difficulties = map(tic['difficultyStats']).values.map(map);
    final multiplayer = map(tic['multiplayerStats']);
    final connect = map(records['connect_four_stats']);
    final flappy = map(records['flappy_bird_stats']);
    final memory = map(records['memory_match_stats']);
    final ticPlayed =
        difficulties.fold(0, (n, s) => n + count(s['gamesPlayed'])) +
            count(multiplayer['gamesPlayed']);
    final ticWins = difficulties.fold(0, (n, s) => n + count(s['gamesWon'])) +
        count(multiplayer['player1Wins']) +
        count(multiplayer['player2Wins']);
    final connectWins = count(connect['playerWins']) +
        count(connect['player1Wins']) +
        count(connect['player2Wins']);
    final connectPlayed = connectWins +
        count(connect['aiWins']) +
        count(connect['draws']) +
        count(connect['multiplayerDraws']);
    final memoryWins = count(memory['completed']);
    final quizzes = count(quiz['totalQuizzesPlayed']);
    final plays = [
      ticPlayed,
      connectPlayed,
      count(records['chess_games_played']),
      count(records['block_merge_games_played']),
      count(flappy['gamesPlayed']),
      memoryWins,
      quizzes
    ];
    return PlayerProgress(
      played: plays.fold(0, (a, b) => a + b),
      games: plays.where((n) => n > 0).length,
      wins: ticWins +
          connectWins +
          count(records['chess_games_won']) +
          count(records['block_merge_games_won']) +
          memoryWins,
      quizzes: quizzes,
      memoryWins: memoryWins,
      flappyBest:
          count(records['flappy_bird_high_score']) > count(flappy['highScore'])
              ? count(records['flappy_bird_high_score'])
              : count(flappy['highScore']),
      highestTile: count(records['block_merge_highest_tile']),
    );
  }

  List<double> get badges {
    double ratio(int n, int target) => (n / target).clamp(0.0, 1.0);
    final base = [
      ratio(wins, 1),
      ratio(games, 3),
      ratio(quizzes, 1),
      ratio(memoryWins, 10),
      ratio(flappyBest, 25),
      ratio(highestTile, 128),
      ratio(games, 7),
      ratio(wins, 50)
    ];
    return [...base, ratio(base.where((n) => n == 1).length, 8)];
  }

  int get unlocked => badges.where((n) => n == 1).length;
}

class PlayerProgressStore extends ValueNotifier<PlayerProgress> {
  PlayerProgressStore() : super(PlayerProgress());
  static final instance = PlayerProgressStore();
  GetStorage? _storage;
  GetStorage? _quiz;
  final List<VoidCallback> _subscriptions = [];

  Future<void> initialize() async {
    if (_storage != null) return;
    await GetStorage.init('quiz_stats');
    _storage = GetStorage();
    _quiz = GetStorage('quiz_stats');
    _subscriptions.add(_storage!.listen(refresh));
    _subscriptions.add(_quiz!.listen(refresh));
    refresh();
  }

  void refresh() {
    value = PlayerProgress.fromRecords(
      {
        for (final key in [
          'tic_tac_toe_stats',
          'connect_four_stats',
          'chess_games_played',
          'chess_games_won',
          'block_merge_games_played',
          'block_merge_games_won',
          'block_merge_highest_tile',
          'flappy_bird_stats',
          'flappy_bird_high_score',
          'memory_match_stats'
        ])
          key: _storage?.read<dynamic>(key)
      },
      {'totalQuizzesPlayed': _quiz?.read<dynamic>('totalQuizzesPlayed')},
    );
  }

  Future<void> recordMemoryWin() async {
    final storage = _storage;
    if (storage == null) return; // Unit tests and previews have no persistence.
    final stats =
        PlayerProgress.map(storage.read<dynamic>('memory_match_stats'));
    await storage.write('memory_match_stats',
        {'completed': PlayerProgress.count(stats['completed']) + 1});
  }

  @override
  void dispose() {
    for (final cancel in _subscriptions) {
      cancel();
    }
    super.dispose();
  }
}
