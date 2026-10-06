import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

/// Prepared CC0 PCM effects, independent pools; game input never awaits audio.
class TicTacToeSoundService extends GetxService {
  final Map<String, AudioPool> _pools = {};
  Future<void>? _loading;
  bool _closed = false;
  static const assets = {
    'move': 'sounds/memory_flip.wav',
    'win': 'chess/sounds_v2/chess_win.wav',
    'draw': 'sounds/memory_match.wav',
  };
  Future<void> preload() => _loading ??= _create();
  Future<void> _create() async {
    try {
      for (final entry in assets.entries) {
        final pool = await AudioPool.createFromAsset(
            path: entry.value,
            minPlayers: entry.key == 'move' ? 2 : 1,
            maxPlayers: 3);
        if (_closed) {
          await pool.dispose();
          return;
        }
        _pools[entry.key] = pool;
      }
    } catch (_) {
      for (final pool in _pools.values) {
        await pool.dispose();
      }
      _pools.clear();
      _loading = null;
    }
  }

  Future<void> play(String event) async {
    if (_closed ||
        !Get.find<TicTacToeSettingsController>().settings.soundEnabled) {
      return;
    }
    try {
      await preload();
      if (_closed ||
          !Get.find<TicTacToeSettingsController>().settings.soundEnabled) {
        return;
      }
      await _pools[event]?.start(volume: event == 'move' ? .45 : .48);
    } catch (_) {/* Audio failure must never prevent a legal move. */}
  }

  @override
  void onClose() {
    _closed = true;
    for (final pool in _pools.values) {
      unawaited(pool.dispose());
    }
    _pools.clear();
    super.onClose();
  }
}
