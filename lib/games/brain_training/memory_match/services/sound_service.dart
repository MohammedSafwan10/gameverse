import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class MemoryMatchSoundService extends GetxService {
  static const _flipAsset = 'sounds/memory_flip.wav';
  static const _matchAsset = 'sounds/memory_match.wav';
  static const _missAsset = 'sounds/memory_miss.wav';
  static const _winAsset = 'sounds/memory_win.wav';

  final _isMuted = false.obs;
  final _logger = Logger();
  Future<_MemorySoundPools>? _pools;

  bool get isMuted => _isMuted.value;

  /// Warms the native players while the mode screen is visible so the first
  /// card tap does not pay asset-loading or decoder-startup cost.
  Future<void> preload() async {
    try {
      await _ensurePools();
    } catch (error) {
      _pools = null;
      _logger.w('Unable to preload Memory Match sounds - $error');
    }
  }

  @override
  void onClose() {
    final pools = _pools;
    _pools = null;
    if (pools != null) unawaited(_disposePools(pools));
    super.onClose();
  }

  void toggleMute() {
    _isMuted.value = !_isMuted.value;
    _logger.i('Sound ${_isMuted.value ? "muted" : "unmuted"}');
  }

  Future<void> playCardFlip() => _play(
        (pools) => pools.flip,
        volume: .72,
        label: 'flip',
      );

  Future<void> playMatchSuccess() => _play(
        (pools) => pools.match,
        volume: .82,
        label: 'success',
      );

  Future<void> playMatchFail() => _play(
        (pools) => pools.miss,
        volume: .62,
        label: 'miss',
      );

  Future<void> playGameComplete() => _play(
        (pools) => pools.win,
        volume: .86,
        label: 'completion',
      );

  Future<void> _play(
    AudioPool Function(_MemorySoundPools pools) selectPool, {
    required double volume,
    required String label,
  }) async {
    if (_isMuted.value) return;
    try {
      final pools = await _ensurePools();
      if (_isMuted.value) return;
      await selectPool(pools).start(volume: volume);
    } catch (error) {
      _logger.w('Error playing Memory Match $label sound - $error');
    }
  }

  Future<_MemorySoundPools> _ensurePools() =>
      _pools ??= _MemorySoundPools.create();

  Future<void> _disposePools(Future<_MemorySoundPools> pools) async {
    try {
      await (await pools).dispose();
    } catch (error) {
      _logger.w('Unable to dispose Memory Match sounds - $error');
    }
  }
}

class _MemorySoundPools {
  const _MemorySoundPools({
    required this.flip,
    required this.match,
    required this.miss,
    required this.win,
  });

  final AudioPool flip;
  final AudioPool match;
  final AudioPool miss;
  final AudioPool win;

  static Future<_MemorySoundPools> create() async {
    final pools = await Future.wait([
      AudioPool.createFromAsset(
        path: MemoryMatchSoundService._flipAsset,
        minPlayers: 3,
        maxPlayers: 5,
      ),
      AudioPool.createFromAsset(
        path: MemoryMatchSoundService._matchAsset,
        minPlayers: 2,
        maxPlayers: 3,
      ),
      AudioPool.createFromAsset(
        path: MemoryMatchSoundService._missAsset,
        minPlayers: 1,
        maxPlayers: 2,
      ),
      AudioPool.createFromAsset(
        path: MemoryMatchSoundService._winAsset,
        minPlayers: 1,
        maxPlayers: 1,
      ),
    ]);

    return _MemorySoundPools(
      flip: pools[0],
      match: pools[1],
      miss: pools[2],
      win: pools[3],
    );
  }

  Future<void> dispose() => Future.wait([
        flip.dispose(),
        match.dispose(),
        miss.dispose(),
        win.dispose(),
      ]);
}
