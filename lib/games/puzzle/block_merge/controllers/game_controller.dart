import 'dart:async';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/block.dart';
import '../models/game_state.dart';
import '../models/merge_engine.dart';
import '../services/audio_service.dart';
import 'settings_controller.dart';

class BlockMergeController extends GetxController {
  final BlockMergeSettingsController settings;
  final Random random;
  final DateTime Function() now;
  final GetStorage _storage = GetStorage();
  final audio = BlockMergeAudio();
  final motion = Rx<MergeResult?>(null);
  final gameState = BlockMergeGameState.initial().obs;
  final score = 0.obs, bestScore = 0.obs, previousScore = 0.obs;
  final isGameOver = false.obs, hasWon = false.obs, isPaused = false.obs;
  final timeRemaining = 180.obs;
  final grid = Rx<List<List<Block?>>>(_empty());
  final previousGrid = Rx<List<List<Block?>>>(_empty());
  Timer? _timer;
  DateTime? _lastTick;
  int _fractionalMicros = 0;
  bool _closed = false,
      _winRecorded = false,
      _milestoneSeen = false,
      _counted = false;

  BlockMergeController(this.settings,
      {Random? random, DateTime Function()? now})
      : random = random ?? Random(),
        now = now ?? _monotonicClock() {
    final best = _storage.read<dynamic>('block_merge_best_score');
    bestScore.value = best is int && best >= 0 ? best : 0;
    settings.updateBestScore(bestScore.value);
    if (!_restore()) _fresh();
  }
  static List<List<Block?>> _empty() =>
      List.generate(4, (_) => List.filled(4, null));
  static DateTime Function() _monotonicClock() {
    final stopwatch = Stopwatch()..start();
    final origin = DateTime.utc(1970);
    return () => origin.add(stopwatch.elapsed);
  }

  List<List<int>> get values =>
      grid.value.map((r) => r.map((b) => b?.value ?? 0).toList()).toList();
  int get highest => values.expand((r) => r).fold(0, max);
  bool get expired =>
      settings.gameMode.value == BlockMergeMode.timeChallenge &&
      timeRemaining.value == 0;
  bool get canUndo => gameState.value.canUndo && !expired;
  List<List<Block?>> _blocks(List<List<int>> source) => List.generate(
      4,
      (y) => List.generate(
          4,
          (x) => source[y][x] == 0
              ? null
              : Block(value: source[y][x], position: Position(x, y))));
  List<List<Block?>> _copy(List<List<Block?>> source) =>
      source.map((r) => r.toList()).toList();
  List<List<int>> _decode(dynamic data) {
    if (data is! List || data.length != 4) {
      throw const FormatException('Board rows');
    }
    return List.generate(4, (y) {
      final row = data[y];
      if (row is! List || row.length != 4) {
        throw const FormatException('Board columns');
      }
      return List.generate(4, (x) {
        final cell = row[x];
        final v = cell is Map ? cell['value'] ?? 0 : cell;
        if (v is! int || v < 0 || v == 1 || (v != 0 && v & (v - 1) != 0)) {
          throw const FormatException('Tile');
        }
        return v;
      });
    });
  }

