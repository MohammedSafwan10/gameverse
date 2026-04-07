import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/home_controller.dart';
import '../theme/app_theme.dart';

class FeaturedCarousel extends StatefulWidget {
  final List<GameCategory> categories;
  final Function(int) onCategoryTap;

  const FeaturedCarousel({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(5.seconds, (timer) {
      if (_currentPage < widget.categories.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: 1.seconds,
          curve: Curves.easeInOutQuint,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemCount: widget.categories.length,
            itemBuilder: (context, index) {
              final category = widget.categories[index];
              final color =
                  AppTheme.categoryColors[category.title] ?? category.color;

              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = _pageController.page! - index;
                    value = (1 - (value.abs() * 0.1)).clamp(0.0, 1.0);
                  }
                  return Transform.scale(
                    scale: value,
                    child: _buildCarouselItem(category, color, index),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        _buildPageIndicator(),
      ],
    );
  }

  Widget _buildCarouselItem(GameCategory category, Color color, int index) {
    String? backgroundImage;
    switch (category.title) {
      case 'Arcade':
        backgroundImage = 'assets/images/categories/arcade.png';
        break;
      case 'Classic Board':
        backgroundImage = 'assets/images/categories/classic_board.png';
        break;
      case 'Word Games':
        backgroundImage = 'assets/images/categories/word_games.png';
        break;
      case 'Brain Training':
        backgroundImage = 'assets/images/categories/brain_training.png';
        break;
      case 'Puzzle':
        backgroundImage = 'assets/images/categories/puzzle.png';
        break;
      case 'Quick Casual':
        backgroundImage = 'assets/images/categories/quick_casual.png';
        break;
      case 'Strategy':
        backgroundImage = 'assets/images/categories/strategy.png';
        break;
      case 'Simulation':
        backgroundImage = 'assets/images/categories/simulation.png';
        break;
      case 'Sports':
        backgroundImage = 'assets/images/categories/sports.png';
        break;
      case 'Reaction':
        backgroundImage = 'assets/images/categories/reaction.png';
        break;
      case 'Educational':
        backgroundImage = 'assets/images/categories/educational.png';
        break;
    }

    return GestureDetector(
      onTap: () => widget.onCategoryTap(index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          boxShadow: const [],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Stack(
                children: [
                  if (backgroundImage != null) ...[
                    Positioned.fill(
                      child: Image.asset(
                        backgroundImage,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.15),
                              Colors.black.withValues(alpha: 0.55),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ] else
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withValues(alpha: 0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'FEATURED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    category.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Explore ${category.gamesCount} games',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 20,
              bottom: 20,
              child: FloatingActionButton.small(
                heroTag: 'featured_fab_$index',
                onPressed: () => widget.onCategoryTap(index),
                  backgroundColor: const Color(0xFFFFF4DE),
                  elevation: 0,
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Color(0xFF6A5C48),
                    size: 28,
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.categories.length,
        (index) => AnimatedContainer(
          duration: 300.ms,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 6,
          width: _currentPage == index ? 20 : 6,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? const Color(0xFFF4B860)
                : const Color(0xFFF4B860).withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}
