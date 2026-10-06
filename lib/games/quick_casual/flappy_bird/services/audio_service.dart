import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

abstract class FlappyCuePlayer {
  Future<StopFunction> start(double volume);
  Future<void> dispose();
}

class _NativePlayer implements FlappyCuePlayer {
  _NativePlayer(this.pool);
  final AudioPool pool;
  @override
  Future<StopFunction> start(double volume) => pool.start(volume: volume);
  @override
  Future<void> dispose() => pool.dispose();
}

/// Short licensed PCM cues. Input and result persistence never await sound.
class FlappyAudio {
  FlappyAudio({required this.enabled, this.createPlayer});
  final bool Function() enabled;
  final Future<FlappyCuePlayer> Function(String path)? createPlayer;
  static const paths = {
    'flap': 'sounds/memory_flip.wav',
    'point': 'sounds/memory_match.wav',
    'hit': 'sounds/memory_miss.wav',
  };
  final _players = <String, FlappyCuePlayer>{};
  final _stops = <String, StopFunction>{};
  final _tickets = <String, int>{};
  int _epoch = 0;
  final _pending = <Future<void>>{};
  bool _closed = false, _paused = false;
  Future<void>? _loading;
  Future<void> preload() => _loading ??= _load();
  Future<void> _load() async {
    for (final entry in paths.entries) {
      if (_closed) return;
      try {
        final player = createPlayer != null
            ? await createPlayer!(entry.value)
            : _NativePlayer(await AudioPool.createFromAsset(
                path: entry.value, minPlayers: 2, maxPlayers: 4));
        if (_closed) {
          await player.dispose();
          return;
        }
        _players[entry.key] = player;
      } catch (_) {/* Missing/unavailable audio cannot break offline play. */}
    }
  }

  void play(String event) {
    final player = _players[event];
    if (_closed || _paused || !enabled() || player == null) return;
    final ticket = (_tickets[event] ?? 0) + 1;
    _tickets[event] = ticket;
    final task =
        _start(player, event, ticket, _epoch, event == 'flap' ? .25 : .32);
    _pending.add(task);
    unawaited(task.whenComplete(() => _pending.remove(task)));
  }

  Future<void> _start(FlappyCuePlayer player, String event, int ticket,
      int epoch, double volume) async {
    try {
      final stop = await player.start(volume);
      if (_closed ||
          _paused ||
          !enabled() ||
          epoch != _epoch ||
          ticket != _tickets[event]) {
        await stop();
        return;
      }
      final previous = _stops[event];
      _stops[event] = stop;
      if (previous != null) await previous();
    } catch (_) {}
  }

  Future<void> _stopAll() async {
    final stops = _stops.values.toList();
    _stops.clear();
    for (final stop in stops) {
      try {
        await stop();
      } catch (_) {}
    }
  }

  void pause(bool paused) {
    _paused = paused;
    if (paused) {
      _epoch++;
      unawaited(_stopAll());
    }
  }

  Future<void> dispose() async {
    _closed = true;
    await _stopAll();
    await Future.wait(_pending.toList());
    for (final player in _players.values) {
      try {
        await player.dispose();
      } catch (_) {}
    }
    _players.clear();
  }
}
