import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class WhackAMoleAudioService extends GetxService {
  late AudioPlayer _bgmPlayer;
  late AudioPlayer _sfxPlayer;
  final _isSoundEnabled = true.obs;
  final _isMusicEnabled = true.obs;

  bool get isSoundEnabled => _isSoundEnabled.value;
  bool get isMusicEnabled => _isMusicEnabled.value;

  @override
  void onInit() {
    super.onInit();
    _bgmPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();
    _loadSounds();
  }

  @override
  void onClose() {
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
    super.onClose();
  }

  Future<void> _loadSounds() async {
    try {
      await _bgmPlayer.setSource(AssetSource('audio/whack_a_mole/bgm.mp3'));
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.setVolume(0.5);
    } catch (e) {
      debugPrint('Error loading background music: $e');
    }
  }

  void toggleSound() {
    _isSoundEnabled.value = !_isSoundEnabled.value;
  }

  void toggleMusic() {
    _isMusicEnabled.value = !_isMusicEnabled.value;
    if (_isMusicEnabled.value) {
      resumeBackgroundMusic();
    } else {
      pauseBackgroundMusic();
    }
  }

  Future<void> playHitSound(bool isGolden) async {
    if (!_isSoundEnabled.value) return;
    try {
      final asset = isGolden
          ? 'audio/whack_a_mole/golden_hit.mp3'
          : 'audio/whack_a_mole/hit.mp3';
      await _sfxPlayer.play(AssetSource(asset));
    } catch (e) {
      debugPrint('Error playing hit sound: $e');
    }
  }

  Future<void> playBombSound() async {
    if (!_isSoundEnabled.value) return;
    try {
      await _sfxPlayer.play(AssetSource('audio/whack_a_mole/bomb.mp3'));
    } catch (e) {
      debugPrint('Error playing bomb sound: $e');
    }
  }

  Future<void> playMissSound() async {
    if (!_isSoundEnabled.value) return;
    try {
      await _sfxPlayer.play(AssetSource('audio/whack_a_mole/miss.mp3'));
    } catch (e) {
      debugPrint('Error playing miss sound: $e');
    }
  }

  Future<void> playComboSound(int combo) async {
    if (!_isSoundEnabled.value) return;
    try {
      final asset = combo >= 10
          ? 'audio/whack_a_mole/combo_super.mp3'
          : 'audio/whack_a_mole/combo.mp3';
      await _sfxPlayer.play(AssetSource(asset));
    } catch (e) {
      debugPrint('Error playing combo sound: $e');
    }
  }

  Future<void> playButtonSound() async {
    if (!_isSoundEnabled.value) return;
    try {
      await _sfxPlayer.play(AssetSource('audio/whack_a_mole/button.mp3'));
    } catch (e) {
      debugPrint('Error playing button sound: $e');
    }
  }

  Future<void> playBackgroundMusic() async {
    if (!_isMusicEnabled.value) return;
    try {
      await _bgmPlayer.resume();
    } catch (e) {
      debugPrint('Error playing background music: $e');
    }
  }

  Future<void> pauseBackgroundMusic() async {
    try {
      await _bgmPlayer.pause();
    } catch (e) {
      debugPrint('Error pausing background music: $e');
    }
  }

  Future<void> resumeBackgroundMusic() async {
    if (!_isMusicEnabled.value) return;
    try {
      await _bgmPlayer.resume();
    } catch (e) {
      debugPrint('Error resuming background music: $e');
    }
  }

  Future<void> stopBackgroundMusic() async {
    try {
      await _bgmPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping background music: $e');
    }
  }
}
