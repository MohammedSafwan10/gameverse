import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

abstract class QuizSoundPlayer {
  Future<StopFunction> start(double volume);
  Future<void> dispose();
}

class _NativeQuizPlayer implements QuizSoundPlayer {
  _NativeQuizPlayer(this.pool);
  final AudioPool pool;
  @override
  Future<StopFunction> start(double volume) => pool.start(volume: volume);
  @override
  Future<void> dispose() => pool.dispose();
}

/// Independent preloaded PCM pools. Never decode or queue a cue on input.
class QuizSoundService extends GetxService {
  QuizSoundService({this.createPlayer});
  final Future<QuizSoundPlayer> Function(String path)? createPlayer;
  final muted = false.obs;
  GetStorage get _storage => GetStorage('quiz_stats');
  final Map<String, QuizSoundPlayer> _players = {};
  final Map<String, StopFunction> _stops = {};
  final Set<Future<void>> _pending = {};
  Future<void>? _loading;
  bool _closed = false, _suspended = false;
  static const events = ['tap', 'correct', 'wrong', 'timeout', 'complete'];
  static const volumes = {
    'tap': .3,
    'correct': .42,
    'wrong': .3,
    'timeout': .3,
    'complete': .4
  };

  @override
  void onInit() {
    super.onInit();
    muted.value = _storage.read<dynamic>('soundMuted') == true;
  }

  Future<void> preload() {
    if (_closed || (Get.testMode && createPlayer == null)) {
      return Future.value();
    }
    return _loading ??= _create();
  }

  Future<void> _create() async {
    try {
      for (final event in events) {
        final path = 'sounds/quiz_master/$event.wav';
        final player = createPlayer != null
            ? await createPlayer!(path)
            : _NativeQuizPlayer(await AudioPool.createFromAsset(
                path: path, minPlayers: event == 'tap' ? 2 : 1, maxPlayers: 3));
        if (_closed) {
          await player.dispose();
          return;
        }
        _players[event] = player;
      }
    } catch (_) {
      for (final player in _players.values) {
        await player.dispose();
      }
      _players.clear();
      _loading = null;
    }
  }

  void play(String event) {
    final player = _players[event];
    if (_closed || _suspended || muted.value || player == null) return;
    _track(_start(event, player));
  }

  Future<void> _start(String event, QuizSoundPlayer player) async {
    try {
      final stop = await player.start(volumes[event] ?? .3);
      if (_closed || _suspended || muted.value) {
        await stop();
        return;
      }
      await _stops.remove(event)?.call();
      _stops[event] = stop;
    } catch (_) {/* Audio must never interrupt an answer or navigation. */}
  }

  void suspend(bool value) {
    _suspended = value;
    if (value) _stopAll();
  }

  void toggleMute() {
    muted.toggle();
    if (muted.value) _stopAll();
    unawaited(_persistMute());
  }

  Future<void> _persistMute() async {
    try {
      await _storage.write('soundMuted', muted.value);
    } catch (_) {}
  }

  void _stopAll() {
    for (final stop in _stops.values) {
      _track(_safeStop(stop));
    }
    _stops.clear();
  }

  void _track(Future<void> task) {
    _pending.add(task);
    unawaited(task.whenComplete(() => _pending.remove(task)));
  }

  Future<void> _disposeAll(List<QuizSoundPlayer> players) async {
    // AudioPool disposes available players only. Return active players to their
    // pools first, including any start that resolves after this route closes.
    await Future.wait(_pending.toList());
    for (final player in players) {
      try {
        await player.dispose();
      } catch (_) {}
    }
  }

  Future<void> _safeStop(StopFunction stop) async {
    try {
      await stop();
    } catch (_) {}
  }

  @override
  void onClose() {
    _closed = true;
    _stopAll();
    unawaited(_disposeAll(_players.values.toList()));
    _players.clear();
    super.onClose();
  }
}
