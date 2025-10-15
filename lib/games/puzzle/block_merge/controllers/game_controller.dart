import 'package:get/get.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/game_state.dart';
import '../models/block.dart';
import 'settings_controller.dart';
import 'dart:developer' as dev;

class BlockMergeController extends GetxController {
  final BlockMergeSettingsController _settingsController;
  final Rx<BlockMergeGameState> gameState = BlockMergeGameState.initial().obs;
  final RxInt score = 0.obs;
  final RxInt bestScore = 0.obs;
  final RxBool isGameOver = false.obs;
  final RxBool hasWon = false.obs;
  final GetStorage _storage = GetStorage();

  final grid = Rx<List<List<Block?>>>(
      List.generate(4, (_) => List.generate(4, (_) => null)));
  final previousGrid = Rx<List<List<Block?>>>(
      List.generate(4, (_) => List.generate(4, (_) => null)));
  final RxInt previousScore = 0.obs;

  Timer? _gameTimer;
  final RxInt timeRemaining = 180.obs;
  final RxBool isPaused = false.obs;

  BlockMergeController(this._settingsController) {
    ever(gameState, _onGameStateChanged);
    bestScore.value = _storage.read('block_merge_best_score') ?? 0;
    _loadGameState();
  }

  void _loadGameState() {
    try {
      final savedMode = _storage.read('block_merge_current_mode');
      if (savedMode != null &&
          savedMode == _settingsController.gameMode.value.toString()) {
        final savedGrid = _storage.read('block_merge_grid');
        final savedScore = _storage.read('block_merge_current_score') ?? 0;
        final savedTime = _storage.read('block_merge_time_remaining') ?? 180;
        final savedPrevGrid = _storage.read('block_merge_previous_grid');
        final savedPrevScore = _storage.read('block_merge_previous_score') ?? 0;

        if (savedGrid != null) {
          try {
            grid.value = _deserializeGrid(savedGrid as List<dynamic>);
            score.value = savedScore as int;
            previousGrid.value = savedPrevGrid != null
                ? _deserializeGrid(savedPrevGrid as List<dynamic>)
                : List.generate(4, (_) => List.generate(4, (_) => null));
            previousScore.value = savedPrevScore as int;

            if (_settingsController.gameMode.value ==
                BlockMergeMode.timeChallenge) {
              timeRemaining.value = savedTime as int;
              if (timeRemaining.value > 0) {
                Future.microtask(() => _startTimer());
              }
            }

            if (score.value > bestScore.value) {
              bestScore.value = score.value;
              _storage.write('block_merge_best_score', bestScore.value);
            }
          } catch (e) {
            dev.log('Error loading saved game state: $e', name: 'BlockMerge');
            _resetGameState();
          }
        } else {
          _resetGameState();
        }
      } else {
        _resetGameState();
      }
    } catch (e) {
      dev.log('Error loading game state: $e', name: 'BlockMerge');
      _resetGameState();
    }
  }