  bool _restore() {
    try {
      final saved = _storage.read<dynamic>('block_merge_session_v2');
      final legacy = saved is! Map;
      dynamic read(String field, String key) =>
          legacy ? _storage.read<dynamic>(key) : saved[field];
      if (read('mode', 'block_merge_current_mode') !=
          settings.gameMode.value.toString()) {
        return false;
      }
      final board = _decode(read('board', 'block_merge_grid'));
      if (board.expand((r) => r).every((v) => v == 0)) return false;
      int integer(dynamic v, int fallback) => v is int && v >= 0 ? v : fallback;
      grid.value = _blocks(board);
      score.value = integer(read('score', 'block_merge_current_score'), 0);
      timeRemaining.value =
          integer(read('remaining', 'block_merge_time_remaining'), 180)
              .clamp(0, 180);
      final prior = read('previous', 'block_merge_previous_grid');
      var undo = false;
      if (prior != null) {
        try {
          final decoded = _decode(prior);
          undo = decoded.expand((r) => r).any((v) => v != 0) &&
              (legacy || saved['undo'] == true);
          previousGrid.value = _blocks(decoded);
        } on FormatException {
          /* A damaged undo does not discard the current board. */
        }
      }
      previousScore.value =
          integer(read('previousScore', 'block_merge_previous_score'), 0);
      _winRecorded = legacy ? highest >= 2048 : saved['winRecorded'] == true;
      _milestoneSeen =
          legacy ? highest >= 2048 : saved['milestoneSeen'] == true;
      _counted = true;
      _fractionalMicros =
          legacy ? 0 : integer(saved['fraction'], 0).clamp(0, 999999);
      hasWon.value = !expired && highest >= 2048 && !_milestoneSeen;
      isGameOver.value = expired || !MergeEngine.canMove(values);
      gameState.value = BlockMergeGameState.initial().copyWith(
          status: hasWon.value
              ? GameStatus.won
              : isGameOver.value
                  ? GameStatus.gameOver
                  : GameStatus.playing,
          moves: legacy ? 0 : integer(saved['moves'], 0),
          playTime:
              Duration(seconds: legacy ? 0 : integer(saved['seconds'], 0)),
          currentScore: score.value,
          highestTile: highest,
          canUndo: undo,
          previousGrid: _copy(previousGrid.value),
          previousScore: previousScore.value);
      _startTimer();
      return true;
    } on Object {
      return false;
    }
  }

  void _fresh() {
    motion.value = null;
    _fractionalMicros = 0;
    _timer?.cancel();
    grid.value = _empty();
    previousGrid.value = _empty();
    score.value = previousScore.value = 0;
    isGameOver.value = hasWon.value = isPaused.value = false;
    _winRecorded = _milestoneSeen = _counted = false;
    timeRemaining.value = 180;
    gameState.value =
        BlockMergeGameState.initial().copyWith(status: GameStatus.playing);
    _spawn();
    _spawn();
    gameState.value = gameState.value.copyWith(highestTile: highest);
    _startTimer();
  }

  void newGame() {
    if (_closed) return;
    _fresh();
    _countGame();
    save();
  }

  /// One active run is saved. Re-entering its mode resumes it; another mode
  /// deliberately starts a fresh run, as does the Restart action.
  void startMode(BlockMergeMode mode) {
    if (settings.gameMode.value == mode && _counted) {
      setPaused(false);
      return;
    }
    settings.setGameMode(mode);
    if (!_restore()) {
      newGame();
    } else {
      setPaused(false);
    }
  }

  void _countGame() {
    if (_counted && settings.gamesPlayed.value > 0) return;
    _counted = true;
    settings.incrementGamesPlayed();
  }

  void _spawn() {
    final empty = <Position>[];
    for (var y = 0; y < 4; y++) {
      for (var x = 0; x < 4; x++) {
        if (grid.value[y][x] == null) empty.add(Position(x, y));
      }
    }
    if (empty.isEmpty) return;
    final p = empty[random.nextInt(empty.length)];
    final next = _copy(grid.value);
    next[p.y][p.x] = Block(
        value: random.nextDouble() < .9 ? 2 : 4, position: p, isNew: true);
    grid.value = next;
  }

  void moveLeft() => _move(Direction.left);
  void moveRight() => _move(Direction.right);
  void moveUp() => _move(Direction.up);
  void moveDown() => _move(Direction.down);
  void _move(Direction direction) {
    _tick();
    if (_closed ||
        isGameOver.value ||
        isPaused.value ||
        hasWon.value ||
        expired) {
      return;
    }
    final result = MergeEngine.move(values, direction);
    if (!result.changed) return;
    _countGame();
    previousGrid.value = _copy(grid.value);
    previousScore.value = score.value;
    motion.value = result;
    grid.value = _blocks(result.board);
    score.value += result.gained;
    _spawn();
    final wonNow = highest >= 2048 && !_milestoneSeen;
    if (highest >= 2048 && !_winRecorded) {
      _winRecorded = true;
      settings.incrementWins();
    }
    hasWon.value = wonNow;
    isGameOver.value = !MergeEngine.canMove(values);
    settings.updateBestScore(score.value);
    settings.updateHighestTile(highest);
    bestScore.value = settings.bestScore.value;
    gameState.value = gameState.value.copyWith(
        moves: gameState.value.moves + 1,
        currentScore: score.value,
        highestTile: highest,
        canUndo: true,
        previousGrid: _copy(previousGrid.value),
        previousScore: previousScore.value,
        status: wonNow
            ? GameStatus.won
            : isGameOver.value
                ? GameStatus.gameOver
                : GameStatus.playing);
    if (settings.vibrationEnabled.value) {
      unawaited(HapticFeedback.lightImpact());
    }
    if (settings.soundEnabled.value) {
      audio.play(wonNow
          ? 'win'
          : result.gained > 0
              ? 'merge'
              : 'slide');
    }
    save();
  }

