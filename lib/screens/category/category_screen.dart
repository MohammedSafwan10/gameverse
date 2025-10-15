import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    return Scaffold(
      body: Container(
        color: Get.theme.colorScheme.surface,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildGamesList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.black.withValues(
                  red: 0,
                  green: 0,
                  blue: 0,
                  alpha: 0.1 * 255,
                ),
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
              color: Get.theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Get.textTheme.headlineMedium?.copyWith(
                    color: Get.theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${games.length} Games Available',
                  style: Get.textTheme.titleSmall?.copyWith(
                    color: Get.theme.colorScheme.onSurface.withValues(
                      red: Get.theme.colorScheme.onSurface.r.toDouble(),
                      green: Get.theme.colorScheme.onSurface.g.toDouble(),
                      blue: Get.theme.colorScheme.onSurface.b.toDouble(),
                      alpha: 0.7 * 255,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGamesList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.black.withValues(
                red: 0,
                green: 0,
                blue: 0,
                alpha: 0.08 * 255,
              ),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: game.isAvailable ? () => Get.to(game.screen) : null,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: color.withValues(
                          red: color.r.toDouble(),
                          green: color.g.toDouble(),
                          blue: color.b.toDouble(),
                          alpha: 0.15,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        game.icon,
                        size: 32,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            game.name,
                            style: Get.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Get.theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            game.description,
                            style: Get.textTheme.bodyMedium?.copyWith(
                              color: Get.theme.colorScheme.onSurface.withValues(
                                red: Get.theme.colorScheme.onSurface.r
                                    .toDouble(),
                                green: Get.theme.colorScheme.onSurface.g
                                    .toDouble(),
                                blue: Get.theme.colorScheme.onSurface.b
                                    .toDouble(),
                                alpha: 0.7 * 255,
                              ),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (!game.isAvailable) ...[
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Get.theme.colorScheme.primary.withValues(
                            red: Get.theme.colorScheme.primary.r.toDouble(),
                            green: Get.theme.colorScheme.primary.g.toDouble(),
                            blue: Get.theme.colorScheme.primary.b.toDouble(),
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Get.theme.colorScheme.primary.withValues(
                              red: Get.theme.colorScheme.primary.r.toDouble(),
                              green: Get.theme.colorScheme.primary.g.toDouble(),
                              blue: Get.theme.colorScheme.primary.b.toDouble(),
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: Text(
                          'Coming Soon',
                          style: Get.textTheme.labelSmall?.copyWith(
                            color: Get.theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
