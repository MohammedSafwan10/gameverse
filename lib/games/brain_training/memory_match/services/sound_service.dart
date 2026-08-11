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
      await _player.play(AssetSource('sounds/drop.mp3'));
    } catch (e) {
      _logger.w('Error playing Memory Match flip sound - $e');
    }
  }

  Future<void> playMatchSuccess() async {
    if (_isMuted.value) return;
    try {
      await _player.play(AssetSource('sounds/win.mp3'));
    } catch (e) {
      _logger.w('Error playing Memory Match success sound - $e');
    }
  }

  Future<void> playMatchFail() async {
    if (_isMuted.value) return;
    try {
      await _player.play(AssetSource('sounds/drop.mp3'));
    } catch (e) {
      _logger.w('Error playing Memory Match miss sound - $e');
    }
  }

  Future<void> playGameComplete() async {
    if (_isMuted.value) return;
    try {
      await _player.play(AssetSource('sounds/win.mp3'));
    } catch (e) {
      _logger.w('Error playing Memory Match completion sound - $e');
    }
  }
}
