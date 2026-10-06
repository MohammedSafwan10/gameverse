import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/services/ai_service.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/models/player.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/models/game_state.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/models/game_settings.dart';
import 'package:gameverse/games/classic_board/tic_tac_toe/models/game_difficulty.dart';

const lines = [
  [0, 1, 2],
  [3, 4, 5],
  [6, 7, 8],
  [0, 3, 6],
  [1, 4, 7],
  [2, 5, 8],
  [0, 4, 8],
  [2, 4, 6]
];
Player? winner(List<Player> b) {
  for (final l in lines) {
    if (b[l[0]] != Player.none && b[l[0]] == b[l[1]] && b[l[0]] == b[l[2]]) {
      return b[l[0]];
    }
  }
  return null;
}

TicTacToeState state(List<Player> b) => TicTacToeState(
    board: List.unmodifiable(b),
    currentPlayer: Player.o,
    status: GameStatus.playing,
    settings: const GameSettings());

void main() {
  test(
      'every difficulty chooses a legal move without modifying any reachable board',
      () {
    final visited = <String>{};
    final ai = AIService(random: Random(42));
    var aiPositions = 0;
    void visit(List<Player> b, Player turn) {
      final key = b.map((p) => p.index).join();
      if (!visited.add(key) || winner(b) != null || !b.contains(Player.none)) {
        return;
      }
      if (turn == Player.o) {
        aiPositions++;
        for (final d in GameDifficulty.values) {
          final before = List.of(b);
          final move = ai.calculateMove(state(b), d);
          expect(move, inInclusiveRange(0, 8), reason: '$d $key');
          expect(b[move], Player.none, reason: '$d $key');
          expect(b, before, reason: 'AI mutated board');
        }
      }
      for (var i = 0; i < 9; i++) {
        if (b[i] == Player.none) {
          b[i] = turn;
          visit(b, turn.opponent);
          b[i] = Player.none;
        }
      }
    }

    visit(List.filled(9, Player.none), Player.x);
    expect(aiPositions, greaterThan(1000));
  });

  test('Impossible never loses against any sequence of human choices', () {
    final ai = AIService(random: Random(7));
    var terminals = 0;
    void play(List<Player> b, Player turn) {
      final w = winner(b);
      expect(w, isNot(Player.x), reason: b.toString());
      if (w != null || !b.contains(Player.none)) {
        terminals++;
        return;
      }
      if (turn == Player.o) {
        final m = ai.calculateMove(state(b), GameDifficulty.impossible);
        b[m] = Player.o;
        play(b, Player.x);
        b[m] = Player.none;
      } else {
        for (var i = 0; i < 9; i++) {
          if (b[i] == Player.none) {
            b[i] = Player.x;
            play(b, Player.o);
            b[i] = Player.none;
          }
        }
      }
    }

    play(List.filled(9, Player.none), Player.x);
    expect(terminals, greaterThan(100));
  });

  test('finished boards never produce extra moves', () {
    final ai = AIService();
    for (final d in GameDifficulty.values) {
      expect(
          ai.calculateMove(
              state([
                Player.x,
                Player.x,
                Player.x,
                Player.o,
                Player.o,
                Player.none,
                Player.none,
                Player.none,
                Player.none
              ]),
              d),
          -1);
      expect(
          ai.calculateMove(
              state([
                Player.x,
                Player.o,
                Player.x,
                Player.x,
                Player.o,
                Player.o,
                Player.o,
                Player.x,
                Player.x
              ]),
              d),
          -1);
    }
  });

  test('Medium, Hard and Impossible take an immediate win', () {
    for (final d in [
      GameDifficulty.medium,
      GameDifficulty.hard,
      GameDifficulty.impossible
    ]) {
      for (var seed = 0; seed < 20; seed++) {
        expect(
            AIService(random: Random(seed)).calculateMove(
                state([
                  Player.o,
                  Player.o,
                  Player.none,
                  Player.x,
                  Player.x,
                  Player.none,
                  Player.x,
                  Player.none,
                  Player.none
                ]),
                d),
            2);
      }
    }
  });
  test('Hard and Impossible block an immediate loss', () {
    for (final d in [GameDifficulty.hard, GameDifficulty.impossible]) {
      expect(
          AIService().calculateMove(
              state([
                Player.x,
                Player.x,
                Player.none,
                Player.o,
                Player.none,
                Player.none,
                Player.none,
                Player.o,
                Player.x
              ]),
              d),
          2);
    }
  });
}