  void undo() {
    if (_closed || !canUndo || isPaused.value || hasWon.value) return;
    motion.value = null;
    grid.value = _copy(previousGrid.value);
    score.value = previousScore.value;
    isGameOver.value = !MergeEngine.canMove(values);
    gameState.value = gameState.value.copyWith(
        status: isGameOver.value ? GameStatus.gameOver : GameStatus.playing,
        canUndo: false,
        moves: max(0, gameState.value.moves - 1),
        currentScore: score.value,
        highestTile: highest);
    save();
  }

  void continueAfterWin() {
    if (!hasWon.value) return;
    _lastTick = now();
    _milestoneSeen = true;
    hasWon.value = false;
    gameState.value = gameState.value.copyWith(
        status: isGameOver.value ? GameStatus.gameOver : GameStatus.playing);
    save();
  }

  void setPaused(bool paused) {
    _tick();
    isPaused.value = paused;
    save();
  }

  void togglePause() => setPaused(!isPaused.value);
  void _startTimer() {
    _timer?.cancel();
    _lastTick = now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    final timestamp = now();
    final elapsed =
        _lastTick == null ? Duration.zero : timestamp.difference(_lastTick!);
    _lastTick = timestamp;
    if (_closed || isPaused.value || hasWon.value || isGameOver.value) return;
    _fractionalMicros += max(0, elapsed.inMicroseconds);
    final seconds = _fractionalMicros ~/ Duration.microsecondsPerSecond;
    _fractionalMicros %= Duration.microsecondsPerSecond;
    if (seconds == 0) return;
    final activeSeconds =
        settings.gameMode.value == BlockMergeMode.timeChallenge
            ? min(seconds, timeRemaining.value)
            : seconds;
    gameState.value = gameState.value.copyWith(
        playTime: gameState.value.playTime + Duration(seconds: activeSeconds));
    if (settings.gameMode.value == BlockMergeMode.timeChallenge) {
      timeRemaining.value = max(0, timeRemaining.value - seconds);
      if (expired) {
        isGameOver.value = true;
        gameState.value = gameState.value
            .copyWith(status: GameStatus.gameOver, canUndo: false);
      }
    }
    if (expired || gameState.value.playTime.inSeconds % 5 == 0) save();
  }

  void save() {
    if (!_counted || _closed) return;
    unawaited(_storage.write('block_merge_session_v2', {
      'mode': settings.gameMode.value.toString(),
      'board': values,
      'score': score.value,
      'previous': previousGrid.value
          .map((r) => r.map((b) => b?.value ?? 0).toList())
          .toList(),
      'previousScore': previousScore.value,
      'undo': gameState.value.canUndo,
      'remaining': timeRemaining.value,
      'moves': gameState.value.moves,
      'seconds': gameState.value.playTime.inSeconds,
      'fraction': _fractionalMicros,
      'winRecorded': _winRecorded,
      'milestoneSeen': _milestoneSeen
    }));
  }

  void clearGameState() => unawaited(_storage.remove('block_merge_session_v2'));
  void exitGame({bool popRoute = true}) {
    setPaused(true);
    if (popRoute) Get.back();
  }

  @override
  void onClose() {
    if (_closed) return;
    save();
    _closed = true;
    _timer?.cancel();
    unawaited(audio.dispose());
    super.onClose();
  }
}
