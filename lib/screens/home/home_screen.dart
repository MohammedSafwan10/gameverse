import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../controllers/home_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/animated_game_card.dart';

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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          bottom: false, // For bottom nav bar
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                sliver: SliverToBoxAdapter(
                  child: _buildHeader(context),
                ),
              ),

              // Categories Grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 900
                        ? 4
                        : (MediaQuery.of(context).size.width > 600 ? 3 : 2),
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = controller.categories[index];
                      final int actualGamesCount = category.games
                          .where((game) => game.isAvailable)
                          .length;
                      final bool isComingSoon = actualGamesCount == 0;
                      final bool hasNewGame = category.games.any((game) =>
                          game.isAvailable &&
                          (game.name.contains('NEW') ||
                              category.title == 'Brain Training'));

                      // Get color from AppTheme or fallback to category color
                      final color = AppTheme.categoryColors[category.title] ??
                          category.color;

                      return AnimatedGameCard(
                        title: category.title,
                        icon: category.icon,
                        color: color,
                        gamesCount: actualGamesCount,
                        isNew: hasNewGame,
                        isComingSoon: isComingSoon,
                        onTap: isComingSoon
                            ? null
                            : () => controller.onCategoryTap(index),
                        index: index,
                      );
                    },
                    childCount: controller.categories.length,
                  ),
                ),
              ),

              // Bottom Padding for Nav Bar
              const SliverPadding(
                padding: EdgeInsets.only(bottom: 100),
              ),
            ],
          ),
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
              ),
            ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
            const SizedBox(height: 4),
            Text(
              'Choose your adventure',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideX(begin: -0.2),
          ],
        ),

        // Settings Button
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => Get.toNamed('/settings'),
            icon: Icon(
              Icons.settings_outlined,
              color: Theme.of(context).iconTheme.color,
            ),
          ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
        ),
      ],
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
