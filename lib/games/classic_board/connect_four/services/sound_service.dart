import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

/// Pre-trimmed CC0 PCM effects, independent pools, one live settings source.
class SoundService extends GetxService {
  final Map<String, AudioPool> _pools = {};
  Future<void>? _loading;
  bool _closed = false;
  Future<void> preload() => _loading ??= _create();
  Future<void> _create() async {
    try {
      for (final entry in const {
        'drop': 'sounds/memory_flip.wav',
        'win': 'chess/sounds_v2/chess_win.wav',
        'draw': 'sounds/memory_match.wav'
      }.entries) {
        final pool = await AudioPool.createFromAsset(
            path: entry.value,
            minPlayers: entry.key == 'drop' ? 2 : 1,
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

  bool get _enabled =>
      Get.isRegistered<ConnectFourSettingsController>() &&
      Get.find<ConnectFourSettingsController>().isSoundEnabled.value;
  Future<void> _play(String event) async {
    if (_closed || !_enabled) return;
    try {
      await preload();
      if (!_closed && _enabled) {
        await _pools[event]?.start(volume: event == 'drop' ? .4 : .45);
      }
    } catch (_) {}
  }

  Future<void> playDropSound() => _play('drop');
  Future<void> playWinSound() => _play('win');
  Future<void> playDrawSound() => _play('draw');
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
