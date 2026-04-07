import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/home_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animated_game_card.dart';
import '../../widgets/premium_background.dart';
import '../../widgets/featured_carousel.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldExit = await _showExitConfirmationDialog(context);
          if (shouldExit) {
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const PremiumBackground(),
            Positioned.fill(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/home_bg.png',
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
            SafeArea(
              bottom: false,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Header
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                    sliver: SliverToBoxAdapter(
                      child: _buildHeader(context),
                    ),
                  ),

                  // Search Bar
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverToBoxAdapter(
                      child: _buildSearchBar(context),
                    ),
                  ),

                  // Featured Section
                  SliverToBoxAdapter(
                    child: _buildFeaturedSection(context),
                  ),

                  // Discover All Section
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                    sliver: SliverToBoxAdapter(
                      child: _buildSectionTitle(context, 'Discover All'),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width > 900
                            ? 4
                            : (MediaQuery.of(context).size.width > 600 ? 3 : 2),
                        childAspectRatio: 0.82,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final category = controller.categories[index];
                          final int actualGamesCount = category.games
                              .where((game) => game.isAvailable)
                              .length;
                          final color =
                              AppTheme.categoryColors[category.title] ??
                                  category.color;

                          String? bgImage;
                          switch (category.title) {
                            case 'Arcade': bgImage = 'assets/images/categories/arcade.png'; break;
                            case 'Classic Board': bgImage = 'assets/images/categories/classic_board.png'; break;
                            case 'Word Games': bgImage = 'assets/images/categories/word_games.png'; break;
                            case 'Brain Training': bgImage = 'assets/images/categories/brain_training.png'; break;
                            case 'Puzzle': bgImage = 'assets/images/categories/puzzle.png'; break;
                            case 'Quick Casual': bgImage = 'assets/images/categories/quick_casual.png'; break;
                            case 'Strategy': bgImage = 'assets/images/categories/strategy.png'; break;
                            case 'Simulation': bgImage = 'assets/images/categories/simulation.png'; break;
                            case 'Sports': bgImage = 'assets/images/categories/sports.png'; break;
                            case 'Reaction': bgImage = 'assets/images/categories/reaction.png'; break;
                            case 'Educational': bgImage = 'assets/images/categories/educational.png'; break;
                          }

                          return AnimatedGameCard(
                            title: category.title,
                            color: color,
                            gamesCount: actualGamesCount,
                            backgroundImage: bgImage,
                            isNew: category.title == 'Brain Training',
                            isComingSoon: actualGamesCount == 0,
                            onTap: actualGamesCount == 0
                                ? null
                                : () => controller.onCategoryTap(index),
                            index: index,
                          );
                        },
                        childCount: controller.categories.length,
                      ),
                    ),
                  ),

                  const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GameVerse',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: const Color(0xFFFFF4DE),
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
            ).animate().fadeIn().slideX(begin: -0.2),
            Text(
              'Your Ultimate Arcade',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFFF6E7C8).withValues(alpha: 0.88),
                    fontWeight: FontWeight.w500,
                  ),
            ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.2),
          ],
        ),
        _buildProfileAvatar(context),
      ],
    );
  }

  Widget _buildProfileAvatar(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed('/profile'),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFFFE0A6).withValues(alpha: 0.4),
          ),
        ),
        child: CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFFFFF4DE).withValues(alpha: 0.88),
          child: const Icon(
            Icons.person_rounded,
            color: Color(0xFF6A5C48),
            size: 28,
          ),
        ),
      ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: TextField(
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Inter',
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: 'Search your favorite game...',
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 14,
            fontFamily: 'Inter',
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.white.withValues(alpha: 0.4),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, curve: Curves.easeOutCubic);
  }

  Widget _buildFeaturedSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: FeaturedCarousel(
        categories: controller.featuredCategories,
        onCategoryTap: (index) {
          final category = controller.featuredCategories[index];
          final realIndex = controller.allCategories.indexOf(category);
          controller.onCategoryTap(realIndex);
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        ),
        TextButton(
          onPressed: () {},
          child: Text('See All', style: TextStyle(color: Colors.grey[500])),
        ),
      ],
    );
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1a1f3a),
              surfaceTintColor: Colors.transparent,
              title: Text(
                'Exit GameVerse',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              content: Text(
                'Are you sure you want to exit the app?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('CANCEL'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('EXIT'),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}
