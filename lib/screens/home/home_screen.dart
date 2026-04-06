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

                  // Quick Play Sections
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                    sliver: SliverToBoxAdapter(
                      child: _buildSectionTitle(context, 'Quick Play'),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _buildQuickPlayList(context),
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
                        childAspectRatio: MediaQuery.of(context).size.width > 600 ? 0.85 : 0.9,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
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

                          return AnimatedGameCard(
                            title: category.title,
                            icon: category.icon,
                            color: color,
                            gamesCount: actualGamesCount,
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
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
            ).animate().fadeIn().slideX(begin: -0.2),
            Text(
              'Your Ultimate Arcade',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
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
              color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
        ),
        child: CircleAvatar(
          radius: 22,
          backgroundColor:
              Theme.of(context).primaryColor.withValues(alpha: 0.1),
          child: Icon(Icons.person_rounded,
              color: Theme.of(context).primaryColor, size: 28),
        ),
      ).animate().scale(delay: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search your favorite game...',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2);
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
                color: Colors.black87,
              ),
        ),
        TextButton(
          onPressed: () {},
          child: Text('See All', style: TextStyle(color: Colors.grey[500])),
        ),
      ],
    );
  }

  Widget _buildQuickPlayList(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: controller.quickPlayCategories.length,
        itemBuilder: (context, index) {
          final category = controller.quickPlayCategories[index];
          final color =
              AppTheme.categoryColors[category.title] ?? category.color;

          return GestureDetector(
            onTap: () => controller
                .onCategoryTap(controller.allCategories.indexOf(category)),
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              child: Column(
                children: [
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(category.icon, color: color, size: 30),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.title.split(' ')[0],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ).animate(delay: (400 + index * 100).ms).fadeIn().slideX(begin: 0.2);
        },
      ),
    );
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
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
