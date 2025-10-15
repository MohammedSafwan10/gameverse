import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';

class SoundService extends GetxService {
  late AudioPlayer _dropPlayer;
  late AudioPlayer _winPlayer;
  final isEnabled = true.obs;
  final _storage = GetStorage();
  static const _soundEnabledKey = 'connect_four_sound_enabled';
  bool _isInitialized = false;
  final _logger = Logger();

  @override
  void onInit() {
    super.onInit();
    _loadSoundSettings();
    _initPlayers();
  }

  void _loadSoundSettings() {
    final soundEnabled = _storage.read(_soundEnabledKey);
    if (soundEnabled != null) {
      isEnabled.value = soundEnabled;
    }
  }

  Future<void> _initPlayers() async {
    try {
      _dropPlayer = AudioPlayer();
      _winPlayer = AudioPlayer();
      
      // Configure players
      await _dropPlayer.setReleaseMode(ReleaseMode.stop);
      await _winPlayer.setReleaseMode(ReleaseMode.stop);
      
      // Set shorter timeout
      await _dropPlayer.setPlayerMode(PlayerMode.lowLatency);
      await _winPlayer.setPlayerMode(PlayerMode.lowLatency);
      
      // Pre-load sound files
      await _dropPlayer.setSourceAsset('sounds/drop.mp3');
      await _winPlayer.setSourceAsset('sounds/win.mp3');
      
      _isInitialized = true;
    } catch (e) {
      _logger.e('Error initializing sound players: $e');
      _isInitialized = false;
    }
  }

  void toggleSound() {
    isEnabled.value = !isEnabled.value;
    _storage.write(_soundEnabledKey, isEnabled.value);
  }

  Future<void> playDropSound() async {
    if (!isEnabled.value || !_isInitialized) return;
    
    try {
      // Use a timeout to prevent hanging
      await _dropPlayer.stop().timeout(
        const Duration(milliseconds: 100),
        onTimeout: () => null,
      );
      
      await _dropPlayer.seek(Duration.zero).timeout(
        const Duration(milliseconds: 100),
        onTimeout: () => null,
      );
      
      await _dropPlayer.resume().timeout(
        const Duration(milliseconds: 500),
        onTimeout: () => null,
      );
    } catch (e) {
      // If there's an error, try to reinitialize the player
      _logger.w('Error playing drop sound: $e');
      _initPlayers();
    }
  }

  Future<void> playWinSound() async {
    if (!isEnabled.value || !_isInitialized) return;
    
    try {
      // Use a timeout to prevent hanging
      await _winPlayer.stop().timeout(
        const Duration(milliseconds: 100),
        onTimeout: () => null,
      );
      
      await _winPlayer.seek(Duration.zero).timeout(
        const Duration(milliseconds: 100),
        onTimeout: () => null,
      );
      
      await _winPlayer.resume().timeout(
        const Duration(milliseconds: 500),
        onTimeout: () => null,
      );
    } catch (e) {
      // If there's an error, try to reinitialize the player
      _logger.w('Error playing win sound: $e');
      _initPlayers();
    }
  }

  @override
  void onClose() {
    try {
      _dropPlayer.dispose();
      _winPlayer.dispose();
    } catch (e) {
      _logger.e('Error disposing sound players: $e');
    }
    super.onClose();
  }
} 