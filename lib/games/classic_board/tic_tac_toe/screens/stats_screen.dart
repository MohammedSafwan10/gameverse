import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/stats_controller.dart';
import '../controllers/settings_controller.dart';
import '../models/achievement.dart';
import '../models/game_difficulty.dart';
import '../models/game_mode.dart';
import '../utils/animations.dart';

class TicTacToeStatsScreen extends StatefulWidget {
  const TicTacToeStatsScreen({super.key});

  @override
  State<TicTacToeStatsScreen> createState() => _TicTacToeStatsScreenState();
}

class _TicTacToeStatsScreenState extends State<TicTacToeStatsScreen>
    with SingleTickerProviderStateMixin {
  final _statsController = Get.find<TicTacToeStatsController>();
  final _settingsController = Get.find<TicTacToeSettingsController>();
  bool _showContent = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() => _showContent = true);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'resetCurrent') {
                _showResetConfirmationDialog(context, false);
              } else if (value == 'resetAll') {
                _showResetConfirmationDialog(context, true);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'resetCurrent',
                child: Text('Reset Current Mode Stats'),
              ),
              const PopupMenuItem<String>(
                value: 'resetAll',
                child: Text('Reset All Stats'),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Single Player'),
            Tab(text: 'Multiplayer'),
          ],
        ),
      ),
      body: TicTacToeAnimations.fadeSlide(
        show: _showContent,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildSinglePlayerStats(),
            _buildMultiplayerStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildSinglePlayerStats() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverallStats(),
          const SizedBox(height: 24),
          _buildDifficultyStats(),
          const SizedBox(height: 24),
          _buildAchievements(),
        ],
      ),
    );
  }

  Widget _buildMultiplayerStats() {
    return Obx(() {
      final multiplayerStats = _statsController.stats.multiplayerStats;

      if (multiplayerStats.gamesPlayed == 0) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sports_esports,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'No multiplayer games yet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Play some games with a friend!',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey.shade500,
                    ),
              ),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Multiplayer Statistics',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            'Games Played',
                            multiplayerStats.gamesPlayed.toString(),
                            Icons.sports_esports,
                          ),
                        ),
                        Expanded(
                          child: _buildStatItem(
                            'Draws',
                            multiplayerStats.draws.toString(),
                            Icons.balance,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Player performances
                    Text(
                      'Player Performance',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),

                    // Player 1 (X)
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  child: Text(
                                    'X',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Player 1',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Spacer(),
                                Text(
                                  '${multiplayerStats.player1Wins} wins',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        color: Colors.blue.shade800,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: multiplayerStats.player1WinRate,
                              backgroundColor: Colors.blue.shade100,
                              color: Colors.blue.shade600,
                              minHeight: 10,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Win rate: ${(multiplayerStats.player1WinRate * 100).toStringAsFixed(1)}%',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Player 2 (O)
                    Card(
                      color: Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.red,
                                  child: Text(
                                    'O',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Player 2',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Spacer(),
                                Text(
                                  '${multiplayerStats.player2Wins} wins',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall
                                      ?.copyWith(
                                        color: Colors.red.shade800,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: multiplayerStats.player2WinRate,
                              backgroundColor: Colors.red.shade100,
                              color: Colors.red.shade600,
                              minHeight: 10,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Win rate: ${(multiplayerStats.player2WinRate * 100).toStringAsFixed(1)}%',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildOverallStats() {
    return Obx(() {
      final stats = _statsController.stats;
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Overall Single Player Statistics',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Games Played',
                      stats.gamesPlayed.toString(),
                      Icons.sports_esports,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Win Rate',
                      '${(stats.winRate * 100).toStringAsFixed(1)}%',
                      Icons.emoji_events,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Your Wins',
                      _statsController.playerWins.toString(),
                      Icons.person,
                      color: Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'AI Wins',
                      _statsController.aiWins.toString(),
                      Icons.smart_toy,
                      color: Colors.red,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Draws',
                      stats.gamesDrawn.toString(),
                      Icons.balance,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildDifficultyStats() {
    return Obx(() {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Performance by Difficulty',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              ...GameDifficulty.values.map((difficulty) {
                final stats =
                    _statsController.stats.difficultyStats[difficulty];
                if (stats == null) {
                  return _buildEmptyDifficultyStats(difficulty);
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            difficulty.displayName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            'Best streak: ${stats.bestStreak}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: stats.winRate,
                        backgroundColor:
                            _getDifficultyColor(difficulty).withValues(
                          red: _getDifficultyColor(difficulty).r.toDouble(),
                          green: _getDifficultyColor(difficulty).g.toDouble(),
                          blue: _getDifficultyColor(difficulty).b.toDouble(),
                          alpha: 0.3 * 255,
                        ),
                        color: _getDifficultyColor(difficulty),
                        minHeight: 8,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${stats.gamesWon} wins out of ${stats.gamesPlayed} games',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          Text(
                            '${(stats.winRate * 100).toStringAsFixed(1)}%',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEmptyDifficultyStats(GameDifficulty difficulty) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            difficulty.displayName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0,
            backgroundColor: Colors.grey.shade200,
            color: _getDifficultyColor(difficulty),
            minHeight: 8,
          ),
          const SizedBox(height: 4),
          Text(
            'No games played on this difficulty',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return Colors.green;
      case GameDifficulty.medium:
        return Colors.orange;
      case GameDifficulty.hard:
        return Colors.red.shade700;
      case GameDifficulty.impossible:
        return Colors.purple;
    }
  }

  Widget _buildAchievements() {
    return Obx(() {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Achievements',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_statsController.stats.unlockedAchievements.length}/${Achievement.values.length}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...Achievement.values.map((achievement) {
                final isUnlocked = _statsController.stats.unlockedAchievements
                    .contains(achievement);
                return Card(
                  color:
                      isUnlocked ? Colors.green.shade50 : Colors.grey.shade100,
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      achievement.icon,
                      color: isUnlocked
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                      size: 32,
                    ),
                    title: Text(
                      achievement.title,
                      style: TextStyle(
                        color: isUnlocked ? null : Colors.grey,
                        fontWeight:
                            isUnlocked ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      achievement.description,
                      style: TextStyle(
                        color: isUnlocked ? Colors.grey.shade600 : Colors.grey,
                      ),
                    ),
                    trailing: isUnlocked
                        ? Icon(Icons.check_circle, color: Colors.green)
                        : Icon(Icons.lock, color: Colors.grey.shade400),
                  ),
                );
              }),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildStatItem(String label, String value, IconData icon,
      {Color? color}) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _showResetConfirmationDialog(
      BuildContext context, bool resetAll) async {
    // Capture ScaffoldMessengerState before async operations
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(resetAll
            ? 'Reset All Statistics?'
            : 'Reset Current Mode Statistics?'),
        content: Text(resetAll
            ? 'This will reset all your game statistics, including achievements. This action cannot be undone.'
            : 'This will reset statistics for the ${_settingsController.settings.gameMode == GameMode.singlePlayer ? 'single player' : 'multiplayer'} mode. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (result == true) {
      if (resetAll) {
        await _settingsController.resetAllStats();
      } else {
        await _settingsController.resetCurrentModeStats();
      }

      // Use the captured scaffoldMessenger instead of accessing context after async gap
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Statistics reset successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
