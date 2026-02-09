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

  @override
  Widget build(BuildContext context) {
    final themeColor = AppTheme.categoryColors[title] ?? color;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const PremiumBackground(),
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
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, size: 18, color: themeColor),
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
            color: Colors.black87,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
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
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: Colors.black54,
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
            Icon(Icons.games_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'No games found',
              style:
                  TextStyle(color: Colors.black45, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(
      BuildContext context, GameInfo game, Color themeColor, int index) {
    final isAvailable = game.isAvailable;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(game.icon, size: 28, color: themeColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          game.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (isAvailable)
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: themeColor,
                      child: const Icon(Icons.play_arrow_rounded,
                          color: Colors.white),
                    )
                  else
                    const Icon(Icons.lock_outline_rounded,
                        color: Colors.black26),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate(delay: (index * 50).ms).fadeIn().slideX(begin: 0.1);
  }
}
