import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';
import 'package:flutter/services.dart';

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
            // Use SystemNavigator to exit the app
            // This approach is safer than using dart:io exit method
            SystemNavigator.pop();
          }
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A1E33),
                Color(0xFF252B4A),
                Color(0xFF1D2241),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      const SizedBox(height: 20),
                      _buildCategoryGrid(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Color(0xFF64FFDA),
                    Color(0xFF00E5FF),
                    Color(0xFF40C4FF),
                  ],
                ).createShader(bounds),
                child: Text(
                  'GameVerse',
                  style: Get.textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    fontSize: 32,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose your adventure',
                style: Get.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(
                    red: 255,
                    green: 255,
                    blue: 255,
                    alpha: 0.85 * 255,
                  ),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Get.toNamed('/settings'),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFF4D69FF),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        red: 0,
                        green: 0,
                        blue: 0,
                        alpha: 0.25 * 255,
                      ),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.settings,
                  size: 26,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 16),
            child: Text(
              'Game Categories',
              style: Get.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 22,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.9,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final category = controller.categories[index];
              // Calculate actual available games count
              final int actualGamesCount =
                  category.games.where((game) => game.isAvailable).length;
              // Determine if this category is actually coming soon
              final bool isComingSoon = actualGamesCount == 0;
              // Check if this category has any new games
              final bool hasNewGame = category.games.any((game) =>
                  game.isAvailable &&
                  (game.name.contains('NEW') ||
                      category.title == 'Brain Training'));

              return _buildEnhancedCategoryCard(
                category.title,
                _getCategoryIcon(category.title),
                actualGamesCount,
                hasNewGame,
                isComingSoon,
                isComingSoon ? null : () => controller.onCategoryTap(index),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String categoryTitle) {
    switch (categoryTitle) {
      case 'Arcade':
        return Icons.sports_esports;
      case 'Classic Board':
        return Icons.grid_on;
      case 'Word Games':
        return Icons.text_fields;
      case 'Brain Training':
        return Icons.psychology;
      case 'Puzzle':
        return Icons.extension;
      case 'Quick Casual':
        return Icons.bolt;
      case 'Reaction':
        return Icons.speed;
      case 'Strategy':
        return Icons.emoji_events;
      case 'Educational':
        return Icons.school;
      default:
        return Icons.games;
    }
  }

  Widget _buildEnhancedCategoryCard(
    String title,
    IconData icon,
    int gamesCount,
    bool hasNewGame,
    bool isComingSoon,
    VoidCallback? onTap,
  ) {
    // Enhanced color mapping
    Color primaryColor;
    Color iconBackgroundColor;
    Color textColor = Colors.white;

    // Apply appropriate colors based on category
    switch (title) {
      case 'Arcade':
        primaryColor = Color(0xFF7B1FA2);
        iconBackgroundColor = Color(0xFF9C27B0);
        break;
      case 'Classic Board':
        primaryColor = Color(0xFF1976D2);
        iconBackgroundColor = Color(0xFF2196F3);
        break;
      case 'Word Games':
        primaryColor = Color(0xFF00796B);
        iconBackgroundColor = Color(0xFF009688);
        break;
      case 'Brain Training':
        primaryColor = Color(0xFF9C27B0);
        iconBackgroundColor = Color(0xFFBA68C8);
        break;
      case 'Puzzle':
        primaryColor = Color(0xFF7B1FA2);
        iconBackgroundColor = Color(0xFF9C27B0);
        break;
      case 'Reaction':
        primaryColor = Color(0xFFEF6C00);
        iconBackgroundColor = Color(0xFFFF9800);
        break;
      case 'Quick Casual':
        primaryColor = Color(0xFF388E3C);
        iconBackgroundColor = Color(0xFF4CAF50);
        break;
      case 'Educational':
        primaryColor = Color(0xFF455A64);
        iconBackgroundColor = Color(0xFF607D8B);
        break;
      case 'Strategy':
        primaryColor = Color(0xFF0288D1);
        iconBackgroundColor = Color(0xFF29B6F6);
        break;
      default:
        primaryColor = Color(0xFF455A64);
        iconBackgroundColor = Color(0xFF607D8B);
    }

    if (isComingSoon) {
      return AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(
                red: primaryColor.r.toDouble(),
                green: primaryColor.g.toDouble(),
                blue: primaryColor.b.toDouble(),
                alpha: 0.4 * 255,
              ),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            splashColor: Colors.white.withValues(
              red: 255,
              green: 255,
              blue: 255,
              alpha: 0.1 * 255,
            ),
            highlightColor: Colors.white.withValues(
              red: 255,
              green: 255,
              blue: 255,
              alpha: 0.05 * 255,
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: iconBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                red: 0,
                                green: 0,
                                blue: 0,
                                alpha: 0.15 * 255,
                              ),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            red: 0,
                            green: 0,
                            blue: 0,
                            alpha: 0.2 * 255,
                          ),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'COMING SOON',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(
              red: primaryColor.r.toDouble(),
              green: primaryColor.g.toDouble(),
              blue: primaryColor.b.toDouble(),
              alpha: 0.4 * 255,
            ),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          splashColor: Colors.white.withValues(
            red: 255,
            green: 255,
            blue: 255,
            alpha: 0.1 * 255,
          ),
          highlightColor: Colors.white.withValues(
            red: 255,
            green: 255,
            blue: 255,
            alpha: 0.05 * 255,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          red: 0,
                          green: 0,
                          blue: 0,
                          alpha: 0.15 * 255,
                        ),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasNewGame && !isComingSoon)
                      Container(
                        margin: EdgeInsets.only(left: 4),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                red: 0,
                                green: 0,
                                blue: 0,
                                alpha: 0.1 * 255,
                              ),
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          'NEW',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  '$gamesCount Games',
                  style: TextStyle(
                    color: Colors.white.withValues(
                      red: 255,
                      green: 255,
                      blue: 255,
                      alpha: 0.85 * 255,
                    ),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(
                'Exit GameVerse',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1E33),
                ),
              ),
              content: Text(
                'Are you sure you want to exit the app?',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF252B4A),
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'CANCEL',
                    style: TextStyle(
                      color: Color(0xFF4D69FF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: Color(0xFF4D69FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'EXIT',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              actionsPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            );
          },
        ) ??
        false;
  }
}
