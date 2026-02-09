import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/stats_controller.dart';
import 'package:gameverse/widgets/premium_background.dart';

class ConnectFourStatsScreen extends StatelessWidget {
  const ConnectFourStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statsController = Get.find<ConnectFourStatsController>();
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Connect Four Statistics'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset Stats',
            onPressed: () => _showResetConfirmation(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          const PremiumBackground(),
          SafeArea(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.1)),
                    ),
                    child: TabBar(
                      tabs: const [
                        Tab(text: 'Solo'),
                        Tab(text: 'Versus'),
                      ],
                      indicator: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                      dividerColor: Colors.transparent,
                    ),
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
          ),
        ],
      ),
    );
  }

  Widget _buildSinglePlayerStats(
      ConnectFourStatsController statsController, BuildContext context) {
    return Obx(() => ListView(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          children: [
            _buildStatGrid(
              context,
              [
                (
                  'Played',
                  statsController.gamesPlayed.value.toString(),
                  Icons.sports_esports,
                  Colors.blue
                ),
                (
                  'Wins',
                  statsController.playerWins.value.toString(),
                  Icons.emoji_events,
                  Colors.green
                ),
                (
                  'Losses',
                  statsController.aiWins.value.toString(),
                  Icons.close,
                  Colors.red
                ),
                (
                  'Draws',
                  statsController.draws.value.toString(),
                  Icons.balance,
                  Colors.orange
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionTitle(context, 'Difficulty Breakdown'),
            const SizedBox(height: 12),
            _buildDifficultyList(statsController, context),
            const SizedBox(height: 32),
            _buildStreakCard(context, statsController.currentStreak.value,
                statsController.bestStreak.value),
            const SizedBox(height: 40),
          ],
        ));
  }

  Widget _buildMultiplayerStats(
      ConnectFourStatsController statsController, BuildContext context) {
    return Obx(() => ListView(
          padding: const EdgeInsets.all(24),
          physics: const BouncingScrollPhysics(),
          children: [
            _buildStatGrid(
              context,
              [
                (
                  'Matches',
                  statsController.multiplayerGamesPlayed.value.toString(),
                  Icons.people,
                  Colors.blue
                ),
                (
                  'P1 Wins',
                  statsController.player1Wins.value.toString(),
                  Icons.person,
                  Colors.red
                ),
                (
                  'P2 Wins',
                  statsController.player2Wins.value.toString(),
                  Icons.person,
                  Colors.yellow.shade700
                ),
                (
                  'Draws',
                  statsController.multiplayerDraws.value.toString(),
                  Icons.balance,
                  Colors.orange
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionTitle(context, 'Win Distribution'),
            const SizedBox(height: 12),
            _buildWinDistribution(statsController, context),
            const SizedBox(height: 40),
          ],
        ));
  }

  Widget _buildStatGrid(
      BuildContext context, List<(String, String, IconData, Color)> stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.0,
      children: stats
          .map((s) => _buildStatCard(context, s.$1, s.$2, s.$3, s.$4))
          .toList(),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value,
      IconData icon, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value,
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w900, color: color)),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(label,
                style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            letterSpacing: 1.5,
            fontWeight: FontWeight.w900,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
    );
  }

  Widget _buildDifficultyList(
      ConnectFourStatsController stats, BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          _buildDiffRow(context, 'Easy', stats.easyWins.value, Colors.green),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildDiffRow(
              context, 'Medium', stats.mediumWins.value, Colors.orange),
          const Divider(height: 1, indent: 20, endIndent: 20),
          _buildDiffRow(context, 'Hard', stats.hardWins.value, Colors.red),
        ],
      ),
    );
  }

  Widget _buildDiffRow(
      BuildContext context, String label, int wins, Color color) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(Icons.star_rounded, color: color, size: 16),
          ),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text(wins.toString(),
              style:
                  const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(width: 4),
          const Text('WINS',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, int current, int best) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          theme.colorScheme.primary,
          theme.colorScheme.primary.withValues(alpha: 0.8)
        ]),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStreakItem('CURRENT', current, Colors.white),
          Container(width: 1, height: 40, color: Colors.white24),
          _buildStreakItem('BEST', best, Colors.white),
        ],
      ),
    );
  }

  Widget _buildStreakItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(value.toString(),
            style: TextStyle(
                fontSize: 32, fontWeight: FontWeight.w900, color: color)),
        Text(label,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: color.withValues(alpha: 0.7))),
      ],
    );
  }

  Widget _buildWinDistribution(
      ConnectFourStatsController stats, BuildContext context) {
    final theme = Theme.of(context);
    final total = stats.player1Wins.value +
        stats.player2Wins.value +
        stats.multiplayerDraws.value;
    if (total == 0) {
      return const Center(
          child:
              Padding(padding: EdgeInsets.all(40), child: Text('No data yet')));
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 24,
              child: Row(
                children: [
                  Expanded(
                      flex: stats.player1Wins.value,
                      child: Container(color: Colors.red)),
                  Expanded(
                      flex: stats.player2Wins.value,
                      child: Container(color: Colors.yellow.shade700)),
                  Expanded(
                      flex: stats.multiplayerDraws.value,
                      child: Container(color: Colors.orange)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildLegendRow(
              'Player 1', Colors.red, stats.player1Wins.value, total),
          const SizedBox(height: 8),
          _buildLegendRow('Player 2', Colors.yellow.shade700,
              stats.player2Wins.value, total),
          const SizedBox(height: 8),
          _buildLegendRow(
              'Draws', Colors.orange, stats.multiplayerDraws.value, total),
        ],
      ),
    );
  }

  Widget _buildLegendRow(String label, Color color, int value, int total) {
    final percent = (value / total * 100).toStringAsFixed(0);
    return Row(
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const Spacer(),
        Text('$percent%', style: const TextStyle(fontWeight: FontWeight.w900)),
      ],
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Reset All Stats?'),
        content: const Text(
            'This will permanently delete all your progress records.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Get.find<ConnectFourStatsController>().resetAllStats();
              Get.back();
            },
            child: const Text('RESET'),
          ),
        ],
      ),
    );
  }
}
