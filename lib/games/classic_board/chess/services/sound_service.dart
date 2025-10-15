import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'dart:developer' as dev;

class ChessSoundService extends GetxService {
  final player = AudioPlayer();
  final RxBool isSoundEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    player.setReleaseMode(ReleaseMode.stop);
    player.setVolume(0.5);
  }

  Future<void> _playSound(String path) async {
    if (isSoundEnabled.value) {
      try {
        await player.stop();
        await player.play(AssetSource(path));
      } catch (e) {
        dev.log('Error playing sound: $e', name: 'Chess');
      }
    }
  }

  Future<void> playGameStartSound() async {
    await _playSound('chess/sounds/board_start.mp3');
  }

  Future<void> playMoveSound() async {
    if (!isSoundEnabled.value) return;
    await _playSound('chess/sounds/piece_move.wav');
  }

  Future<void> playCaptureSound() async {
    if (!isSoundEnabled.value) return;
    await _playSound('chess/sounds/capture.wav');
  }

  Future<void> playPromotionSound() async {
    if (!isSoundEnabled.value) return;
    await _playSound('chess/sounds/promotion.wav');
  }

  Future<void> playCheckSound() async {
    if (!isSoundEnabled.value) return;
    await _playSound('chess/sounds/check.ogg');
  }

  Future<void> playCheckmateSound() async {
    await _playSound('chess/sounds/checkmate.wav');
  }

  Future<void> playGameEndSound() async {
    await _playSound('chess/sounds/game_end.wav');
  }

  Future<void> playMenuSelectionSound() async {
    await _playSound('chess/sounds/menu_selection.wav');
  }

  Future<void> playTimeUpSound() async {
    await _playSound('chess/sounds/time_up.mp3');
  }

  Future<void> playClockTickSound() async {
    await _playSound('chess/sounds/clock_tick.wav');
  }

  Future<void> playSelectSound() async {
    await _playSound('chess/sounds/piece_move.wav');
  }

  Future<void> playDeselectSound() async {
    await _playSound('chess/sounds/piece_move.wav');
  }

  Future<void> playErrorSound() async {
    await _playSound('chess/sounds/check.ogg');
  }

  void toggleSound() {
    isSoundEnabled.value = !isSoundEnabled.value;
  }

  @override
  void onClose() {
    player.dispose();
    super.onClose();
  }
}
