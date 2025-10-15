import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:developer' as dev;

class ChessStorageService extends GetxService {
  static const String _storageKey = 'chess_game_data';
  final _storage = GetStorage();

  // Game statistics as reactive variables
  final RxInt _gamesPlayed = 0.obs;
  final RxInt _gamesWon = 0.obs;
  final RxInt _gamesLost = 0.obs;
  final RxInt _gamesDraw = 0.obs;

  // Settings as reactive variables
  final RxBool _soundEnabled = true.obs;
  final RxString _boardTheme = 'classic'.obs;
  final RxBool _showLegalMoves = true.obs;
  final RxBool _showLastMove = true.obs;
  final RxBool _timerEnabled = false.obs;
  final RxInt _timePerPlayer = 10.obs; // minutes
  final RxInt _aiDifficulty = 2.obs; // 1: Easy, 2: Medium, 3: Hard

  // Getters for reactive variables
  int get gamesPlayed => _gamesPlayed.value;
  int get gamesWon => _gamesWon.value;
  int get gamesLost => _gamesLost.value;
  int get gamesDraw => _gamesDraw.value;
  bool get soundEnabled => _soundEnabled.value;
  String get boardTheme => _boardTheme.value;
  set boardTheme(String value) {
    _boardTheme.value = value;
    saveSettings();
  }

  bool get showLegalMoves => _showLegalMoves.value;
  bool get showLastMove => _showLastMove.value;
  bool get timerEnabled => _timerEnabled.value;
  int get timePerPlayer => _timePerPlayer.value;
  int get aiDifficulty => _aiDifficulty.value;

  @override
  void onInit() {
    super.onInit();
    dev.log('Initializing ChessStorageService', name: 'Chess');
    _loadStats();
    _loadSettings();
  }

  void _loadStats() {
    try {
      _gamesPlayed.value = _storage.read('chess_games_played') ?? 0;
      _gamesWon.value = _storage.read('chess_games_won') ?? 0;
      _gamesLost.value = _storage.read('chess_games_lost') ?? 0;
      _gamesDraw.value = _storage.read('chess_games_draw') ?? 0;

      dev.log(
          'Stats loaded: Played=${_gamesPlayed.value}, Won=${_gamesWon.value}, Lost=${_gamesLost.value}, Draw=${_gamesDraw.value}',
          name: 'Chess');
    } catch (e) {
      dev.log('Error loading stats: $e', name: 'Chess');
      clearStats();
    }
  }

  void _loadSettings() {
    try {
      final settings = _storage.read('chess_settings');
      if (settings != null) {
        final Map<String, dynamic> settingsMap = json.decode(settings);
        _soundEnabled.value = settingsMap['soundEnabled'] ?? true;
        _boardTheme.value = settingsMap['boardTheme'] ?? 'classic';
        _showLegalMoves.value = settingsMap['showLegalMoves'] ?? true;
        _showLastMove.value = settingsMap['showLastMove'] ?? true;
        _timerEnabled.value = settingsMap['timerEnabled'] ?? false;
        _timePerPlayer.value = settingsMap['timePerPlayer'] ?? 10;
        _aiDifficulty.value = settingsMap['aiDifficulty'] ?? 2;

        dev.log('Settings loaded', name: 'Chess');
      }
    } catch (e) {
      dev.log('Error loading settings: $e', name: 'Chess');
      resetSettings();
    }
  }

  // Save game state
  Future<void> saveGameState(Map<String, dynamic> gameState) async {
    await _storage.write(_storageKey, json.encode(gameState));
    dev.log('Game state saved', name: 'Chess');
  }

  // Load game state
  Map<String, dynamic>? loadGameState() {
    final data = _storage.read(_storageKey);
    if (data != null) {
      return json.decode(data);
    }
    return null;
  }

  // Update game statistics
  Future<void> updateGameStats({
    required String result, // 'win', 'loss', 'draw'
  }) async {
    dev.log('Updating game stats with result: $result', name: 'Chess');

    // Increment games played counter
    _gamesPlayed.value++;
    await _storage.write('chess_games_played', _gamesPlayed.value);

    switch (result) {
      case 'win':
        _gamesWon.value++;
        await _storage.write('chess_games_won', _gamesWon.value);
        break;
      case 'loss':
        _gamesLost.value++;
        await _storage.write('chess_games_lost', _gamesLost.value);
        break;
      case 'draw':
        _gamesDraw.value++;
        await _storage.write('chess_games_draw', _gamesDraw.value);
        break;
    }

    // Force update by calling refresh on all reactive variables
    _gamesPlayed.refresh();
    _gamesWon.refresh();
    _gamesLost.refresh();
    _gamesDraw.refresh();

    dev.log(
        'Stats updated: Played=${_gamesPlayed.value}, Won=${_gamesWon.value}, Lost=${_gamesLost.value}, Draw=${_gamesDraw.value}',
        name: 'Chess');
  }

  // Save settings
  Future<void> saveSettings() async {
    final settings = {
      'soundEnabled': _soundEnabled.value,
      'showLegalMoves': _showLegalMoves.value,
      'showLastMove': _showLastMove.value,
      'boardTheme': _boardTheme.value,
      'timerEnabled': _timerEnabled.value,
      'timePerPlayer': _timePerPlayer.value,
      'aiDifficulty': _aiDifficulty.value,
    };
    await _storage.write('chess_settings', json.encode(settings));
    dev.log('Settings saved', name: 'Chess');
  }

  // Update individual settings
  Future<void> updateSoundEnabled(bool value) async {
    _soundEnabled.value = value;
    await saveSettings();
  }

  Future<void> updateBoardTheme(String theme) async {
    _boardTheme.value = theme;
    await saveSettings();
  }

  Future<void> updateShowLegalMoves(bool value) async {
    _showLegalMoves.value = value;
    await saveSettings();
  }

  Future<void> updateShowLastMove(bool value) async {
    _showLastMove.value = value;
    await saveSettings();
  }

  Future<void> updateTimerEnabled(bool value) async {
    _timerEnabled.value = value;
    await saveSettings();
  }

  Future<void> updateTimePerPlayer(int minutes) async {
    _timePerPlayer.value = minutes;
    await saveSettings();
  }

  Future<void> updateAiDifficulty(int level) async {
    if (level >= 1 && level <= 3) {
      _aiDifficulty.value = level;
      await saveSettings();
    }
  }

  // Reset functions
  Future<void> clearStats() async {
    _gamesPlayed.value = 0;
    _gamesWon.value = 0;
    _gamesLost.value = 0;
    _gamesDraw.value = 0;

    await _storage.remove('chess_games_played');
    await _storage.remove('chess_games_won');
    await _storage.remove('chess_games_lost');
    await _storage.remove('chess_games_draw');

    // Force update by calling refresh on all reactive variables
    _gamesPlayed.refresh();
    _gamesWon.refresh();
    _gamesLost.refresh();
    _gamesDraw.refresh();

    dev.log('Stats cleared', name: 'Chess');
  }

  Future<void> resetSettings() async {
    _soundEnabled.value = true;
    _boardTheme.value = 'classic';
    _showLegalMoves.value = true;
    _showLastMove.value = true;
    _timerEnabled.value = false;
    _timePerPlayer.value = 10;
    _aiDifficulty.value = 2;
    await saveSettings();
    dev.log('Settings reset to defaults', name: 'Chess');
  }

  // Clear all chess related data
  Future<void> clearAllData() async {
    await clearStats();
    await resetSettings();
    await _storage.remove(_storageKey);
    dev.log('All chess data cleared', name: 'Chess');
  }
}
