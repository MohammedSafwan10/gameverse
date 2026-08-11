import 'dart:async';
import 'dart:developer' as dev;

import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

import 'storage_service.dart';

/// Low-latency, pre-warmed Chess sound effects.
///
/// Each effect owns a small native player pool so a capture/check can overlap
/// the move sound instead of cancelling it. All files are short PCM WAVs to
/// avoid decoder startup lag on Android.
class ChessSoundService extends GetxService {
  static const _root = 'chess/sounds_v2';
  static const _uiAsset = '$_root/chess_ui.wav';
  static const _moveAsset = '$_root/chess_move.wav';
  static const _captureAsset = '$_root/chess_capture.wav';
  static const _checkAsset = '$_root/chess_check.wav';
  static const _winAsset = '$_root/chess_win.wav';
  static const _promoteAsset = '$_root/chess_promote.wav';
  static const _tickAsset = '$_root/chess_tick.wav';
  static const _errorAsset = '$_root/chess_error.wav';

  final RxBool isSoundEnabled = true.obs;
  Future<_ChessSoundPools>? _pools;

  @override
  void onInit() {
    super.onInit();
    isSoundEnabled.value = Get.find<ChessStorageService>().soundEnabled;
    unawaited(preload());
  }

  Future<void> preload() async {
    try {
      await _ensurePools();
    } catch (error) {
      _pools = null;
      dev.log('Unable to preload Chess sounds: $error', name: 'Chess');
    }
  }

  Future<void> _play(
    AudioPool Function(_ChessSoundPools pools) select, {
    required String label,
    double volume = .72,
  }) async {
    if (!isSoundEnabled.value) return;
    try {
      final pools = await _ensurePools();
      if (!isSoundEnabled.value) return;
      await select(pools).start(volume: volume);
    } catch (error) {
      dev.log('Unable to play Chess $label sound: $error', name: 'Chess');
    }
  }

  Future<_ChessSoundPools> _ensurePools() =>
      _pools ??= _ChessSoundPools.create();

  Future<void> playGameStartSound() =>
      _play((p) => p.ui, label: 'start', volume: .38);
  Future<void> playMoveSound() =>
      _play((p) => p.move, label: 'move', volume: .7);
  Future<void> playCaptureSound() =>
      _play((p) => p.capture, label: 'capture', volume: .82);
  Future<void> playPromotionSound() =>
      _play((p) => p.promote, label: 'promotion', volume: .82);
  Future<void> playCheckSound() =>
      _play((p) => p.check, label: 'check', volume: .82);
  Future<void> playCheckmateSound() =>
      _play((p) => p.win, label: 'checkmate', volume: .88);
  Future<void> playGameEndSound() =>
      _play((p) => p.win, label: 'game end', volume: .78);
  Future<void> playMenuSelectionSound() =>
      _play((p) => p.ui, label: 'menu selection', volume: .66);
  Future<void> playTimeUpSound() =>
      _play((p) => p.error, label: 'time up', volume: .88);
  Future<void> playClockTickSound() =>
      _play((p) => p.tick, label: 'clock tick', volume: .42);
  Future<void> playSelectSound() =>
      _play((p) => p.ui, label: 'selection', volume: .55);
  Future<void> playDeselectSound() =>
      _play((p) => p.ui, label: 'deselection', volume: .45);
  Future<void> playErrorSound() =>
      _play((p) => p.error, label: 'error', volume: .72);

  void toggleSound() {
    isSoundEnabled.toggle();
    Get.find<ChessStorageService>().updateSoundEnabled(isSoundEnabled.value);
    if (isSoundEnabled.value) unawaited(playMenuSelectionSound());
  }

  @override
  void onClose() {
    final pools = _pools;
    _pools = null;
    if (pools != null) unawaited(_disposePools(pools));
    super.onClose();
  }

  Future<void> _disposePools(Future<_ChessSoundPools> pools) async {
    try {
      await (await pools).dispose();
    } catch (error) {
      dev.log('Unable to dispose Chess sounds: $error', name: 'Chess');
    }
  }
}

class _ChessSoundPools {
  const _ChessSoundPools({
    required this.ui,
    required this.move,
    required this.capture,
    required this.check,
    required this.win,
    required this.promote,
    required this.tick,
    required this.error,
  });

  final AudioPool ui;
  final AudioPool move;
  final AudioPool capture;
  final AudioPool check;
  final AudioPool win;
  final AudioPool promote;
  final AudioPool tick;
  final AudioPool error;

  static Future<_ChessSoundPools> create() async {
    final pools = await Future.wait([
      _pool(ChessSoundService._uiAsset, maxPlayers: 4),
      _pool(ChessSoundService._moveAsset, maxPlayers: 3),
      _pool(ChessSoundService._captureAsset, maxPlayers: 2),
      _pool(ChessSoundService._checkAsset, maxPlayers: 2),
      _pool(ChessSoundService._winAsset),
      _pool(ChessSoundService._promoteAsset),
      _pool(ChessSoundService._tickAsset, maxPlayers: 2),
      _pool(ChessSoundService._errorAsset, maxPlayers: 2),
    ]);
    return _ChessSoundPools(
      ui: pools[0],
      move: pools[1],
      capture: pools[2],
      check: pools[3],
      win: pools[4],
      promote: pools[5],
      tick: pools[6],
      error: pools[7],
    );
  }

  static Future<AudioPool> _pool(String path, {int maxPlayers = 1}) =>
      AudioPool.createFromAsset(
        path: path,
        minPlayers: 1,
        maxPlayers: maxPlayers,
      );

  Future<void> dispose() => Future.wait([
        ui.dispose(),
        move.dispose(),
        capture.dispose(),
        check.dispose(),
        win.dispose(),
        promote.dispose(),
        tick.dispose(),
        error.dispose(),
      ]);
}
