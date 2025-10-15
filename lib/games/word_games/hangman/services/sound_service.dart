import 'package:audioplayers/audioplayers.dart';

class HangmanSoundService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMuted = false;

  bool get isMuted => _isMuted;

  Future<void> init() async {
    await _audioPlayer.setVolume(1.0);
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    _audioPlayer.setVolume(_isMuted ? 0.0 : 1.0);
  }

  Future<void> playCorrectGuess() async {
    if (_isMuted) return;
    await _audioPlayer.play(AssetSource('sounds/correct_guess.mp3'));
  }

  Future<void> playWrongGuess() async {
    if (_isMuted) return;
    await _audioPlayer.play(AssetSource('sounds/wrong_guess.mp3'));
  }

  Future<void> playGameOver() async {
    if (_isMuted) return;
    await _audioPlayer.play(AssetSource('sounds/game_over.mp3'));
  }

  Future<void> playGameWon() async {
    if (_isMuted) return;
    await _audioPlayer.play(AssetSource('sounds/game_won.mp3'));
  }

  Future<void> playHint() async {
    if (_isMuted) return;
    await _audioPlayer.play(AssetSource('sounds/hint.mp3'));
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
} 