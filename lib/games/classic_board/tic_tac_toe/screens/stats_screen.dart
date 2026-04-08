import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gameverse/theme/app_theme.dart';
import '../controllers/stats_controller.dart';
import '../controllers/settings_controller.dart';
import '../models/game_stats.dart';
import '../models/game_difficulty.dart';
import '../models/game_mode.dart';
import '../models/achievement.dart';
import '../theme/game_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

class TicTacToeStatsScreen extends StatefulWidget {
  const TicTacToeStatsScreen({super.key});

  @override
  State<TicTacToeStatsScreen> createState() => _TicTacToeStatsScreenState();
}

class _TicTacToeStatsScreenState extends State<TicTacToeStatsScreen>
    with SingleTickerProviderStateMixin {
  final _statsController = Get.find<TicTacToeStatsController>();
  final _settingsController = Get.find<TicTacToeSettingsController>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _buildAnimatedBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                const SizedBox(height: 12),
                _buildModeSelector(),
                const SizedBox(height: 16),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSoloStats(),
                      _buildVersusStats(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Stack(
      children: [
        Container(color: const Color(0xFF0F172A)), // Base dark color
        Positioned(
          top: -100,
          right: -50,
          child: _blurredBlob(AppTheme.primaryColor.withValues(alpha: 0.12), 300),
        ),
        Positioned(
          bottom: -50,
          left: -100,
          child: _blurredBlob(AppTheme.accentColor.withValues(alpha: 0.1), 350),
        ),
        Positioned(
          top: 200,
          left: 100,
          child: _blurredBlob(Colors.purple.withValues(alpha: 0.06), 250),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(color: Colors.transparent),
        ),
      ],
    );
  }

  Widget _blurredBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
     .move(begin: const Offset(-20, -20), end: const Offset(20, 20), duration: const Duration(seconds: 10), curve: Curves.easeInOut)
     .scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: const Duration(seconds: 8), curve: Curves.easeInOut);
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _topIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.pop(context),
          ),
          Column(
            children: [
              Text(
                'STATISTICS',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ).animate().fadeIn().slideY(begin: -0.2),
              Text(
                'YOUR PERFORMANCE',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          _topIconButton(
            icon: Icons.more_vert_rounded,
            onTap: () => _showStatsActionsSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: TabBar(
        controller: _tabController,
        dividerColor: Colors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.4),
        labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.4),
              AppTheme.primaryColor.withValues(alpha: 0.1),
            ],
          ),
          border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
        ),
        tabs: const [
          Tab(text: 'SOLO MODE'),
          Tab(text: 'VERSUS'),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _topIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Future<void> _showStatsActionsSheet(BuildContext context) async {
    final theme = Theme.of(context);

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF111827),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Stats actions',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose what you want to reset.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.68),
                ),
              ),
              const SizedBox(height: 18),
              _statsActionTile(
                icon: Icons.refresh_rounded,
                title: 'Reset Current Mode Stats',
                subtitle: 'Clear stats only for the selected tab or active mode.',
                color: AppTheme.primaryColor,
                onTap: () {
                  Navigator.of(context).pop();
                  _showResetConfirmationDialog(context, false);
                },
              ),
              const SizedBox(height: 12),
              _statsActionTile(
                icon: Icons.delete_forever_rounded,
                title: 'Reset All Stats',
                subtitle: 'Clear all Tic Tac Toe progress and achievement history.',
                color: const Color(0xFFE57373),
                onTap: () {
                  Navigator.of(context).pop();
                  _showResetConfirmationDialog(context, true);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statsActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.66),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateLevel(int gamesPlayed) {
    if (gamesPlayed < 10) return 1;
    if (gamesPlayed < 50) return 2;
    if (gamesPlayed < 100) return 3;
    if (gamesPlayed < 250) return 4;
    return 5 + (gamesPlayed ~/ 250);
  }

  Widget _statTile(String label, String value, IconData icon, {Color? color, bool isHero = false}) {
    final effectiveColor = color ?? Colors.white;
    return Container(
      padding: EdgeInsets.symmetric(vertical: isHero ? 20 : 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isHero ? 0.08 : 0.04),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isHero 
            ? AppTheme.primaryColor.withValues(alpha: 0.2) 
            : Colors.white.withValues(alpha: 0.05)
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: effectiveColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: isHero ? 28 : 20, color: effectiveColor),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: isHero ? 28 : 20,
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoloStats() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOverallDashboard(),
          const SizedBox(height: 24),
          _buildAchievementsCarousel(),
          const SizedBox(height: 24),
          _buildDifficultySection(),
          const SizedBox(height: 40),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildVersusStats() {
    return Obx(() {
      final multiplayerStats = _statsController.stats.multiplayerStats;

      if (multiplayerStats.gamesPlayed == 0) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.group_rounded,
                  size: 64,
                  color: Colors.white.withValues(alpha: 0.45),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No Versus History',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Challenge a friend to start tracking!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.68),
                    ),
              ),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            _buildVersusComparison(multiplayerStats),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _statTile(
                    'TOTAL BATTLES',
                    multiplayerStats.gamesPlayed.toString(),
                    Icons.sports_esports_rounded,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _statTile(
                    'STALEMATES',
                    multiplayerStats.draws.toString(),
                    Icons.balance_rounded,
                    color: const Color(0xFFFFB74D),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),
            const SizedBox(height: 24),
            _buildPlayerComparisonCard(
              'PLAYER 1',
              'X',
              TicTacToeTheme.xColor,
              multiplayerStats.player1Wins,
              multiplayerStats.player1WinRate,
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
            const SizedBox(height: 16),
            _buildPlayerComparisonCard(
              'PLAYER 2',
              'S.PLAYER',
              TicTacToeTheme.oColor,
              multiplayerStats.player2Wins,
              multiplayerStats.player2WinRate,
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
            const SizedBox(height: 40),
          ],
        ),
      ).animate().fadeIn(delay: 300.ms);
    });
  }

  Widget _buildVersusComparison(MultiplayerStats stats) {
    final int totalWins = stats.player1Wins + stats.player2Wins;
    final double progress = totalWins > 0 ? stats.player1Wins / totalWins : 0.5;

    return Container(
      decoration: AppTheme.glassmorphicDecoration(
        backgroundColor: Colors.white.withValues(alpha: 0.08),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PLAYER 1',
                    style: TextStyle(
                      color: TicTacToeTheme.xColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}% Dominance',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'PLAYER 2',
                    style: TextStyle(
                      color: TicTacToeTheme.oColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    '${((1 - progress) * 100).toInt()}% Dominance',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            children: [
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: TicTacToeTheme.oColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.fastOutSlowIn,
                    height: 12,
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          TicTacToeTheme.xColor,
                          TicTacToeTheme.xColor.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: TicTacToeTheme.xColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Center(
                child: Container(
                  height: 12,
                  width: 2,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'STRENGTH BALANCE',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerComparisonCard(
    String label,
    String symbol,
    Color color,
    int wins,
    double winRate,
  ) {
    return Container(
      decoration: AppTheme.glassmorphicDecoration(
        backgroundColor: Colors.white.withValues(alpha: 0.05),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              symbol.length > 1 ? symbol.substring(0, 1) : symbol,
              style: TextStyle(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                fontFamily: 'Outfit',
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  '$wins VICTORIES',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: winRate,
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    color: color,
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'RATE',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.4),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(winRate * 100).toInt()}%',
                style: TextStyle(
                  color: color,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverallDashboard() {
    return Obx(() {
      final stats = _statsController.stats;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppTheme.glassmorphicDecoration(
                borderRadius: 32,
                backgroundColor: Colors.white.withValues(alpha: 0.03),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TOTAL PERFORMANCE',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              'WIN RATE STABILITY',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.4),
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'LVL ${_calculateLevel(stats.gamesPlayed)}',
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: CircularProgressIndicator(
                          value: stats.winRate,
                          strokeWidth: 12,
                          strokeCap: StrokeCap.round,
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(stats.winRate * 100).toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                            ),
                          ),
                          Text(
                            'WINS',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: _miniStatItem(
                          'GAMES',
                          stats.gamesPlayed.toString(),
                          Icons.grid_4x4_rounded,
                        ),
                      ),
                      Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.1)),
                      Expanded(
                        child: _miniStatItem(
                          'WINS',
                          _statsController.playerWins.toString(),
                          Icons.person_rounded,
                          color: Colors.greenAccent,
                        ),
                      ),
                      Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.1)),
                      Expanded(
                        child: _miniStatItem(
                          'LOSSES',
                          _statsController.aiWins.toString(),
                          Icons.smart_toy_rounded,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _miniStatItem(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color ?? Colors.white.withValues(alpha: 0.5)),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.3),
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultySection() {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 16),
              child: Text(
                'DIFFICULTY MASTERY',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            ...GameDifficulty.values.map((difficulty) {
              final dStats = _statsController.stats.difficultyStats[difficulty];
              final hasStats = dStats != null && dStats.gamesPlayed > 0;
              final color = _getDifficultyColor(difficulty);

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.glassmorphicDecoration(
                  backgroundColor: Colors.white.withValues(alpha: 0.03),
                  borderColor: Colors.white.withValues(alpha: 0.05),
                  borderRadius: 20,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.psychology, size: 18, color: color),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                difficulty.displayName.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                              if (hasStats)
                                Text(
                                  'BEST STREAK: ${dStats.bestStreak}',
                                  style: TextStyle(
                                    color: color.withValues(alpha: 0.6),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        if (hasStats)
                          Text(
                            '${(dStats.winRate * 100).toInt()}%',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                            ),
                          ),
                      ],
                    ),
                    if (hasStats) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: dStats.winRate,
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          color: color,
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${dStats.gamesWon} W / ${dStats.gamesPlayed} G',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.3),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ] else
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          'NO ENGAGEMENT DATA',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.1),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    });
  }

  Color _getDifficultyColor(GameDifficulty difficulty) {
    switch (difficulty) {
      case GameDifficulty.easy:
        return const Color(0xFF22C55E);
      case GameDifficulty.medium:
        return AppTheme.primaryColor;
      case GameDifficulty.hard:
        return const Color(0xFFEF4444);
      case GameDifficulty.impossible:
        return const Color(0xFFA855F7);
    }
  }

  Widget _buildAchievementsCarousel() {
    return Obx(() {
      final unlocked = _statsController.stats.unlockedAchievements;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ACHIEVEMENTS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  '${unlocked.length}/${Achievement.values.length}',
                  style: TextStyle(
                    color: AppTheme.primaryColor.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: Achievement.values.length,
              itemBuilder: (context, index) {
                final achievement = Achievement.values[index];
                final isUnlocked = unlocked.contains(achievement);
                return _achievementBadge(achievement, isUnlocked);
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _achievementBadge(Achievement achievement, bool isUnlocked) {
    return Container(
      width: 110,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.glassmorphicDecoration(
        backgroundColor: isUnlocked
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.03),
        borderColor: isUnlocked
            ? AppTheme.primaryColor.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: isUnlocked ? AppTheme.primaryGradient : null,
              color: isUnlocked ? null : Colors.white.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              boxShadow: isUnlocked ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ] : null,
            ),
            child: Icon(
              achievement.icon, 
              color: isUnlocked ? Colors.white : Colors.white.withValues(alpha: 0.1),
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            achievement.title.toUpperCase(),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isUnlocked ? Colors.white : Colors.white.withValues(alpha: 0.2),
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showResetConfirmationDialog(
      BuildContext context, bool resetAll) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111827),
        surfaceTintColor: Colors.transparent,
        title: Text(resetAll
            ? 'Reset All Statistics?'
            : 'Reset Current Mode Statistics?', style: const TextStyle(color: Colors.white)),
        content: Text(resetAll
            ? 'This will reset all your game statistics, including achievements. This action cannot be undone.'
            : 'This will reset statistics for the ${_settingsController.settings.gameMode == GameMode.singlePlayer ? 'single player' : 'multiplayer'} mode. This action cannot be undone.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.72))),
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
