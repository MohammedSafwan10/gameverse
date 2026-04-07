import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../widgets/premium_background.dart';

class GameInfo {
  final String name;
  final String description;
  final IconData icon;
  final Widget Function() screen;
  final bool isAvailable;

  const GameInfo({
    required this.name,
    required this.description,
    required this.icon,
    required this.screen,
    this.isAvailable = true,
  });
}

class CategoryScreen extends StatelessWidget {
  final String title;
  final Color color;
  final List<GameInfo> games;

  const CategoryScreen({
    super.key,
    required this.title,
    required this.color,
    required this.games,
  });

  String _getBackgroundImage(String categoryTitle) {
    switch (categoryTitle) {
      case 'Arcade': return 'assets/images/categories/arcade.png';
      case 'Classic Board': return 'assets/images/categories/classic_board.png';
      case 'Word Games': return 'assets/images/categories/word_games.png';
      case 'Brain Training': return 'assets/images/categories/brain_training.png';
      case 'Puzzle': return 'assets/images/categories/puzzle.png';
      case 'Quick Casual': return 'assets/images/categories/quick_casual.png';
      case 'Strategy': return 'assets/images/categories/strategy.png';
      case 'Simulation': return 'assets/images/categories/simulation.png';
      case 'Sports': return 'assets/images/categories/sports.png';
      case 'Reaction': return 'assets/images/categories/reaction.png';
      case 'Educational': return 'assets/images/categories/educational.png';
      default: return '';
    }
  }

  String? _getGameImage(String gameName) {
    switch (gameName) {
      case 'Tic Tac Toe':
        return 'assets/images/games/tic_tac_toe.png';
      case 'Connect Four':
        return 'assets/images/games/connect_four.png';
      case 'Chess':
        return 'assets/images/games/chess.png';
      case 'Hangman':
        return 'assets/images/games/hangman.png';
      case 'Memory Match':
        return 'assets/images/games/memory_match.png';
      case 'Block Merge':
        return 'assets/images/games/block_merge.png';
      case 'Flappy Bird':
        return 'assets/images/games/flappy_bird.png';
      case 'Quiz Master':
        return 'assets/images/games/quiz_master.png';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = AppTheme.categoryColors[title] ?? color;
    final bgImage = _getBackgroundImage(title);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const PremiumBackground(),
          if (bgImage.isNotEmpty)
            Positioned.fill(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    bgImage,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.2),
                        ],
                        stops: const [0.0, 0.3, 1.0],
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 800.ms),
            ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context, themeColor),
              _buildGamesList(context, themeColor),
              const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Color themeColor) {
    return SliverAppBar.large(
      expandedHeight: 200,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Soft gradient highlight for the app bar area
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    themeColor.withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              right: -20,
              top: 20,
              child: Icon(
                Icons.grid_view_rounded,
                size: 150,
                color: themeColor.withValues(alpha: 0.05),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGamesList(BuildContext context, Color themeColor) {
    final availableGames = games.where((g) => g.isAvailable).toList();
    final upcomingGames = games.where((g) => !g.isAvailable).toList();

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          if (availableGames.isNotEmpty) ...[
            _buildSectionHeader('Available Games'),
            ...availableGames.asMap().entries.map((entry) =>
                _buildGameCard(context, entry.value, themeColor, entry.key)),
          ],
          if (upcomingGames.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildSectionHeader('Coming Soon'),
            ...upcomingGames.asMap().entries.map((entry) => _buildGameCard(
                context,
                entry.value,
                Colors.grey,
                entry.key + availableGames.length)),
          ],
          if (games.isEmpty) _buildEmptyState(),
        ]),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: Colors.white70,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Column(
          children: [
            Icon(Icons.games_outlined, size: 80, color: Colors.white30),
            const SizedBox(height: 16),
            const Text(
              'No games found',
              style:
                  TextStyle(color: Colors.white54, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(
      BuildContext context, GameInfo game, Color themeColor, int index) {
    final isAvailable = game.isAvailable;
    final gameImage = _getGameImage(game.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isAvailable ? () => Get.to(game.screen) : null,
            splashColor: themeColor.withValues(alpha: 0.2),
            highlightColor: themeColor.withValues(alpha: 0.1),
            child: Stack(
              children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Positioned.fill(
                          child: gameImage != null
                              ? Image.asset(gameImage, fit: BoxFit.cover)
                              : Container(color: themeColor.withValues(alpha: 0.25)),
                        ),
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.08),
                                  Colors.black.withValues(alpha: 0.58),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Spacer(),
                                  if (!isAvailable)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.28),
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                      child: const Text(
                                        'SOON',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Text(
                                game.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  height: 1.1,
                                ),
                              ),
                              const Spacer(),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.18),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isAvailable
                                          ? Icons.play_arrow_rounded
                                          : Icons.lock_outline_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.1);
  }
}
