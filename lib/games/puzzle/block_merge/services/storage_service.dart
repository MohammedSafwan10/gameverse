import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class BlockMergeStorageService extends GetxService {
  final _storage = GetStorage();

  int get bestScore => _storage.read('block_merge_best_score') ?? 0;
  int get gamesPlayed => _storage.read('block_merge_games_played') ?? 0;
  int get highestTile => _storage.read('block_merge_highest_tile') ?? 2;

  Future<void> saveBestScore(int score) async {
    if (score > bestScore) {
      await _storage.write('block_merge_best_score', score);
    }
  }

  Future<void> incrementGamesPlayed() async {
    await _storage.write('block_merge_games_played', gamesPlayed + 1);
  }

  Future<void> updateHighestTile(int value) async {
    if (value > highestTile) {
      await _storage.write('block_merge_highest_tile', value);
    }
  }
}
