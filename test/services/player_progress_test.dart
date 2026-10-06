import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameverse/services/player_progress.dart';

void main() {
  test('fresh install has no awarded badges or fabricated statistics', () {
    final progress = PlayerProgress.fromRecords({}, {});
    expect(progress.played, 0);
    expect(progress.wins, 0);
    expect(progress.unlocked, 0);
    expect(progress.badges, everyElement(0));
  });
  test('all games aggregate actual persisted formats and local winners', () {
    final progress = PlayerProgress.fromRecords({
      'tic_tac_toe_stats': jsonEncode({
        'difficultyStats': {
          'easy': {'gamesPlayed': 3, 'gamesWon': 2}
        },
        'multiplayerStats': {
          'gamesPlayed': 2,
          'player1Wins': 1,
          'player2Wins': 1
        },
      }),
      'connect_four_stats': {
        'playerWins': 2,
        'aiWins': 1,
        'draws': 1,
        'player1Wins': 1,
        'player2Wins': 1,
        'multiplayerDraws': 1
      },
      'chess_games_played': 4,
      'chess_games_won': 2,
      'block_merge_games_played': 2,
      'block_merge_games_won': 1,
      'block_merge_highest_tile': 256,
      'flappy_bird_stats': {'gamesPlayed': 3, 'highScore': 30},
      'flappy_bird_high_score': 25,
      'memory_match_stats': {'completed': 10},
    }, {
      'totalQuizzesPlayed': 2
    });
    expect(progress.games, 7);
    expect(progress.played, 33);
    expect(progress.wins, 21);
    expect(progress.flappyBest, 30);
    expect(progress.unlocked, 7);
    expect(progress.badges.last, 7 / 8);
  });
  test('corrupt, missing and negative records cannot award progress', () {
    final progress = PlayerProgress.fromRecords({
      'tic_tac_toe_stats': 'invalid json',
      'connect_four_stats': [],
      'chess_games_won': -1,
      'memory_match_stats': {'completed': '10'},
      'flappy_bird_high_score': double.infinity,
    }, {
      'totalQuizzesPlayed': -3
    });
    expect(progress.unlocked, 0);
    expect(progress.wins, 0);
  });
  test('collector depends on other badges, never on itself; ratios clamp', () {
    final progress = PlayerProgress(
        wins: 500,
        games: 7,
        quizzes: 100,
        memoryWins: 20,
        flappyBest: 100,
        highestTile: 2048);
    expect(progress.unlocked, 9);
    expect(progress.badges, everyElement(1));
    expect(PlayerProgress.fromRecords({}, {}).unlocked, 0);
  });
}
