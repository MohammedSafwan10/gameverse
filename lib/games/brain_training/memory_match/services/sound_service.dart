import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class MemoryMatchSoundService extends GetxService {
  AudioPlayer? _audioPlayer;
  final _isMuted = false.obs;
  final _logger = Logger();

  bool get isMuted => _isMuted.value;
  AudioPlayer get _player => _audioPlayer ??= AudioPlayer();

  @override
  void onClose() {
    _audioPlayer?.dispose();
    super.onClose();
  }

  void toggleMute() {
    _isMuted.value = !_isMuted.value;
    _logger.i('Sound ${_isMuted.value ? "muted" : "unmuted"}');
  }

  Future<void> playCardFlip() async {
    if (_isMuted.value) return;
    try {
      await _player.play(AssetSource('sounds/card_flip.mp3'));
    } catch (e) {
      _logger.w('Error playing sound: card_flip.mp3 - $e');
    }
  }

  Future<void> playMatchSuccess() async {
    if (_isMuted.value) return;
    try {
      await _player.play(AssetSource('sounds/match_success.mp3'));
    } catch (e) {
      _logger.w('Error playing sound: match_success.mp3 - $e');
    }
  }

  Future<void> playMatchFail() async {
    if (_isMuted.value) return;
    try {
      await _player.play(AssetSource('sounds/match_fail.mp3'));
    } catch (e) {
      _logger.w('Error playing sound: match_fail.mp3 - $e');
    }
  }

  Future<void> playGameComplete() async {
    if (_isMuted.value) return;
    try {
      await _player.play(AssetSource('sounds/game_complete.mp3'));
    } catch (e) {
      _logger.w('Error playing sound: game_complete.mp3 - $e');
    }
  }
}
