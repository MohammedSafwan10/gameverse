import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

/// Input never waits for decoding. Unready/muted cues are skipped, not queued.
class BlockMergeAudio {
  final Map<String, AudioPool> _pools = {};
  Future<void>? _loading;
  bool _closed = false;
  Future<void> preload() => _loading ??= _load();
  Future<void> _load() async {
    try {
      for (final name in ['slide', 'merge', 'win']) {
        final pool = await AudioPool.createFromAsset(
            path: 'sounds/block_merge/$name.wav', minPlayers: 2, maxPlayers: 4);
        if (_closed) {
          await pool.dispose();
          return;
        }
        _pools[name] = pool;
      }
    } catch (_) {
      for (final pool in _pools.values) {
        await pool.dispose();
      }
      _pools.clear();
      _loading = null;
    }
  }

  void play(String name) {
    if (_closed) return;
    final pool = _pools[name];
    if (pool == null) {
      unawaited(preload());
      return;
    }
    unawaited(pool
        .start(volume: name == 'slide' ? .3 : .4)
        .catchError((_) => () async {}));
  }

  Future<void> dispose() async {
    _closed = true;
    for (final pool in _pools.values) {
      await pool.dispose();
    }
    _pools.clear();
  }
}