  void _resetGameState() {
    grid.value = List.generate(4, (_) => List.generate(4, (_) => null));
    previousGrid.value = List.generate(4, (_) => List.generate(4, (_) => null));
    score.value = 0;
    previousScore.value = 0;
    isGameOver.value = false;
    hasWon.value = false;
    isPaused.value = false;
    timeRemaining.value = 180;

    if (_settingsController.gameMode.value == BlockMergeMode.timeChallenge) {
      Future.microtask(() => _startTimer());
    }

    gameState.value = BlockMergeGameState.initial().copyWith(
      status: GameStatus.playing,
      moves: 0,
      playTime: Duration.zero,
      highestTile: 0,
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      _addNewBlock();
      Future.delayed(const Duration(milliseconds: 100), () {
        _addNewBlock();
      });
    });
  }

  void _saveGameState() {
    try {
      _storage.write('block_merge_current_mode',
          _settingsController.gameMode.value.toString());
      _storage.write('block_merge_grid', _serializeGrid(grid.value));
      _storage.write('block_merge_current_score', score.value);
      _storage.write('block_merge_time_remaining', timeRemaining.value);
      _storage.write(
          'block_merge_previous_grid', _serializeGrid(previousGrid.value));
      _storage.write('block_merge_previous_score', previousScore.value);
    } catch (e) {
      dev.log('Error saving game state: $e', name: 'BlockMerge');
    }
  }

  List<List<Map<String, dynamic>>> _serializeGrid(List<List<Block?>> grid) {
    return List.generate(
      4,
      (i) => List.generate(4, (j) {
        final block = grid[i][j];
        return block != null
            ? {
                'value': block.value,
                'x': block.position.x,
                'y': block.position.y,
                'isNew': block.isNew,
                'isMerged': block.isMerged,
              }
            : <String, dynamic>{};
      }),
    );
  }

  List<List<Block?>> _deserializeGrid(List<dynamic> serializedGrid) {
    return List.generate(
      4,
      (i) => List.generate(4, (j) {
        final blockData = serializedGrid[i][j];
        if (blockData is Map && blockData.isNotEmpty) {
          return Block(
            value: blockData['value'] as int,
            position: Position(blockData['x'] as int, blockData['y'] as int),
            isNew: blockData['isNew'] as bool? ?? false,
            isMerged: blockData['isMerged'] as bool? ?? false,
          );
        }
        return null;
      }),
    );
  }

  void _saveState() {
    try {
      previousGrid.value = List.generate(
          4,
          (i) => List.generate(4, (j) {
                final block = grid.value[i][j];
                return block != null
                    ? Block(
                        value: block.value,
                        position: Position(block.position.x, block.position.y),
                        isNew: block.isNew,
                        isMerged: block.isMerged,
                      )
                    : null;
              }));
      previousScore.value = score.value;
      gameState.value = gameState.value.copyWith(
        previousGrid: List.generate(
            4,
            (i) => List.generate(4, (j) {
                  final block = grid.value[i][j];
                  return block != null
                      ? Block(
                          value: block.value,
                          position:
                              Position(block.position.x, block.position.y),
                          isNew: block.isNew,
                          isMerged: block.isMerged,
                        )
                      : null;
                })),
        previousScore: score.value,
        canUndo: true,
        moves: gameState.value.moves + 1,
        currentScore: score.value,
      );
      _saveGameState();
    } catch (e) {
      dev.log('Error saving state: $e', name: 'BlockMerge');
    }
  }

  void undo() {
    if (!gameState.value.canUndo || isPaused.value) return;

    try {
      grid.value = List.generate(
          4,
          (i) => List.generate(4, (j) {
                final block = previousGrid.value[i][j];
                return block != null
                    ? Block(
                        value: block.value,
                        position: Position(block.position.x, block.position.y),
                        isNew: false,
                        isMerged: false,
                      )
                    : null;
              }));

      score.value = previousScore.value;
      gameState.value = gameState.value.copyWith(
        canUndo: false,
        moves: gameState.value.moves - 1,
        currentScore: previousScore.value,
      );
      _saveGameState();
    } catch (e) {
      dev.log('Error during undo: $e', name: 'BlockMerge');
    }
  }

  void newGame() {
    try {
      _gameTimer?.cancel();
      clearGameState();
      _resetGameState();
      _settingsController.incrementGamesPlayed();
    } catch (e) {
      dev.log('Error starting new game: $e', name: 'BlockMerge');
    }
  }

  void clearGameState() {
    _storage.remove('block_merge_grid');
    _storage.remove('block_merge_current_score');
    _storage.remove('block_merge_time_remaining');
    _storage.remove('block_merge_previous_grid');
    _storage.remove('block_merge_previous_score');
  }

  @override
  void onClose() {
    _gameTimer?.cancel();
    clearGameState();
    super.onClose();
  }

  void _onGameStateChanged(BlockMergeGameState state) {
    if (state.status == GameStatus.gameOver || state.status == GameStatus.won) {
      _gameTimer?.cancel();
      _settingsController.updateBestScore(score.value);
      _settingsController.updateHighestTile(gameState.value.highestTile);
      if (state.status == GameStatus.won) {
        _settingsController.incrementWins();
      }
    }
  }

  void togglePause() {
    isPaused.value = !isPaused.value;
    if (isPaused.value) {
      _gameTimer?.cancel();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    if (_settingsController.gameMode.value != BlockMergeMode.timeChallenge) {
      return;
    }

    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isPaused.value && timeRemaining.value > 0) {
        timeRemaining.value--;
        if (timeRemaining.value == 0) {
          isGameOver.value = true;
          timer.cancel();
          _settingsController.updateBestScore(score.value);
        }
      }
    });
  }

  void continueAfterWin() {
    if (hasWon.value) {
      hasWon.value = false;
      gameState.value = gameState.value.copyWith(status: GameStatus.playing);
    }
  }

  void _addNewBlock() {
    try {
      final emptyPositions = _getEmptyPositions();
      if (emptyPositions.isEmpty) return;

      final random = math.Random();
      final position = emptyPositions[random.nextInt(emptyPositions.length)];
      final value = random.nextDouble() < 0.9 ? 2 : 4;

      final newGrid = List.generate(
          4,
          (i) => List.generate(4, (j) {
                final block = grid.value[i][j];
                return block != null
                    ? Block(
                        value: block.value,
                        position: Position(block.position.x, block.position.y),
                        isNew: block.isNew,
                        isMerged: block.isMerged,
                      )
                    : null;
              }));

      newGrid[position.y][position.x] = Block(
        value: value,
        position: position,
        isNew: true,
      );
      grid.value = newGrid;

      if (value > gameState.value.highestTile) {
        gameState.value = gameState.value.copyWith(highestTile: value);
      }
    } catch (e) {
      dev.log('Error adding new block: $e', name: 'BlockMerge');
    }
  }

  List<Position> _getEmptyPositions() {
    List<Position> emptyPositions = [];
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (grid.value[i][j] == null) {
          emptyPositions.add(Position(j, i));
        }
      }
    }
    return emptyPositions;
  }

  void moveLeft() => _move(Direction.left);
  void moveRight() => _move(Direction.right);
  void moveUp() => _move(Direction.up);
  void moveDown() => _move(Direction.down);

  void _move(Direction direction) {
    if (isGameOver.value || isPaused.value) return;

    try {
      _saveState();
      bool moved = false;
      List<List<Block?>> newGrid = List.generate(
          4,
          (i) => List.generate(4, (j) {
                final block = grid.value[i][j];
                return block != null
                    ? Block(
                        value: block.value,
                        position: Position(block.position.x, block.position.y),
                        isNew: block.isNew,
                        isMerged: block.isMerged,
                      )
                    : null;
              }));

      switch (direction) {
        case Direction.left:
          moved = _moveHorizontal(newGrid, false);
          break;
        case Direction.right:
          moved = _moveHorizontal(newGrid, true);
          break;
        case Direction.up:
          moved = _moveVertical(newGrid, false);
          break;
        case Direction.down:
          moved = _moveVertical(newGrid, true);
          break;
      }

      if (moved) {
        grid.value = newGrid;
        _addNewBlock();
        _checkGameState();

        if (score.value > _settingsController.bestScore.value) {
          _settingsController.updateBestScore(score.value);
        }

        if (_settingsController.vibrationEnabled.value) {
          _playMoveVibration();
        }

        if (_settingsController.soundEnabled.value) {
          // Add sound effect here if needed
        }

        _saveGameState();
      }
    } catch (e) {
      dev.log('Error during move: $e', name: 'BlockMerge');
    }
  }

  void _playMoveVibration() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (e) {
      dev.log('Move vibration error: $e', name: 'BlockMerge');
    }
  }

  void _playMergeVibration(int value) async {
    if (!_settingsController.vibrationEnabled.value) return;

    try {
      if (value >= 512) {
        for (var i = 0; i < 3; i++) {
          await HapticFeedback.heavyImpact();
          await Future.delayed(const Duration(milliseconds: 50));
        }
      } else if (value >= 128) {
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 50));
        await HapticFeedback.heavyImpact();
      } else if (value >= 32) {
        await HapticFeedback.heavyImpact();
      } else {
        await HapticFeedback.mediumImpact();
      }
    } catch (e) {
      dev.log('Merge vibration error: $e', name: 'BlockMerge');
    }
  }

  bool _moveHorizontal(List<List<Block?>> newGrid, bool toRight) {
    bool moved = false;
    for (int y = 0; y < 4; y++) {
      List<Block?> row = List.generate(4, (x) {
        final block = newGrid[y][x];
        return block != null
            ? Block(
                value: block.value,
                position: Position(block.position.x, block.position.y),
                isNew: block.isNew,
                isMerged: block.isMerged,
              )
            : null;
      });
      List<Block?> newRow = _mergeLine(row, toRight, y);
      if (!_listEquals(row, newRow)) {
        moved = true;
        newGrid[y] = newRow;
      }
    }
    return moved;
  }

  bool _moveVertical(List<List<Block?>> newGrid, bool toBottom) {
    bool moved = false;
    for (int x = 0; x < 4; x++) {
      List<Block?> column = List.generate(4, (y) {
        final block = newGrid[y][x];
        return block != null
            ? Block(
                value: block.value,
                position: Position(block.position.x, block.position.y),
                isNew: block.isNew,
                isMerged: block.isMerged,
              )
            : null;
      });
      List<Block?> newColumn = _mergeLine(column, toBottom, x);
      if (!_listEquals(column, newColumn)) {
        moved = true;
        for (int y = 0; y < 4; y++) {
          newGrid[y][x] = newColumn[y];
        }
      }
    }
    return moved;
  }

  List<Block?> _mergeLine(List<Block?> line, bool reverse, int index) {
    if (reverse) line = line.reversed.toList();
    List<Block?> result = List.filled(4, null);
    int resultIndex = 0;

    List<Block?> nonNull = line.where((block) => block != null).toList();
    for (int i = 0; i < nonNull.length; i++) {
      if (i + 1 < nonNull.length &&
          nonNull[i]!.value == nonNull[i + 1]!.value) {
        final newValue = nonNull[i]!.value * 2;
        result[resultIndex] = Block(
          value: newValue,
          position: Position(reverse ? 3 - resultIndex : resultIndex, index),
          isMerged: true,
        );
        score.value += newValue;

        if (score.value > bestScore.value) {
          bestScore.value = score.value;
          _storage.write('block_merge_best_score', bestScore.value);
        }

        _playMergeVibration(newValue);

        if (newValue == 2048 && !hasWon.value) {
          hasWon.value = true;
          _settingsController.incrementWins();
          gameState.value = gameState.value.copyWith(
            status: _settingsController.gameMode.value == BlockMergeMode.zen
                ? GameStatus.playing
                : GameStatus.won,
          );

          if (_settingsController.vibrationEnabled.value) {
            _playVictoryVibration();
          }
        }

        if (newValue > gameState.value.highestTile) {
          gameState.value = gameState.value.copyWith(highestTile: newValue);
          _settingsController.updateHighestTile(newValue);
        }

        i++;
      } else {
        result[resultIndex] = nonNull[i]!.copyWith(
          position: Position(reverse ? 3 - resultIndex : resultIndex, index),
          isNew: false,
          isMerged: false,
        );
      }
      resultIndex++;
    }

    if (reverse) result = result.reversed.toList();
    return result;
  }

  void _playVictoryVibration() async {
    try {
      for (var i = 0; i < 3; i++) {
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 100));
      }
      await Future.delayed(const Duration(milliseconds: 150));
      for (var i = 0; i < 2; i++) {
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 50));
      }
    } catch (e) {
      dev.log('Victory vibration error: $e', name: 'BlockMerge');
    }
  }

  void _checkGameState() {
    if (!_hasValidMoves()) {
      isGameOver.value = true;
      gameState.value = gameState.value.copyWith(status: GameStatus.gameOver);
      _settingsController.updateBestScore(score.value);
      _settingsController.updateHighestTile(gameState.value.highestTile);
    }
  }

  bool _hasValidMoves() {
    // Check for empty cells
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        if (grid.value[i][j] == null) return true;
      }
    }

    // Check for possible merges
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 4; j++) {
        final current = grid.value[i][j];
        if (current != null) {
          // Check right
          if (j < 3 && grid.value[i][j + 1]?.value == current.value) {
            return true;
          }
          // Check down
          if (i < 3 && grid.value[i + 1][j]?.value == current.value) {
            return true;
          }
        }
      }
    }

    return false;
  }

  bool _listEquals<T>(List<T?> a, List<T?> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void exitGame() {
    _gameTimer?.cancel();
    clearGameState();
    Get.back();
  }

  Future<bool> onWillPop() async {
    if (isPaused.value) return true;

    final shouldExit = await Get.dialog<bool>(
          AlertDialog(
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.orange.shade800),
                const SizedBox(width: 8),
                const Text('Exit Game'),
              ],
            ),
            content: const Text(
                'Are you sure you want to exit? Progress will be lost.'),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.orange.shade800),
                ),
              ),
              ElevatedButton(
                onPressed: () => Get.back(result: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade800,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Exit'),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldExit) {
      exitGame();
    }
    return false;
  }
}
