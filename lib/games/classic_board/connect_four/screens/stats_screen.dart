import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/stats_controller.dart';

class ConnectFourStatsScreen extends StatelessWidget {
  const ConnectFourStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statsController = Get.find<ConnectFourStatsController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connect Four Stats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Statistics',
            onPressed: () => _showResetConfirmation(context),
          ),
        ],
      ),
      body: Obx(() {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Get.theme.colorScheme.primary.withValues(
                  red: Get.theme.colorScheme.primary.r.toDouble(),
                  green: Get.theme.colorScheme.primary.g.toDouble(),
                  blue: Get.theme.colorScheme.primary.b.toDouble(),
                  alpha: 0.15,
                ),
                Get.theme.colorScheme.surface,
              ],
            ),
          ),
          child: DefaultTabController(
            length: 2,
            child: Column(
              children: [
                TabBar(
                  tabs: const [
                    Tab(text: 'Single Player'),
                    Tab(text: 'Multiplayer'),
                  ],
                  indicatorColor: Get.theme.colorScheme.primary,
                  labelColor: Get.theme.colorScheme.primary,
                  unselectedLabelColor: Get.theme.colorScheme.onSurface,
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildSinglePlayerStats(statsController, context),
                      _buildMultiplayerStats(statsController, context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSinglePlayerStats(
      ConnectFourStatsController statsController, BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatCard(
          title: 'Overall Statistics',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Games Played',
                      '${statsController.gamesPlayed.value}',
                      Icons.sports_esports,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Win Rate',
                      statsController.gamesPlayed.value > 0
                          ? '${((statsController.playerWins.value / statsController.gamesPlayed.value) * 100).toStringAsFixed(1)}%'
                          : '0.0%',
                      Icons.emoji_events,
                    ),
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Your Wins',
                      '${statsController.playerWins.value}',
                      Icons.person,
                      color: Colors.green,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'AI Wins',
                      '${statsController.aiWins.value}',
                      Icons.smart_toy,
                      color: Colors.red,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Draws',
                      '${statsController.draws.value}',
                      Icons.balance,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          title: 'By Difficulty',
          child: Column(
            children: [
              _buildDifficultyItem(
                'Easy',
                statsController.easyWins.value,
                Icons.sentiment_satisfied,
                Colors.green,
              ),
              const Divider(),
              _buildDifficultyItem(
                'Medium',
                statsController.mediumWins.value,
                Icons.sentiment_neutral,
                Colors.orange,
              ),
              const Divider(),
              _buildDifficultyItem(
                'Hard',
                statsController.hardWins.value,
                Icons.sentiment_very_dissatisfied,
                Colors.red,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          title: 'Streaks',
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Current Streak',
                  '${statsController.currentStreak.value}',
                  Icons.bolt,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Best Streak',
                  '${statsController.bestStreak.value}',
                  Icons.star,
                  color: Colors.amber,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _resetSinglePlayerStats(context, statsController),
          icon: const Icon(Icons.refresh),
          label: const Text('Reset Single Player Stats'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Get.theme.colorScheme.error,
          ),
        ),
      ],
    );
  }

  Widget _buildMultiplayerStats(
      ConnectFourStatsController statsController, BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatCard(
          title: 'Multiplayer Statistics',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Games Played',
                      '${statsController.multiplayerGamesPlayed.value}',
                      Icons.sports_esports,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Draw Rate',
                      statsController.multiplayerGamesPlayed.value > 0
                          ? '${((statsController.multiplayerDraws.value / statsController.multiplayerGamesPlayed.value) * 100).toStringAsFixed(1)}%'
                          : '0.0%',
                      Icons.balance,
                    ),
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Player 1 Wins',
                      '${statsController.player1Wins.value}',
                      Icons.looks_one,
                      color: Colors.red,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Player 2 Wins',
                      '${statsController.player2Wins.value}',
                      Icons.looks_two,
                      color: Colors.yellow,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Draws',
                      '${statsController.multiplayerDraws.value}',
                      Icons.balance,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          title: 'Win Distribution',
          child: SizedBox(
            height: 200,
            child: statsController.multiplayerGamesPlayed.value > 0
                ? _buildWinDistributionChart(statsController)
                : const Center(
                    child: Text('Play games to see win distribution'),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _resetMultiplayerStats(context, statsController),
          icon: const Icon(Icons.refresh),
          label: const Text('Reset Multiplayer Stats'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Get.theme.colorScheme.error,
          ),
        ),
      ],
    );
  }

  Widget _buildWinDistributionChart(
      ConnectFourStatsController statsController) {
    final total = statsController.player1Wins.value +
        statsController.player2Wins.value +
        statsController.multiplayerDraws.value;

    if (total == 0) return const Center(child: Text('No games played yet'));

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartWidth = constraints.maxWidth;
        final player1Width =
            (statsController.player1Wins.value / total) * chartWidth;
        final player2Width =
            (statsController.player2Wins.value / total) * chartWidth;
        final drawsWidth =
            (statsController.multiplayerDraws.value / total) * chartWidth;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 30,
              child: Row(
                children: [
                  Container(
                    width: player1Width,
                    color: Colors.red,
                    child: Center(
                      child: Text(
                        '${((statsController.player1Wins.value / total) * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: player2Width,
                    color: Colors.yellow,
                    child: Center(
                      child: Text(
                        '${((statsController.player2Wins.value / total) * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: drawsWidth,
                    color: Colors.orange,
                    child: Center(
                      child: Text(
                        '${((statsController.multiplayerDraws.value / total) * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLegendItem('Player 1', Colors.red),
                _buildLegendItem('Player 2', Colors.yellow),
                _buildLegendItem('Draws', Colors.orange),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  Widget _buildDifficultyItem(
      String difficulty, int wins, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                difficulty,
                style: Get.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('Difficulty Level'),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$wins',
                style: Get.textTheme.titleLarge,
              ),
              Text('Wins'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({required String title, required Widget child}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Get.theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon,
      {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Icon(
            icon,
            color: color ?? Get.theme.colorScheme.primary,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Get.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Statistics'),
        content: const Text(
            'Are you sure you want to reset all Connect Four statistics? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () {
              final statsController = Get.find<ConnectFourStatsController>();
              statsController.resetAllStats();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All statistics have been reset')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.error,
            ),
            child: const Text('RESET ALL'),
          ),
        ],
      ),
    );
  }

  void _resetSinglePlayerStats(
      BuildContext context, ConnectFourStatsController statsController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Single Player Statistics'),
        content: const Text(
            'Are you sure you want to reset all single player statistics? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () {
              statsController.resetSinglePlayerStats();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Single player statistics have been reset')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.error,
            ),
            child: const Text('RESET'),
          ),
        ],
      ),
    );
  }

  void _resetMultiplayerStats(
      BuildContext context, ConnectFourStatsController statsController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Multiplayer Statistics'),
        content: const Text(
            'Are you sure you want to reset all multiplayer statistics? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () {
              statsController.resetMultiplayerStats();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Multiplayer statistics have been reset')),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.error,
            ),
            child: const Text('RESET'),
          ),
        ],
      ),
    );
  }
}
