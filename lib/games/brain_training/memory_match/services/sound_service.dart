import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class SoundService extends GetxService {
  late AudioPlayer _audioPlayer;
  final _isMuted = false.obs;
  final _logger = Logger();

  bool get isMuted => _isMuted.value;

  @override
  void onInit() {
    super.onInit();
    _audioPlayer = AudioPlayer();
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    try {
      // Set global volume to moderate level
      _audioPlayer.setVolume(0.7);

      // Pre-load common sounds to reduce lag
      _preloadSounds();

      _logger.i('Audio player initialized successfully');
    } catch (e) {
      _logger.e('Error initializing audio player: $e');
    }
  }

  Future<void> _preloadSounds() async {
    try {
      await Future.wait([
        _loadSound('sounds/card_flip.mp3'),
        _loadSound('sounds/match_success.mp3'),
        _loadSound('sounds/match_fail.mp3'),
        _loadSound('sounds/game_complete.mp3'),
      ]);
    } catch (e) {
      _logger.w('Error preloading sounds: $e');
    }
  }

  Future<void> _loadSound(String path) async {
    try {
      await _audioPlayer.audioCache.load(path);
    } catch (e) {
      _logger.w('Could not preload sound: $path - $e');
    }
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }

  void toggleMute() {
    _isMuted.value = !_isMuted.value;
    _logger.i('Sound ${_isMuted.value ? "muted" : "unmuted"}');
  }

  Future<void> playCardFlip() async {
    if (_isMuted.value) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/card_flip.mp3'));
    } catch (e) {
      _logger.w('Error playing sound: card_flip.mp3 - $e');
    }
  }

  Future<void> playMatchSuccess() async {
    if (_isMuted.value) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/match_success.mp3'));
    } catch (e) {
      _logger.w('Error playing sound: match_success.mp3 - $e');
    }
  }

  Future<void> playMatchFail() async {
    if (_isMuted.value) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/match_fail.mp3'));
    } catch (e) {
      _logger.w('Error playing sound: match_fail.mp3 - $e');
    }
  }

  Future<void> playGameComplete() async {
    if (_isMuted.value) return;
    try {
      await _audioPlayer.play(AssetSource('sounds/game_complete.mp3'));
    } catch (e) {
      _logger.w('Error playing sound: game_complete.mp3 - $e');
    }
  }
}
