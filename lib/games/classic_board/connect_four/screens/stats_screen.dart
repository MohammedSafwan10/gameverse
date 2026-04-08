import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/stats_controller.dart';
import 'package:gameverse/theme/app_theme.dart';

class ConnectFourStatsScreen extends StatelessWidget {
  const ConnectFourStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statsController = Get.find<ConnectFourStatsController>();
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Statistics',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: Colors.white),
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.refresh_rounded,
                  size: 18, color: Colors.white),
            ),
            tooltip: 'Reset Stats',
            onPressed: () => _showResetConfirmation(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // Connect Four specific animated/gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color(0xFF0F172A),
                  Color(0xFF1E3A8A), // Deep blue
                  Color(0xFF0F172A),
                ],
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withValues(alpha: 0.15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.2),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withValues(alpha: 0.1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.15),
                    blurRadius: 100,
                    spreadRadius: 50,
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    decoration: AppTheme.glassmorphicDecoration(
                      backgroundColor: Colors.white.withValues(alpha: 0.05),
                      borderColor: Colors.white.withValues(alpha: 0.1),
                      borderRadius: 24,
                    ),
                    child: TabBar(
                      tabs: const [
                        Tab(text: 'Solo'),
                        Tab(text: 'Versus'),
                      ],
                      indicator: BoxDecoration(
                        color: Colors.blue.shade600,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade600.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 16),
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
                  Colors.blueAccent
                ),
                (
                  'Wins',
                  statsController.playerWins.value.toString(),
                  Icons.emoji_events,
                  Colors.greenAccent
                ),
                (
                  'Losses',
                  statsController.aiWins.value.toString(),
                  Icons.close,
                  Colors.redAccent
                ),
                (
                  'Draws',
                  statsController.draws.value.toString(),
                  Icons.balance,
                  Colors.orangeAccent
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionTitle(context, 'Difficulty Breakdown'),
            const SizedBox(height: 16),
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
                  Colors.blueAccent
                ),
                (
                  'P1 Wins',
                  statsController.player1Wins.value.toString(),
                  Icons.person,
                  Colors.redAccent
                ),
                (
                  'P2 Wins',
                  statsController.player2Wins.value.toString(),
                  Icons.person,
                  Colors.yellow.shade600
                ),
                (
                  'Draws',
                  statsController.multiplayerDraws.value.toString(),
                  Icons.balance,
                  Colors.orangeAccent
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionTitle(context, 'Win Distribution'),
            const SizedBox(height: 16),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassmorphicDecoration(
        backgroundColor: Colors.white.withValues(alpha: 0.05),
        borderColor: color.withValues(alpha: 0.3),
        borderRadius: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: color,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 14,
        letterSpacing: 2,
        fontWeight: FontWeight.w900,
        color: Colors.white.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildDifficultyList(
      ConnectFourStatsController stats, BuildContext context) {
    return Container(
      decoration: AppTheme.glassmorphicDecoration(
        backgroundColor: Colors.white.withValues(alpha: 0.05),
        borderColor: Colors.white.withValues(alpha: 0.1),
        borderRadius: 24,
      ),
      child: Column(
        children: [
          _buildDiffRow(
              context, 'Easy', stats.easyWins.value, Colors.greenAccent),
          Divider(
              height: 1,
              indent: 20,
              endIndent: 20,
              color: Colors.white.withValues(alpha: 0.1)),
          _buildDiffRow(
              context, 'Medium', stats.mediumWins.value, Colors.orangeAccent),
          Divider(
              height: 1,
              indent: 20,
              endIndent: 20,
              color: Colors.white.withValues(alpha: 0.1)),
          _buildDiffRow(
              context, 'Hard', stats.hardWins.value, Colors.redAccent),
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
                color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
            child: Icon(Icons.star_rounded, color: color, size: 16),
          ),
          const SizedBox(width: 16),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16)),
          const Spacer(),
          Text(wins.toString(),
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w900, fontSize: 20)),
          const SizedBox(width: 6),
          Text('WINS',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: color.withValues(alpha: 0.7))),
        ],
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, int current, int best) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade700.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStreakItem('CURRENT', current, Colors.white),
          Container(
              width: 2, height: 50, color: Colors.white.withValues(alpha: 0.2)),
          _buildStreakItem('BEST', best, Colors.amberAccent),
        ],
      ),
    );
  }

  Widget _buildStreakItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(value.toString(),
            style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: color,
                height: 1)),
        const SizedBox(height: 8),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: color.withValues(alpha: 0.8))),
      ],
    );
  }

  Widget _buildWinDistribution(
      ConnectFourStatsController stats, BuildContext context) {
    final total = stats.player1Wins.value +
        stats.player2Wins.value +
        stats.multiplayerDraws.value;
    if (total == 0) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: AppTheme.glassmorphicDecoration(
          backgroundColor: Colors.white.withValues(alpha: 0.05),
          borderColor: Colors.white.withValues(alpha: 0.1),
          borderRadius: 24,
        ),
        child: const Center(
          child: Text('No matches played yet',
              style: TextStyle(
                  color: Colors.white60, fontWeight: FontWeight.bold)),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: AppTheme.glassmorphicDecoration(
        backgroundColor: Colors.white.withValues(alpha: 0.05),
        borderColor: Colors.white.withValues(alpha: 0.1),
        borderRadius: 24,
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 24,
              child: Row(
                children: [
                  if (stats.player1Wins.value > 0)
                    Expanded(
                        flex: stats.player1Wins.value,
                        child: Container(color: Colors.redAccent)),
                  if (stats.player2Wins.value > 0)
                    Expanded(
                        flex: stats.player2Wins.value,
                        child: Container(color: Colors.yellow.shade600)),
                  if (stats.multiplayerDraws.value > 0)
                    Expanded(
                        flex: stats.multiplayerDraws.value,
                        child: Container(color: Colors.blueGrey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildLegendRow(
              'Player 1', Colors.redAccent, stats.player1Wins.value, total),
          const SizedBox(height: 12),
          _buildLegendRow('Player 2', Colors.yellow.shade600,
              stats.player2Wins.value, total),
          const SizedBox(height: 12),
          _buildLegendRow(
              'Draws', Colors.blueGrey, stats.multiplayerDraws.value, total),
        ],
      ),
    );
  }

  Widget _buildLegendRow(String label, Color color, int value, int total) {
    final percent = (value / total * 100).toStringAsFixed(0);
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.5), blurRadius: 4)
              ]),
        ),
        const SizedBox(width: 12),
        Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16)),
        const Spacer(),
        Text('$percent%',
            style: TextStyle(
                color: color, fontWeight: FontWeight.w900, fontSize: 16)),
      ],
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Text('Reset All Stats?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
            'This will permanently delete all your progress records.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: const Text('CANCEL',
                  style: TextStyle(color: Colors.white60))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white),
            onPressed: () {
              Get.find<ConnectFourStatsController>().resetAllStats();
              Get.back();
            },
            child: const Text('RESET',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
